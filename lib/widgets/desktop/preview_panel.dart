// widgets/desktop/preview_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/theme.dart';
import '../../controllers/file_controller.dart';
import '../../models/file_model.dart';

class PreviewPanel extends GetView<FileController> {
  const PreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.files.isEmpty) {
        return _buildNoSelection();
      }
      
      final file = controller.files.first;
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معاينة الملف',
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            Center(
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  _getFileIcon(file),
                  color: AppTheme.primary,
                  size: 48.sp,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                file.name,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4.h),
            Center(
              child: Text(
                file.size,
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ),
            const Divider(height: 40, color: Color(0xFF2A3450)),
            _buildInfoRow('نوع الملف', file.typeString),
            _buildInfoRow('تاريخ التعديل', file.modifiedDate),
            _buildInfoRow('الحجم', file.size),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.openFile(file),
                icon: const Icon(Iconsax.folder_open),
                label: Text(
                  'فتح الملف',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNoSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document, color: AppTheme.textTertiary, size: 48.sp),
          SizedBox(height: 12.h),
          Text(
            'لم يتم تحديد ملف',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 12.sp),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(CloudFile file) {
    final icons = {
      'pdf': Iconsax.document_text,
      'image': Iconsax.gallery,
      'video': Iconsax.video_play,
      'music': Iconsax.music,
      'document': Iconsax.document,
      'folder': Iconsax.folder,
    };
    return icons[file.typeString] ?? Iconsax.document;
  }
}
