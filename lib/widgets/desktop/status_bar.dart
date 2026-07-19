// widgets/desktop/status_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/theme.dart';
import '../../controllers/file_controller.dart';

class DesktopStatusBar extends GetView<FileController> {
  const DesktopStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Obx(() => Text(
            '${controller.files.length} عنصر',
            style: GoogleFonts.poppins(
              color: AppTheme.textTertiary,
              fontSize: 12.sp,
            ),
          )),
          const Spacer(),
          Obx(() => Row(
            children: [
              if (controller.isLoading.value) ...[
                SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8.w),
                Text(
                  'جاري التحميل...',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textTertiary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
              if (controller.uploadProgress.value > 0) ...[
                Icon(Iconsax.cloud, color: AppTheme.primary, size: 14.sp),
                SizedBox(width: 4.w),
                Text(
                  '${controller.uploadProgress.value.toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    color: AppTheme.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          )),
          SizedBox(width: 16.w),
          Text(
            'متصفح الملفات',
            style: GoogleFonts.poppins(
              color: AppTheme.textTertiary,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
