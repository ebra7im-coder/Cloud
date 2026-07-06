import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/file_model.dart';
import '../services/file_storage_service.dart';
import '../utils/constants.dart';
import '../screens/media_viewer_screen.dart';

class FileGridCard extends StatelessWidget {
  final CloudFile file;
  final VoidCallback? onRefresh;
  const FileGridCard({super.key, required this.file, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => MediaViewerScreen(file: file),
        transition: Transition.fadeIn,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.cardDark,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail or icon
            if (file.localPath != null && File(file.localPath!).existsSync() &&
                file.type == FileType.image)
              Image.file(File(file.localPath!), fit: BoxFit.cover)
            else
              _buildPlaceholder(),
            // Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Text(
                  file.name,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Favorite
            if (file.isFavorite)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Colors.red, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    Color color;
    IconData icon;
    switch (file.type) {
      case FileType.image:    color = AppConstants.greenColor; icon = Icons.image_rounded; break;
      case FileType.video:    color = AppConstants.redColor; icon = Icons.videocam_rounded; break;
      case FileType.audio:    color = AppConstants.purpleColor; icon = Icons.music_note_rounded; break;
      case FileType.document: color = AppConstants.orangeColor; icon = Icons.description_rounded; break;
      default:                color = Colors.grey; icon = Icons.insert_drive_file_rounded;
    }
    return Container(
      color: color.withOpacity(0.15),
      child: Center(child: Icon(icon, color: color, size: 36)),
    );
  }
}
