import 'package:flutter/material.dart';

class AppConstants {
  // ── Telegram ──────────────────────────────────────────────────
  static const String botToken = '8993813907:AAEDilniSH02BlvOOuympGqGrUBVqrED48A';
  static const String chatId   = '7206282732';
  static const String telegramApiBase  = 'https://api.telegram.org/bot$botToken';
  static const String telegramFileBase = 'https://api.telegram.org/file/bot$botToken';

  // ── Hive ──────────────────────────────────────────────────────
  static const String filesBox    = 'cloud_files';
  static const String settingsBox = 'settings';
  static const String cacheBox    = 'cache';

  // ── Colors ────────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF2AABEE);
  static const Color primaryLight   = Color(0xFF4DB8F4);
  static const Color gradientStart  = Color(0xFF2AABEE);
  static const Color gradientEnd    = Color(0xFF1A8AC0);
  static const Color bgDark         = Color(0xFF17212B);
  static const Color cardDark       = Color(0xFF232E3C);
  static const Color greenColor     = Color(0xFF4CAF50);
  static const Color redColor       = Color(0xFFEF5350);
  static const Color orangeColor    = Color(0xFFFF9800);
  static const Color purpleColor    = Color(0xFF9C27B0);
}
