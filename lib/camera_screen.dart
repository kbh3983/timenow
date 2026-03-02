import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import 'timestamp_overlays.dart';

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
  TimestampDesign _selectedDesign = TimestampDesign.dateText;
  bool _isCapturing = false;
  double _overlayOpacity = 0.9;
  bool _showOpacitySlider = false;

  FlashMode _flashMode = FlashMode.off;
  int _timerSeconds = 0;
  int _timerCountdown = 0;
  Timer? _captureTimer;

  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
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
    setState(() => _controller = controller);
  }

  Future<void> _flipCamera() async {
    if (widget.cameras.length < 2) return;
    _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
    await _controller?.dispose();
    setState(() => _controller = null);
    await _initCamera();
  }

  Future<void> _toggleFlash() async {
    final modes = [FlashMode.off, FlashMode.auto, FlashMode.always];
    final idx = modes.indexOf(_flashMode);
    _flashMode = modes[(idx + 1) % modes.length];
    await _controller?.setFlashMode(_flashMode);
    setState(() {});
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  String get _flashLabel {
    switch (_flashMode) {
      case FlashMode.auto:
        return 'Auto';
      case FlashMode.always:
        return 'On';
      default:
        return 'Off';
    }
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
      if (_timerCountdown <= 1) {
        timer.cancel();
        setState(() => _timerCountdown = 0);
        _capturePhoto();
      } else {
        setState(() => _timerCountdown--);
      }
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
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/timenow_${DateTime.now().millisecondsSinceEpoch}.png';
        await File(path).writeAsBytes(bytes);
        await Gal.putImage(path, album: 'Timenow');

        if (mounted) _showSavedSnackbar();
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

  void _showTimerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
              child: Text(
                'Self-timer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...[0, 3, 5, 10].map((sec) {
              final selected = _timerSeconds == sec;
              return ListTile(
                leading: Icon(
                  sec == 0 ? Icons.timer_off : Icons.timer,
                  color: selected ? Colors.deepOrange : Colors.white54,
                ),
                title: Text(
                  sec == 0 ? 'Off' : '${sec}s',
                  style: TextStyle(
                    color: selected ? Colors.deepOrange : Colors.white,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check, color: Colors.deepOrange)
                    : null,
                onTap: () {
                  setState(() => _timerSeconds = sec);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    final bool isFullScreen = _aspectRatio == CameraAspectRatio.ratio16x9;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isFullScreen ? _buildFullLayout() : _buildNormalLayout(),
      ),
    );
  }

  // ─── Normal Layout (1:1 / 5:4) ───────────────────────────────────
  Widget _buildNormalLayout() {
    return Column(
      children: [
        _topBar(isOverlay: false),
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return _buildCameraBox(constraints);
            },
          ),
        ),
        _bottomControls(isOverlay: false),
        _timestampPicker(),
      ],
    );
  }

  Widget _buildCameraBox(BoxConstraints constraints) {
    final targetRatio = _aspectRatio.value;
    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;

    double boxW, boxH;
    if (maxW / targetRatio <= maxH) {
      boxW = maxW;
      boxH = maxW / targetRatio;
    } else {
      boxH = maxH;
      boxW = maxH * targetRatio;
    }

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: SizedBox(
              width: boxW,
              height: boxH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRect(child: _cameraPreview()),
                  if (_selectedDesign != TimestampDesign.none)
                    Positioned.fill(
                      child: TimestampOverlayWidget(design: _selectedDesign),
                    ),
                ],
              ),
            ),
          ),
          _ratioButtons(isOverlay: false),
          if (_timerCountdown > 0)
            Text(
              '$_timerCountdown',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 60,
                fontWeight: FontWeight.w200,
              ),
            ),
        ],
      ),
    );
  }

  // ─── Full Screen Layout (16:9) ───────────────────────────────────
  Widget _buildFullLayout() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera + timestamp overlay (full screen)
        RepaintBoundary(
          key: _repaintKey,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _cameraPreview(),
              if (_selectedDesign != TimestampDesign.none)
                Positioned.fill(
                  child: TimestampOverlayWidget(design: _selectedDesign),
                ),
            ],
          ),
        ),
        // Ratio buttons are mid-overlay, above camera, below controls
        Positioned(
          left: 0,
          right: 0,
          bottom: 230,
          child: Opacity(
            opacity: _overlayOpacity,
            child: Center(child: _ratioButtons(isOverlay: true)),
          ),
        ),
        // Top bar overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: _overlayOpacity,
            child: _topBar(isOverlay: true),
          ),
        ),
        // Bottom controls overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: _overlayOpacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [_bottomControls(isOverlay: true), _timestampPicker()],
            ),
          ),
        ),
        // Opacity control icon
        Positioned(
          right: 12,
          bottom: 240,
          child: GestureDetector(
            onTap: () =>
                setState(() => _showOpacitySlider = !_showOpacitySlider),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _showOpacitySlider ? Icons.tune : Icons.opacity,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        if (_showOpacitySlider)
          Positioned(right: 52, bottom: 234, child: _opacitySlider()),
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
      ],
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

  Widget _topBar({required bool isOverlay}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isOverlay ? Colors.black.withOpacity(0.0) : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _glassButton(
                onTap: _toggleFlash,
                icon: _flashIcon,
                label: _flashLabel,
                isOverlay: isOverlay,
              ),
              const SizedBox(width: 8),
              _glassButton(
                onTap: _showTimerSheet,
                icon: Icons.timer,
                label: _timerSeconds == 0 ? 'Timer' : '${_timerSeconds}s',
                isOverlay: isOverlay,
              ),
            ],
          ),
          _glassButton(
            onTap: () {
              // TODO: Navigate to Album Settings Screen
            },
            icon: Icons.photo_library_outlined,
            label: 'Album',
            isOverlay: isOverlay,
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isOverlay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isOverlay
              ? Colors.white.withOpacity(0.18)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isOverlay ? Colors.white30 : Colors.black12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isOverlay ? Colors.white : Colors.black87,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isOverlay ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratioButtons({required bool isOverlay}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CameraAspectRatio.values.map((ratio) {
          final selected = _aspectRatio == ratio;
          return GestureDetector(
            onTap: () => setState(() => _aspectRatio = ratio),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.deepOrange
                    : isOverlay
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black12,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? Colors.deepOrange
                      : (isOverlay ? Colors.white38 : Colors.black12),
                ),
              ),
              child: Text(
                ratio.label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : (isOverlay ? Colors.white : Colors.black87),
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bottomControls({required bool isOverlay}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      color: isOverlay ? Colors.black.withOpacity(0.0) : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Album
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isOverlay
                    ? Colors.white.withOpacity(0.18)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOverlay ? Colors.white30 : Colors.black12,
                ),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                color: isOverlay ? Colors.white : Colors.black87,
                size: 24,
              ),
            ),
          ),
          // Shutter
          GestureDetector(
            onTap: _isCapturing || _timerCountdown > 0
                ? null
                : _onCapturePressed,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOverlay ? Colors.white : Colors.black12,
                boxShadow: [
                  BoxShadow(
                    color: isOverlay
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isCapturing
                  ? Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: isOverlay ? Colors.black : Colors.deepOrange,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : _timerCountdown > 0
                  ? Center(
                      child: Text(
                        '$_timerCountdown',
                        style: TextStyle(
                          color: isOverlay ? Colors.black : Colors.deepOrange,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isOverlay ? Colors.black12 : Colors.black26,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          // Flip
          GestureDetector(
            onTap: _flipCamera,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isOverlay
                    ? Colors.white.withOpacity(0.18)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOverlay ? Colors.white30 : Colors.black12,
                ),
              ),
              child: Icon(
                Icons.flip_camera_ios_outlined,
                color: isOverlay ? Colors.white : Colors.black87,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timestampPicker() {
    return Container(
      height: 112,
      color: Colors.grey[50],
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: TimestampDesign.values.map((design) {
          return TimestampThumbnail(
            design: design,
            isSelected: _selectedDesign == design,
            onTap: () => setState(() => _selectedDesign = design),
          );
        }).toList(),
      ),
    );
  }

  Widget _opacitySlider() {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.brightness_3, color: Colors.white54, size: 16),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _overlayOpacity,
                min: 0.1,
                max: 1.0,
                activeColor: Colors.white,
                inactiveColor: Colors.white24,
                onChanged: (val) => setState(() => _overlayOpacity = val),
              ),
            ),
          ),
          const Icon(Icons.brightness_high, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}
