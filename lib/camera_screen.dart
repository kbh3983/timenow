import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'timestamp_overlays.dart';
import 'timestamp_metadata.dart';
import 'calendar_album_screen.dart';
import 'album_service.dart';
import 'photo_review_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'ux_config.dart';

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
  TimestampDesign _currentDesign = TimestampDesign.custom01;
  Alignment _currentAlignment = CameraUX.defaultAlignment;
  double _overlayOpacity = 1.0;
  String _currentAlbum = '일상';
  bool _isCapturing = false;

  FlashMode _flashMode = FlashMode.off;
  int _timerSeconds = 0;
  int _timerCountdown = 0;
  Timer? _captureTimer;

  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;
  double _timestampFontSize = 14.0;
  final GlobalKey _repaintKey = GlobalKey();
  final GlobalKey _rawRepaintKey = GlobalKey();
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

  List<double> get _currentFontSizes => TimestampMetadata.getFontSizeSteps(_currentDesign);
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
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
    } catch (e) {
      debugPrint('Camera init error: $e');
      return;
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
      final boundary =
          _rawRepaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/timenow_raw_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(path);
        await file.writeAsBytes(bytes);

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

  void _showSavedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Photo saved to gallery!'),
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
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview with localized RepaintBoundary for cropping
          _cameraPreviewWithTimestamp(),

          // 2. Translucent Mask for Aspect Ratio
          _buildCameraMask(),

          // 3. UI Overlays
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _topBar(iconColor: topIconColor),
          ),

          // Bottom UI Stack
          Positioned(
            bottom: SharedUX.stackBottomOffset,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ratioButtons(isOverlay: !isFullAuto),
                const SizedBox(height: CameraUX.gapRatioToPicker),
                _timestampPicker(),
                // Calculate the visual gap so it feels direct from the shutter button top
                // Use clamp to prevent negative height which causes the "red screen" layout error
                SizedBox(
                  height: (CameraUX.gapPickerToShutterTop -
                          (SharedUX.containerHeight -
                              (SharedUX.shutterPosition +
                                  SharedUX.centerButtonSize)))
                      .clamp(0.0, double.infinity),
                ),
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
        ],
      ),
    );
  }

  Widget _cameraPreviewWithTimestamp() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        final targetRatio = _aspectRatio.value;
        double clearW, clearH;
        if (screenW / targetRatio <= screenH) {
          clearW = screenW;
          clearH = screenW / targetRatio;
        } else {
          clearH = screenH;
          clearW = screenH * targetRatio;
        }

        // Centering logic: Center between top bar and bottom ratio buttons
        final topPadding = MediaQuery.of(context).padding.top;
        final topMenuH = topPadding + 60;
        final pickerToShutterGap = (CameraUX.gapPickerToShutterTop -
                (SharedUX.containerHeight -
                    (SharedUX.shutterPosition +
                        SharedUX.centerButtonSize)))
            .clamp(0.0, double.infinity);

        final bottomUIH = SharedUX.stackBottomOffset +
            SharedUX.containerHeight +
            pickerToShutterGap +
            CameraUX.timestampPickerHeight +
            CameraUX.gapRatioToPicker +
            CameraUX.ratioButtonsHeight; // pos + ctrls + gap + picker + gap + ratio
        final availableH = screenH - topMenuH - bottomUIH;

        // Vertically center clearH within availableH (except for 9:16 which starts from top)
        final bool isFullAuto = _aspectRatio == CameraAspectRatio.ratio16x9;

        final clearTop =
            (isFullAuto ||
                    _aspectRatio == CameraAspectRatio.ratio5x4 ||
                    _aspectRatio == CameraAspectRatio.ratio1x1)
                ? topMenuH
                : topMenuH + (availableH - clearH) / 2;
        final clearLeft = (screenW - clearW) / 2;

        // 1:1 specific coordinates for fixed hover buttons
        final ratio1x1 = CameraAspectRatio.ratio1x1.value;
        double clearW1x1, clearH1x1;
        if (screenW / ratio1x1 <= screenH) {
          clearW1x1 = screenW;
          clearH1x1 = screenW / ratio1x1;
        } else {
          clearH1x1 = screenH;
          clearW1x1 = screenH * ratio1x1;
        }
        final clearTop1x1 = topMenuH;
        final clearLeft1x1 = (screenW - clearW1x1) / 2;

        return GestureDetector(
          onScaleStart: (_) => _baseZoom = _currentZoom,
          onScaleUpdate: (d) async {
            if (_controller == null || !_controller!.value.isInitialized) return;
            final z = (_baseZoom * d.scale).clamp(_minZoom, _maxZoom);
            try { await _controller!.setZoomLevel(z); } catch (_) {}
            if (mounted) setState(() => _currentZoom = z);
          },
          child: Stack(
          children: [
            // Full background preview (non-captured)
            Positioned.fill(
              child: OverflowBox(
                maxHeight: screenH,
                maxWidth: screenW,
                child: _cameraPreview(),
              ),
            ),

            // Captured area (Clear hole + Timestamp)
            Positioned(
              top: clearTop,
              left: clearLeft,
              child: RepaintBoundary(
                key: _repaintKey,
                child: SizedBox(
                  width: clearW,
                  height: clearH,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        key: _rawRepaintKey,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              top: -clearTop,
                              left: -clearLeft,
                              width: screenW,
                              height: screenH,
                              child: _cameraPreview(),
                            ),
                          ],
                        ),
                      ),
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

            // Hover buttons (fixed to 1:1 position)
            Positioned(
              top: clearTop1x1,
              left: clearLeft1x1,
              width: clearW1x1,
              height: clearH1x1,
              child: _buildHoverButtons(),
            ),
          ],
          ),  // end Stack
        );  // end GestureDetector
      },
    );
  }

  Widget _buildHoverButtons() {
    return Container(
      padding: const EdgeInsets.only(right: 12, bottom: 12),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _hoverButton(
            icon: Icons.open_with,
            onTap: _toggleAlignment,
          ),
          const SizedBox(height: 12),
          _hoverButton(
            label: "${_fontSizeIndex + 1}A", 
            onTap: _cycleFontSize,
          ),
        ],
      ),
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
          color: Colors.black.withOpacity(0.4),
          border: Border.all(color: Colors.white24, width: 1),
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

  Widget _buildCameraMask() {
    final topPadding = MediaQuery.of(context).padding.top;
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenH = constraints.maxHeight;
          final topMenuH = topPadding + 60;
          final pickerToShutterGap = (CameraUX.gapPickerToShutterTop -
                  (SharedUX.containerHeight -
                      (SharedUX.shutterPosition +
                          SharedUX.centerButtonSize)))
              .clamp(0.0, double.infinity);

          final bottomUIH = SharedUX.stackBottomOffset +
              SharedUX.containerHeight +
              pickerToShutterGap +
              CameraUX.timestampPickerHeight +
              CameraUX.gapRatioToPicker +
              CameraUX.ratioButtonsHeight;
          final availableH = screenH - topMenuH - bottomUIH;

          // Same centering calculation for the mask
          final targetRatio = _aspectRatio.value;
          final screenW = constraints.maxWidth;
          final bool isFullAuto = _aspectRatio == CameraAspectRatio.ratio16x9;

          double clearH;
          if (screenW / targetRatio <= screenH) {
            clearH = screenW / targetRatio;
          } else {
            clearH = screenH;
          }

          final clearTop =
              (isFullAuto ||
                      _aspectRatio == CameraAspectRatio.ratio5x4 ||
                      _aspectRatio == CameraAspectRatio.ratio1x1)
                  ? topMenuH
                  : topMenuH + (availableH - clearH) / 2;

          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _CameraMaskPainter(
              aspectRatio: _aspectRatio.value,
              topOffset: clearTop,
              maskColor: Colors.black.withOpacity(CameraUX.maskOpacity),
            ),
          );
        },
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────
  Widget _cameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.black26, size: 48),
              SizedBox(height: 12),
              Text(
                'Camera Preview',
                style: TextStyle(color: Colors.black26, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    return CameraPreview(_controller!);
  }

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
          // Flip Camera icon only
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
              margin: const EdgeInsets.symmetric(horizontal: CameraUX.ratioButtonMarginHorizontal),
              width: CameraUX.ratioButtonWidth,
              padding: const EdgeInsets.symmetric(vertical: CameraUX.ratioButtonPaddingVertical),

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
            builder: (context) => CalendarAlbumScreen(initialAlbum: _currentAlbum),
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
      onRightActionPressed: () {
        // TODO: Open Gallery
      },
      onCenterActionPressed: _onCapturePressed,
      rightThumbnail: _latestPhoto,
      isLoading: _isCapturing || _timerCountdown > 0,
    );
  }

  Widget _timestampPicker() {
    return SizedBox(
      height: CameraUX.timestampPickerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: TimestampDesign.values.length,
        itemBuilder: (context, index) {
          final design = TimestampDesign.values[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: TimestampThumbnail(
              design: design,
              isSelected: _currentDesign == design,
              onTap: () => setState(() {
                _currentDesign = design;
                _currentAlignment = CameraUX.defaultAlignment;
                // Reset font size and index to metadata defaults for the new design
                _fontSizeIndex = TimestampMetadata.getDefaultFontSizeIndex(design);
                _timestampFontSize = TimestampMetadata.getDefaultFontSize(design);
              }),
            ),
          );
        },
      ),
    );
  }
}

