// widgets/desktop/sidebar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/theme.dart';
import '../../controllers/file_controller.dart';

class DesktopSidebar extends GetView<FileController> {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.w,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          _buildQuickActions(),
          const Divider(color: Color(0xFF2A3450)),
          _buildNavigationItems(),
          const Spacer(),
          _buildStorageInfo(),
          const Divider(color: Color(0xFF2A3450)),
          _buildUserInfo(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          _buildQuickAction(Iconsax.document_upload, 'رفع ملف', () {
            controller.pickAndUploadFiles();
          }),
          _buildQuickAction(Iconsax.folder_add, 'مجلد جديد', () {
            controller.createNewFolder();
          }),
          _buildQuickAction(Iconsax.scan, 'مسح ضوئي', () {
            controller.scanFiles();
          }),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItems() {
    final items = [
      {'icon': Iconsax.home, 'label': 'الرئيسية'},
      {'icon': Iconsax.folder, 'label': 'جميع الملفات'},
      {'icon': Iconsax.gallery, 'label': 'الصور'},
      {'icon': Iconsax.video_play, 'label': 'الفيديوهات'},
      {'icon': Iconsax.music, 'label': 'الموسيقى'},
      {'icon': Iconsax.document, 'label': 'المستندات'},
      {'icon': Iconsax.trash, 'label': 'سلة المحذوفات'},
    ];
    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: 4.h),
        itemBuilder: (context, index) {
          final item = items[index];
          final isActive = index == 0;
          return _buildNavItem(
            item['icon'] as IconData,
            item['label'] as String,
            isActive,
          );
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {
        // تحديث الفهرس
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                fontSize: 13.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مساحة التخزين',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: 0.48,
                    minHeight: 6.h,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '48%',
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '2.4 GB من 5 GB',
            style: GoogleFonts.poppins(
              color: AppTheme.textTertiary,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Iconsax.user, color: Colors.white, size: 20),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أحمد محمد',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ahmed@example.com',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textTertiary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/settings'),
            icon: Icon(Iconsax.setting, color: AppTheme.textSecondary, size: 20.sp),
          ),
        ],
      ),
    );
  }
}
