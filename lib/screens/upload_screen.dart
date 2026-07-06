import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/telegram_service.dart';
import '../services/file_storage_service.dart';
import '../controllers/home_controller.dart';
import '../utils/constants.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final List<_UploadTask> _tasks = [];
  bool _isUploading = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        for (final f in result.files) {
          if (f.path != null) {
            _tasks.add(_UploadTask(
              file: File(f.path!),
              name: f.name,
            ));
          }
        }
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (photo != null) {
      setState(() {
        _tasks.add(_UploadTask(file: File(photo.path), name: photo.name));
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final media = await picker.pickMultipleMedia();
    setState(() {
      for (final m in media) {
        _tasks.add(_UploadTask(file: File(m.path), name: m.name));
      }
    });
  }

  Future<void> _startUpload() async {
    if (_tasks.isEmpty) return;
    setState(() => _isUploading = true);

    for (final task in _tasks) {
      if (task.status == _Status.done || task.status == _Status.uploading) continue;
      setState(() => task.status = _Status.uploading);

      try {
        final result = await TelegramService.instance.uploadFile(
          task.file,
          onProgress: (progress, sent, total) {
            setState(() => task.progress = progress);
          },
          folder: 'root',
        );

        if (result != null) {
          await FileStorageService.instance.saveFile(result);
          setState(() => task.status = _Status.done);
        } else {
          setState(() => task.status = _Status.failed);
        }
      } catch (_) {
        setState(() => task.status = _Status.failed);
      }
    }

    setState(() => _isUploading = false);

    // Refresh home controller
    try {
      Get.find<HomeController>().loadFiles();
    } catch (_) {}

    if (_tasks.every((t) => t.status == _Status.done)) {
      await Future.delayed(const Duration(milliseconds: 800));
      Get.back();
      Get.snackbar(
        '✅ اكتمل الرفع',
        'تم رفع ${_tasks.length} ملف بنجاح',
        backgroundColor: AppConstants.greenColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      appBar: AppBar(
        title: const Text('رفع الملفات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.bgDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildPickerButtons(),
          Expanded(child: _buildTaskList()),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildPickerButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _pickerBtn(
                  icon: Icons.folder_open_rounded,
                  label: 'اختر ملفات',
                  color: AppConstants.primaryColor,
                  onTap: _pickFiles)),
              const SizedBox(width: 10),
              Expanded(child: _pickerBtn(
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  color: AppConstants.greenColor,
                  onTap: _pickFromGallery)),
              const SizedBox(width: 10),
              Expanded(child: _pickerBtn(
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  color: AppConstants.orangeColor,
                  onTap: _pickFromCamera)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pickerBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('اختر الملفات للرفع',
                style: TextStyle(color: Colors.grey[400], fontSize: 16)),
            const SizedBox(height: 8),
            Text('صور • فيديو • موسيقى • مستندات',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _tasks.length,
      itemBuilder: (_, i) {
        final task = _tasks[i];
        return _buildTaskTile(task, i);
      },
    );
  }

  Widget _buildTaskTile(_UploadTask task, int index) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (task.status) {
      case _Status.pending:
        statusColor = Colors.grey;
        statusIcon  = Icons.schedule_rounded;
        statusText  = 'في الانتظار';
        break;
      case _Status.uploading:
        statusColor = AppConstants.primaryColor;
        statusIcon  = Icons.cloud_upload_rounded;
        statusText  = '${(task.progress * 100).toInt()}%';
        break;
      case _Status.done:
        statusColor = AppConstants.greenColor;
        statusIcon  = Icons.check_circle_rounded;
        statusText  = 'تم الرفع';
        break;
      case _Status.failed:
        statusColor = AppConstants.redColor;
        statusIcon  = Icons.error_rounded;
        statusText  = 'فشل';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon(task.name), color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                    Text(
                      _formatSize(task.file.lengthSync()),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 4),
                  Text(statusText,
                      style: TextStyle(color: statusColor, fontSize: 12)),
                ],
              ),
              if (task.status == _Status.pending)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                  onPressed: () =>
                      setState(() => _tasks.removeAt(index)),
                ),
            ],
          ),
          if (task.status == _Status.uploading) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: task.progress,
              backgroundColor: Colors.grey[800],
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ],
      ),
    );
  }

  IconData _typeIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg','jpeg','png','gif','webp'].contains(ext)) return Icons.image_rounded;
    if (['mp4','mkv','avi','mov'].contains(ext)) return Icons.videocam_rounded;
    if (['mp3','aac','ogg','flac','wav'].contains(ext)) return Icons.music_note_rounded;
    return Icons.description_rounded;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Widget _buildUploadButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isUploading || _tasks.isEmpty ? null : _startUpload,
          icon: _isUploading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.cloud_upload_rounded),
          label: Text(
            _isUploading
                ? 'جاري الرفع...'
                : 'رفع ${_tasks.length} ملف',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            disabledBackgroundColor: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

enum _Status { pending, uploading, done, failed }

class _UploadTask {
  final File file;
  final String name;
  _Status status;
  double progress;

  _UploadTask({
    required this.file,
    required this.name,
    this.status = _Status.pending,
    this.progress = 0,
  });
}
