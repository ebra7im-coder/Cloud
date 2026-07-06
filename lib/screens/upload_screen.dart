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
  final List<_Task> _tasks = [];
  bool _uploading = false;

  Future<void> _pickFiles() async {
    final r = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.any);
    if (r != null) {
      setState(() {
        for (final f in r.files) {
          if (f.path != null) _tasks.add(_Task(File(f.path!), f.name));
        }
      });
    }
  }

  Future<void> _pickCamera() async {
    final img = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 90);
    if (img != null) setState(() => _tasks.add(_Task(File(img.path), img.name)));
  }

  Future<void> _pickGallery() async {
    final list = await ImagePicker().pickMultipleMedia();
    setState(() {
      for (final m in list) _tasks.add(_Task(File(m.path), m.name));
    });
  }

  Future<void> _startUpload() async {
    if (_tasks.isEmpty || _uploading) return;
    setState(() => _uploading = true);
    for (final t in _tasks) {
      if (t.status == _Status.done) continue;
      setState(() { t.status = _Status.uploading; t.progress = 0; });
      try {
        final result = await TelegramService.instance.uploadFile(
          t.file,
          onProgress: (p, _, __) => setState(() => t.progress = p),
          folder: 'root',
        );
        if (result != null) {
          await FileStorageService.instance.saveFile(result);
          setState(() => t.status = _Status.done);
        } else {
          setState(() => t.status = _Status.failed);
        }
      } catch (_) {
        setState(() => t.status = _Status.failed);
      }
    }
    setState(() => _uploading = false);
    try { Get.find<HomeController>().loadFiles(); } catch (_) {}
    if (_tasks.every((t) => t.status == _Status.done)) {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
      Get.snackbar('✅ اكتمل', 'تم رفع ${_tasks.length} ملف',
          backgroundColor: AppConstants.greenColor, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      appBar: AppBar(
        backgroundColor: AppConstants.bgDark,
        elevation: 0,
        title: const Text('رفع الملفات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(children: [
        _pickers(),
        Expanded(child: _list()),
        _uploadBtn(),
      ]),
    );
  }

  Widget _pickers() => Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _pickerBtn('اختر ملف', Icons.folder_open_rounded,
              AppConstants.primaryColor, _pickFiles),
          const SizedBox(width: 10),
          _pickerBtn('المعرض', Icons.photo_library_rounded,
              AppConstants.greenColor, _pickGallery),
          const SizedBox(width: 10),
          _pickerBtn('الكاميرا', Icons.camera_alt_rounded,
              AppConstants.orangeColor, _pickCamera),
        ]),
      );

  Widget _pickerBtn(String l, IconData icon, Color color, VoidCallback tap) =>
      Expanded(
        child: GestureDetector(
          onTap: tap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(.35)),
            ),
            child: Column(children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(l,
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );

  Widget _list() {
    if (_tasks.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 14),
          Text('اختر ملفات للرفع',
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 6),
          Text('صور • فيديو • موسيقى • مستندات',
              style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _tasks.length,
      itemBuilder: (_, i) => _taskTile(_tasks[i], i),
    );
  }

  Widget _taskTile(_Task t, int i) {
    final (color, icon, label) = switch (t.status) {
      _Status.pending  => (Colors.grey[500]!, Icons.schedule_rounded, 'انتظار'),
      _Status.uploading => (AppConstants.primaryColor, Icons.cloud_upload_rounded,
          '${(t.progress * 100).toInt()}%'),
      _Status.done     => (AppConstants.greenColor, Icons.check_circle_rounded, 'تم'),
      _Status.failed   => (AppConstants.redColor, Icons.error_rounded, 'فشل'),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppConstants.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(.25))),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(_typeIcon(t.name), color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
              Text(_fmtSize(t.file.lengthSync()),
                  style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            ]),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
            if (t.status == _Status.pending) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _tasks.removeAt(i)),
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ]
          ]),
        ]),
        if (t.status == _Status.uploading) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: t.progress, minHeight: 4,
              backgroundColor: Colors.grey[800],
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ]),
    );
  }

  IconData _typeIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg','jpeg','png','gif','webp'].contains(ext)) return Icons.image_rounded;
    if (['mp4','mkv','avi','mov'].contains(ext)) return Icons.videocam_rounded;
    if (['mp3','aac','ogg','flac','wav'].contains(ext)) return Icons.music_note_rounded;
    return Icons.description_rounded;
  }

  String _fmtSize(int b) {
    if (b < 1024) return '$b B';
    if (b < 1048576) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1073741824) return '${(b / 1048576).toStringAsFixed(1)} MB';
    return '${(b / 1073741824).toStringAsFixed(2)} GB';
  }

  Widget _uploadBtn() => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_uploading || _tasks.isEmpty) ? null : _startUpload,
            icon: _uploading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.cloud_upload_rounded),
            label: Text(
              _uploading ? 'جاري الرفع...' : 'رفع ${_tasks.length} ملف',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: Colors.grey[800],
            ),
          ),
        ),
      );
}

enum _Status { pending, uploading, done, failed }

class _Task {
  final File file;
  final String name;
  _Status status;
  double progress;
  _Task(this.file, this.name,
      {this.status = _Status.pending, this.progress = 0});
}
