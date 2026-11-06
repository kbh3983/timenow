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
import 'services/timestamp_deck_manager.dart';
import 'services/timestamp_access_manager.dart';
import 'widgets/unlock_timestamp_dialog.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/camera_native_view.dart';
import 'ux_config.dart';
import 'gallery_picker_screen.dart';
import 'stamp_management_screen.dart';
import 'settings_screen.dart';
import 'services/app_settings_service.dart';
import 'stamps/stamp_text_store.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';

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

  // Real-time Native Video recording state (CameraX + OverlayEffect + MediaCodec)
  final TimenowNativeCameraController _nativeController =
      TimenowNativeCameraController();
  Timer? _nativeOverlayTimer;
  String? _currentRecordingPath;
  CameraCaptureMode _captureMode = CameraCaptureMode.photo;
  bool _isRecording = false;
  bool _isVideoActionBusy = false;
  DateTime? _recordingStartTime;
  int _recordDurationSeconds = 0;
  Timer? _recordDurationTimer;

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
    _checkPhotoPermissionsOnLaunch();
    // Initialize font size and index based on default design
    _fontSizeIndex = TimestampMetadata.getDefaultFontSizeIndex(_currentDesign);
    _timestampFontSize = TimestampMetadata.getDefaultFontSize(_currentDesign);

    if (AppSettingsService().showLocation && AppSettingsService().locationText.isEmpty) {
      AppSettingsService().fetchAndApplyGpsLocation(overwrite: true);
    }

    _nativeController.onInitialized = () {
      _lastOverlayPushKey = null;
      _updateVideoAspectRatio(_aspectRatio);
      _pushNativeOverlay(force: true);
    };
  }

  Future<void> _checkPhotoPermissionsOnLaunch() async {
    try {
      await PhotoManager.requestPermissionExtend();
    } catch (e) {
      debugPrint('Photo permission check on launch error: $e');
    }
  }

  List<double> get _currentFontSizes =>
      TimestampMetadata.getFontSizeSteps(_currentDesign);
  int _fontSizeIndex = 0;

  void _cycleFontSize() {
    if (!TimestampMetadata.supportsFontSize(_currentDesign)) return;
    setState(() {
      final steps = _currentFontSizes;
      _fontSizeIndex = (_fontSizeIndex + 1) % steps.length;
      _timestampFontSize = steps[_fontSizeIndex];
    });
    _pushNativeOverlay(force: true);
  }

  Future<void> _loadAlbums() async {
    final albums = await AlbumService.getAlbums();
    if (!albums.contains(_currentAlbum)) {
      _currentAlbum = albums.isNotEmpty ? albums.first : '일상';
    }
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
    _nativeOverlayTimer?.cancel();
    _nativeController.detachChannel();
    super.dispose();
  }

  void _updateVideoAspectRatio(CameraAspectRatio ratio) {
    String ratioStr = "1:1";
    if (ratio == CameraAspectRatio.ratio5x4) {
      ratioStr = "4:5";
    } else if (ratio == CameraAspectRatio.ratio16x9) {
      ratioStr = "16:9";
    }
    _nativeController.setAspectRatio(ratioStr);
    _pushNativeOverlay(force: true);
  }

  String? _lastOverlayPushKey;
  double _lastClearW = 0.0;

  Future<void> _pushNativeOverlay({bool force = false}) async {
    if (_captureMode != CameraCaptureMode.video ||
        !_nativeController.isInitialized) {
      return;
    }
    try {
      final now = DateTime.now();
      // 성능 최적화: 분(Minute), 디자인, 비율, 정렬, 글자크기 변경 시에만 1080p 렌더링 및 네이티브 전송 수행.
      // 매초 발생하던 무의미한 8MB 비트맵 인코딩/IPC 호출을 98% 제거하여 발열과 프레임 드랍을 원천 차단합니다.
      final pushKey =
          '${_aspectRatio.name}_${_currentDesign.name}_${_currentAlignment.x}_${_currentAlignment.y}_${_timestampFontSize}_${AppSettingsService().showLocation}_${AppSettingsService().locationText}_${AppSettingsService().locationPosition}_${StampTextStore().version}_${now.year}${now.month}${now.day}${now.hour}${now.minute}';
      if (!force && pushKey == _lastOverlayPushKey) {
        return;
      }

      // 비율에 맞춰 오버레이 캔버스 및 크롭 영역을 동적으로 설정 (1:1 -> 1080x1080, 4:5 -> 1080x1350, 16:9 -> 1080x1920)
      // ViewPort와 일치하도록 종횡비를 정확히 맞춤으로써 타임스탬프 왜곡을 제거하고 완벽한 시각적 일관성을 유지합니다.
      final double canvasW = 1080.0;
      final double canvasH = _aspectRatio == CameraAspectRatio.ratio1x1
          ? 1080.0
          : (_aspectRatio == CameraAspectRatio.ratio5x4 ? 1350.0 : 1920.0);

      final screenW = MediaQuery.of(context).size.width;
      final screenH = MediaQuery.of(context).size.height;
      final topMenuH = MediaQuery.of(context).padding.top + 60;
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      final double clearTop = (_aspectRatio == CameraAspectRatio.ratio16x9)
          ? (screenH - bottomPadding - screenW * (16.0 / 9.0)).clamp(0.0, topMenuH)
          : topMenuH;
      final maxH = screenH - clearTop;

      double clearW = screenW;
      if (_aspectRatio == CameraAspectRatio.ratio16x9 && screenW > 0 && maxH > 0) {
        final viewH = screenW * (16.0 / 9.0);
        if (viewH > maxH) {
          clearW = maxH * (9.0 / 16.0);
        }
      }

      final Rect cropRect = Rect.fromLTWH(0, 0, canvasW, canvasH);

      // 사진 모드와 타임스탬프 크기가 1:1로 정확히 일치하도록 스케일 비율 계산 (캔버스 기준 스케일)
      final double effectiveClearW = _lastClearW > 0 ? _lastClearW : clearW;
      final effectiveScale = effectiveClearW > 0 ? (1080.0 / effectiveClearW) : 2.7;

      final bytes = await VideoProcessingService().renderTimestampBytes(
        currentTime: now,
        design: _currentDesign,
        alignment: _currentAlignment,
        fontSize: _timestampFontSize * effectiveScale,
        canvasWidth: canvasW,
        canvasHeight: canvasH,
        cropRect: cropRect,
        scale: effectiveScale,
      );
      if (mounted) {
        await _nativeController.updateOverlay(Uint8List.fromList(bytes));
        _lastOverlayPushKey = pushKey;
      }
    } catch (e) {
      debugPrint('Error pushing native overlay: $e');
    }
  }

  bool _isModeSwitching = false;

  Future<void> _setCaptureMode(CameraCaptureMode mode) async {
    if (_captureMode == mode || _isRecording || _isModeSwitching) return;
    _isModeSwitching = true;
    HapticFeedback.selectionClick();

    try {
      if (mode == CameraCaptureMode.video) {
        // 1. Flutter 사진 카메라를 먼저 완전히 닫고 하드웨어 자원을 안전하게 반환합니다.
        final oldController = _controller;
        _controller = null;
        if (oldController != null) {
          try {
            await oldController.dispose();
          } catch (_) {}
          // Android Camera HAL이 카메라 센서 점유를 완전히 해제할 시간을 부여합니다.
          await Future.delayed(const Duration(milliseconds: 150));
        }

        if (!mounted) return;
        _lastOverlayPushKey = null;
        setState(() {
          _captureMode = mode;
        });

        _updateVideoAspectRatio(_aspectRatio);

        _nativeOverlayTimer?.cancel();
        _nativeOverlayTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => _pushNativeOverlay(),
        );

        // 네이티브 CameraX 초기화 완료 시점 편차에 대비하여 단계적 force push 수행
        for (final delayMs in [150, 400, 800, 1300]) {
          Future.delayed(
            Duration(milliseconds: delayMs),
            () {
              if (mounted && _captureMode == CameraCaptureMode.video) {
                _pushNativeOverlay(force: true);
              }
            },
          );
        }
      } else {
        // 2. 동영상 -> 사진 모드 복귀 시
        _nativeOverlayTimer?.cancel();
        _lastOverlayPushKey = null;
        setState(() {
          _captureMode = mode;
        });
        // 네이티브 CameraX가 언바인딩될 수 있도록 잠시 대기 후 사진 카메라 초기화
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          await _initCamera();
        }
      }
    } finally {
      _isModeSwitching = false;
    }
  }

  bool _isCameraInitializing = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 1. 앱이 비활성화되거나 백그라운드로 전환될 때 (화면 잠금, 홈 화면 전환, 전체화면 광고 노출 등)
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_captureMode == CameraCaptureMode.photo) {
        final oldController = _controller;
        if (oldController != null) {
          // 화면이 다시 빌드되더라도 폐기된 컨트롤러를 참조하지 않도록 즉시 null 처리
          setState(() {
            _controller = null;
          });
          oldController.dispose();
        }
      } else {
        // 비디오 녹화 중 잠금이나 백그라운드 전환 시 녹화 안전 종료
        if (_isRecording) {
          _stopVideoRecording();
        }
      }
    }
    // 2. 앱으로 복귀했을 때 (화면 잠금 해제, 광고 닫기, 앱 재진입 등)
    else if (state == AppLifecycleState.resumed) {
      if (_captureMode == CameraCaptureMode.photo) {
        if (!_isCameraInitializing) {
          _initCamera();
        }
      } else {
        // 비디오 모드인 경우 네이티브 오버레이 갱신
        _lastOverlayPushKey = null;
        _pushNativeOverlay(force: true);
      }
    }
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) return;
    if (_isCameraInitializing) return;
    _isCameraInitializing = true;

    try {
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
        try {
          await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
        } catch (_) {}
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
          try {
            await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
          } catch (_) {}
          await controller.setFlashMode(_flashMode);
        } catch (e2) {
          debugPrint('Camera init error: $e2');
          return;
        }
      }
      if (!mounted) {
        controller.dispose();
        return;
      }
      double minZoom = 1.0;
      double maxZoom = 8.0;
      try {
        minZoom = await controller.getMinZoomLevel();
        maxZoom = await controller.getMaxZoomLevel();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _controller = controller;
          _minZoom = minZoom;
          _maxZoom = maxZoom;
        });
      } else {
        controller.dispose();
      }
    } finally {
      _isCameraInitializing = false;
    }
  }

  Future<void> _flipCamera() async {
    if (_isRecording) return;
    if (_captureMode == CameraCaptureMode.video) {
      final isFront = await _nativeController.switchCamera();
      if (widget.cameras.length >= 2) {
        _selectedCameraIndex = isFront ? 1 : 0;
      }
      _lastOverlayPushKey = null;
      if (mounted) setState(() {});
      _pushNativeOverlay(force: true);
    } else {
      if (widget.cameras.length < 2) return;
      _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
      await _controller?.dispose();
      setState(() => _controller = null);
      await _initCamera();
    }
  }

  Future<void> _toggleFlash() async {
    _flashMode = _flashMode == FlashMode.off ? FlashMode.always : FlashMode.off;
    if (_captureMode == CameraCaptureMode.video) {
      await _nativeController.setFlash(_flashMode == FlashMode.always);
    } else {
      await _controller?.setFlashMode(_flashMode);
    }
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
    if (!TimestampMetadata.supportsAlignment(_currentDesign)) return;
    setState(() {
      _currentAlignment = TimestampMetadata.nextAlignment(
        _currentDesign,
        _currentAlignment,
      );
    });
    if (_captureMode == CameraCaptureMode.video) {
      _pushNativeOverlay(force: true);
    }
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
    if (_isRecording || _isVideoActionBusy) return;
    _isVideoActionBusy = true;
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/timenow_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      _currentRecordingPath = outputPath;

      await _nativeController.startRecording(outputPath);
      _recordingStartTime = DateTime.now();
      _recordDurationSeconds = 0;
      _recordDurationTimer?.cancel();
      _recordDurationTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordDurationSeconds++;
          });
        }
      });
      if (mounted) {
        setState(() {
          _isRecording = true;
        });
      }
      // 녹화 시작 시 햅틱 진동을 발생시키지 않습니다 (기기 모터 진동이 마이크로 즉시 녹음되어 '뚝!' 하는 잡음 유발 방지)
    } catch (e) {
      debugPrint('Error starting video recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('동영상 촬영 시작 실패: $e')),
        );
      }
    } finally {
      _isVideoActionBusy = false;
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_isRecording || _isVideoActionBusy) return;
    _isVideoActionBusy = true;
    _recordDurationTimer?.cancel();
    // 녹화 종료 시에도 마이크 수음 중 진동 잡음 방지를 위해 햅틱을 발생시키지 않습니다.

    try {
      final recordedResult = await _nativeController.stopRecording();
      final recordedPath = recordedResult ?? _currentRecordingPath;
      final startTime = _recordingStartTime ?? DateTime.now();

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      if (recordedPath != null && mounted) {
        final videoFile = File(recordedPath);
        if (await videoFile.exists()) {
          final isFront = widget.cameras.isNotEmpty &&
              _selectedCameraIndex < widget.cameras.length &&
              widget.cameras[_selectedCameraIndex].lensDirection ==
                  CameraLensDirection.front;

          // 녹화 직후 비디오 최적화:
          // 1. 전면 카메라 거울 모드 (hflip)
          // 2. 1:1 / 4:5 화면 비율 크롭
          // 3. 마이크 전원 인가 시 발생하는 시작 지점 팝 노이즈("뚝!" 소리) 원천 제거
          final processedFile =
              await VideoProcessingService().processRecordedVideo(
            rawVideoFile: videoFile,
            aspectRatioValue: _aspectRatio.value,
            mirrorHorizontally: isFront,
          );

          if (!mounted) return;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoReviewScreen(
                videoFile: processedFile,
                initialAlbum: _currentAlbum,
                captureTime: startTime,
                aspectRatio: _aspectRatio.value,
                mirrorHorizontally: false, // processedFile에 이미 영구 반영 완료
              ),
            ),
          );

          if (mounted) {
            if (result == true) {
              _loadAlbums();
            } else if (result is String && result != "전체") {
              setState(() => _currentAlbum = result);
              _loadAlbums();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('영상 저장 실패: $e')),
        );
      }
    } finally {
      _isVideoActionBusy = false;
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showSavedSnackbar({bool isVideo = false}) {
    final accent = AppSettingsService().accentColor;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: accent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isVideo ? '동영상이 저장되었습니다!' : '사진이 저장되었습니다!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E2129),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    final bool isFullAuto = _aspectRatio == CameraAspectRatio.ratio16x9;
    final Color topIconColor = CameraUX.getTopIconColor(_aspectRatio.value);
    final screenW = MediaQuery.of(context).size.width;
    final topMenuH = MediaQuery.of(context).padding.top + 60;
    final pickerToShutterGap = (CameraUX.gapPickerToShutterTop -
            (SharedUX.containerHeight -
                (SharedUX.shutterPosition +
                    SharedUX.centerButtonSize)))
        .clamp(0.0, double.infinity);

    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        final isPureBlack = AppSettingsService().isPureBlack;
        return Scaffold(
          backgroundColor: isPureBlack ? Colors.black : const Color(0xFF0F1013),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera Preview with localized RepaintBoundary and ClipRect for precise ratio viewport
              _cameraPreviewWithTimestamp(),

          // 2. Hover buttons (Alignment & Font Size) - Outer Stack overlay layer ensures it is visible over native video
          Positioned(
            right: 12,
            top: topMenuH + screenW - 110,
            child: _buildHoverButtons(),
          ),

          // 3. UI Overlays (Top bar)
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
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppSettingsService().accentColor.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppSettingsService().accentColor,
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
                SizedBox(height: pickerToShutterGap),
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
      },
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
          final bottomPadding = MediaQuery.of(context).padding.bottom;
          clearW = screenW;
          clearH = screenW * (16.0 / 9.0); // 9:16 viewport

          // 화면이 넉넉한 기기는 기존처럼 상단 메뉴 아래(topMenuH)를 유지하고,
          // 9:16이 하단 소프트키(bottomPadding)나 바닥을 침범하는 작은 기기에서는
          // 침범하는 만큼 위로 올려 최대 top: 0(화면 맨 위)까지 자연스럽게 이동
          clearTop = (screenH - bottomPadding - clearH).clamp(0.0, topMenuH);

          final maxH = screenH - clearTop;
          if (clearH > maxH) {
            clearH = maxH;
            clearW = maxH * (9.0 / 16.0);
            clearLeft = (screenW - clearW) / 2;
          }
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

        _lastClearW = clearW;
        return GestureDetector(
          onScaleStart: (_) => _baseZoom = _currentZoom,
          onScaleUpdate: (d) async {
            final z = (_baseZoom * d.scale).clamp(_minZoom, _maxZoom);
            if (_captureMode == CameraCaptureMode.video) {
              _nativeController.setZoom(z);
            } else if (_controller != null && _controller!.value.isInitialized) {
              try {
                await _controller!.setZoomLevel(z);
              } catch (_) {}
            }
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

                        // Timestamp overlay inside the viewfinder (in video mode native OverlayEffect renders pixels on GPU, while opacity 0 keeps editable text hit-targets active)
                        if (_currentDesign != TimestampDesign.none)
                          Positioned.fill(
                            child: TimestampOverlayWidget(
                              design: _currentDesign,
                              alignment: _currentAlignment,
                              opacity: _captureMode == CameraCaptureMode.video ? 0.0 : _overlayOpacity,
                              fontSize: _timestampFontSize,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatioCameraPreview(double boxW, double boxH, CameraAspectRatio ratio) {
    if (_captureMode == CameraCaptureMode.video) {
      final isFront = widget.cameras.isNotEmpty &&
          _selectedCameraIndex < widget.cameras.length &&
          widget.cameras[_selectedCameraIndex].lensDirection == CameraLensDirection.front;
      return SizedBox(
        width: boxW,
        height: boxH,
        child: CameraNativeView(
          controller: _nativeController,
          isFrontCamera: isFront,
        ),
      );
    }

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
    final canAlign = TimestampMetadata.supportsAlignment(_currentDesign);
    final canResize = TimestampMetadata.supportsFontSize(_currentDesign);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _hoverButton(
          icon: Icons.open_with,
          enabled: canAlign,
          onTap: canAlign ? _toggleAlignment : null,
        ),
        const SizedBox(height: 10),
        _hoverButton(
          label: "${_fontSizeIndex + 1}A",
          enabled: canResize,
          onTap: canResize ? _cycleFontSize : null,
        ),
      ],
    );
  }

  Widget _hoverButton({
    IconData? icon,
    String? label,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    final fgColor = Colors.white.withValues(alpha: enabled ? 1.0 : 0.4);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1.0 : 0.38,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: enabled ? 0.5 : 0.35),
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.25 : 0.12),
              width: 1,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: fgColor, size: 20)
                : Text(
                    label!,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
          // Right action buttons: Photo/Video Mode Switch + Flip Camera
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _topModeSwitch(),
              const SizedBox(width: 6),
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

  Widget _topModeSwitch() {
    final isPhoto = _captureMode == CameraCaptureMode.photo;
    final isVideo = _captureMode == CameraCaptureMode.video;
    final bool isLocked = _isRecording;

    return Opacity(
      opacity: isLocked ? 0.4 : 1.0,
      child: Container(
        height: 32,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _topModeItem(
              label: '사진',
              isSelected: isPhoto,
              onTap: () {
                if (_isRecording) return;
                if (!isPhoto) {
                  HapticFeedback.selectionClick();
                  _setCaptureMode(CameraCaptureMode.photo);
                }
              },
            ),
            _topModeItem(
              label: '동영상',
              isSelected: isVideo,
              onTap: () {
                if (_isRecording) return;
                if (!isVideo) {
                  HapticFeedback.selectionClick();
                  _setCaptureMode(CameraCaptureMode.video);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _topModeItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final accent = AppSettingsService().accentColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF333333) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.7)
                : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? accent : Colors.white70,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
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
    final accent = AppSettingsService().accentColor;
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
          final isLocked = _isRecording && !selected;

          return Opacity(
            opacity: isLocked ? 0.35 : 1.0,
            child: GestureDetector(
              onTap: () {
                if (_isRecording) return; // 촬영 중 비율 변경 방지
                if (_aspectRatio != ratio) {
                  setState(() => _aspectRatio = ratio);
                  if (_captureMode == CameraCaptureMode.video) {
                    _updateVideoAspectRatio(ratio);
                  }
                }
              },
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
                      : Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? Colors.white24 : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    ratio.label,
                    style: TextStyle(
                      color: selected ? accent : Colors.white70,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    ),
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
      onSettingsPressed: () async {
        HapticFeedback.lightImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        if (mounted) setState(() {});
      },
      onPhotoPickerPressed: () async {
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
          while (result is GalleryResult) {
            final gr = result;
            if (!mounted) break;
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
      onAlbumPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CalendarAlbumScreen(initialAlbum: _currentAlbum),
          ),
        );
        if (mounted) {
          final albums = await AlbumService.getAlbums();
          if (result != null && result is String && result != "전체" && albums.contains(result)) {
            setState(() {
              _currentAlbum = result;
              _currentAlignment = CameraUX.defaultAlignment;
            });
          } else {
            setState(() {
              _currentAlbum = albums.contains(_currentAlbum)
                  ? _currentAlbum
                  : (albums.isNotEmpty ? albums.first : '일상');
              _currentAlignment = CameraUX.defaultAlignment;
            });
          }
          await _loadAlbums();
        }
      },
      onStampManagementPressed: () async {
        HapticFeedback.lightImpact();
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const StampManagementScreen(),
          ),
        );
        if (mounted) {
          setState(() {});
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
      photoThumbnail: _latestPhoto,
      isVideoMode: _captureMode == CameraCaptureMode.video,
      isRecording: _isRecording,
      isLoading: _isCapturing || _timerCountdown > 0,
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
    _lastOverlayPushKey = null;
    _pushNativeOverlay(force: true);
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // designs (최대 8개) + 맨 마지막 아이템: '스탬프 관리' 버튼
            itemCount: designs.length + 1,
            itemBuilder: (context, index) {
              if (index < designs.length) {
                final design = designs[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TimestampThumbnail(
                    design: design,
                    isSelected: _currentDesign == design,
                    onTap: () => _onDesignTapped(design),
                  ),
                );
              }

              // 맨 오른쪽 끝: 스탬프 관리 화면 진입 버튼
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                            color: AppSettingsService().accentColor.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppSettingsService().accentColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.approval_rounded,
                                color: AppSettingsService().accentColor,
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
