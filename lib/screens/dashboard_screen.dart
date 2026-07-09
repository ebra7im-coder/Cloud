// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme.dart';
import '../controllers/home_controller.dart';
import '../models/file_model.dart';
import '../widgets/glass_card.dart';
import 'upload_screen.dart';
import 'files_screen.dart';

class DashboardScreen extends GetView<HomeController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _buildStorageCard(),
          SizedBox(height: 20.h),
          _buildQuickStats(),
          SizedBox(height: 20.h),
          _buildRecentActivity(),
          SizedBox(height: 20.h),
          _buildQuickActions(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    return GlassCard(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.2),
              AppTheme.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(Iconsax.cloud, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مساحة التخزين',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Obx(() => Text(
                          '${controller.usedStorage.value} GB من 5 GB',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 12.sp,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.arrow_up, color: AppTheme.primary, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '12%',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Obx(() => FractionallySizedBox(
                widthFactor: controller.storagePercentage.value / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              )),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final s = controller.stats;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStorageStat(Iconsax.document, 'الملفات', '${s['docs'] ?? 0}'),
                  _buildStorageStat(Iconsax.gallery, 'الصور', '${s['images'] ?? 0}'),
                  _buildStorageStat(Iconsax.video, 'الفيديوهات', '${s['videos'] ?? 0}'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageStat(IconData icon, String label, String count) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 16.sp),
            SizedBox(width: 4.w),
            Text(
              count,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppTheme.textTertiary,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Obx(() {
      final s = controller.stats;
      return Row(
        children: [
          Expanded(
            child: GlassCard(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Iconsax.clock, color: AppTheme.primary, size: 20.sp),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '+12%',
                            style: GoogleFonts.poppins(
                              color: Colors.green,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${s['total'] ?? 0}',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'إجمالي الملفات',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GlassCard(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Iconsax.share, color: AppTheme.secondary, size: 20.sp),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '+8%',
                            style: GoogleFonts.poppins(
                              color: Colors.green,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${s['audios'] ?? 0}',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textPrimary,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'الملفات الصوتية',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRecentActivity() {
    return Obx(() {
      final recentFiles = controller.allFiles.take(3).toList();
      if (recentFiles.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'النشاط الأخير',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...List.generate(3, (index) => _buildMockActivityItem(index)),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النشاط الأخير',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => controller.currentIndex.value = 1,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                ),
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...recentFiles.map((file) => _buildActualFileItem(file)),
        ],
      );
    });
  }

  Widget _buildActualFileItem(CloudFile file) {
    IconData icon = Iconsax.document_text;
    if (file.type == FileType.image) icon = Iconsax.gallery;
    if (file.type == FileType.video) icon = Iconsax.video_play;
    if (file.type == FileType.audio) icon = Iconsax.music;

    final mb = file.sizeBytes / (1024 * 1024);
    final sizeStr = mb >= 1024
        ? '${(mb / 1024).toStringAsFixed(2)} GB'
        : '${mb.toStringAsFixed(1)} MB';

    return GlassCard(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20.sp),
        ),
        title: Text(
          file.name,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$sizeStr • ${_timeago(file.uploadedAt)}',
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
            fontSize: 11.sp,
          ),
        ),
        trailing: Icon(Iconsax.arrow_right_1, color: AppTheme.textSecondary, size: 16.sp),
      ),
    );
  }

  String _timeago(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  Widget _buildMockActivityItem(int index) {
    final activities = [
      {'name': 'تقرير المبيعات.pdf', 'time': 'منذ 5 دقائق', 'size': '2.4 MB', 'icon': Iconsax.document_text},
      {'name': 'صورة_المنتج.jpg', 'time': 'منذ ساعة', 'size': '4.8 MB', 'icon': Iconsax.gallery},
      {'name': 'فيديو_تعليمي.mp4', 'time': 'منذ 3 ساعات', 'size': '15.2 MB', 'icon': Iconsax.video_play},
    ];
    
    final activity = activities[index];
    
    return GlassCard(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(activity['icon'] as IconData, color: AppTheme.primary, size: 20.sp),
        ),
        title: Text(
          activity['name'] as String,
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${activity['size']} • ${activity['time']}',
          style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
            fontSize: 11.sp,
          ),
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: Icon(Iconsax.more, color: AppTheme.textSecondary, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _buildActionCard(Iconsax.document_upload, 'رفع ملف', AppTheme.primary, () {
              Get.to(() => const UploadScreen(), transition: Transition.downToUp);
            }),
            SizedBox(width: 12.w),
            _buildActionCard(Iconsax.folder_add, 'مجلد جديد', AppTheme.secondary, () {
              Get.snackbar(
                'مجلد جديد',
                'هذه الميزة ستتوفر قريباً!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.cardDark,
                colorText: AppTheme.textPrimary,
              );
            }),
            SizedBox(width: 12.w),
            _buildActionCard(Iconsax.scan, 'مسح ضوئي', AppTheme.tertiary, () {
              Get.snackbar(
                'مسح ضوئي',
                'هذه الميزة ستتوفر قريباً!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.cardDark,
                colorText: AppTheme.textPrimary,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
