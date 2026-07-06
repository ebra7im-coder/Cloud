import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/file_model.dart';
import '../services/file_storage_service.dart';
import '../utils/constants.dart';
import '../widgets/file_card.dart';
import '../widgets/file_grid_card.dart';

class FilesScreen extends StatefulWidget {
  final FileType? filterType;
  const FilesScreen({super.key, this.filterType});
  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isGrid = false;
  String _sort = 'date';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    if (widget.filterType != null) {
      _tabCtrl.index = widget.filterType!.index + 1;
    }
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  List<CloudFile> _files(FileType? type) {
    final list = type == null
        ? FileStorageService.instance.getAllFiles()
        : FileStorageService.instance.getByType(type);
    switch (_sort) {
      case 'name': list.sort((a, b) => a.name.compareTo(b.name)); break;
      case 'size': list.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes)); break;
      default:     list.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      appBar: AppBar(
        backgroundColor: AppConstants.bgDark,
        elevation: 0,
        automaticallyImplyLeading: widget.filterType != null,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('ملفاتي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.list_rounded : Icons.grid_view_rounded,
                color: Colors.white70),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: Colors.white70),
            color: AppConstants.cardDark,
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => [
              _menuItem('date', 'حسب التاريخ'),
              _menuItem('name', 'حسب الاسم'),
              _menuItem('size', 'حسب الحجم'),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: AppConstants.primaryColor,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: '🖼 صور'),
            Tab(text: '🎥 فيديو'),
            Tab(text: '🎵 موسيقى'),
            Tab(text: '📄 ملفات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [null, FileType.image, FileType.video, FileType.audio, FileType.document]
            .map((t) => _fileList(t))
            .toList(),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String v, String l) => PopupMenuItem(
      value: v, child: Text(l, style: const TextStyle(color: Colors.white)));

  Widget _fileList(FileType? type) {
    final files = _files(type);
    if (files.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.folder_open_rounded, size: 70, color: Colors.grey[700]),
          const SizedBox(height: 14),
          Text('لا توجد ملفات',
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ]),
      );
    }
    if (_isGrid && (type == FileType.image || type == null)) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
        itemCount: files.length,
        itemBuilder: (_, i) =>
            FileGridCard(file: files[i], onRefresh: () => setState(() {})),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: files.length,
      itemBuilder: (_, i) =>
          FileCard(file: files[i], onRefresh: () => setState(() {})),
    );
  }
}
