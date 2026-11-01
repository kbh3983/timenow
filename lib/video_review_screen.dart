import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:video_player/video_player.dart';

import 'album_service.dart';
import 'calendar_album_screen.dart';

class VideoReviewScreen extends StatefulWidget {
  final File videoFile;
  final String initialAlbum;
  final DateTime captureTime;

  const VideoReviewScreen({
    super.key,
    required this.videoFile,
    required this.initialAlbum,
    required this.captureTime,
  });

  @override
  State<VideoReviewScreen> createState() => _VideoReviewScreenState();
}

class _VideoReviewScreenState extends State<VideoReviewScreen> {
  late VideoPlayerController _videoController;
  late String _selectedAlbum;
  List<String> _albumList = [];
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedAlbum = widget.initialAlbum;
    _initVideo();
    _loadAlbums();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.file(widget.videoFile);
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.play();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Video initialize error: $e');
    }
  }

  Future<void> _loadAlbums() async {
    final albums = await AlbumService.getAlbums();
    if (mounted) {
      setState(() => _albumList = albums);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _saveVideo() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // 1. 시스템 갤러리에 저장
      await Gal.putVideo(widget.videoFile.path, album: 'Timenow');

      // 2. 앱 앨범에 저장
      await AlbumService.saveVideo(
        widget.videoFile,
        _selectedAlbum,
        originalDate: widget.captureTime,
      );

      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CalendarAlbumScreen(initialAlbum: _selectedAlbum),
          ),
        );
        if (mounted) {
          Navigator.pop(context, result is String ? result : _selectedAlbum);
        }
      }
    } catch (e) {
      debugPrint('Video save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동영상 저장 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 비디오 플레이어
          if (_isInitialized)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoController.value.isPlaying) {
                    _videoController.pause();
                  } else {
                    _videoController.play();
                  }
                });
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_videoController),
                      if (!_videoController.value.isPlaying)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFC6FF00)),
            ),

          // 2. 상단 바
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 닫기 / 뒤로가기
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                // 앨범 선택 드롭다운 캡슐
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedAlbum,
                      dropdownColor: const Color(0xFF1E2129),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _albumList.map((album) {
                        return DropdownMenuItem<String>(
                          value: album,
                          child: Text(album),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedAlbum = val);
                        }
                      },
                    ),
                  ),
                ),

                // 저장 버튼
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveVideo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC6FF00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
