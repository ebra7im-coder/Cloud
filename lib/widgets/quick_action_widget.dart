import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../screens/upload_screen.dart';

class QuickActionWidget extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback? onTap;

  const QuickActionWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? _handleTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _handleTap() {
    switch (label) {
      case 'رفع':
        Get.to(() => const UploadScreen(), transition: Transition.downToUp);
        break;
      case 'مجلد جديد':
        _showCreateFolder();
        break;
      case 'مشاركة':
        Get.snackbar('مشاركة', 'تم فتح واجهة المشاركة',
            backgroundColor: AppConstants.primaryColor,
            colorText: Colors.white);
        break;
      case 'تحميل':
        Get.snackbar('تحميل', 'اختر ملفاً من قائمة الملفات أولاً',
            backgroundColor: AppConstants.cardDark,
            colorText: Colors.white);
        break;
    }
  }

  void _showCreateFolder() {
    final ctrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppConstants.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('📁 مجلد جديد',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'أدخل اسم المجلد',
            hintStyle: TextStyle(color: Colors.grey[500]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: AppConstants.primaryColor),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: Get.back,
              child: const Text('إلغاء',
                  style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (ctrl.text.isNotEmpty) {
                Get.snackbar('✅ تم', 'تم إنشاء المجلد "${ctrl.text}"',
                    backgroundColor: AppConstants.greenColor,
                    colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إنشاء',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
