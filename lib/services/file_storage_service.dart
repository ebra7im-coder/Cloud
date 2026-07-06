import 'package:hive/hive.dart';
import '../models/file_model.dart';
import '../utils/constants.dart';

class FileStorageService {
  FileStorageService._();
  static final FileStorageService instance = FileStorageService._();

  Box<CloudFile> get _box => Hive.box<CloudFile>(AppConstants.filesBox);

  // ── Save file ────────────────────────────────────────────────────
  Future<void> saveFile(CloudFile file) async {
    await _box.put(file.id, file);
  }

  // ── Get all files ────────────────────────────────────────────────
  List<CloudFile> getAllFiles() {
    return _box.values.toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  // ── Get by type ──────────────────────────────────────────────────
  List<CloudFile> getByType(FileType type) {
    return _box.values
        .where((f) => f.type == type)
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  // ── Get favorites ────────────────────────────────────────────────
  List<CloudFile> getFavorites() {
    return _box.values
        .where((f) => f.isFavorite)
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  // ── Get by folder ────────────────────────────────────────────────
  List<CloudFile> getByFolder(String folder) {
    return _box.values
        .where((f) => (f.folder ?? 'root') == folder)
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  // ── Get all folders ──────────────────────────────────────────────
  List<String> getFolders() {
    final folders = _box.values
        .map((f) => f.folder ?? 'root')
        .toSet()
        .toList();
    folders.sort();
    return folders;
  }

  // ── Search ───────────────────────────────────────────────────────
  List<CloudFile> search(String query) {
    final q = query.toLowerCase();
    return _box.values
        .where((f) => f.name.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  // ── Toggle favorite ──────────────────────────────────────────────
  Future<void> toggleFavorite(String id) async {
    final file = _box.get(id);
    if (file != null) {
      file.isFavorite = !file.isFavorite;
      await file.save();
    }
  }

  // ── Delete ───────────────────────────────────────────────────────
  Future<void> deleteFile(String id) async {
    await _box.delete(id);
  }

  // ── Stats ────────────────────────────────────────────────────────
  Map<String, dynamic> getStats() {
    final all  = _box.values.toList();
    int total  = all.length;
    int images = all.where((f) => f.type == FileType.image).length;
    int videos = all.where((f) => f.type == FileType.video).length;
    int audios = all.where((f) => f.type == FileType.audio).length;
    int docs   = all.where((f) => f.type == FileType.document).length;
    int size   = all.fold(0, (sum, f) => sum + f.sizeBytes);

    return {
      'total':  total,
      'images': images,
      'videos': videos,
      'audios': audios,
      'docs':   docs,
      'size':   size,
    };
  }

  // ── Sync remote list ─────────────────────────────────────────────
  Future<void> syncFiles(List<CloudFile> remoteFiles) async {
    for (final file in remoteFiles) {
      if (!_box.containsKey(file.id)) {
        await _box.put(file.id, file);
      }
    }
  }

  // ── Update local path after download ─────────────────────────────
  Future<void> updateLocalPath(String id, String path) async {
    final file = _box.get(id);
    if (file != null) {
      file.localPath = path;
      await file.save();
    }
  }
}
