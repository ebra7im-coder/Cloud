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
      body: Obx(() => _buildBody()),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    switch (controller.currentIndex.value) {
      case 0:  return const DashboardScreen();
      case 1:  return const FilesScreen();
      case 3:  return const SearchScreen();
      case 4:  return const SettingsScreen();
      default: return const DashboardScreen();
    }
  }

  Widget _buildBottomNav() {
    return Obx(() => BottomAppBar(
      color: AppConstants.cardDark,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, 'الرئيسية'),
            _navItem(1, Icons.folder_rounded, 'الملفات'),
            const SizedBox(width: 60),
            _navItem(3, Icons.search_rounded, 'بحث'),
            _navItem(4, Icons.settings_rounded, 'إعدادات'),
          ],
        ),
      ),
    ));
  }

  Widget _navItem(int index, IconData icon, String label) {
    return Obx(() {
      final isActive = controller.currentIndex.value == index;
      return GestureDetector(
        onTap: () => controller.currentIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppConstants.primaryColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: isActive ? AppConstants.primaryColor : Colors.grey,
                  size: 24),
              Text(label,
                  style: TextStyle(
                      color: isActive
                          ? AppConstants.primaryColor
                          : Colors.grey,
                      fontSize: 10)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => Get.to(
        () => const UploadScreen(),
        transition: Transition.downToUp,
      ),
      backgroundColor: AppConstants.primaryColor,
      child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
    );
  }
}
