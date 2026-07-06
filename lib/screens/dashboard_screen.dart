import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../models/file_model.dart';
import '../utils/constants.dart';
import '../widgets/file_card.dart';
import 'files_screen.dart';
import 'upload_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: RefreshIndicator(
        color: AppConstants.primaryColor,
        backgroundColor: AppConstants.cardDark,
        onRefresh: ctrl.syncFiles,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _appBar(ctrl),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _storageCard(ctrl),
                  const SizedBox(height: 20),
                  _quickActions(context),
                  const SizedBox(height: 20),
                  _categories(ctrl),
                  const SizedBox(height: 20),
                  _recentSection(ctrl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────
  Widget _appBar(HomeController ctrl) {
    return SliverAppBar(
      backgroundColor: AppConstants.bgDark,
      expandedHeight: 100,
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF2AABEE), Color(0xFF1565C0)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.cloud_done_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text('CloudGram',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
      ),
      actions: [
        Obx(() => ctrl.isLoading.value
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppConstants.primaryColor)))
            : IconButton(
                icon: const Icon(Icons.sync_rounded, color: Colors.white70),
                onPressed: ctrl.syncFiles,
                tooltip: 'مزامنة')),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Storage Hero Card ─────────────────────────────────────────────
  Widget _storageCard(HomeController ctrl) {
    return Obx(() {
      final s = ctrl.stats;
      final mb = (s['size'] as int) / (1024 * 1024);
      final display = mb >= 1024
          ? '${(mb / 1024).toStringAsFixed(2)} GB'
          : '${mb.toStringAsFixed(1)} MB';
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF2AABEE), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppConstants.primaryColor.withOpacity(.35),
                blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 10),
            const Expanded(
                child: Text('مساحة لا محدودة 🚀',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Telegram',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _statItem('${s['total']}', 'ملف', Icons.folder_rounded),
            _divider(),
            _statItem(display, 'مستخدم', Icons.storage_rounded),
            _divider(),
            _statItem('∞', 'متاح', Icons.all_inclusive_rounded),
          ]),
        ]),
      );
    });
  }

  Widget _statItem(String v, String l, IconData icon) => Column(children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(v,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(l,
            style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 12)),
      ]);

  Widget _divider() => Container(
      width: 1, height: 40,
      color: Colors.white.withOpacity(.25));

  // ── Quick Actions ─────────────────────────────────────────────────
  Widget _quickActions(BuildContext context) {
    final actions = [
      {'label': 'رفع', 'icon': Icons.upload_rounded, 'color': AppConstants.primaryColor},
      {'label': 'الصور', 'icon': Icons.image_rounded, 'color': AppConstants.greenColor},
      {'label': 'الفيديو', 'icon': Icons.videocam_rounded, 'color': AppConstants.redColor},
      {'label': 'الموسيقى', 'icon': Icons.music_note_rounded, 'color': AppConstants.purpleColor},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('إجراءات سريعة',
          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Row(
        children: actions.map((a) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (a['label'] == 'رفع') {
                  Get.to(() => const UploadScreen(), transition: Transition.downToUp);
                } else {
                  FileType? t;
                  if (a['label'] == 'الصور') t = FileType.image;
                  if (a['label'] == 'الفيديو') t = FileType.video;
                  if (a['label'] == 'الموسيقى') t = FileType.audio;
                  Get.to(() => FilesScreen(filterType: t), transition: Transition.rightToLeft);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: (a['color'] as Color).withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: (a['color'] as Color).withOpacity(.3)),
                ),
                child: Column(children: [
                  Icon(a['icon'] as IconData, color: a['color'] as Color, size: 26),
                  const SizedBox(height: 5),
                  Text(a['label'] as String,
                      style: TextStyle(
                          color: a['color'] as Color, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  // ── Categories Grid ────────────────────────────────────────────────
  Widget _categories(HomeController ctrl) {
    return Obx(() {
      final s = ctrl.stats;
      final cats = [
        {'label': 'الصور', 'count': s['images'], 'icon': Icons.image_rounded,
         'color': AppConstants.greenColor, 'type': FileType.image},
        {'label': 'الفيديو', 'count': s['videos'], 'icon': Icons.videocam_rounded,
         'color': AppConstants.redColor, 'type': FileType.video},
        {'label': 'الموسيقى', 'count': s['audios'], 'icon': Icons.music_note_rounded,
         'color': AppConstants.purpleColor, 'type': FileType.audio},
        {'label': 'المستندات', 'count': s['docs'], 'icon': Icons.description_rounded,
         'color': AppConstants.orangeColor, 'type': FileType.document},
      ];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('التصنيفات',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.6),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final c = cats[i];
            final color = c['color'] as Color;
            return GestureDetector(
              onTap: () => Get.to(
                  () => FilesScreen(filterType: c['type'] as FileType?),
                  transition: Transition.rightToLeft),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppConstants.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(.25)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: color.withOpacity(.15),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(c['icon'] as IconData, color: color, size: 22),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${c['count']}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(c['label'] as String,
                            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      ]),
                    ]),
              ),
            );
          },
        ),
      ]);
    });
  }

  // ── Recent Files ──────────────────────────────────────────────────
  Widget _recentSection(HomeController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('الأخيرة',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () => ctrl.currentIndex.value = 1,
          child: const Text('عرض الكل',
              style: TextStyle(color: AppConstants.primaryColor, fontSize: 13)),
        ),
      ]),
      const SizedBox(height: 8),
      Obx(() {
        final recent = ctrl.allFiles.take(5).toList();
        if (recent.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 12),
                Text('لا توجد ملفات بعد\nارفع أول ملف! 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], height: 1.6)),
              ]),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recent.length,
          itemBuilder: (_, i) =>
              FileCard(file: recent[i], onRefresh: ctrl.loadFiles),
        );
      }),
    ]);
  }
}
