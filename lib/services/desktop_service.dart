// services/desktop_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:system_tray/system_tray.dart';
import '../controllers/file_controller.dart';
import '../models/file_model.dart';

class DesktopService extends GetxService implements TrayListener {
  DesktopService._();
  static final DesktopService instance = DesktopService._();

  FileController get fileController => Get.find<FileController>();
  final SystemTray _systemTray = SystemTray();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _initializeTray();
      await _initializeHotkeys();
      await _initializeFileWatcher();
      _isInitialized = true;
      debugPrint('✅ خدمات سطح المكتب مهيأة');
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة خدمات سطح المكتب: $e');
    }
  }

  // MARK: - System Tray
  Future<void> _initializeTray() async {
    if (Platform.isWindows || Platform.isLinux) {
      final appIcon = Platform.isWindows 
          ? 'assets/icons/app_icon.ico'
          : 'assets/icons/app_icon.png';
      
      await _systemTray.initSystemTray(
        title: "CloudVault",
        iconPath: appIcon,
      );
      
      await _systemTray.setContextMenu([
        SystemMenuItem(label: 'فتح التطبيق', enabled: true),
        SystemMenuItem(label: 'رفع ملف', enabled: true),
        SystemMenuItem(label: 'مشاركة شاشة', enabled: true),
        SystemMenuItem.separator(),
        SystemMenuItem(label: 'الإعدادات', enabled: true),
        SystemMenuItem.separator(),
        SystemMenuItem(label: 'خروج', enabled: true),
      ]);
    }
  }

  // MARK: - TrayListener
  @override
  void onTrayIconClick() {
    _showApp();
  }

  @override
  void onTrayIconRightClick() {
    // Show menu on right click
  }

  @override
  void onTrayMenuItemClick(TrayEntry item) {
    switch (item.label) {
      case 'فتح التطبيق':
        _showApp();
        break;
      case 'رفع ملف':
        _uploadFile();
        break;
      case 'مشاركة شاشة':
        _shareScreen();
        break;
      case 'الإعدادات':
        Get.toNamed('/settings');
        break;
      case 'خروج':
        _exitApp();
        break;
    }
  }

  // MARK: - Hotkeys
  Future<void> _initializeHotkeys() async {
    if (!Platform.isWindows && !Platform.isLinux) return;
    
    try {
      await hotKeyManager.register(
        HotKey(
          key: KeyCode.space,
          modifiers: [KeyModifier.control, KeyModifier.shift],
          scope: HotKeyScope.system,
        ),
        onPress: () {
          _toggleAppVisibility();
        },
      );
      
      await hotKeyManager.register(
        HotKey(
          key: KeyCode.keyU,
          modifiers: [KeyModifier.control, KeyModifier.shift],
          scope: HotKeyScope.system,
        ),
        onPress: () {
          _uploadFile();
        },
      );
      
      await hotKeyManager.register(
        HotKey(
          key: KeyCode.keyS,
          modifiers: [KeyModifier.control, KeyModifier.shift],
          scope: HotKeyScope.system,
        ),
        onPress: () {
          _searchFiles();
        },
      );
      
      debugPrint('✅ مفاتيح الاختصار مهيأة');
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة مفاتيح الاختصار: $e');
    }
  }

  // MARK: - File Watcher
  Future<void> _initializeFileWatcher() async {
    // مراقبة المجلدات المحددة
    final watchPaths = [
      if (Platform.environment['HOME'] != null) Directory(Platform.environment['HOME']!),
      if (Platform.environment['USERPROFILE'] != null) Directory('${Platform.environment['USERPROFILE']}\\Desktop'),
    ];
    
    for (var dir in watchPaths) {
      try {
        if (await dir.exists()) {
          final watcher = dir.watch();
          watcher.listen((event) {
            _handleFileSystemEvent(event);
          });
        }
      } catch (e) {
        debugPrint('⚠️ خطأ في مراقبة المجلد: $e');
      }
    }
  }

  void _handleFileSystemEvent(FileSystemEvent event) {
    if (event is FileSystemCreateEvent || event is FileSystemModifyEvent) {
      // تحديث قائمة الملفات
      fileController.refreshFiles();
    }
  }

  // MARK: - Drag and Drop
  Future<void> handleDragDrop(List<File> files) async {
    try {
      final List<File> droppedFiles = [];
      
      for (var file in files) {
        if (await file.exists()) {
          droppedFiles.add(file);
        }
      }
      
      if (droppedFiles.isNotEmpty) {
        await fileController.uploadFiles(droppedFiles);
        Get.snackbar(
          'نجاح',
          'تم رفع ${droppedFiles.length} ملفات',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في رفع الملفات: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  // MARK: - Desktop Actions
  void _showApp() {
    if (Platform.isWindows || Platform.isLinux) {
      windowManager.show();
      windowManager.focus();
    }
  }

  void _toggleAppVisibility() {
    if (Platform.isWindows || Platform.isLinux) {
      windowManager.isVisible().then((visible) {
        if (visible) {
          windowManager.hide();
        } else {
          windowManager.show();
          windowManager.focus();
        }
      });
    }
  }

  void _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      
      if (result != null) {
        final files = result.paths.map((path) => File(path!)).toList();
        await fileController.uploadFiles(files);
      }
    } catch (e) {
      debugPrint('خطأ في رفع الملفات: $e');
    }
  }

  void _shareScreen() {
    // فتح شاشة مشاركة الشاشة
    Get.toNamed('/share-screen');
  }

  void _searchFiles() {
    Get.toNamed('/search');
  }

  void _exitApp() {
    if (Platform.isWindows || Platform.isLinux) {
      windowManager.close();
    } else {
      Get.back();
    }
  }
}
