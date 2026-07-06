import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../models/file_model.dart';
import '../utils/constants.dart';
import '../widgets/file_card.dart';
import 'files_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(ctrl),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStorageCard(ctrl),
                const SizedBox(height: 20),
                _buildCategories(ctrl),
                const SizedBox(height: 20),
                _buildRecentSection(ctrl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(HomeController ctrl) {
    return SliverAppBar(
      backgroundColor: AppConstants.bgDark,
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'CloudGram ☁️',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A2A3A), Color(0xFF17212B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        Obx(() => ctrl.isLoading.value
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppConstants.primaryColor,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.sync_rounded, color: Colors.white),
                onPressed: ctrl.syncFiles,
                tooltip: 'مزامنة من تيليجرام',
              )),
      ],
    );
  }

  Widget _buildStorageCard(HomeController ctrl) {
    return Obx(() {
      final stats = ctrl.stats;
      final totalMB = (stats['size'] as int) / (1024 * 1024);
      final totalGB = totalMB / 1024;
      final display = totalGB >= 1
          ? '${totalGB.toStringAsFixed(2)} GB'
          : '${totalMB.toStringAsFixed(1)} MB';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2AABEE), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_done_rounded,
                    color: Colors.white, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'تخزين لا محدود 🚀',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Telegram',
                      style: TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('${stats['total']}', 'ملف', Icons.folder),
                _statItem(display, 'مستخدم', Icons.storage),
                _statItem('∞', 'متاح', Icons.all_inclusive),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildCategories(HomeController ctrl) {
    return Obx(() {
      final stats = ctrl.stats;
      final categories = [
        {
          'label': 'الصور',
          'count': stats['images'],
          'icon': Icons.image_rounded,
          'color': const Color(0xFF4CAF50),
          'type': FileType.image,
        },
        {
          'label': 'الفيديو',
          'count': stats['videos'],
          'icon': Icons.videocam_rounded,
          'color': const Color(0xFFEF5350),
          'type': FileType.video,
        },
        {
          'label': 'الموسيقى',
          'count': stats['audios'],
          'icon': Icons.music_note_rounded,
          'color': const Color(0xFF9C27B0),
          'type': FileType.audio,
        },
        {
          'label': 'الملفات',
          'count': stats['docs'],
          'icon': Icons.description_rounded,
          'color': const Color(0xFFFF9800),
          'type': FileType.document,
        },
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () => Get.to(
              () => FilesScreen(filterType: cat['type'] as FileType?),
              transition: Transition.rightToLeft,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (cat['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (cat['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat['icon'] as IconData,
                        color: cat['color'] as Color, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cat['count']}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildRecentSection(HomeController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('أحدث الملفات',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => ctrl.currentIndex.value = 1,
              child: const Text('عرض الكل',
                  style: TextStyle(color: AppConstants.primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final recent = ctrl.allFiles.take(6).toList();
          if (recent.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 60, color: Colors.grey[600]),
                    const SizedBox(height: 12),
                    Text('لا توجد ملفات بعد\nارفع أول ملف الآن! 🚀',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 14)),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recent.length,
            itemBuilder: (_, i) => FileCard(file: recent[i],
                onRefresh: ctrl.loadFiles),
          );
        }),
      ],
    );
  }
}
