import 'package:get/get.dart';
import '../services/file_storage_service.dart';
import '../services/telegram_service.dart';
import '../models/file_model.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final isLoading    = false.obs;
  final allFiles     = <CloudFile>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  void loadFiles() {
    allFiles.value = FileStorageService.instance.getAllFiles();
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

  Map<String, dynamic> get stats =>
      FileStorageService.instance.getStats();
}
