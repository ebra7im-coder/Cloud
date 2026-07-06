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

  static const _items = [
    {'icon': Icons.home_rounded, 'label': 'الرئيسية'},
    {'icon': Icons.folder_rounded, 'label': 'الملفات'},
    {'icon': Icons.search_rounded, 'label': 'بحث'},
    {'icon': Icons.settings_rounded, 'label': 'إعدادات'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: Obx(() => _body()),
      bottomNavigationBar: _bottomNav(),
      floatingActionButton: _fab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.3), blurRadius: 16)],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0),
              _navItem(1),
              const SizedBox(width: 60),
              _navItem(2),
              _navItem(3),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _navItem(int index) {
    return Obx(() {
      final active = controller.currentIndex.value == index;
      final item = _items[index];
      return GestureDetector(
        onTap: () => controller.currentIndex.value = index,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 64,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? AppConstants.primaryColor.withOpacity(.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: active ? AppConstants.primaryColor : Colors.grey[500],
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['label'] as String,
                style: TextStyle(
                  color: active ? AppConstants.primaryColor : Colors.grey[500],
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ]),
          ),
        ),
      );
    });
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
