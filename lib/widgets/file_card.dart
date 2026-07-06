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
  double _progress = 0;

  Color get _color {
    switch (widget.file.type) {
      case FileType.image:    return AppConstants.greenColor;
      case FileType.video:    return AppConstants.redColor;
      case FileType.audio:    return AppConstants.purpleColor;
      case FileType.document: return AppConstants.orangeColor;
      default:                return Colors.blueGrey;
    }
  }

  IconData get _icon {
    switch (widget.file.type) {
      case FileType.image:    return Icons.image_rounded;
      case FileType.video:    return Icons.videocam_rounded;
      case FileType.audio:    return Icons.music_note_rounded;
      case FileType.document: return Icons.description_rounded;
      default:                return Icons.insert_drive_file_rounded;
    }
  }

  void _open() {
    if ([FileType.image, FileType.video, FileType.audio]
        .contains(widget.file.type)) {
      Get.to(() => MediaViewerScreen(file: widget.file),
          transition: Transition.fadeIn);
    } else {
      _download();
    }
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() { _downloading = true; _progress = 0; });
    final path = await TelegramService.instance.downloadFile(
      widget.file,
      onProgress: (p, _, __) => setState(() => _progress = p),
    );
    setState(() => _downloading = false);
    if (path != null) {
      await FileStorageService.instance.updateLocalPath(widget.file.id, path);
      Get.snackbar('✅ تم', 'حُفظ: ${widget.file.name}',
          backgroundColor: AppConstants.greenColor, colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else {
      Get.snackbar('❌ خطأ', 'فشل التنزيل',
          backgroundColor: AppConstants.redColor, colorText: Colors.white);
    }
  }

  Future<void> _delete() async {
    final ok = await Get.dialog<bool>(AlertDialog(
      backgroundColor: AppConstants.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('حذف الملف', style: TextStyle(color: Colors.white)),
      content: Text('هل تريد حذف "${widget.file.name}"؟',
          style: TextStyle(color: Colors.grey[400])),
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
    if (ok == true) {
      if (widget.file.telegramMessageId != null) {
        await TelegramService.instance
            .deleteFile(widget.file.telegramMessageId!);
      }
      await FileStorageService.instance.deleteFile(widget.file.id);
      widget.onRefresh?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.file;
    return GestureDetector(
      onTap: _open,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppConstants.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _color.withOpacity(.15)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              // Icon
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                    color: _color.withOpacity(.13),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(_icon, color: _color, size: 24),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        _badge(f.typeLabel, _color),
                        const SizedBox(width: 6),
                        Text(f.sizeFormatted,
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11)),
                        const SizedBox(width: 6),
                        Text(
                            DateFormat('dd/MM/yy').format(f.uploadedAt),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 11)),
                      ]),
                    ]),
              ),
              // Actions
              Row(mainAxisSize: MainAxisSize.min, children: [
                _iconBtn(
                  f.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  f.isFavorite ? Colors.red : Colors.grey[600]!,
                  () async {
                    await FileStorageService.instance.toggleFavorite(f.id);
                    widget.onRefresh?.call();
                  },
                ),
                _iconBtn(Icons.download_rounded, AppConstants.primaryColor,
                    _download),
                _iconBtn(Icons.delete_outline_rounded,
                    AppConstants.redColor.withOpacity(.8), _delete),
              ]),
            ]),
          ),
          if (_downloading)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 3,
                  backgroundColor: Colors.grey[800],
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(.15),
            borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: 20),
        ),
      );
}
