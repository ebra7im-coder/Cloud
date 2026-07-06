import 'package:flutter/material.dart';

class AppConstants {
  // ── Telegram Config ──────────────────────────────────────────────
  static const String botToken = '8993813907:AAEDilniSH02BlvOOuympGqGrUBVqrED48A';
  static const String chatId   = '7206282732';
  static const String telegramApiBase  = 'https://api.telegram.org/bot$botToken';
  static const String telegramFileBase = 'https://api.telegram.org/file/bot$botToken';

  // ── Hive Boxes ───────────────────────────────────────────────────
  static const String filesBox    = 'cloud_files';
  static const String settingsBox = 'settings';

  // ── File Size Limits ─────────────────────────────────────────────
  static const int maxFileSizeBytes = 2 * 1024 * 1024 * 1024;

  // ── Supported Extensions ─────────────────────────────────────────
  static const List<String> imageExtensions  = ['jpg','jpeg','png','gif','webp','bmp','heic','heif'];
  static const List<String> videoExtensions  = ['mp4','mkv','avi','mov','wmv','flv','webm','m4v','3gp'];
  static const List<String> audioExtensions  = ['mp3','aac','ogg','flac','wav','m4a','opus','wma'];
  static const List<String> docExtensions    = ['pdf','doc','docx','xls','xlsx','ppt','pptx','txt','zip','rar'];

  // ── UI Colors ─────────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF2AABEE);
  static const Color secondaryColor = Color(0xFF229ED9);
  static const Color bgDark         = Color(0xFF17212B);
  static const Color cardDark       = Color(0xFF232E3C);
  static const Color greenColor     = Color(0xFF4CAF50);
  static const Color redColor       = Color(0xFFEF5350);
  static const Color orangeColor    = Color(0xFFFF9800);
  static const Color purpleColor    = Color(0xFF9C27B0);
}
