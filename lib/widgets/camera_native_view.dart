import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimenowNativeCameraController {
  MethodChannel? _channel;
  bool _isInitialized = false;
  VoidCallback? onInitialized;

  bool get isInitialized => _isInitialized;

  void attachChannel(int viewId) {
    _channel = MethodChannel('timenow_camera_view_$viewId');
    _channel!.setMethodCallHandler((call) async {
      if (call.method == 'onCameraInitialized') {
        _isInitialized = true;
        onInitialized?.call();
      }
    });
    // Check if camera is already initialized in native
    isCameraReady().then((ready) {
      if (ready) {
        _isInitialized = true;
        onInitialized?.call();
      }
    });
  }

  Future<bool> isCameraReady() async {
    if (_channel == null) return false;
    try {
      final ready = await _channel!.invokeMethod<bool>('isCameraReady');
      return ready ?? false;
    } catch (_) {
      return false;
    }
  }

  void detachChannel() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    _isInitialized = false;
  }

  Future<String?> startRecording(String outputPath) async {
    if (_channel == null) return null;
    try {
      final result = await _channel!.invokeMethod<String>('startRecording', {
        'path': outputPath,
      });
      return result;
    } catch (e) {
      debugPrint('Native startRecording error: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording() async {
    if (_channel == null) return null;
    try {
      final result = await _channel!.invokeMethod<String>('stopRecording');
      return result;
    } catch (e) {
      debugPrint('Native stopRecording error: $e');
      rethrow;
    }
  }

  Future<String?> takePhoto(String outputPath) async {
    if (_channel == null) return null;
    try {
      final result = await _channel!.invokeMethod<String>('takePhoto', {
        'path': outputPath,
      });
      return result;
    } catch (e) {
      debugPrint('Native takePhoto error: $e');
      rethrow;
    }
  }

  Future<void> updateOverlay(Uint8List pngBytes) async {
    if (_channel == null) return;
    try {
      await _channel!.invokeMethod('updateOverlay', {
        'bytes': pngBytes,
      });
    } catch (e) {
      debugPrint('Native updateOverlay error: $e');
    }
  }

  Future<bool> switchCamera() async {
    if (_channel == null) return false;
    try {
      final result = await _channel!.invokeMethod<bool>('switchCamera');
      return result ?? false;
    } catch (e) {
      debugPrint('Native switchCamera error: $e');
      return false;
    }
  }

  Future<void> setFlash(bool on) async {
    if (_channel == null) return;
    try {
      await _channel!.invokeMethod('setFlash', {'on': on});
    } catch (e) {
      debugPrint('Native setFlash error: $e');
    }
  }

  Future<void> setZoom(double zoomRatio) async {
    if (_channel == null) return;
    try {
      await _channel!.invokeMethod('setZoom', {'zoom': zoomRatio});
    } catch (e) {
      debugPrint('Native setZoom error: $e');
    }
  }

  Future<void> setAspectRatio(String ratio) async {
    if (_channel == null) return;
    try {
      await _channel!.invokeMethod('setAspectRatio', {'ratio': ratio});
    } catch (e) {
      debugPrint('Native setAspectRatio error: $e');
    }
  }
}

class CameraNativeView extends StatefulWidget {
  final TimenowNativeCameraController controller;
  final bool isFrontCamera;

  const CameraNativeView({
    super.key,
    required this.controller,
    this.isFrontCamera = false,
  });

  @override
  State<CameraNativeView> createState() => _CameraNativeViewState();
}

class _CameraNativeViewState extends State<CameraNativeView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Center(child: Text('Android only'));
    }

    return AndroidView(
      viewType: 'timenow_camera_view',
      onPlatformViewCreated: (id) {
        widget.controller.attachChannel(id);
      },
      creationParams: {
        'isFrontCamera': widget.isFrontCamera,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  @override
  void dispose() {
    widget.controller.detachChannel();
    super.dispose();
  }
}
