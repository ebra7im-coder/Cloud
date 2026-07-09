// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'models/file_model.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'bindings/app_bindings.dart';
import 'utils/translations.dart';
import 'services/telegram_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await _initializeStorage();
  
  try {
    await TelegramService.instance.initialize();
  } catch (e) {
    debugPrint('Telegram Service Init error: $e');
  }
  
  runApp(const CloudGramApp());
}

Future<void> _initializeStorage() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CloudFileAdapter());
  Hive.registerAdapter(FileTypeAdapter());
  await Hive.openBox<CloudFile>(AppConstants.filesBox);
  await Hive.openBox(AppConstants.settingsBox);
}

class CloudGramApp extends StatelessWidget {
  const CloudGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'CloudVault',
          debugShowCheckedModeBanner: false,
          initialBinding: AppBindings(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          defaultTransition: Transition.cupertino,
          locale: const Locale('ar', 'SA'),
          fallbackLocale: const Locale('en', 'US'),
          translations: AppTranslations(),
          home: const SplashScreen(),
        );
      },
    );
  }
}
