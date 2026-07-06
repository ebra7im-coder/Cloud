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
  late TabController _tabController;
  bool _isGrid = false;
  String _sortBy = 'date'; // date | name | size
  final _storage = FileStorageService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    if (widget.filterType != null) {
      _tabController.index = widget.filterType!.index + 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CloudFile> _getFiles(FileType? type) {
    List<CloudFile> files;
    if (type == null) {
      files = _storage.getAllFiles();
    } else {
      files = _storage.getByType(type);
    }
    switch (_sortBy) {
      case 'name': files.sort((a, b) => a.name.compareTo(b.name)); break;
      case 'size': files.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes)); break;
      default:     files.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    }
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      appBar: AppBar(
        backgroundColor: AppConstants.bgDark,
        title: const Text('ملفاتي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.list_rounded : Icons.grid_view_rounded,
                color: Colors.white),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            color: AppConstants.cardDark,
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'date',
                  child: Text('حسب التاريخ', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'name',
                  child: Text('حسب الاسم', style: TextStyle(color: Colors.white))),
              const PopupMenuItem(value: 'size',
                  child: Text('حسب الحجم', style: TextStyle(color: Colors.white))),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppConstants.primaryColor,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.grey,
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
        controller: _tabController,
        children: [
          _buildFileList(null),
          _buildFileList(FileType.image),
          _buildFileList(FileType.video),
          _buildFileList(FileType.audio),
          _buildFileList(FileType.document),
        ],
      ),
    );
  }

  Widget _buildFileList(FileType? type) {
    final files = _getFiles(type);

    if (files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 70, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('لا توجد ملفات هنا',
                style: TextStyle(color: Colors.grey[400], fontSize: 16)),
          ],
        ),
      );
    }

    if (_isGrid && (type == FileType.image || type == null)) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: files.length,
        itemBuilder: (_, i) => FileGridCard(
          file: files[i],
          onRefresh: () => setState(() {}),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: files.length,
      itemBuilder: (_, i) => FileCard(
        file: files[i],
        onRefresh: () => setState(() {}),
      ),
    );
  }
}
