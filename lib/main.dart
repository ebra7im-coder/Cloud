// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'models/file_model.dart';
import 'screens/splash_screen.dart';
import 'screens/desktop_home_screen.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'bindings/app_bindings.dart';
import 'services/desktop_service.dart';
import 'services/storage_service.dart';
import 'utils/translations.dart';
import 'services/telegram_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // إخفاء شاشة البداية
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // تهيئة نافذة التطبيق
  await _initializeWindow();
  
  // تهيئة التخزين
  await _initializeStorage();
  
  // تهيئة خدمات سطح المكتب
  await _initializeDesktopServices();
  
  try {
    await TelegramService.instance.initialize();
  } catch (e) {
    debugPrint('Telegram Service Init error: $e');
  }

  runApp(const CloudGramApp());
  
  // إظهار التطبيق بعد التهيئة
  FlutterNativeSplash.remove();
}

Future<void> _initializeWindow() async {
  if (Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    
    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

Future<void> _initializeStorage() async {
  try {
    // استخدام مسار مخصص للتطبيق
    final appDir = await _getApplicationDirectory();
    Hive.init(appDir.path);
    
    Hive.registerAdapter(CloudFileAdapter());
    Hive.registerAdapter(FileTypeAdapter());
    
    await Hive.openBox<CloudFile>(AppConstants.filesBox);
    await Hive.openBox(AppConstants.settingsBox);
    await Hive.openBox(AppConstants.cacheBox);
  } catch (e) {
    debugPrint('خطأ في تهيئة التخزين: $e');
    rethrow;
  }
}

Future<Directory> _getApplicationDirectory() async {
  if (Platform.isWindows) {
    final appData = await getApplicationSupportDirectory();
    final appDir = Directory('${appData.path}/CloudVault');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  } else if (Platform.isLinux) {
    final home = Platform.environment['HOME'] ?? '';
    final appDir = Directory('$home/.config/cloudvault');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  } else {
    return await getApplicationDocumentsDirectory();
  }
}

Future<void> _initializeDesktopServices() async {
  if (Platform.isWindows || Platform.isLinux) {
    await DesktopService.instance.initialize();
    await StorageService.instance.initialize();
  }
}

class CloudGramApp extends StatelessWidget {
  const CloudGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'CloudVault Desktop',
          debugShowCheckedModeBanner: false,
          initialBinding: AppBindings(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          defaultTransition: Transition.cupertino,
          locale: const Locale('ar', 'SA'),
          fallbackLocale: const Locale('en', 'US'),
          translations: AppTranslations(),
          home: Platform.isWindows || Platform.isLinux 
              ? const DesktopHomeScreen()
              : const SplashScreen(),
          builder: (context, child) {
            if (Platform.isWindows || Platform.isLinux) {
              return DropTarget(
                onDragDone: (details) {
                  DesktopService.instance.handleDragDrop(details.files.map((f) => File(f.path)).toList());
                },
                child: child!,
              );
            }
            return child!;
          },
        );
      },
    );
  }
}
