import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import '../models/file_model.dart';
import '../services/telegram_service.dart';
import '../services/file_storage_service.dart';
import '../utils/constants.dart';

class MediaViewerScreen extends StatefulWidget {
  final CloudFile file;
  const MediaViewerScreen({super.key, required this.file});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  bool _loading = true;
  String? _localPath;
  String? _error;
  double _downloadProgress = 0;

  // Video
  VideoPlayerController? _videoCtrl;
  bool _videoPlaying = false;

  // Audio
  AudioPlayer? _audioPlayer;
  bool _audioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    if (widget.file.localPath != null &&
        File(widget.file.localPath!).existsSync()) {
      setState(() => _localPath = widget.file.localPath);
      await _initPlayer(_localPath!);
      return;
    }
    setState(() { _loading = true; _downloadProgress = 0; });
    try {
      final path = await TelegramService.instance.downloadFile(
        widget.file,
        onProgress: (p, s, t) => setState(() => _downloadProgress = p),
      );
      if (path != null) {
        await FileStorageService.instance.updateLocalPath(widget.file.id, path);
        setState(() => _localPath = path);
        await _initPlayer(path);
      } else {
        setState(() { _error = 'تعذر تحميل الملف'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _initPlayer(String path) async {
    switch (widget.file.type) {
      case FileType.video: await _initVideo(path); break;
      case FileType.audio: await _initAudio(path); break;
      default: setState(() => _loading = false);
    }
  }

  Future<void> _initVideo(String path) async {
    _videoCtrl = VideoPlayerController.file(File(path));
    await _videoCtrl!.initialize();
    _videoCtrl!.addListener(() {
      if (mounted) setState(() => _videoPlaying = _videoCtrl!.value.isPlaying);
    });
    await _videoCtrl!.play();
    setState(() => _loading = false);
  }

  Future<void> _initAudio(String path) async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer!.setFilePath(path);
    _audioDuration = _audioPlayer!.duration ?? Duration.zero;
    _audioPlayer!.positionStream.listen((p) {
      if (mounted) setState(() => _audioPosition = p);
    });
    _audioPlayer!.playerStateStream.listen((s) {
      if (mounted) setState(() => _audioPlaying = s.playing);
    });
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2,'0')}:'
      '${d.inSeconds.remainder(60).toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.file.name,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              widget.file.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: widget.file.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              await FileStorageService.instance.toggleFavorite(widget.file.id);
              setState(() {});
            },
          ),
        ],
      ),
      body: _loading ? _buildLoading() : _error != null ? _buildError() : _buildContent(),
    );
  }

  Widget _buildLoading() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 80, height: 80,
        child: CircularProgressIndicator(
          value: _downloadProgress > 0 ? _downloadProgress : null,
          color: AppConstants.primaryColor, strokeWidth: 4,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        _downloadProgress > 0
            ? 'جاري التحميل ${(_downloadProgress * 100).toInt()}%'
            : 'جاري التحميل...',
        style: TextStyle(color: Colors.grey[400]),
      ),
    ]),
  );

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: AppConstants.redColor, size: 60),
      const SizedBox(height: 12),
      Text(_error!, style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: _loadFile,
        icon: const Icon(Icons.refresh),
        label: const Text('إعادة المحاولة'),
        style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
      ),
    ]),
  );

  Widget _buildContent() {
    switch (widget.file.type) {
      case FileType.image:    return _buildImage();
      case FileType.video:    return _buildVideo();
      case FileType.audio:    return _buildAudio();
      default:                return _buildDoc();
    }
  }

  Widget _buildImage() => InteractiveViewer(
    child: Center(child: Image.file(File(_localPath!), fit: BoxFit.contain)),
  );

  Widget _buildVideo() {
    if (_videoCtrl == null || !_videoCtrl!.value.isInitialized) return const SizedBox();
    final dur = _videoCtrl!.value.duration;
    final pos = _videoCtrl!.value.position;
    return Column(children: [
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: _videoCtrl!.value.aspectRatio,
            child: VideoPlayer(_videoCtrl!),
          ),
        ),
      ),
      Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: [
          VideoProgressIndicator(_videoCtrl!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                  playedColor: AppConstants.primaryColor,
                  bufferedColor: Colors.grey)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_fmt(pos), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            IconButton(
              icon: Icon(_videoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 36),
              onPressed: () => _videoPlaying ? _videoCtrl!.pause() : _videoCtrl!.play(),
            ),
            Text(_fmt(dur), style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ]),
      ),
    ]);
  }

  Widget _buildAudio() => Center(
    child: Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 120, height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF673AB7)]),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 60),
        ),
        const SizedBox(height: 24),
        Text(widget.file.name,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Slider(
          value: _audioPosition.inSeconds.clamp(0, _audioDuration.inSeconds.clamp(1,9999)).toDouble(),
          max: _audioDuration.inSeconds.clamp(1, 9999).toDouble(),
          activeColor: AppConstants.primaryColor,
          onChanged: (v) => _audioPlayer?.seek(Duration(seconds: v.toInt())),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_fmt(_audioPosition), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          Text(_fmt(_audioDuration), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 32),
            onPressed: () => _audioPlayer?.seek(_audioPosition - const Duration(seconds: 10)),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _audioPlaying ? _audioPlayer?.pause() : _audioPlayer?.play(),
            child: Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: AppConstants.primaryColor, shape: BoxShape.circle),
              child: Icon(_audioPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 32),
            onPressed: () => _audioPlayer?.seek(_audioPosition + const Duration(seconds: 10)),
          ),
        ]),
      ]),
    ),
  );

  Widget _buildDoc() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.description_rounded, color: AppConstants.primaryColor, size: 80),
      const SizedBox(height: 16),
      Text(widget.file.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
      const SizedBox(height: 8),
      Text(widget.file.sizeFormatted, style: TextStyle(color: Colors.grey[400])),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.open_in_new_rounded),
        label: const Text('فتح الملف'),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white),
      ),
    ]),
  );
}
