// controllers/file_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path/path.dart' as path;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../models/file_model.dart';
import '../services/storage_service.dart';

class FileController extends GetxController {
  final StorageService _storageService = Get.find();
  
  final files = <CloudFile>[].obs;
  final isLoading = false.obs;
  final uploadProgress = 0.0.obs;
  final currentPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  Future<void> loadFiles() async {
    isLoading.value = true;
    try {
      files.value = await _storageService.getFiles();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الملفات');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadFiles() async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: fp.FileType.any,
      );
      
      if (result != null) {
        final filePaths = result.paths.where((p) => p != null).cast<String>();
        await uploadFiles(filePaths.map((p) => File(p)).toList());
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في اختيار الملفات');
    }
  }

  Future<void> uploadFiles(List<File> filesToUpload) async {
    isLoading.value = true;
    uploadProgress.value = 0;
    
    try {
      final total = filesToUpload.length;
      for (var i = 0; i < total; i++) {
        final file = filesToUpload[i];
        await _storageService.uploadFile(file);
        uploadProgress.value = ((i + 1) / total) * 100;
      }
      
      await loadFiles();
      Get.snackbar('نجاح', 'تم رفع ${filesToUpload.length} ملفات');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في رفع الملفات');
    } finally {
      isLoading.value = false;
      uploadProgress.value = 0;
    }
  }

  Future<void> createNewFolder() async {
    final name = await _showInputDialog('إنشاء مجلد جديد', 'أدخل اسم المجلد');
    if (name != null && name.isNotEmpty) {
      await _storageService.createFolder(name);
      await loadFiles();
      Get.snackbar('نجاح', 'تم إنشاء المجلد $name');
    }
  }

  Future<void> openFile(CloudFile file) async {
    try {
      final pathStr = file.localPath;
      if (pathStr == null) {
        Get.snackbar('تحميل مطلوب', 'يرجى تحميل الملف أولاً لمشاهدته.');
        return;
      }
      final result = await OpenFilex.open(pathStr);
      if (result.type != ResultType.done) {
        Get.snackbar('خطأ', 'لا يمكن فتح الملف');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في فتح الملف');
    }
  }

  Future<void> previewFile(CloudFile file) async {
    Get.toNamed('/preview', arguments: file);
  }

  Future<void> shareFile(CloudFile file) async {
    try {
      final pathStr = file.localPath;
      if (pathStr == null) {
        Get.snackbar('مشاركة مطلوبة', 'يرجى تحميل الملف أولاً لمشاركته.');
        return;
      }
      await Share.shareXFiles([XFile(pathStr)]);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في مشاركة الملف');
    }
  }

  Future<void> downloadFile(CloudFile file) async {
    try {
      final result = await fp.FilePicker.platform.saveFile(
        dialogTitle: 'حفظ الملف',
        fileName: file.name,
      );
      
      if (result != null) {
        await _storageService.downloadFile(file, result);
        Get.snackbar('نجاح', 'تم تحميل الملف');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الملف');
    }
  }

  Future<void> renameFile(CloudFile file) async {
    final newName = await _showInputDialog('إعادة تسمية', 'أدخل الاسم الجديد', initialValue: file.name);
    if (newName != null && newName.isNotEmpty) {
      await _storageService.renameFile(file, newName);
      await loadFiles();
      Get.snackbar('نجاح', 'تم إعادة تسمية الملف');
    }
  }

  Future<void> toggleFavorite(CloudFile file) async {
    file.isFavorite = !file.isFavorite;
    await _storageService.updateFile(file);
    await loadFiles();
  }

  Future<void> deleteFile(CloudFile file) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الملف؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _storageService.deleteFile(file);
      await loadFiles();
      Get.snackbar('نجاح', 'تم حذف الملف');
    }
  }

  Future<String?> _showInputDialog(String title, String hint, {String? initialValue}) async {
    final textController = TextEditingController(text: initialValue);
    return await Get.dialog<String>(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: textController.text),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void handleFileAction(CloudFile file, String action) {
    switch (action) {
      case 'preview': previewFile(file); break;
      case 'share': shareFile(file); break;
      case 'download': downloadFile(file); break;
      case 'rename': renameFile(file); break;
      case 'favorite': toggleFavorite(file); break;
      case 'delete': deleteFile(file); break;
    }
  }

  void scanFiles() {
    Get.toNamed('/scan');
  }

  Future<void> saveState() async {
    await _storageService.saveState();
  }

  void refreshFiles() {
    loadFiles();
  }
}
