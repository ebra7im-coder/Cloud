// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme.dart';
import '../controllers/home_controller.dart';
import '../widgets/glass_card.dart';
import '../widgets/neumorphic_container.dart';
import 'dashboard_screen.dart';
import 'files_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    return const HomeView();
  }
}

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Obx(() => IndexedStack(
                  index: controller.currentIndex.value,
                  children: const [
                    DashboardScreen(),
                    FilesScreen(),
                    SearchScreen(),
                    ProfileScreen(),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: Obx(() => _buildFAB() ?? const SizedBox.shrink()),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          _buildAvatar(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  'مرحباً، ${controller.userName.value}',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                )),
                Obx(() => Row(
                  children: [
                    Icon(Iconsax.cloud, size: 14.sp, color: AppTheme.primary),
                    SizedBox(width: 4.w),
                    Text(
                      '${controller.totalFiles.value} ملفات',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: const BoxDecoration(
                        color: AppTheme.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(Iconsax.clock, size: 14.sp, color: AppTheme.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      'آخر تحديث: اليوم',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        gradient: AppTheme.secondaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Iconsax.user, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildIconButton(Iconsax.notification, () {
          Get.snackbar(
            'الإشعارات',
            'ليس لديك إشعارات جديدة',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.cardDark,
            colorText: AppTheme.textPrimary,
          );
        }),
        SizedBox(width: 8.w),
        _buildIconButton(Iconsax.menu, () {
          Get.snackbar(
            'القائمة',
            'تم فتح القائمة الجانبية',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.cardDark,
            colorText: AppTheme.textPrimary,
          );
        }),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        width: 42.w,
        height: 42.w,
        child: Icon(icon, color: AppTheme.textSecondary, size: 20.sp),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.backgroundDark.withOpacity(0.3),
          ],
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72.h,
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(4, (index) => _buildNavItem(index)),
          )),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final items = [
      {'icon': Iconsax.home, 'label': 'الرئيسية'},
      {'icon': Iconsax.folder, 'label': 'ملفاتي'},
      {'icon': Iconsax.search_normal, 'label': 'بحث'},
      {'icon': Iconsax.user, 'label': 'الملف الشخصي'},
    ];
    
    final isActive = controller.currentIndex.value == index;
    final item = items[index];
    
    return GestureDetector(
      onTap: () => controller.currentIndex.value = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isActive ? [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item['icon'] as IconData,
              color: isActive ? Colors.white : AppTheme.textSecondary,
              size: isActive ? 22.sp : 20.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              item['label'] as String,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : AppTheme.textSecondary,
                fontSize: isActive ? 10.sp : 8.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFAB() {
    // إخفاء الـ FAB في شاشة البحث (Index 2) وشاشة الملف الشخصي (Index 3)
    final hiddenScreens = [2, 3];
    if (hiddenScreens.contains(controller.currentIndex.value)) {
      return null;
    }
    
    return Hero(
      tag: 'upload_fab',
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => const UploadScreen(), transition: Transition.downToUp);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Iconsax.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
