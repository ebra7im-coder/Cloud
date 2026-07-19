import 'package:hive/hive.dart';

part 'file_model.g.dart';

@HiveType(typeId: 0)
enum FileType {
  @HiveField(0)
  image,
  @HiveField(1)
  video,
  @HiveField(2)
  audio,
  @HiveField(3)
  document,
  @HiveField(4)
  other,
}

@HiveType(typeId: 1)
class CloudFile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? telegramFileId;

  @HiveField(3)
  String? telegramMessageId;

  @HiveField(4)
  int sizeBytes;

  @HiveField(5)
  FileType type;

  @HiveField(6)
  DateTime uploadedAt;

  @HiveField(7)
  String? mimeType;

  @HiveField(8)
  String? thumbnailFileId;

  @HiveField(9)
  String? localPath;

  @HiveField(10)
  String? folder;

  @HiveField(11)
  bool isFavorite;

  @HiveField(12)
  String? caption;

  CloudFile({
    required this.id,
    required this.name,
    this.telegramFileId,
    this.telegramMessageId,
    required this.sizeBytes,
    required this.type,
    required this.uploadedAt,
    this.mimeType,
    this.thumbnailFileId,
    this.localPath,
    this.folder,
    this.isFavorite = false,
    this.caption,
  });

  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get typeLabel {
    switch (type) {
      case FileType.image:    return 'صورة';
      case FileType.video:    return 'فيديو';
      case FileType.audio:    return 'موسيقى';
      case FileType.document: return 'مستند';
      case FileType.other:    return 'ملف';
    }
  }

  String get size => sizeFormatted;

  String get modifiedDate => '${uploadedAt.year}/${uploadedAt.month.toString().padLeft(2, '0')}/${uploadedAt.day.toString().padLeft(2, '0')}';

  String get typeString {
    switch (type) {
      case FileType.image:    return 'image';
      case FileType.video:    return 'video';
      case FileType.audio:    return 'music';
      case FileType.document: return 'document';
      default:                return 'document';
    }
  }

  static FileType detectType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    if (['jpg','jpeg','png','gif','webp','bmp','heic','heif'].contains(ext)) return FileType.image;
    if (['mp4','mkv','avi','mov','wmv','flv','webm','m4v','3gp'].contains(ext)) return FileType.video;
    if (['mp3','aac','ogg','flac','wav','m4a','opus','wma'].contains(ext)) return FileType.audio;
    if (['pdf','doc','docx','xls','xlsx','ppt','pptx','txt','zip','rar'].contains(ext)) return FileType.document;
    return FileType.other;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'telegramFileId': telegramFileId,
    'telegramMessageId': telegramMessageId,
    'sizeBytes': sizeBytes,
    'type': type.index,
    'uploadedAt': uploadedAt.toIso8601String(),
    'mimeType': mimeType,
    'thumbnailFileId': thumbnailFileId,
    'localPath': localPath,
    'folder': folder,
    'isFavorite': isFavorite,
    'caption': caption,
  };

  factory CloudFile.fromJson(Map<String, dynamic> json) => CloudFile(
    id: json['id'],
    name: json['name'],
    telegramFileId: json['telegramFileId'],
    telegramMessageId: json['telegramMessageId'],
    sizeBytes: json['sizeBytes'],
    type: FileType.values[json['type']],
    uploadedAt: DateTime.parse(json['uploadedAt']),
    mimeType: json['mimeType'],
    thumbnailFileId: json['thumbnailFileId'],
    localPath: json['localPath'],
    folder: json['folder'],
    isFavorite: json['isFavorite'] ?? false,
    caption: json['caption'],
  );
}
