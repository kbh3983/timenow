import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:video_player/video_player.dart';

import 'album_service.dart';
import 'calendar_album_screen.dart';
import 'gallery_picker_screen.dart';
import 'stamp_management_screen.dart';
import 'settings_screen.dart';
import 'package:flutter/services.dart';
import 'services/video_processing_service.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/ad_banner_widget.dart';
import 'ux_config.dart';
import 'services/app_settings_service.dart';

class VideoReviewScreen extends StatefulWidget {
  final File videoFile;
  final String initialAlbum;
  final DateTime captureTime;
  final double? aspectRatio;
  final bool mirrorHorizontally;

  const VideoReviewScreen({
    super.key,
    required this.videoFile,
    required this.initialAlbum,
    required this.captureTime,
    this.aspectRatio,
    this.mirrorHorizontally = false,
  });

  @override
  State<VideoReviewScreen> createState() => _VideoReviewScreenState();
}

class _VideoReviewScreenState extends State<VideoReviewScreen>
    with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  late String _selectedAlbum;
  List<String> _albumList = [];
  File? _latestPhoto;
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedAlbum = widget.initialAlbum;
    _initVideo();
    _loadAlbums();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isInitialized && _videoController.value.isPlaying) {
        _videoController.pause();
      }
    }
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.file(
      widget.videoFile,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      // 오디오 트랙 및 ExoPlayer 버퍼 초기화 하드웨어 팝 방지:
      // 무음(0.0)으로 재생 시작 후 120ms 뒤 정상 볼륨(1.0)으로 부드럽게 복구
      await _videoController.setVolume(0.0);
      await _videoController.play();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted && _videoController.value.isInitialized) {
          _videoController.setVolume(1.0);
        }
      });
    } catch (e) {
      debugPrint('Video initialize error: $e');
    }
  }

  Future<void> _loadAlbums() async {
    final albums = await AlbumService.getAlbums();
    final allPhotos = await AlbumService.getAllPhotos(albumName: '전체');
    if (mounted) {
      setState(() {
        _albumList = albums;
        if (allPhotos.isNotEmpty) {
          _latestPhoto = allPhotos.first;
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _saveVideo() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    // 저장 처리 시작과 동시에 영상 재생 즉시 일시정지 (소리 중복 방지)
    try {
      if (_isInitialized && _videoController.value.isPlaying) {
        await _videoController.pause();
        if (mounted) setState(() {});
      }
    } catch (_) {}

    try {
      File fileToSave = widget.videoFile;

      // 전면 카메라 좌우 반전(거울 모드)이 아직 처리되지 않은 경우에만 처리
      // (비율 크롭 및 오디오 팝 제거는 VideoReviewScreen 진입 전에 이미 완료됨)
      if (widget.mirrorHorizontally) {
        fileToSave = await VideoProcessingService().processRecordedVideo(
          rawVideoFile: widget.videoFile,
          mirrorHorizontally: widget.mirrorHorizontally,
        );
      }

      // 1. 시스템 갤러리에 저장
      await Gal.putVideo(fileToSave.path, album: 'LOG');

      // 2. 앱 앨범에 저장
      await AlbumService.saveVideo(
        fileToSave,
        _selectedAlbum,
        originalDate: widget.captureTime,
      );

      if (mounted) {
        // 앨범 화면 진입 전 확실하게 비디오 일시정지
        if (_isInitialized && _videoController.value.isPlaying) {
          await _videoController.pause();
        }
        if (!mounted) return;

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarAlbumScreen(
              initialAlbum: _selectedAlbum,
              initialDate: widget.captureTime,
            ),
          ),
        );
        if (mounted) {
          Navigator.pop(context, result is String ? result : true);
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
    final double ratioVal = widget.aspectRatio ?? (9.0 / 16.0);
    final bool isFullAuto = (ratioVal - (9.0 / 16.0)).abs() < 0.01;

    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final settings = AppSettingsService();
        return Scaffold(
          backgroundColor: settings.scaffoldBackgroundColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildVideoPlayer(),
              _buildTopBar(),
              _buildBottomControls(isFullAuto: isFullAuto),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: Container(
        // 상단 메뉴 영역(60) 안에 배너(50)가 들어가도록 세로 여백 5
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: const Center(
          child: AdBannerWidget(compact: true),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        final topPadding = MediaQuery.of(context).padding.top;
        final topMenuH = topPadding + 60;

        final double ratioVal = widget.aspectRatio ?? (9.0 / 16.0);
        final bool isFullAuto = (ratioVal - (9.0 / 16.0)).abs() < 0.01;
        final bool is4x5 = (ratioVal - (4.0 / 5.0)).abs() < 0.01 ||
            (ratioVal - 0.8).abs() < 0.01;

        double clearW = screenW;
        double clearH;
        double clearTop;
        double clearLeft = 0;

        if (isFullAuto) {
          clearTop = topMenuH;
          clearW = screenW;
          clearH = screenW * (16.0 / 9.0);
          final maxH = screenH - topMenuH;
          if (clearH > maxH) {
            clearH = maxH;
            clearW = maxH * (9.0 / 16.0);
            clearLeft = (screenW - clearW) / 2;
          }
        } else if (is4x5) {
          clearW = screenW;
          clearH = screenW * 1.25;
          clearTop = topMenuH;
        } else {
          // 1:1
          clearW = screenW;
          clearH = screenW;
          clearTop = topMenuH;
        }

        return Stack(
          children: [
            Positioned(
              top: clearTop,
              left: clearLeft,
              width: clearW,
              height: clearH,
              child: ClipRect(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
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
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController.value.size.width > 0
                                  ? _videoController.value.size.width
                                  : 1080,
                              height: _videoController.value.size.height > 0
                                  ? _videoController.value.size.height
                                  : 1920,
                              child: widget.mirrorHorizontally
                                  ? Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: VideoPlayer(_videoController),
                                    )
                                  : VideoPlayer(_videoController),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: CircularProgressIndicator(
                            color: AppSettingsService().accentColor,
                          ),
                        ),

                      if (_isInitialized && !_videoController.value.isPlaying)
                        IgnorePointer(
                          child: Center(
                            child: Container(
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
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: topMenuH + screenW - 56,
              child: _buildBackHoverButton(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackHoverButton() {
    final settings = AppSettingsService();
    final isLight = settings.isLight;

    final bgColor = isLight
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.4);
    final borderColor = isLight
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.24);
    final fgColor = isLight ? const Color(0xFF1E2026) : Colors.white;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        if (_isInitialized && _videoController.value.isPlaying) {
          await _videoController.pause();
        }
        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: fgColor,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls({required bool isFullAuto}) {
    return Positioned(
      bottom: SharedUX.stackBottomOffset + MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAlbumSelector(isOverlay: !isFullAuto),
          const SizedBox(height: 38),
          _buildFloatingMenu(isOverlay: !isFullAuto),
        ],
      ),
    );
  }

  Widget _buildAlbumSelector({required bool isOverlay}) {
    final settings = AppSettingsService();
    final isLight = settings.isLight;

    return SizedBox(
      height: ReviewUX.albumSelectorHeight,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _albumList.length,
          itemBuilder: (context, index) {
            final album = _albumList[index];
            final isSelected = _selectedAlbum == album;

            final unselectedBg = isLight
                ? Colors.black.withValues(alpha: 0.06)
                : ReviewUX.albumButtonBg;
            final unselectedTextColor = isLight
                ? const Color(0xFF4B5563)
                : ReviewUX.albumButtonText;
            final selectedBorder = isLight
                ? Colors.black.withValues(alpha: 0.12)
                : Colors.white24;

            return GestureDetector(
              onTap: () => setState(() => _selectedAlbum = album),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: ReviewUX.albumButtonMarginHorizontal,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: ReviewUX.albumButtonHorizontalPadding,
                  vertical: ReviewUX.albumButtonVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ReviewUX.albumButtonSelectedBg
                      : unselectedBg,
                  borderRadius:
                      BorderRadius.circular(ReviewUX.albumButtonBorderRadius),
                  border: Border.all(
                    color: isSelected ? selectedBorder : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    album,
                    style: TextStyle(
                      color: isSelected
                          ? ReviewUX.albumButtonSelectedText
                          : unselectedTextColor,
                      fontSize: ReviewUX.albumButtonFontSize,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingMenu({required bool isOverlay}) {
    return CustomBottomNavBar(
      onSettingsPressed: () async {
        HapticFeedback.lightImpact();
        if (_isInitialized && _videoController.value.isPlaying) {
          await _videoController.pause();
          if (mounted) setState(() {});
        }
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        if (mounted && _isInitialized) {
          _videoController.play();
          setState(() {});
        }
      },
      onPhotoPickerPressed: () async {
        if (_isInitialized && _videoController.value.isPlaying) {
          await _videoController.pause();
          if (mounted) setState(() {});
        }
        if (!mounted) return;
        final GalleryResult? galleryResult =
            await Navigator.push<GalleryResult>(
          context,
          MaterialPageRoute(
            builder: (context) => const GalleryPickerScreen(),
          ),
        );
        if (galleryResult != null && mounted) {
          Navigator.pop(context, galleryResult);
        } else if (mounted && _isInitialized) {
          _videoController.play();
          setState(() {});
        }
      },
      onAlbumPressed: () async {
        if (_isInitialized && _videoController.value.isPlaying) {
          await _videoController.pause();
          if (mounted) setState(() {});
        }
        if (!mounted) return;
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarAlbumScreen(
              initialAlbum: _selectedAlbum,
              initialDate: widget.captureTime,
            ),
          ),
        );
        if (mounted && result is String) {
          Navigator.pop(context, result);
        } else if (mounted && _isInitialized) {
          _videoController.play();
          setState(() {});
        }
      },
      onStampManagementPressed: () async {
        HapticFeedback.lightImpact();
        if (_isInitialized && _videoController.value.isPlaying) {
          await _videoController.pause();
          if (mounted) setState(() {});
        }
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const StampManagementScreen(),
          ),
        );
        if (mounted && _isInitialized) {
          _videoController.play();
          setState(() {});
        }
      },
      onCenterActionPressed: _saveVideo,
      photoThumbnail: _latestPhoto,
      isLoading: _isSaving,
      centerIcon: Icons.check,
      isReviewScreen: true,
    );
  }
}
