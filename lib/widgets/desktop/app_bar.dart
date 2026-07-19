// widgets/desktop/app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/theme.dart';
import '../../controllers/file_controller.dart';

class DesktopAppBar extends GetView<FileController> {
  const DesktopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                style: GoogleFonts.poppins(color: AppTheme.textPrimary, fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'ابحث في ملفاتك السحابية...',
                  hintStyle: GoogleFonts.poppins(color: AppTheme.textTertiary, fontSize: 13.sp),
                  prefixIcon: Icon(Iconsax.search_normal, color: AppTheme.textSecondary, size: 18.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
                onChanged: (val) {
                  // handle search
                },
              ),
            ),
          ),
          SizedBox(width: 20.w),
          // Sync button
          IconButton(
            onPressed: () => controller.loadFiles(),
            icon: Icon(Iconsax.refresh, color: AppTheme.textSecondary, size: 20.sp),
          ),
          // Notification button
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.notification, color: AppTheme.textSecondary, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
