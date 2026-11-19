
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AssetVideoPlayer extends StatefulWidget {
  final String assetPath;

  const AssetVideoPlayer({
    super.key,
    required this.assetPath,
  });

  @override
  State<AssetVideoPlayer> createState() => _AssetVideoPlayerState();
}

class _AssetVideoPlayerState extends State<AssetVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath);
    _controller.addListener(_videoListener);
    _initialize();
  }

  void _videoListener() {
    if (mounted) setState(() {});
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);

      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Video gagal dimuat.\nPeriksa format dan aset video.';
        });
      }
      debugPrint('Video initialization error: $e');
    }
  }

  Future<void> _togglePlayback() async {
    if (!_ready || _busy) return;

    setState(() => _busy = true);

    try {
      if (_controller.value.isPlaying) {
        await _controller.pause();
      } else {
        await _controller.play();
      }
    } catch (e) {
      debugPrint('Video playback error: $e');

      if (mounted) {
        setState(() {
          _error = 'Video tidak dapat diputar.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_ready) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio > 0
              ? _controller.value.aspectRatio
              : 1,
          child: VideoPlayer(_controller),
        ),
        IconButton(
          tooltip: _controller.value.isPlaying ? 'Pause' : 'Play',
          iconSize: 42,
          onPressed: _busy ? null : _togglePlayback,
          icon: _busy
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
        ),
      ],
    );
  }
}
