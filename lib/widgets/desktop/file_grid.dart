// widgets/desktop/file_grid.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/theme.dart';
import '../../controllers/file_controller.dart';
import '../../models/file_model.dart';

class FileGridView extends GetView<FileController> {
  const FileGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.files.isEmpty) {
        return _buildEmptyState();
      }
      
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.9,
        ),
        itemCount: controller.files.length,
        itemBuilder: (context, index) {
          final file = controller.files[index];
          return _buildFileCard(file);
        },
      );
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 4;
    return 3;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document, color: AppTheme.textTertiary, size: 64.sp),
          SizedBox(height: 16.h),
          Text(
            'لا توجد ملفات',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قم برفع الملفات أو اسحبها إلى هنا',
            style: GoogleFonts.poppins(
              color: AppTheme.textTertiary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => controller.pickAndUploadFiles(),
            icon: const Icon(Iconsax.document_upload),
            label: const Text('رفع ملفات'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(CloudFile file) {
    return InkWell(
      onTap: () => controller.openFile(file),
      onDoubleTap: () => controller.previewFile(file),
      onLongPress: () => _showFileMenu(file),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أيقونة الملف
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _getFileGradient(file),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getFileIcon(file),
                      color: Colors.white.withOpacity(0.8),
                      size: 48.sp,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _buildFileMenu(file),
                  ),
                  if (file.isFavorite) ...[
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: const Icon(
                        Iconsax.star1,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // معلومات الملف
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textPrimary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        file.size,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textTertiary,
                          fontSize: 11.sp,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        file.modifiedDate,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textTertiary,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileMenu(CloudFile file) {
    return PopupMenuButton<String>(
      icon: Icon(Iconsax.more, color: Colors.white.withOpacity(0.6), size: 20.sp),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'preview', child: Text('معاينة')),
        const PopupMenuItem(value: 'share', child: Text('مشاركة')),
        const PopupMenuItem(value: 'download', child: Text('تحميل')),
        const PopupMenuItem(value: 'rename', child: Text('إعادة تسمية')),
        const PopupMenuItem(value: 'favorite', child: Text('إضافة للمفضلة')),
        const PopupMenuItem(value: 'delete', child: Text('حذف')),
      ],
      onSelected: (value) => controller.handleFileAction(file, value),
    );
  }

  Gradient _getFileGradient(CloudFile file) {
    final colors = {
      'pdf': [Colors.red, Colors.orange],
      'image': [Colors.purple, Colors.pink],
      'video': [Colors.blue, Colors.cyan],
      'music': [Colors.green, Colors.teal],
      'document': [Colors.orange, Colors.amber],
      'folder': [Colors.blue, Colors.indigo],
    };
    
    final gradientColors = colors[file.typeString] ?? [AppTheme.primary, AppTheme.primaryLight];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors.map((c) => c.withOpacity(0.8)).toList(),
    );
  }

  IconData _getFileIcon(CloudFile file) {
    final icons = {
      'pdf': Iconsax.document_text,
      'image': Iconsax.gallery,
      'video': Iconsax.video_play,
      'music': Iconsax.music,
      'document': Iconsax.document,
      'folder': Iconsax.folder,
    };
    return icons[file.typeString] ?? Iconsax.document;
  }

  void _showFileMenu(CloudFile file) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Wrap(
          children: [
            _buildBottomSheetItem(Iconsax.eye, 'معاينة', () => controller.previewFile(file)),
            _buildBottomSheetItem(Iconsax.share, 'مشاركة', () => controller.shareFile(file)),
            _buildBottomSheetItem(Iconsax.download, 'تحميل', () => controller.downloadFile(file)),
            _buildBottomSheetItem(Iconsax.edit, 'إعادة تسمية', () => controller.renameFile(file)),
            _buildBottomSheetItem(Iconsax.star, 'المفضلة', () => controller.toggleFavorite(file)),
            _buildBottomSheetItem(Iconsax.trash, 'حذف', () => controller.deleteFile(file), isDanger: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetItem(IconData icon, String label, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : AppTheme.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: isDanger ? Colors.red : AppTheme.textPrimary,
        ),
      ),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }
}
