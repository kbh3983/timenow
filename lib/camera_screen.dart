import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'timestamp_overlays.dart';
import 'timestamp_metadata.dart';
import 'calendar_album_screen.dart';
import 'album_service.dart';
import 'photo_review_screen.dart';
import 'video_review_screen.dart';
import 'services/video_processing_service.dart';
import 'services/timestamp_access_manager.dart';
import 'services/timestamp_deck_manager.dart';
import 'widgets/unlock_timestamp_dialog.dart';
import 'widgets/bottom_nav_bar.dart';
import 'ux_config.dart';
import 'gallery_picker_screen.dart';
import 'stamp_management_screen.dart';

enum CameraCaptureMode { photo, video }

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  CameraAspectRatio _aspectRatio = CameraAspectRatio.ratio1x1;
  TimestampDesign _currentDesign = TimestampDesign.n1_1;
  Alignment _currentAlignment = CameraUX.defaultAlignment;
  final double _overlayOpacity = 1.0;
  String _currentAlbum = '일상';
  bool _isCapturing = false;

  // Video recording state
  CameraCaptureMode _captureMode = CameraCaptureMode.photo;
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  int _recordDurationSeconds = 0;
  Timer? _recordDurationTimer;
  bool _isProcessingVideo = false;
  String _processingStatus = '';

  FlashMode _flashMode = FlashMode.off;
  int _timerSeconds = 0;
  int _timerCountdown = 0;
  Timer? _captureTimer;

  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;
  double _timestampFontSize = 14.0;
  File? _latestPhoto;

  // Timer Status Overlay State
  String? _timerStatusText;
  Timer? _statusOverlayTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _loadAlbums();
    // Initialize font size and index based on default design
    _fontSizeIndex = TimestampMetadata.getDefaultFontSizeIndex(_currentDesign);
    _timestampFontSize = TimestampMetadata.getDefaultFontSize(_currentDesign);
  }

  List<double> get _currentFontSizes =>
      TimestampMetadata.getFontSizeSteps(_currentDesign);
  int _fontSizeIndex = 0;

  void _cycleFontSize() {
    setState(() {
      final steps = _currentFontSizes;
      _fontSizeIndex = (_fontSizeIndex + 1) % steps.length;
      _timestampFontSize = steps[_fontSizeIndex];
    });
  }

  Future<void> _loadAlbums() async {
    final allPhotos = await AlbumService.getAllPhotos(albumName: '전체');
    if (mounted) {
      setState(() {
        if (allPhotos.isNotEmpty) {
          _latestPhoto = allPhotos.first;
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _captureTimer?.cancel();
    _recordDurationTimer?.cancel();
    _statusOverlayTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;
    final camera = widget.cameras[_selectedCameraIndex];
    // ResolutionPreset.max → full-sensor 4:3 output (same as stock camera).
    CameraController controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
    } catch (e) {
      debugPrint('Camera init with audio failed, retrying without audio: $e');
      try {
        controller = CameraController(
          camera,
          ResolutionPreset.max,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await controller.initialize();
        await controller.setFlashMode(_flashMode);
      } catch (e2) {
        debugPrint('Camera init error: $e2');
        return;
      }
    }
    if (!mounted) return;
    double minZoom = 1.0;
    double maxZoom = 8.0;
    try {
      minZoom = await controller.getMinZoomLevel();
      maxZoom = await controller.getMaxZoomLevel();
    } catch (_) {}
    setState(() {
      _controller = controller;
      _minZoom = minZoom;
      _maxZoom = maxZoom;
    });
  }

  Future<void> _flipCamera() async {
    if (widget.cameras.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _controller?.dispose();
    setState(() => _controller = null);
    await _initCamera();
  }

  Future<void> _toggleFlash() async {
    // Only OFF and ALWAYS (ON) for 2-way toggle
    _flashMode = _flashMode == FlashMode.off ? FlashMode.always : FlashMode.off;
    await _controller?.setFlashMode(_flashMode);
    setState(() {});
  }

  String get _flashSvg {
    return _flashMode == FlashMode.always
        ? 'assets/icons/flash_on.svg'
        : 'assets/icons/flash_off.svg';
  }

  void _onCapturePressed() {
    if (_timerSeconds == 0) {
      _capturePhoto();
    } else {
      _startCountdown();
    }
  }

  void _startCountdown() {
    setState(() => _timerCountdown = _timerSeconds);
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerCountdown > 0) {
        setState(() => _timerCountdown--);
        if (_timerCountdown == 0) {
          timer.cancel();
          _capturePhoto();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _cycleTimer() {
    final cycle = CameraUX.timerCycle;
    final currentIndex = cycle.indexOf(_timerSeconds);
    final nextIndex = (currentIndex + 1) % cycle.length;
    final nextSeconds = cycle[nextIndex];

    setState(() => _timerSeconds = nextSeconds);
    _showTimerStatusOverlay(nextSeconds == 0 ? 'OFF' : '$nextSeconds');
  }

  void _showTimerStatusOverlay(String text) {
    _statusOverlayTimer?.cancel();
    setState(() => _timerStatusText = text);
    _statusOverlayTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _timerStatusText = null);
      }
    });
  }

  void _toggleAlignment() {
    setState(() {
      final index = CameraUX.alignments.indexOf(_currentAlignment);
      final nextIndex = (index + 1) % CameraUX.alignments.length;
      _currentAlignment = CameraUX.alignments[nextIndex];
    });
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);

    try {
      // Native full-resolution sensor capture (respects flash & zoom).
      // The review screen center-crops it to the selected ratio (BoxFit.cover),
      // which matches exactly what the preview hole shows.
      final isFront =
          _controller!.description.lensDirection == CameraLensDirection.front;
      final xFile = await _controller!.takePicture();
      final file = File(xFile.path);

      if (mounted) {
        final now = DateTime.now();
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoReviewScreen(
              imageFile: file,
              initialDesign: _currentDesign,
              initialAlbum: _currentAlbum,
              aspectRatio: _aspectRatio.value,
              captureTime: now,
              initialAlignment: _currentAlignment,
              initialFontSizeIndex: _fontSizeIndex,
              mirrorHorizontally: isFront,
            ),
          ),
        );

        if (mounted) {
          if (result == true) {
            _showSavedSnackbar();
            _loadAlbums();
          } else if (result is String && result != "전체") {
            setState(() => _currentAlbum = result);
            _loadAlbums();
          }
        }
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _startVideoRecording() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording ||
        _isProcessingVideo) {
      return;
    }
    try {
      await _controller!.startVideoRecording();
      _recordingStartTime = DateTime.now();
      _recordDurationSeconds = 0;
      _recordDurationTimer?.cancel();
      _recordDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordDurationSeconds++;
          });
        }
      });
      setState(() {
        _isRecording = true;
      });
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error starting video recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동영상 촬영 시작 실패: $e')),
        );
      }
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_controller == null || !_isRecording) return;
    _recordDurationTimer?.cancel();
    HapticFeedback.mediumImpact();

    try {
      final xFile = await _controller!.stopVideoRecording();
      final rawVideoFile = File(xFile.path);
      final startTime = _recordingStartTime ?? DateTime.now();

      setState(() {
        _isRecording = false;
        _isProcessingVideo = true;
        _processingStatus = '타임스탬프 영상 처리 중...';
      });

      final endTime = DateTime.now();
      final recordedDuration = endTime.difference(startTime);

      final processedVideo =
          await VideoProcessingService().processVideoWithTimestamp(
        rawVideoFile: rawVideoFile,
        startTime: startTime,
        duration: recordedDuration,
        design: _currentDesign,
        alignment: _currentAlignment,
        fontSize: _timestampFontSize,
        aspectRatio: _aspectRatio,
      );

      // Clean up raw temp file if different
      if (processedVideo.path != rawVideoFile.path &&
          await rawVideoFile.exists()) {
        try {
          await rawVideoFile.delete();
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _isProcessingVideo = false;
        });

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoReviewScreen(
              videoFile: processedVideo,
              initialAlbum: _currentAlbum,
              captureTime: startTime,
            ),
          ),
        );

        if (mounted) {
          if (result == true) {
            _showSavedSnackbar(isVideo: true);
            _loadAlbums();
          } else if (result is String && result != "전체") {
            setState(() => _currentAlbum = result);
            _loadAlbums();
          }
        }
      }
    } catch (e) {
      debugPrint('Error stopping/processing video: $e');
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isProcessingVideo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('영상 처리 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showSavedSnackbar({bool isVideo = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(isVideo ? '동영상이 저장되었습니다!' : '사진이 저장되었습니다!'),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    final bool isFullAuto = _aspectRatio == CameraAspectRatio.ratio16x9;
    final Color topIconColor = CameraUX.getTopIconColor(_aspectRatio.value);
    return Scaffold(
      backgroundColor: const Color(0xFF0F1013),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview with localized RepaintBoundary and ClipRect for precise ratio viewport
          _cameraPreviewWithTimestamp(),

          // 2. UI Overlays (Top bar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _topBar(iconColor: topIconColor),
          ),

          // Recording Timer Indicator
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF3B30).withOpacity(0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3B30),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_recordDurationSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom UI Stack
          Positioned(
            bottom: SharedUX.stackBottomOffset +
                MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ratioButtons(isOverlay: !isFullAuto),
                const SizedBox(height: CameraUX.gapRatioToPicker),
                _timestampPicker(),
                const SizedBox(height: 4),
                _modeSwitch(),
                _bottomControls(isOverlay: !isFullAuto),
              ],
            ),
          ),

          // Countdown
          if (_timerCountdown > 0)
            Center(
              child: Text(
                '$_timerCountdown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 120,
                  fontWeight: FontWeight.w100,
                  shadows: [Shadow(blurRadius: 20, color: Colors.black)],
                ),
              ),
            ),

          // Timer Status Overlay
          if (_timerStatusText != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _timerStatusText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Video Processing Modal Overlay
          if (_isProcessingVideo)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2026),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFD700),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _processingStatus.isNotEmpty
                              ? _processingStatus
                              : '영상 처리 중...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '타임스탬프를 영상에 합성하고 있습니다',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cameraPreviewWithTimestamp() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        final topPadding = MediaQuery.of(context).padding.top;
        final topMenuH = topPadding + 60;
        final bool isFullAuto = _aspectRatio == CameraAspectRatio.ratio16x9;

        double clearW = screenW;
        double clearH;
        double clearTop;
        double clearLeft = 0;

        if (isFullAuto) {
          clearW = screenW;
          clearH = screenH; // Full-screen 9:16 viewport
          clearTop = 0;
        } else if (_aspectRatio == CameraAspectRatio.ratio5x4) {
          clearW = screenW;
          clearH = screenW * 1.25; // 4:5 viewport
          clearTop = topMenuH;
        } else {
          // ratio1x1
          clearW = screenW;
          clearH = screenW; // 1:1 square viewport
          clearTop = topMenuH;
        }

        return GestureDetector(
          onScaleStart: (_) => _baseZoom = _currentZoom,
          onScaleUpdate: (d) async {
            if (_controller == null || !_controller!.value.isInitialized) {
              return;
            }
            final z = (_baseZoom * d.scale).clamp(_minZoom, _maxZoom);
            try {
              await _controller!.setZoomLevel(z);
            } catch (_) {}
            if (mounted) setState(() => _currentZoom = z);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Gesture detector hit-test area for pinch-to-zoom
              const Positioned.fill(child: ColoredBox(color: Colors.transparent)),

              // 2. Viewfinder container with strict ClipRect (Pure black background outside)
              Positioned(
                left: clearLeft,
                top: clearTop,
                width: clearW,
                height: clearH,
                child: ClipRect(
                  child: Container(
                    color: Colors.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Live sensor preview with ratio-specific FOV, zoom, and framing
                        RepaintBoundary(
                          child: _buildRatioCameraPreview(clearW, clearH, _aspectRatio),
                        ),

                        // Timestamp overlay inside the viewfinder
                        if (_currentDesign != TimestampDesign.none)
                          Positioned.fill(
                            child: TimestampOverlayWidget(
                              design: _currentDesign,
                              alignment: _currentAlignment,
                              opacity: _overlayOpacity,
                              fontSize: _timestampFontSize,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Hover buttons (Alignment & Font Size) - Fixed at 1:1 viewport bottom-right across all ratios
              Positioned(
                right: 12,
                top: topMenuH + screenW - 110,
                child: _buildHoverButtons(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatioCameraPreview(double boxW, double boxH, CameraAspectRatio ratio) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: const Color(0xFF0F1013),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.white24, size: 48),
              SizedBox(height: 12),
              Text(
                'Camera Preview',
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final sensorRatio = 1 / _controller!.value.aspectRatio;
    final boxRatio = boxW / boxH;

    double previewW;
    double previewH;

    final bool isSensor16x9 = sensorRatio < 0.65;

    if (isSensor16x9) {
      // For 16:9 sensor devices:
      // Stock camera framing: 4:5 has widest field of view, 1:1 is centered square, 9:16 is full screen
      if (ratio == CameraAspectRatio.ratio16x9) {
        previewW = boxW;
        previewH = boxH;
      } else if (ratio == CameraAspectRatio.ratio5x4) {
        previewH = boxH;
        previewW = boxH * sensorRatio * 1.15;
        if (previewW < boxW) previewW = boxW;
      } else {
        previewW = boxW * 1.05;
        previewH = previewW / sensorRatio;
      }
    } else {
      // For 4:3 sensor devices (stock camera standard native sensor):
      // 4:5 -> Wide angle (full sensor width)
      // 1:1 -> Center square crop
      // 9:16 -> Vertical full bleed with horizontal crop-zoom (1.33x)
      if (boxRatio < sensorRatio) {
        // Taller than sensor (e.g. 9:16 on 4:3 sensor) -> matches height, crops sides (Zoom-in feel!)
        previewH = boxH;
        previewW = boxH * sensorRatio;
      } else {
        // Wider than sensor (e.g. 4:5 or 1:1 on 4:3 sensor) -> matches width, crops top/bottom
        previewW = boxW;
        previewH = boxW / sensorRatio;
      }
    }

    final previewLeft = (boxW - previewW) / 2;
    final previewTop = (boxH - previewH) / 2;

    return Stack(
      children: [
        Positioned(
          left: previewLeft,
          top: previewTop,
          width: previewW,
          height: previewH,
          child: CameraPreview(_controller!),
        ),
      ],
    );
  }

  Widget _buildHoverButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _hoverButton(icon: Icons.open_with, onTap: _toggleAlignment),
        const SizedBox(height: 10),
        _hoverButton(label: "${_fontSizeIndex + 1}A", onTap: _cycleFontSize),
      ],
    );
  }

  Widget _hoverButton({IconData? icon, String? label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 20)
              : Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────

  Widget _topBar({required Color iconColor}) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 10, 16, 10),
      decoration: const BoxDecoration(
        color:
            Colors.transparent, // Always transparent to show camera underneath
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _glassButton(
                onTap: _toggleFlash,
                svgPath: _flashSvg,
                iconColor: iconColor,
              ),
              const SizedBox(width: 8),
              _glassButton(
                onTap: _cycleTimer,
                imagePath: _timerImagePath,
                iconColor: iconColor,
              ),
            ],
          ),
          // Right action buttons: Stamp Management + Flip Camera
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _glassButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StampManagementScreen(),
                    ),
                  );
                },
                icon: Icons.tune_rounded,
                iconColor: iconColor,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _flipCamera,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/icons/camera_flip.svg',
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required VoidCallback onTap,
    IconData? icon,
    String? svgPath,
    String? imagePath,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: imagePath != null
            ? Image.asset(imagePath, width: 24, height: 24, color: iconColor)
            : (svgPath != null
                  ? SvgPicture.asset(
                      svgPath,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                      width: 24,
                      height: 24,
                    )
                  : Icon(icon, color: iconColor, size: 24)),
      ),
    );
  }

  String get _timerImagePath {
    switch (_timerSeconds) {
      case 3:
        return CameraUX.timerIcon3s;
      case 5:
        return CameraUX.timerIcon5s;
      case 7:
        return CameraUX.timerIcon7s;
      default:
        return CameraUX.timerIconOff;
    }
  }

  Widget _ratioButtons({required bool isOverlay}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CameraUX.ratioButtonContainerHorizontal,
        vertical: CameraUX.ratioButtonContainerVertical,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: CameraAspectRatio.values.map((ratio) {
          final selected = _aspectRatio == ratio;
          return GestureDetector(
            onTap: () => setState(() => _aspectRatio = ratio),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(
                horizontal: CameraUX.ratioButtonMarginHorizontal,
              ),
              width: CameraUX.ratioButtonWidth,
              padding: const EdgeInsets.symmetric(
                vertical: CameraUX.ratioButtonPaddingVertical,
              ),

              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF333333)
                    : Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? Colors.white24 : Colors.transparent,
                ),
              ),
              child: Center(
                child: Text(
                  ratio.label,
                  style: TextStyle(
                    color: selected ? const Color(0xFFFFD700) : Colors.white70,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bottomControls({required bool isOverlay}) {
    return CustomBottomNavBar(
      onLeftActionPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CalendarAlbumScreen(initialAlbum: _currentAlbum),
          ),
        );
        if (result != null && result is String && mounted) {
          if (result != "전체") {
            setState(() {
              _currentAlbum = result;
              _currentAlignment = CameraUX.defaultAlignment;
            });
          } else {
            setState(() => _currentAlignment = CameraUX.defaultAlignment);
          }
          _loadAlbums();
        }
      },
      onRightActionPressed: () async {
        final GalleryResult? galleryResult = await Navigator.push<GalleryResult>(
          context,
          MaterialPageRoute(
            builder: (context) => const GalleryPickerScreen(),
          ),
        );
        if (galleryResult != null && mounted) {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoReviewScreen(
                imageFile: galleryResult.file,
                initialDesign: _currentDesign,
                initialAlbum: _currentAlbum,
                aspectRatio: _aspectRatio.value,
                captureTime: galleryResult.creationTime,
                initialAlignment: _currentAlignment,
                initialFontSizeIndex: _fontSizeIndex,
              ),
            ),
          );
          // If review screen returns another GalleryResult, open review with it
          while (result is GalleryResult && mounted) {
            final gr = result;
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoReviewScreen(
                  imageFile: gr.file,
                  initialDesign: _currentDesign,
                  initialAlbum: _currentAlbum,
                  aspectRatio: _aspectRatio.value,
                  captureTime: gr.creationTime,
                  initialAlignment: _currentAlignment,
                  initialFontSizeIndex: _fontSizeIndex,
                ),
              ),
            );
          }
          if (mounted) {
            if (result == true) {
              _showSavedSnackbar();
              _loadAlbums();
            } else if (result is String && result != "전체") {
              setState(() => _currentAlbum = result);
              _loadAlbums();
            }
          }
        }
      },
      onCenterActionPressed: () {
        if (_captureMode == CameraCaptureMode.photo) {
          _onCapturePressed();
        } else {
          if (_isRecording) {
            _stopVideoRecording();
          } else {
            _startVideoRecording();
          }
        }
      },
      rightThumbnail: _latestPhoto,
      isVideoMode: _captureMode == CameraCaptureMode.video,
      isRecording: _isRecording,
      isLoading: _isCapturing || _timerCountdown > 0 || _isProcessingVideo,
    );
  }

  Widget _modeSwitch() {
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _modeButton(
            label: '사진',
            isSelected: _captureMode == CameraCaptureMode.photo,
            onTap: () {
              if (_isRecording || _isProcessingVideo) return;
              HapticFeedback.selectionClick();
              setState(() => _captureMode = CameraCaptureMode.photo);
            },
          ),
          const SizedBox(width: 14),
          _modeButton(
            label: '동영상',
            isSelected: _captureMode == CameraCaptureMode.video,
            onTap: () {
              if (_isRecording || _isProcessingVideo) return;
              HapticFeedback.selectionClick();
              setState(() => _captureMode = CameraCaptureMode.video);
            },
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2D35) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700).withOpacity(0.7)
                : Colors.white12,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white60,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  void _selectDesign(TimestampDesign design) {
    setState(() {
      _currentDesign = design;
      _currentAlignment = CameraUX.defaultAlignment;
      // Reset font size and index to metadata defaults for the new design
      _fontSizeIndex = TimestampMetadata.getDefaultFontSizeIndex(design);
      _timestampFontSize = TimestampMetadata.getDefaultFontSize(design);
    });
  }

  void _onDesignTapped(TimestampDesign design) {
    if (TimestampAccessManager().isUnlocked(design)) {
      _selectDesign(design);
    } else {
      UnlockTimestampDialog.show(
        context,
        design: design,
        onUnlocked: () {
          _selectDesign(design);
        },
      );
    }
  }

  Widget _timestampPicker() {
    return ListenableBuilder(
       listenable: TimestampDeckManager(),
       builder: (context, _) {
        final designs = TimestampDeckManager().getMainScreenDesigns();

        return SizedBox(
          height: CameraUX.timestampPickerHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            // designs (최대 20개) + 맨 마지막 아이템: '스탬프 관리' 버튼
            itemCount: designs.length + 1,
            itemBuilder: (context, index) {
              if (index < designs.length) {
                final design = designs[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: TimestampThumbnail(
                    design: design,
                    isSelected: _currentDesign == design,
                    onTap: () => _onDesignTapped(design),
                  ),
                );
              }

              // 맨 오른쪽 끝: 스탬프 관리 화면 진입 버튼
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StampManagementScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1D24),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFC6FF00).withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC6FF00).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: Color(0xFFC6FF00),
                                size: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '스탬프\n관리',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
