// services/storage_service.dart
import 'dart:io';
import 'package:get/get.dart';
import '../models/file_model.dart';
import 'file_storage_service.dart';
import 'telegram_service.dart';

class StorageService extends GetxService {
  static StorageService get instance => Get.find();

  Future<void> initialize() async {
    // Initialization code if needed
  }

  Future<List<CloudFile>> getFiles() async {
    return FileStorageService.instance.getAllFiles();
  }

  Future<void> uploadFile(File file) async {
    final result = await TelegramService.instance.uploadFile(file, folder: 'root');
    if (result != null) {
      await FileStorageService.instance.saveFile(result);
    } else {
      throw Exception('Upload failed');
    }
  }

  Future<void> createFolder(String name) async {
    // Folders are handled virtually, no native directories needed
  }

  Future<void> downloadFile(CloudFile file, String destination) async {
    final path = await TelegramService.instance.downloadFile(file);
    if (path != null) {
      final destFile = File(destination);
      await File(path).copy(destFile.path);
      await FileStorageService.instance.updateLocalPath(file.id, destination);
    } else {
      throw Exception('Download failed');
    }
  }

  Future<void> renameFile(CloudFile file, String newName) async {
    final all = FileStorageService.instance.getAllFiles();
    final boxFile = all.firstWhere((f) => f.id == file.id);
    boxFile.name = newName;
    await boxFile.save();
  }

  Future<void> updateFile(CloudFile file) async {
    await FileStorageService.instance.saveFile(file);
  }

  Future<void> deleteFile(CloudFile file) async {
    if (file.telegramMessageId != null) {
      await TelegramService.instance.deleteFile(file.telegramMessageId!);
    }
    await FileStorageService.instance.deleteFile(file.id);
  }

  Future<void> saveState() async {
    // Handled automatically by Hive
  }
}
