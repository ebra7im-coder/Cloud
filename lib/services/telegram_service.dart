import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:mime/mime.dart';

import '../models/file_model.dart';
import '../utils/constants.dart';

typedef ProgressCallback = void Function(double progress, int sent, int total);

class TelegramService {
  TelegramService._();
  static final TelegramService instance = TelegramService._();

  late final Dio _dio;
  final _uuid = const Uuid();

  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 10),
      sendTimeout: const Duration(minutes: 10),
    ));
  }

  // ── Upload any file ─────────────────────────────────────────────
  Future<CloudFile?> uploadFile(
    File file, {
    ProgressCallback? onProgress,
    String? folder,
    String? caption,
  }) async {
    try {
      final filename = file.path.split(Platform.pathSeparator).last;
      final fileType = CloudFile.detectType(filename);
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final fileSize = await file.length();
      final fileId   = _uuid.v4();

      // Caption to send as Telegram caption (used as metadata)
      final meta = jsonEncode({
        'id':     fileId,
        'name':   filename,
        'folder': folder ?? 'root',
        'type':   fileType.index,
        'size':   fileSize,
      });
      final tgCaption = '📁 CloudGram\n$meta';

      String endpoint;
      String fieldName;

      switch (fileType) {
        case FileType.image:
          endpoint  = 'sendPhoto';
          fieldName = 'photo';
          break;
        case FileType.video:
          endpoint  = 'sendVideo';
          fieldName = 'video';
          break;
        case FileType.audio:
          endpoint  = 'sendAudio';
          fieldName = 'audio';
          break;
        default:
          endpoint  = 'sendDocument';
          fieldName = 'document';
      }

      final formData = FormData.fromMap({
        'chat_id': AppConstants.chatId,
        'caption': tgCaption,
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: filename,
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response = await _dio.post(
        '${AppConstants.telegramApiBase}/$endpoint',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total, sent, total);
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final result = data['result'];

        String? tgFileId;
        String? messageId = result['message_id']?.toString();
        String? thumbId;

        if (fileType == FileType.image && result['photo'] != null) {
          final photos = result['photo'] as List;
          tgFileId = photos.last['file_id'];
        } else if (result[fieldName] != null) {
          tgFileId = result[fieldName]['file_id'];
          thumbId  = result[fieldName]['thumb']?['file_id'];
        }

        return CloudFile(
          id: fileId,
          name: filename,
          telegramFileId: tgFileId,
          telegramMessageId: messageId,
          sizeBytes: fileSize,
          type: fileType,
          uploadedAt: DateTime.now(),
          mimeType: mimeType,
          thumbnailFileId: thumbId,
          folder: folder ?? 'root',
          caption: caption,
        );
      }
    } catch (e) {
      // log error
      rethrow;
    }
    return null;
  }

  // ── Get download URL ─────────────────────────────────────────────
  Future<String?> getDownloadUrl(String fileId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.telegramApiBase}/getFile?file_id=$fileId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final filePath = data['result']['file_path'];
        return '${AppConstants.telegramFileBase}/$filePath';
      }
    } catch (_) {}
    return null;
  }

  // ── Download file ────────────────────────────────────────────────
  Future<String?> downloadFile(
    CloudFile cloudFile, {
    ProgressCallback? onProgress,
  }) async {
    try {
      if (cloudFile.telegramFileId == null) return null;

      final url = await getDownloadUrl(cloudFile.telegramFileId!);
      if (url == null) return null;

      final dir  = await getApplicationDocumentsDirectory();
      final dest = '${dir.path}/${cloudFile.name}';

      await _dio.download(
        url,
        dest,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total, received, total);
        },
      );

      return dest;
    } catch (_) {
      return null;
    }
  }

  // ── Delete message (soft delete) ─────────────────────────────────
  Future<bool> deleteFile(String messageId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.telegramApiBase}/deleteMessage'),
        body: {'chat_id': AppConstants.chatId, 'message_id': messageId},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Sync all files from Telegram ─────────────────────────────────
  Future<List<CloudFile>> syncFromTelegram() async {
    final files = <CloudFile>[];
    try {
      int offset = 0;
      while (true) {
        final response = await http.get(
          Uri.parse('${AppConstants.telegramApiBase}/getUpdates?offset=$offset&limit=100'),
        );
        if (response.statusCode != 200) break;

        final data    = jsonDecode(response.body);
        final updates = data['result'] as List;
        if (updates.isEmpty) break;

        for (final update in updates) {
          final message = update['message'];
          if (message == null) continue;

          final caption = message['caption'] as String? ?? '';
          if (!caption.contains('CloudGram')) continue;

          try {
            final metaStart = caption.indexOf('{');
            final metaEnd   = caption.lastIndexOf('}') + 1;
            if (metaStart < 0 || metaEnd <= metaStart) continue;

            final meta    = jsonDecode(caption.substring(metaStart, metaEnd));
            final msgId   = update['update_id'].toString();
            offset        = update['update_id'] + 1;

            String? tgFileId;
            final int typeIdx = meta['type'] ?? 4;
            final fType = FileType.values[typeIdx];

            if (message['photo'] != null) {
              tgFileId = (message['photo'] as List).last['file_id'];
            } else if (message['video'] != null) {
              tgFileId = message['video']['file_id'];
            } else if (message['audio'] != null) {
              tgFileId = message['audio']['file_id'];
            } else if (message['document'] != null) {
              tgFileId = message['document']['file_id'];
            }

            files.add(CloudFile(
              id: meta['id'] ?? _uuid.v4(),
              name: meta['name'] ?? 'unknown',
              telegramFileId: tgFileId,
              telegramMessageId: msgId,
              sizeBytes: meta['size'] ?? 0,
              type: fType,
              uploadedAt: DateTime.fromMillisecondsSinceEpoch(
                (message['date'] ?? 0) * 1000,
              ),
              folder: meta['folder'] ?? 'root',
            ));
          } catch (_) {
            continue;
          }
        }

        if (updates.length < 100) break;
      }
    } catch (_) {}
    return files;
  }

  // ── Get bot info ─────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getBotInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.telegramApiBase}/getMe'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['result'];
      }
    } catch (_) {}
    return null;
  }
}
