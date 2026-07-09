// controllers/home_controller.dart
import 'package:get/get.dart';
import '../services/file_storage_service.dart';
import '../services/telegram_service.dart';
import '../models/file_model.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final isLoading = false.obs;
  final allFiles = <CloudFile>[].obs;

  final userName = 'أحمد'.obs;
  final totalFiles = 0.obs;
  final usedStorage = 0.0.obs; // In GB
  final storagePercentage = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  void loadFiles() {
    allFiles.value = FileStorageService.instance.getAllFiles();
    final fileStats = FileStorageService.instance.getStats();
    totalFiles.value = fileStats['total'] as int;
    
    // Calculate size in MB and convert to GB
    final sizeInMB = (fileStats['size'] as int) / (1024 * 1024);
    usedStorage.value = double.parse((sizeInMB / 1024).toStringAsFixed(2));
    
    // Assume limit is 5.0 GB for display, clip percentage between 0 and 100
    storagePercentage.value = (usedStorage.value / 5.0 * 100).clamp(0.0, 100.0);
  }

  String get usedStorageDisplay {
    if (usedStorage.value >= 1.0) {
      return '${usedStorage.value.toStringAsFixed(2)} GB';
    }
    final sizeInMB = usedStorage.value * 1024;
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }

  Future<void> syncFiles() async {
    isLoading.value = true;
    try {
      final remote = await TelegramService.instance.syncFromTelegram();
      await FileStorageService.instance.syncFiles(remote);
      loadFiles();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void updateStorage(double newUsed) {
    usedStorage.value = newUsed;
    storagePercentage.value = (newUsed / 5.0 * 100).clamp(0.0, 100.0);
  }

  Map<String, dynamic> get stats => FileStorageService.instance.getStats();
}
