import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/file_model.dart';
import 'screens/splash_screen.dart';
import 'services/telegram_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(CloudFileAdapter());
  Hive.registerAdapter(FileTypeAdapter());
  await Hive.openBox<CloudFile>(AppConstants.filesBox);
  await Hive.openBox(AppConstants.settingsBox);

  await TelegramService.instance.initialize();

  runApp(const CloudGramApp());
}

class CloudGramApp extends StatelessWidget {
  const CloudGramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CloudGram',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2AABEE),
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.cairoTextTheme(),
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2AABEE),
        brightness: Brightness.dark,
        surface: const Color(0xFF17212B),
        surfaceContainer: const Color(0xFF232E3C),
      ),
      scaffoldBackgroundColor: const Color(0xFF17212B),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF17212B),
      ),
      cardTheme: const CardTheme(
        color: Color(0xFF232E3C),
        elevation: 0,
      ),
    );
  }
}
