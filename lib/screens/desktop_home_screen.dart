// screens/desktop_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../utils/theme.dart';
import '../controllers/home_controller.dart';
import '../controllers/file_controller.dart';
import '../widgets/desktop/app_bar.dart';
import '../widgets/desktop/sidebar.dart';
import '../widgets/desktop/file_grid.dart';
import '../widgets/desktop/status_bar.dart';
import '../widgets/desktop/preview_panel.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> with WindowListener {
  @override
  void initState() {
    super.initState();
    if (Platform.isWindows || Platform.isLinux) {
      windowManager.addListener(this);
      Get.put(FileController());
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Column(
        children: [
          // شريط العنوان المخصص
          if (Platform.isWindows || Platform.isLinux)
            const DesktopTitleBar(),
          // التطبيق الرئيسي
          Expanded(
            child: Row(
              children: [
                // الشريط الجانبي
                const DesktopSidebar(),
                // المحتوى الرئيسي
                Expanded(
                  child: Column(
                    children: [
                      const DesktopAppBar(),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: const FileGridView(),
                            ),
                            // لوحة المعاينة
                            Container(
                              width: 320.w,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                              ),
                              child: const PreviewPanel(),
                            ),
                          ],
                        ),
                      ),
                      const DesktopStatusBar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onWindowClose() async {
    // حفظ البيانات قبل الإغلاق
    try {
      await Get.find<FileController>().saveState();
    } catch (_) {}
    
    // إظهار إشعار قبل الإغلاق
    if (Platform.isWindows || Platform.isLinux) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: Text(
            'إغلاق التطبيق',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل تريد إغلاق التطبيق؟',
            style: GoogleFonts.poppins(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('لا', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('نعم', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      );
      
      if (result == true) {
        await windowManager.destroy();
      }
    }
  }
}

// شريط العنوان المخصص
class DesktopTitleBar extends StatelessWidget {
  const DesktopTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      color: AppTheme.surfaceDark,
      child: Row(
        children: [
          if (Platform.isWindows) ...[
            const SizedBox(width: 8),
            _buildWindowButton(
              onPressed: () => windowManager.minimize(),
              icon: Icons.remove,
              color: Colors.amber,
            ),
            const SizedBox(width: 4),
            _buildWindowButton(
              onPressed: () => windowManager.maximizeOrUnmaximize(),
              icon: Icons.crop_square,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            _buildWindowButton(
              onPressed: () => windowManager.close(),
              icon: Icons.close,
              color: Colors.red,
            ),
          ],
          
          const Spacer(),
          
          // عنوان التطبيق
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: const Icon(
                  Iconsax.cloud,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'CloudVault',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          if (Platform.isLinux) ...[
            _buildWindowButton(
              onPressed: () => windowManager.minimize(),
              icon: Icons.remove,
              color: Colors.amber,
            ),
            const SizedBox(width: 4),
            _buildWindowButton(
              onPressed: () => windowManager.maximizeOrUnmaximize(),
              icon: Icons.crop_square,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            _buildWindowButton(
              onPressed: () => windowManager.close(),
              icon: Icons.close,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildWindowButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 28.w,
      height: 28.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4.r),
          hoverColor: color.withOpacity(0.2),
          child: Center(
            child: Icon(icon, color: Colors.white70, size: 16.sp),
          ),
        ),
      ),
    );
  }
}
