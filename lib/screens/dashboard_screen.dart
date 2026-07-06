import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../models/file_model.dart';
import '../utils/constants.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_action_widget.dart';
import '../widgets/recent_file_item.dart';
import 'upload_screen.dart';
import 'files_screen.dart';

class DashboardScreen extends GetView<HomeController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: RefreshIndicator(
        color: AppConstants.primaryColor,
        backgroundColor: AppConstants.cardDark,
        onRefresh: controller.syncFiles,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── AppBar ─────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppConstants.bgDark,
              floating: true,
              pinned: true,
              expandedHeight: 0,
              toolbarHeight: 64,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Avatar + Welcome
                      CircleAvatar(
                        radius: 22,
                        backgroundColor:
                            AppConstants.primaryColor.withOpacity(0.2),
                        child: const Icon(Icons.person_rounded,
                            color: AppConstants.primaryColor, size: 26),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('مرحباً بك 👋',
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)),
                            const Text('CloudGram',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // Sync button
                      Obx(() => controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppConstants.primaryColor))
                          : IconButton(
                              onPressed: controller.syncFiles,
                              icon: const Icon(Icons.sync_rounded,
                                  color: Colors.white70),
                              tooltip: 'مزامنة',
                            )),
                      // Notifications
                      IconButton(
                        onPressed: _showNotifications,
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_rounded,
                                color: Colors.white),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Body ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Storage Card
                  _buildStorageCard(),
                  const SizedBox(height: 20),

                  // Stats row
                  _buildStatsRow(),
                  const SizedBox(height: 20),

                  // Quick actions
                  _buildQuickActions(),
                  const SizedBox(height: 20),

                  // Recent files
                  _buildRecentFiles(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Storage Card ─────────────────────────────────────────────
  Widget _buildStorageCard() {
    return Obx(() {
      final pct = (controller.usedStorageMB.value / (5 * 1024))
          .clamp(0.0, 1.0);
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppConstants.gradientStart, AppConstants.gradientEnd],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مساحة التخزين',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.upload_file_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                          '${controller.totalFiles.value} ملف',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.usedStorageDisplay,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'تخزين لا محدود ∞',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12),
                    ),
                  ],
                ),
                const Icon(Icons.cloud_rounded,
                    color: Colors.white, size: 52),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Telegram Cloud — مساحة غير محدودة',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.65), fontSize: 11),
            ),
          ],
        ),
      );
    });
  }

  // ── Stats Row ─────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Obx(() {
      final s = controller.stats;
      return Row(
        children: [
          Expanded(
              child: StatsCard(
            icon: Icons.image_rounded,
            label: 'الصور',
            value: '${s['images']}',
            color: AppConstants.greenColor,
          )),
          const SizedBox(width: 10),
          Expanded(
              child: StatsCard(
            icon: Icons.videocam_rounded,
            label: 'الفيديو',
            value: '${s['videos']}',
            color: AppConstants.redColor,
          )),
          const SizedBox(width: 10),
          Expanded(
              child: StatsCard(
            icon: Icons.music_note_rounded,
            label: 'الموسيقى',
            value: '${s['audios']}',
            color: AppConstants.purpleColor,
          )),
          const SizedBox(width: 10),
          Expanded(
              child: StatsCard(
            icon: Icons.description_rounded,
            label: 'ملفات',
            value: '${s['docs']}',
            color: AppConstants.orangeColor,
          )),
        ],
      );
    });
  }

  // ── Quick Actions ─────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('إجراءات سريعة',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            QuickActionWidget(
              icon: Icons.upload_file_rounded,
              label: 'رفع',
              color: AppConstants.primaryColor,
              onTap: () => Get.to(() => const UploadScreen(),
                  transition: Transition.downToUp),
            ),
            QuickActionWidget(
              icon: Icons.photo_library_rounded,
              label: 'الصور',
              color: AppConstants.greenColor,
              onTap: () => Get.to(
                  () => const FilesScreen(filterType: FileType.image),
                  transition: Transition.rightToLeft),
            ),
            QuickActionWidget(
              icon: Icons.video_library_rounded,
              label: 'الفيديو',
              color: AppConstants.redColor,
              onTap: () => Get.to(
                  () => const FilesScreen(filterType: FileType.video),
                  transition: Transition.rightToLeft),
            ),
            QuickActionWidget(
              icon: Icons.library_music_rounded,
              label: 'موسيقى',
              color: AppConstants.purpleColor,
              onTap: () => Get.to(
                  () => const FilesScreen(filterType: FileType.audio),
                  transition: Transition.rightToLeft),
            ),
          ],
        ),
      ],
    );
  }

  // ── Recent Files ──────────────────────────────────────────────
  Widget _buildRecentFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('آخر الملفات',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => controller.currentIndex.value = 1,
              child: const Text('عرض الكل',
                  style: TextStyle(
                      color: AppConstants.primaryColor, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Obx(() {
          final recent = controller.allFiles.take(5).toList();
          if (recent.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 64, color: Colors.grey[700]),
                    const SizedBox(height: 12),
                    Text('لا توجد ملفات بعد\nارفع أول ملف الآن! 🚀',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey[500], height: 1.7)),
                  ],
                ),
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: AppConstants.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Color(0xFF2C3A4A),
                  indent: 16,
                  endIndent: 16),
              itemBuilder: (_, i) => RecentFileItem(
                  file: recent[i], onRefresh: controller.loadFiles),
            ),
          );
        }),
      ],
    );
  }

  // ── Notifications Dialog ──────────────────────────────────────
  void _showNotifications() {
    Get.dialog(
      Dialog(
        backgroundColor: AppConstants.cardDark,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📬 الإشعارات',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _notifItem(Icons.folder_rounded, AppConstants.primaryColor,
                  'تم رفع ملف جديد', 'منذ 5 دقائق'),
              const Divider(color: Color(0xFF2C3A4A)),
              _notifItem(Icons.sync_rounded, AppConstants.greenColor,
                  'تمت المزامنة بنجاح', 'منذ ساعة'),
              const Divider(color: Color(0xFF2C3A4A)),
              _notifItem(Icons.cloud_done_rounded, AppConstants.orangeColor,
                  'تم النسخ الاحتياطي', 'منذ يوم'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: Get.back,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('إغلاق',
                      style:
                          TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifItem(IconData icon, Color color, String title, String sub) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
      subtitle: Text(sub,
          style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      trailing: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle)),
    );
  }
}
