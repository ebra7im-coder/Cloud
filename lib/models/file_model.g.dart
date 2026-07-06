// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CloudFileAdapter extends TypeAdapter<CloudFile> {
  @override
  final int typeId = 1;

  @override
  CloudFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CloudFile(
      id: fields[0] as String,
      name: fields[1] as String,
      telegramFileId: fields[2] as String?,
      telegramMessageId: fields[3] as String?,
      sizeBytes: fields[4] as int,
      type: fields[5] as FileType,
      uploadedAt: fields[6] as DateTime,
      mimeType: fields[7] as String?,
      thumbnailFileId: fields[8] as String?,
      localPath: fields[9] as String?,
      folder: fields[10] as String?,
      isFavorite: fields[11] as bool,
      caption: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CloudFile obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.telegramFileId)
      ..writeByte(3)
      ..write(obj.telegramMessageId)
      ..writeByte(4)
      ..write(obj.sizeBytes)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.uploadedAt)
      ..writeByte(7)
      ..write(obj.mimeType)
      ..writeByte(8)
      ..write(obj.thumbnailFileId)
      ..writeByte(9)
      ..write(obj.localPath)
      ..writeByte(10)
      ..write(obj.folder)
      ..writeByte(11)
      ..write(obj.isFavorite)
      ..writeByte(12)
      ..write(obj.caption);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FileTypeAdapter extends TypeAdapter<FileType> {
  @override
  final int typeId = 0;

  @override
  FileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:  return FileType.image;
      case 1:  return FileType.video;
      case 2:  return FileType.audio;
      case 3:  return FileType.document;
      default: return FileType.other;
    }
  }

  @override
  void write(BinaryWriter writer, FileType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
