import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/file_model.dart';
import '../services/file_storage_service.dart';
import '../services/telegram_service.dart';
import '../screens/media_viewer_screen.dart';
import '../utils/constants.dart';

class RecentFileItem extends StatelessWidget {
  final CloudFile file;
  final VoidCallback? onRefresh;

  const RecentFileItem({super.key, required this.file, this.onRefresh});

  Color get _color {
    switch (file.type) {
      case FileType.image:    return AppConstants.greenColor;
      case FileType.video:    return AppConstants.redColor;
      case FileType.audio:    return AppConstants.purpleColor;
      case FileType.document: return AppConstants.orangeColor;
      default:                return Colors.blueGrey;
    }
  }

  IconData get _icon {
    switch (file.type) {
      case FileType.image:    return Icons.image_rounded;
      case FileType.video:    return Icons.videocam_rounded;
      case FileType.audio:    return Icons.music_note_rounded;
      case FileType.document: return Icons.description_rounded;
      default:                return Icons.insert_drive_file_rounded;
    }
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(file.uploadedAt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24)   return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_icon, color: _color, size: 22),
      ),
      title: Text(
        file.name,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$_timeAgo • ${file.sizeFormatted}',
        style: TextStyle(color: Colors.grey[500], fontSize: 11),
      ),
      trailing: IconButton(
        onPressed: _showOptions,
        icon: Icon(Icons.more_vert_rounded, color: Colors.grey[500], size: 20),
      ),
      onTap: () {
        if ([FileType.image, FileType.video, FileType.audio]
            .contains(file.type)) {
          Get.to(() => MediaViewerScreen(file: file),
              transition: Transition.fadeIn);
        }
      },
    );
  }

  void _showOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppConstants.cardDark,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            _sheetItem(Icons.download_rounded, 'تحميل'),
            _sheetItem(Icons.share_rounded, 'مشاركة'),
            _sheetItem(Icons.delete_rounded, 'حذف', danger: true),
          ],
        ),
      ),
    );
  }

  Widget _sheetItem(IconData icon, String label,
      {bool danger = false}) {
    return ListTile(
      leading: Icon(icon, color: danger ? Colors.red : Colors.white),
      title: Text(label,
          style:
              TextStyle(color: danger ? Colors.red : Colors.white)),
      onTap: () {
        Get.back();
        if (danger) {
          _confirmDelete();
        } else {
          Get.snackbar('✅', 'تم $label الملف',
              backgroundColor: AppConstants.primaryColor,
              colorText: Colors.white);
        }
      },
    );
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppConstants.cardDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: const Text('🗑️ تأكيد الحذف',
            style: TextStyle(color: Colors.white)),
        content: Text('هل تريد حذف "${file.name}"؟',
            style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(
              onPressed: Get.back,
              child:
                  const Text('إلغاء', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              if (file.telegramMessageId != null) {
                await TelegramService.instance
                    .deleteFile(file.telegramMessageId!);
              }
              await FileStorageService.instance.deleteFile(file.id);
              onRefresh?.call();
              Get.snackbar('✅ حُذف', file.name,
                  backgroundColor: AppConstants.redColor,
                  colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
