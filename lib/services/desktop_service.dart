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
import '../controllers/file_controller.dart';
import '../models/file_model.dart';

class DesktopService extends GetxService with TrayListener {
  DesktopService._();
  static final DesktopService instance = DesktopService._();

  FileController get fileController => Get.find<FileController>();
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
      
      await trayManager.setIcon(appIcon);
      
      final menu = Menu(
        items: [
          MenuItem(key: 'open_app', label: 'فتح التطبيق'),
          MenuItem(key: 'upload_file', label: 'رفع ملف'),
          MenuItem(key: 'share_screen', label: 'مشاركة شاشة'),
          MenuItem.separator(),
          MenuItem(key: 'settings', label: 'الإعدادات'),
          MenuItem.separator(),
          MenuItem(key: 'exit', label: 'خروج'),
        ],
      );
      
      await trayManager.setContextMenu(menu);
      trayManager.addListener(this);
    }
  }

  // MARK: - TrayListener
  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    // Show menu on right click
  }

  @override
  void onTrayMenuItemClick(MenuItem item) {
    switch (item.key) {
      case 'open_app':
        _showApp();
        break;
      case 'upload_file':
        _uploadFile();
        break;
      case 'share_screen':
        _shareScreen();
        break;
      case 'settings':
        Get.toNamed('/settings');
        break;
      case 'exit':
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
          KeyCode.space,
          modifiers: [KeyModifier.control, KeyModifier.shift],
          scope: HotKeyScope.system,
        ),
        keyDownHandler: (hotKey) {
          _toggleAppVisibility();
        },
      );
      
      await hotKeyManager.register(
        HotKey(
          KeyCode.keyU,
          modifiers: [KeyModifier.control, KeyModifier.shift],
          scope: HotKeyScope.system,
        ),
        keyDownHandler: (hotKey) {
          _uploadFile();
        },
      );
      
      await hotKeyManager.register(
        HotKey(
          KeyCode.keyS,
          modifiers: [KeyModifier.control, KeyModifier.shift],
          scope: HotKeyScope.system,
        ),
        keyDownHandler: (hotKey) {
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
