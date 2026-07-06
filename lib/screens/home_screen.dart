import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../controllers/home_controller.dart';
import 'files_screen.dart';
import 'upload_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return const _HomeView();
  }
}

class _HomeView extends GetView<HomeController> {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: Obx(() => _body()),
      bottomNavigationBar: _bottomNav(),
      floatingActionButton: _fab(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _body() {
    switch (controller.currentIndex.value) {
      case 0:  return const DashboardScreen();
      case 1:  return const FilesScreen();
      case 2:  return const SearchScreen();
      case 3:  return const SettingsScreen();
      default: return const DashboardScreen();
    }
  }

  Widget _bottomNav() {
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, 'الرئيسية'),
                _navItem(1, Icons.folder_rounded, 'الملفات'),
                const SizedBox(width: 60), // FAB space
                _navItem(2, Icons.search_rounded, 'بحث'),
                _navItem(3, Icons.settings_rounded, 'إعدادات'),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = controller.currentIndex.value == index;
    return GestureDetector(
      onTap: () => controller.currentIndex.value = index,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? AppConstants.primaryColor.withOpacity(0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: active
                      ? AppConstants.primaryColor
                      : Colors.grey[600],
                  size: 22),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  color: active
                      ? AppConstants.primaryColor
                      : Colors.grey[600],
                  fontSize: 10,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }

  Widget _fab() {
    return FloatingActionButton(
      onPressed: () =>
          Get.to(() => const UploadScreen(), transition: Transition.downToUp),
      backgroundColor: AppConstants.primaryColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
    );
  }
}
