import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/file_controller.dart';
import '../services/storage_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StorageService>(() => StorageService());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<FileController>(() => FileController());
  }
}
