import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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

  // Video
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;

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
    // Check local path first
    if (widget.file.localPath != null &&
        File(widget.file.localPath!).existsSync()) {
      setState(() => _localPath = widget.file.localPath);
      _initPlayer(_localPath!);
      return;
    }

    // Download from Telegram
    setState(() => _loading = true);
    try {
      final path = await TelegramService.instance.downloadFile(
        widget.file,
        onProgress: (p, s, t) {},
      );
      if (path != null) {
        await FileStorageService.instance.updateLocalPath(widget.file.id, path);
        setState(() => _localPath = path);
        _initPlayer(path);
      } else {
        setState(() { _error = 'تعذر تحميل الملف'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _initPlayer(String path) {
    switch (widget.file.type) {
      case FileType.video:
        _initVideo(path);
        break;
      case FileType.audio:
        _initAudio(path);
        break;
      default:
        setState(() => _loading = false);
    }
  }

  Future<void> _initVideo(String path) async {
    _videoCtrl = VideoPlayerController.file(File(path));
    await _videoCtrl!.initialize();
    _chewieCtrl = ChewieController(
      videoPlayerController: _videoCtrl!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppConstants.primaryColor,
        handleColor: AppConstants.primaryColor,
      ),
    );
    setState(() => _loading = false);
  }

  Future<void> _initAudio(String path) async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer!.setFilePath(path);
    _audioDuration = _audioPlayer!.duration ?? Duration.zero;
    _audioPlayer!.positionStream.listen((pos) {
      setState(() => _audioPosition = pos);
    });
    _audioPlayer!.playerStateStream.listen((state) {
      setState(() => _audioPlaying = state.playing);
    });
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _chewieCtrl?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.file.name,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            overflow: TextOverflow.ellipsis),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              widget.file.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: widget.file.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              await FileStorageService.instance.toggleFavorite(widget.file.id);
              setState(() {});
            },
          ),
        ],
      ),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppConstants.primaryColor),
          const SizedBox(height: 16),
          Text('جاري التحميل...',
              style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppConstants.redColor, size: 60),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadFile,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.file.type) {
      case FileType.image:  return _buildImageView();
      case FileType.video:  return _buildVideoView();
      case FileType.audio:  return _buildAudioView();
      default:              return _buildDocView();
    }
  }

  Widget _buildImageView() {
    return InteractiveViewer(
      child: Center(
        child: Image.file(File(_localPath!), fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildVideoView() {
    if (_chewieCtrl == null) return const SizedBox();
    return Center(child: Chewie(controller: _chewieCtrl!));
  }

  Widget _buildAudioView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConstants.cardDark,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            Text(widget.file.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Slider(
              value: _audioPosition.inSeconds.toDouble(),
              max: _audioDuration.inSeconds.toDouble().clamp(1, double.infinity),
              activeColor: AppConstants.primaryColor,
              onChanged: (v) {
                _audioPlayer?.seek(Duration(seconds: v.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_audioPosition),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  Text(_formatDuration(_audioDuration),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _audioPlayer?.seek(
                    _audioPosition - const Duration(seconds: 10)),
                  icon: const Icon(Icons.replay_10_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    if (_audioPlaying) {
                      _audioPlayer?.pause();
                    } else {
                      _audioPlayer?.play();
                    }
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _audioPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _audioPlayer?.seek(
                    _audioPosition + const Duration(seconds: 10)),
                  icon: const Icon(Icons.forward_10_rounded,
                      color: Colors.white, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description_rounded,
              color: AppConstants.primaryColor, size: 80),
          const SizedBox(height: 16),
          Text(widget.file.name,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          Text(widget.file.sizeFormatted,
              style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              // Open with system app
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('فتح الملف'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