class _CameraMaskPainter extends CustomPainter {
  final double aspectRatio;
  final double topOffset;
  final Color maskColor;

  _CameraMaskPainter({
    required this.aspectRatio,
    required this.topOffset,
    required this.maskColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screenW = size.width;
    final screenH = size.height;

    double clearW, clearH;
    if (screenW / aspectRatio <= screenH) {
      clearW = screenW;
      clearH = screenW / aspectRatio;
    } else {
      clearH = screenH;
      clearW = screenH * aspectRatio;
    }

    // Alignment: Center horizontally, specific offset vertically
    final clearRect = Rect.fromLTWH(
      (screenW - clearW) / 2,
      topOffset,
      clearW,
      clearH,
    );

    final paint = Paint()..color = maskColor;

    // Create a path for the whole screen
    final maskPath = Path()..addRect(Rect.fromLTWH(0, 0, screenW, screenH));
    // Create a path for the hole
    final holePath = Path()..addRect(clearRect);

    // Subtract the hole from the mask
    final finalPath = Path.combine(
      PathOperation.difference,
      maskPath,
      holePath,
    );

    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CameraMaskPainter oldDelegate) {
    return oldDelegate.aspectRatio != aspectRatio ||
        oldDelegate.topOffset != topOffset ||
        oldDelegate.maskColor != maskColor;
  }
}
