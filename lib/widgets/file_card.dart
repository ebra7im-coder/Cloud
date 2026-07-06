import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/file_model.dart';
import '../services/file_storage_service.dart';
import '../services/telegram_service.dart';
import '../utils/constants.dart';
import '../screens/media_viewer_screen.dart';

class FileCard extends StatefulWidget {
  final CloudFile file;
  final VoidCallback? onRefresh;
  const FileCard({super.key, required this.file, this.onRefresh});

  @override
  State<FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  bool _downloading = false;
  double _downloadProgress = 0;

  Color get _typeColor {
    switch (widget.file.type) {
      case FileType.image:    return AppConstants.greenColor;
      case FileType.video:    return AppConstants.redColor;
      case FileType.audio:    return AppConstants.purpleColor;
      case FileType.document: return AppConstants.orangeColor;
      default:                return Colors.grey;
    }
  }

  IconData get _typeIcon {
    switch (widget.file.type) {
      case FileType.image:    return Icons.image_rounded;
      case FileType.video:    return Icons.videocam_rounded;
      case FileType.audio:    return Icons.music_note_rounded;
      case FileType.document: return Icons.description_rounded;
      default:                return Icons.insert_drive_file_rounded;
    }
  }

  Future<void> _openFile() async {
    if (widget.file.type == FileType.image ||
        widget.file.type == FileType.video ||
        widget.file.type == FileType.audio) {
      Get.to(() => MediaViewerScreen(file: widget.file),
          transition: Transition.fadeIn);
    } else {
      _downloadFile();
    }
  }

  Future<void> _downloadFile() async {
    if (_downloading) return;
    setState(() { _downloading = true; _downloadProgress = 0; });

    final path = await TelegramService.instance.downloadFile(
      widget.file,
      onProgress: (p, s, t) => setState(() => _downloadProgress = p),
    );

    if (path != null) {
      await FileStorageService.instance.updateLocalPath(widget.file.id, path);
      Get.snackbar('✅ تم التنزيل', 'تم حفظ: ${widget.file.name}',
          backgroundColor: AppConstants.greenColor, colorText: Colors.white);
    } else {
      Get.snackbar('❌ خطأ', 'تعذر تنزيل الملف',
          backgroundColor: AppConstants.redColor, colorText: Colors.white);
    }

    setState(() => _downloading = false);
  }

  Future<void> _deleteFile() async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      backgroundColor: AppConstants.cardDark,
      title: const Text('حذف الملف', style: TextStyle(color: Colors.white)),
      content: Text('هل تريد حذف "${widget.file.name}"؟',
          style: const TextStyle(color: Colors.grey)),
      actions: [
        TextButton(onPressed: () => Get.back(result: false),
            child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: AppConstants.redColor),
          child: const Text('حذف', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));

    if (confirm == true) {
      if (widget.file.telegramMessageId != null) {
        await TelegramService.instance.deleteFile(widget.file.telegramMessageId!);
      }
      await FileStorageService.instance.deleteFile(widget.file.id);
      widget.onRefresh?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    return GestureDetector(
      onTap: _openFile,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _typeColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 26),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _typeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(file.typeLabel,
                                style: TextStyle(
                                    color: _typeColor, fontSize: 10)),
                          ),
                          const SizedBox(width: 8),
                          Text(file.sizeFormatted,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yy').format(file.uploadedAt),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        file.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: file.isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      onPressed: () async {
                        await FileStorageService.instance.toggleFavorite(file.id);
                        widget.onRefresh?.call();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_rounded,
                          color: AppConstants.primaryColor, size: 20),
                      onPressed: _downloadFile,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded,
                          color: AppConstants.redColor, size: 20),
                      onPressed: _deleteFile,
                    ),
                  ],
                ),
              ],
            ),
            if (_downloading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[800],
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
