import 'package:get/get.dart';
import '../services/file_storage_service.dart';
import '../services/telegram_service.dart';
import '../models/file_model.dart';

class HomeController extends GetxController {
  final currentIndex  = 0.obs;
  final isLoading     = false.obs;
  final allFiles      = <CloudFile>[].obs;

  // UI state
  final userName      = 'CloudGram'.obs;
  final totalFiles    = 0.obs;
  final usedStorageMB = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  void loadFiles() {
    allFiles.value = FileStorageService.instance.getAllFiles();
    final stats = FileStorageService.instance.getStats();
    totalFiles.value    = stats['total'] as int;
    usedStorageMB.value = (stats['size'] as int) / (1024 * 1024);
  }

  String get usedStorageDisplay {
    if (usedStorageMB.value >= 1024) {
      return '${(usedStorageMB.value / 1024).toStringAsFixed(2)} GB';
    }
    return '${usedStorageMB.value.toStringAsFixed(1)} MB';
  }

  Future<void> syncFiles() async {
    isLoading.value = true;
    try {
      final remote = await TelegramService.instance.syncFromTelegram();
      await FileStorageService.instance.syncFiles(remote);
      loadFiles();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> get stats => FileStorageService.instance.getStats();
}
