package com.kbh3983.log

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.PorterDuff
import android.graphics.RectF
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Rational
import android.view.OrientationEventListener
import android.view.Surface
import android.view.View
import androidx.camera.core.*
import androidx.camera.effects.OverlayEffect
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.video.*
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class TimenowCameraView(
    private val context: Context,
    messenger: BinaryMessenger,
    id: Int,
    private val lifecycleOwner: LifecycleOwner,
    private val activity: Activity? = null,
    initialFrontCamera: Boolean = false
) : PlatformView, MethodChannel.MethodCallHandler {

    private enum class RecordingState {
        IDLE,
        STARTING,
        RECORDING,
        STOPPING
    }

    private val previewView: PreviewView = PreviewView(context).apply {
        scaleType = PreviewView.ScaleType.FILL_CENTER
        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
    }
    private val channel: MethodChannel = MethodChannel(messenger, "timenow_camera_view_$id")
    private var cameraProvider: ProcessCameraProvider? = null
    private var camera: Camera? = null
    private var preview: Preview? = null
    private var imageCapture: ImageCapture? = null
    private var videoCapture: VideoCapture<Recorder>? = null
    private var overlayEffect: OverlayEffect? = null

    @Volatile
    private var recordingState = RecordingState.IDLE
    private var activeRecording: Recording? = null
    private var startResultCallback: MethodChannel.Result? = null
    private var stopResultCallback: MethodChannel.Result? = null

    @Volatile
    private var overlayBitmap: Bitmap? = null
    private var isFrontCamera = initialFrontCamera
    private var flashMode = ImageCapture.FLASH_MODE_OFF

    private val currentTargetRotation: Int = Surface.ROTATION_0
    private var currentAspectRatioStr: String = "1:1"

    private val cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val overlayHandlerThread = HandlerThread("OverlayEffectThread").apply { start() }
    private val overlayHandler = Handler(overlayHandlerThread.looper)

    init {
        channel.setMethodCallHandler(this)
        previewView.post {
            initCamera()
        }
    }

    override fun getView(): View = previewView

    override fun dispose() {
        channel.setMethodCallHandler(null)
        try {
            if (recordingState != RecordingState.IDLE) {
                activeRecording?.stop()
            }
            activeRecording = null
            recordingState = RecordingState.IDLE
            startResultCallback = null
            stopResultCallback = null

            overlayEffect?.clearOnDrawListener()
            overlayEffect?.close()
            overlayEffect = null

            cameraProvider?.unbindAll()
            cameraExecutor.shutdown()
            overlayHandlerThread.quitSafely()

            overlayBitmap?.recycle()
            overlayBitmap = null
        } catch (_: Exception) {}
    }

    private fun initCamera() {
        val act = activity ?: (context as? Activity) ?: (lifecycleOwner as? Activity)
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            act?.let {
                ActivityCompat.requestPermissions(it, arrayOf(Manifest.permission.RECORD_AUDIO), 1002)
            }
        }

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()
                bindCameraUseCases()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }, ContextCompat.getMainExecutor(context))
    }

    private fun bindCameraUseCases() {
        val provider = cameraProvider ?: return
        provider.unbindAll()

        val cameraSelector = if (isFrontCamera) {
            CameraSelector.DEFAULT_FRONT_CAMERA
        } else {
            CameraSelector.DEFAULT_BACK_CAMERA
        }

        // 1:1 및 4:5는 센서 네이티브 4:3 전체 화각(와이드)을 사용하여 사진/후면처럼 넓은 배율을 제공
        // 16:9는 16:9 비율을 사용하여 세로 크롭 줌인 배율을 제공
        val targetRatio = if (currentAspectRatioStr == "16:9") {
            AspectRatio.RATIO_16_9
        } else {
            AspectRatio.RATIO_4_3
        }

        val targetRational = when (currentAspectRatioStr) {
            "1:1" -> Rational(1, 1)
            "4:5" -> Rational(4, 5)
            else -> Rational(9, 16)
        }

        // 1. Preview
        preview = Preview.Builder()
            .setTargetAspectRatio(targetRatio)
            .setTargetRotation(currentTargetRotation)
            .build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }

        // 2. ImageCapture
        imageCapture = ImageCapture.Builder()
            .setTargetAspectRatio(targetRatio)
            .setTargetRotation(currentTargetRotation)
            .setFlashMode(flashMode)
            .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
            .build()

        // 3. VideoCapture (Optimized to FHD 1080p to prevent 4K/8K thermal heating and lag)
        val recorder = Recorder.Builder()
            .setQualitySelector(QualitySelector.from(Quality.FHD, FallbackStrategy.lowerQualityOrHigherThan(Quality.SD)))
            .build()
        videoCapture = VideoCapture.withOutput(recorder).apply {
            targetRotation = currentTargetRotation
        }

        // 4. OverlayEffect (Real-time GPU overlay running on background cameraExecutor, NOT main UI thread)
        // 프리뷰에는 Flutter 레이어의 TimestampOverlayWidget이 단독으로 표시되도록 하고,
        // 네이티브 효과는 녹화 비디오(VIDEO_CAPTURE)에만 단독 적용하여 타임스탬프가 2겹으로 겹치는 현상 및 불필요한 GPU 렌더링을 원천 차단합니다.
        overlayEffect?.clearOnDrawListener()
        overlayEffect?.close()
        overlayEffect = OverlayEffect(
            CameraEffect.VIDEO_CAPTURE,
            0,
            overlayHandler
        ) { throwable ->
            android.util.Log.e("TimenowCamera", "Overlay error", throwable)
        }.apply {
            setOnDrawListener { frame ->
                val canvas = frame.overlayCanvas
                canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)

                val bmp = overlayBitmap
                if (bmp != null && !bmp.isRecycled) {
                    val canvasW = canvas.width.toFloat()
                    val canvasH = canvas.height.toFloat()
                    val bmpW = bmp.width.toFloat()
                    val bmpH = bmp.height.toFloat()

                    canvas.save()
                    val sensorRotation = camera?.cameraInfo?.sensorRotationDegrees ?: if (isFrontCamera) 270 else 90
                    val needsRotation = (sensorRotation == 90 || sensorRotation == 270)

                    val logicalW: Float
                    val logicalH: Float
                    if (needsRotation) {
                        logicalW = canvasH
                        logicalH = canvasW
                        if (sensorRotation == 270) {
                            canvas.translate(canvasW, 0f)
                            canvas.rotate(90f)
                        } else {
                            canvas.translate(0f, canvasH)
                            canvas.rotate(-90f)
                        }
                    } else {
                        logicalW = canvasW
                        logicalH = canvasH
                    }

                    // 1:1, 4:5, 16:9 모두 CameraX ViewPort(FILL_CENTER)가 적용되어 전체 버퍼의 중앙 영역을 크롭하여 표시합니다.
                    // 따라서 오버레이 비트맵도 전체 버퍼에 늘려 그리지 않고, ViewPort의 가시 영역(Center crop window)에 1:1로 정확히 매핑하여 가로/세로 스케일(scaleX == scaleY)을 완벽히 일치시킵니다.
                    val targetAspect = when (currentAspectRatioStr) {
                        "1:1" -> 1.0f
                        "4:5" -> 4.0f / 5.0f
                        else -> 9.0f / 16.0f
                    }
                    val currentAspect = logicalW / logicalH
                    val visibleW: Float
                    val visibleH: Float
                    if (currentAspect > targetAspect) {
                        visibleH = logicalH
                        visibleW = logicalH * targetAspect
                    } else {
                        visibleW = logicalW
                        visibleH = logicalW / targetAspect
                    }
                    val offsetX = (logicalW - visibleW) / 2f
                    val offsetY = (logicalH - visibleH) / 2f

                    val scaleX = visibleW / bmpW
                    val scaleY = visibleH / bmpH
                    canvas.translate(offsetX, offsetY)
                    canvas.scale(scaleX, scaleY)

                    if (isFrontCamera) {
                        // 전면 카메라 미러링(좌우 반전) 효과를 상쇄하여 글자와 정렬 위치가 정상적으로 보이도록 보정
                        canvas.translate(bmpW, 0f)
                        canvas.scale(-1f, 1f)
                    }
                    try {
                        canvas.drawBitmap(bmp, 0f, 0f, null)
                    } catch (_: Exception) {}
                    canvas.restore()
                }
                true
            }
        }

        // CameraX ViewPort: 1:1, 4:5, 16:9에 맞게 뷰포트를 설정하여 Preview와 VideoCapture가 일치하도록 구성
        val viewPort = ViewPort.Builder(targetRational, currentTargetRotation)
            .setScaleType(ViewPort.FILL_CENTER)
            .build()

        // 5. UseCaseGroup with effect and viewport
        val useCaseGroup = UseCaseGroup.Builder()
            .setViewPort(viewPort)
            .addUseCase(preview!!)
            .addUseCase(imageCapture!!)
            .addUseCase(videoCapture!!)
            .addEffect(overlayEffect!!)
            .build()

        try {
            camera = provider.bindToLifecycle(lifecycleOwner, cameraSelector, useCaseGroup)
            channel.invokeMethod("onCameraInitialized", null)
        } catch (e: Exception) {
            android.util.Log.w("TimenowCamera", "Primary bindToLifecycle failed, scheduling retry: ${e.message}")
            mainHandler.postDelayed({
                try {
                    provider.unbindAll()
                    camera = provider.bindToLifecycle(lifecycleOwner, cameraSelector, useCaseGroup)
                    channel.invokeMethod("onCameraInitialized", null)
                } catch (e2: Exception) {
                    android.util.Log.e("TimenowCamera", "Retry bind failed", e2)
                    try {
                        provider.unbindAll()
                        camera = provider.bindToLifecycle(lifecycleOwner, cameraSelector, preview!!, imageCapture!!, videoCapture!!)
                        channel.invokeMethod("onCameraInitialized", null)
                    } catch (e3: Exception) {
                        e3.printStackTrace()
                    }
                }
            }, 300)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkAudioPermission" -> {
                val granted = ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
                result.success(granted)
            }
            "requestAudioPermission" -> {
                val granted = ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED
                if (granted) {
                    result.success(true)
                } else {
                    val act = activity ?: (context as? Activity) ?: (lifecycleOwner as? Activity)
                    if (act != null) {
                        ActivityCompat.requestPermissions(act, arrayOf(Manifest.permission.RECORD_AUDIO), 1002)
                    }
                    result.success(false)
                }
            }
            "isCameraReady" -> {
                result.success(camera != null)
            }
            "resumeCamera" -> {
                if (camera == null) {
                    mainHandler.post {
                        bindCameraUseCases()
                    }
                }
                result.success(true)
            }
            "setAspectRatio" -> {
                val ratio = call.argument<String>("ratio") ?: "1:1"
                if (recordingState != RecordingState.IDLE) {
                    result.success(false)
                    return
                }
                val changed = (currentAspectRatioStr != ratio)
                currentAspectRatioStr = ratio
                if (changed) {
                    mainHandler.post {
                        bindCameraUseCases()
                    }
                }
                result.success(true)
            }
            "startRecording" -> {
                val outputPath = call.argument<String>("path") ?: run {
                    result.error("INVALID_PATH", "Output path required", null)
                    return
                }
                startRecording(outputPath, result)
            }
            "stopRecording" -> {
                stopRecording(result)
            }
            "takePhoto" -> {
                val outputPath = call.argument<String>("path") ?: run {
                    result.error("INVALID_PATH", "Output path required", null)
                    return
                }
                takePhoto(outputPath, result)
            }
            "updateOverlay" -> {
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes != null) {
                    try {
                        val newBmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                        val oldBmp = overlayBitmap
                        overlayBitmap = newBmp
                        if (oldBmp != null && oldBmp != newBmp) {
                            cameraExecutor.execute {
                                try {
                                    Thread.sleep(50)
                                    if (!oldBmp.isRecycled) {
                                        oldBmp.recycle()
                                    }
                                } catch (_: Exception) {}
                            }
                        }
                    } catch (_: Exception) {}
                }
                result.success(true)
            }
            "switchCamera" -> {
                if (recordingState != RecordingState.IDLE) {
                    result.success(isFrontCamera)
                    return
                }
                isFrontCamera = !isFrontCamera
                bindCameraUseCases()
                result.success(isFrontCamera)
            }
            "setFlash" -> {
                val on = call.argument<Boolean>("on") ?: false
                flashMode = if (on) ImageCapture.FLASH_MODE_ON else ImageCapture.FLASH_MODE_OFF
                imageCapture?.flashMode = flashMode
                camera?.cameraControl?.enableTorch(on)
                result.success(true)
            }
            "setZoom" -> {
                val ratio = call.argument<Double>("zoom")?.toFloat() ?: 1.0f
                camera?.cameraControl?.setZoomRatio(ratio)
                result.success(true)
            }
            "setFocusPoint" -> {
                val nx = call.argument<Double>("x")?.toFloat() ?: 0.5f
                val ny = call.argument<Double>("y")?.toFloat() ?: 0.5f
                val w = previewView.width.toFloat()
                val h = previewView.height.toFloat()
                if (w > 0 && h > 0) {
                    val factory = previewView.meteringPointFactory
                    val point = factory.createPoint(nx * w, ny * h)
                    val action = FocusMeteringAction.Builder(point, FocusMeteringAction.FLAG_AF or FocusMeteringAction.FLAG_AE)
                        .build()
                    camera?.cameraControl?.startFocusAndMetering(action)
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun startRecording(outputPath: String, result: MethodChannel.Result) {
        if (recordingState != RecordingState.IDLE) {
            result.error("BUSY", "Recording cannot start while state is $recordingState", null)
            return
        }

        val vc = videoCapture ?: run {
            result.error("NOT_INITIALIZED", "VideoCapture not ready", null)
            return
        }

        recordingState = RecordingState.STARTING
        startResultCallback = result

        try {
            val outputFile = File(outputPath)
            outputFile.parentFile?.mkdirs()

            vc.targetRotation = currentTargetRotation

            val outputOptions = FileOutputOptions.Builder(outputFile).build()
            var pendingRecording = vc.output.prepareRecording(context, outputOptions)

            if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
                android.util.Log.i("TimenowCamera", "Starting recording with audio enabled")
                pendingRecording = pendingRecording.withAudioEnabled()
            } else {
                android.util.Log.w("TimenowCamera", "RECORD_AUDIO permission not granted, requesting now")
                val act = activity ?: (context as? Activity) ?: (lifecycleOwner as? Activity)
                act?.let {
                    ActivityCompat.requestPermissions(it, arrayOf(Manifest.permission.RECORD_AUDIO), 1002)
                }
            }

            activeRecording = pendingRecording.start(ContextCompat.getMainExecutor(context)) { event: VideoRecordEvent ->
                when (event) {
                    is VideoRecordEvent.Start -> {
                        recordingState = RecordingState.RECORDING
                        startResultCallback?.success(outputPath)
                        startResultCallback = null
                    }
                    is VideoRecordEvent.Finalize -> {
                        recordingState = RecordingState.IDLE
                        activeRecording = null

                        val stopCallback = stopResultCallback
                        stopResultCallback = null

                        val startCallback = startResultCallback
                        startResultCallback = null

                        if (event.hasError()) {
                            android.util.Log.e("TimenowCamera", "Video finalize error: ${event.error}")
                            val errMsg = "Recording error code: ${event.error}"
                            startCallback?.error("START_FAILED", errMsg, null)
                            stopCallback?.error("RECORDING_ERROR", errMsg, null)
                        } else {
                            stopCallback?.success(outputPath)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            recordingState = RecordingState.IDLE
            activeRecording = null
            startResultCallback = null
            result.error("START_FAILED", e.message ?: "Failed to start recording", null)
        }
    }

    private fun stopRecording(result: MethodChannel.Result) {
        if (recordingState == RecordingState.IDLE) {
            result.error("NOT_RECORDING", "No active recording to stop", null)
            return
        }

        if (recordingState == RecordingState.STOPPING) {
            stopResultCallback = result
            return
        }

        if (recordingState == RecordingState.STARTING) {
            recordingState = RecordingState.STOPPING
            stopResultCallback = result
            try {
                activeRecording?.stop()
            } catch (e: Exception) {
                recordingState = RecordingState.IDLE
                activeRecording = null
                stopResultCallback = null
                result.error("STOP_FAILED", e.message ?: "Failed to stop", null)
            }
            return
        }

        recordingState = RecordingState.STOPPING
        stopResultCallback = result
        try {
            activeRecording?.stop()
        } catch (e: Exception) {
            recordingState = RecordingState.IDLE
            activeRecording = null
            stopResultCallback = null
            result.error("STOP_FAILED", e.message ?: "Failed to stop", null)
        }
    }

    private fun takePhoto(outputPath: String, result: MethodChannel.Result) {
        val ic = imageCapture ?: run {
            result.error("NOT_INITIALIZED", "ImageCapture not ready", null)
            return
        }
        val outputFile = File(outputPath)
        outputFile.parentFile?.mkdirs()

        ic.targetRotation = currentTargetRotation

        val outputOptions = ImageCapture.OutputFileOptions.Builder(outputFile).build()
        ic.takePicture(outputOptions, ContextCompat.getMainExecutor(context), object : ImageCapture.OnImageSavedCallback {
            override fun onImageSaved(outputFileResults: ImageCapture.OutputFileResults) {
                result.success(outputPath)
            }
            override fun onError(exception: ImageCaptureException) {
                result.error("CAPTURE_ERROR", exception.message, null)
            }
        })
    }
}

