import Flutter
import UIKit
import AVFoundation
import CoreGraphics

class TimenowPreviewContainerView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if let superBounds = superview?.bounds, superBounds.width > 0, superBounds.height > 0 {
            frame = superBounds
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let superBounds = superview?.bounds, superBounds.width > 0, superBounds.height > 0, frame != superBounds {
            frame = superBounds
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        videoPreviewLayer.frame = bounds
        CATransaction.commit()
    }
}

class TimenowCameraView: NSObject, FlutterPlatformView, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    private let viewId: Int64
    private let messenger: FlutterBinaryMessenger
    private var channel: FlutterMethodChannel?

    private let previewContainer: TimenowPreviewContainerView
    private var previewLayer: AVCaptureVideoPreviewLayer {
        return previewContainer.videoPreviewLayer
    }

    // AVFoundation capture
    private let captureSession = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var audioDeviceInput: AVCaptureDeviceInput?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let audioDataOutput = AVCaptureAudioDataOutput()
    private let captureQueue = DispatchQueue(label: "timenow.camera.captureQueue", qos: .userInitiated)

    // Recording & Overlay
    private var assetWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var audioWriterInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?

    private var isRecording = false
    private var isStopping = false
    private var startSessionTime: CMTime = .invalid
    private var lastVideoPts: CMTime = .invalid
    private var isFrontCamera: Bool
    private var currentAspectRatioStr: String = "1:1"
    private var overlayImage: CGImage?

    private var startResultCallback: FlutterResult?
    private var stopResultCallback: FlutterResult?
    private var recordingOutputPath: String?

    init(frame: CGRect, viewIdentifier: Int64, arguments: Any?, messenger: FlutterBinaryMessenger) {
        self.viewId = viewIdentifier
        self.messenger = messenger
        self.previewContainer = TimenowPreviewContainerView(frame: frame)
        let args = arguments as? [String: Any]
        self.isFrontCamera = (args?["isFrontCamera"] as? Bool) ?? false
        if let ratio = args?["aspectRatio"] as? String {
            self.currentAspectRatioStr = ratio
        }
        super.init()

        self.channel = FlutterMethodChannel(name: "timenow_camera_view_\(viewIdentifier)", binaryMessenger: messenger)
        self.channel?.setMethodCallHandler(self.handle)

        setupPreviewView()
        setupCaptureSession()
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSessionInterruptionEnded(_:)),
            name: .AVCaptureSessionInterruptionEnded,
            object: captureSession
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func handleSessionInterruptionEnded(_ notification: Notification) {
        resumeCaptureSessionIfNeeded()
    }

    @objc private func handleAppDidBecomeActive(_ notification: Notification) {
        resumeCaptureSessionIfNeeded()
    }

    private func resumeCaptureSessionIfNeeded() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            try? AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .videoRecording,
                options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers]
            )
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
            }
            DispatchQueue.main.async {
                if let superBounds = self.previewContainer.superview?.bounds,
                   superBounds.width > 0, superBounds.height > 0 {
                    self.previewContainer.frame = superBounds
                }
                self.previewLayer.frame = self.previewContainer.bounds
                self.previewContainer.setNeedsLayout()
                self.previewContainer.layoutIfNeeded()
            }
        }
    }

    func view() -> UIView {
        return previewContainer
    }

    private func setupPreviewView() {
        previewContainer.backgroundColor = .black
        previewContainer.clipsToBounds = true
        previewContainer.isUserInteractionEnabled = false
        previewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        previewLayer.session = captureSession
        previewLayer.videoGravity = .resizeAspectFill
    }

    private func setupCaptureSession() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            try? AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .videoRecording,
                options: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers]
            )
            try? AVAudioSession.sharedInstance().setActive(true)

            self.captureSession.beginConfiguration()
            self.captureSession.automaticallyConfiguresApplicationAudioSession = false
            self.captureSession.sessionPreset = .hd1920x1080

            // 1. Video Input
            let position: AVCaptureDevice.Position = self.isFrontCamera ? .front : .back
            if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
               let input = try? AVCaptureDeviceInput(device: camera) {
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                    self.videoDeviceInput = input
                }
            }

            // 2. Audio Input
            if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
                AVCaptureDevice.requestAccess(for: .audio) { _ in }
            }
            if let mic = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: mic) {
                if self.captureSession.canAddInput(audioInput) {
                    self.captureSession.addInput(audioInput)
                    self.audioDeviceInput = audioInput
                }
            }

            // 3. Video Output
            self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
            self.videoDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            self.videoDataOutput.setSampleBufferDelegate(self, queue: self.captureQueue)
            if self.captureSession.canAddOutput(self.videoDataOutput) {
                self.captureSession.addOutput(self.videoDataOutput)
                if let connection = self.videoDataOutput.connection(with: .video) {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                    if connection.isVideoMirroringSupported {
                        connection.isVideoMirrored = self.isFrontCamera
                    }
                }
            }

            // 4. Audio Output
            self.audioDataOutput.setSampleBufferDelegate(self, queue: self.captureQueue)
            if self.captureSession.canAddOutput(self.audioDataOutput) {
                self.captureSession.addOutput(self.audioDataOutput)
            }

            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()

            DispatchQueue.main.async {
                self.previewLayer.frame = self.previewContainer.bounds
                self.previewContainer.setNeedsLayout()
                self.channel?.invokeMethod("onCameraInitialized", arguments: nil)
            }
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isCameraReady":
            result(captureSession.isRunning)
        case "resumeCamera":
            resumeCaptureSessionIfNeeded()
            result(true)
        case "setAspectRatio":
            let args = call.arguments as? [String: Any]
            self.currentAspectRatioStr = (args?["ratio"] as? String) ?? "1:1"
            let syncLayout = { [weak self] in
                guard let self = self else { return }
                if let superBounds = self.previewContainer.superview?.bounds,
                   superBounds.width > 0, superBounds.height > 0 {
                    self.previewContainer.frame = superBounds
                }
                self.previewLayer.frame = self.previewContainer.bounds
                self.previewContainer.setNeedsLayout()
                self.previewContainer.layoutIfNeeded()
            }
            DispatchQueue.main.async(execute: syncLayout)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04, execute: syncLayout)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: syncLayout)
            result(true)

        case "updateOverlay":
            guard let args = call.arguments as? [String: Any],
                  let flutterData = args["bytes"] as? FlutterStandardTypedData else {
                result(false)
                return
            }
            if let uiImage = UIImage(data: flutterData.data) {
                // UIImage의 cgImage 추출 시 내부 orientation을 정규화하여 생성
                UIGraphicsBeginImageContextWithOptions(uiImage.size, false, 1.0)
                uiImage.draw(in: CGRect(origin: .zero, size: uiImage.size))
                let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                self.overlayImage = normalizedImage?.cgImage ?? uiImage.cgImage
            }
            result(true)

        case "switchCamera":
            if isRecording {
                result(isFrontCamera)
                return
            }
            captureQueue.async { [weak self] in
                guard let self = self else { return }
                self.isFrontCamera = !self.isFrontCamera
                self.captureSession.beginConfiguration()
                if let oldInput = self.videoDeviceInput {
                    self.captureSession.removeInput(oldInput)
                }
                let position: AVCaptureDevice.Position = self.isFrontCamera ? .front : .back
                if let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
                   let newInput = try? AVCaptureDeviceInput(device: newCamera) {
                    if self.captureSession.canAddInput(newInput) {
                        self.captureSession.addInput(newInput)
                        self.videoDeviceInput = newInput
                    }
                }
                if let connection = self.videoDataOutput.connection(with: .video) {
                    if connection.isVideoOrientationSupported {
                        connection.videoOrientation = .portrait
                    }
                    if connection.isVideoMirroringSupported {
                        connection.isVideoMirrored = self.isFrontCamera
                    }
                }
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    result(self.isFrontCamera)
                }
            }

        case "setFlash":
            let args = call.arguments as? [String: Any]
            let on = (args?["on"] as? Bool) ?? false
            guard let device = videoDeviceInput?.device, device.hasTorch else {
                result(true)
                return
            }
            try? device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
            result(true)

        case "setZoom":
            let args = call.arguments as? [String: Any]
            let zoom = CGFloat((args?["zoom"] as? Double) ?? 1.0)
            guard let device = videoDeviceInput?.device else {
                result(true)
                return
            }
            try? device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(zoom, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
            result(true)

        case "setFocusPoint":
            let args = call.arguments as? [String: Any]
            let x = CGFloat((args?["x"] as? Double) ?? 0.5)
            let y = CGFloat((args?["y"] as? Double) ?? 0.5)
            guard let device = videoDeviceInput?.device else {
                result(true)
                return
            }
            let bounds = previewLayer.bounds
            let layerPoint = CGPoint(x: x * bounds.width, y: y * bounds.height)
            let devicePoint = (bounds.width > 0 && bounds.height > 0)
                ? previewLayer.captureDevicePointConverted(fromLayerPoint: layerPoint)
                : CGPoint(x: y, y: 1.0 - x)
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = devicePoint
                    if device.isFocusModeSupported(.autoFocus) {
                        device.focusMode = .autoFocus
                    } else if device.isFocusModeSupported(.continuousAutoFocus) {
                        device.focusMode = .continuousAutoFocus
                    }
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = devicePoint
                    if device.isExposureModeSupported(.autoExpose) {
                        device.exposureMode = .autoExpose
                    } else if device.isExposureModeSupported(.continuousAutoExposure) {
                        device.exposureMode = .continuousAutoExposure
                    }
                }
                device.isSubjectAreaChangeMonitoringEnabled = true
                device.unlockForConfiguration()
            } catch {}
            result(true)

        case "checkAudioPermission":
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            result(status == .authorized)

        case "requestAudioPermission":
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            if status == .authorized {
                result(true)
            } else if status == .notDetermined {
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    DispatchQueue.main.async {
                        result(granted)
                    }
                }
            } else {
                result(false)
            }

        case "startRecording":
            guard let args = call.arguments as? [String: Any],
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_PATH", message: "Output path required", details: nil))
                return
            }
            startRecording(path: path, result: result)

        case "stopRecording":
            stopRecording(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startRecording(path: String, result: @escaping FlutterResult) {
        if isRecording {
            result(FlutterError(code: "BUSY", message: "Already recording", details: nil))
            return
        }
        self.recordingOutputPath = path
        let url = URL(fileURLWithPath: path)
        try? FileManager.default.removeItem(at: url)

        captureQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)

                // Target crop resolution based on aspect ratio (standard 1080 width)
                let targetW: Int = 1080
                let targetH: Int
                switch self.currentAspectRatioStr {
                case "1:1":
                    targetH = 1080
                case "4:5":
                    targetH = 1350
                default: // 9:16
                    targetH = 1920
                }

                let videoSettings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: targetW,
                    AVVideoHeightKey: targetH,
                    AVVideoCompressionPropertiesKey: [
                        AVVideoAverageBitRateKey: 8_000_000,
                        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
                    ]
                ]

                let vInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
                vInput.expectsMediaDataInRealTime = true

                let sourcePixelBufferAttributes: [String: Any] = [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
                    kCVPixelBufferWidthKey as String: targetW,
                    kCVPixelBufferHeightKey as String: targetH
                ]
                let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                    assetWriterInput: vInput,
                    sourcePixelBufferAttributes: sourcePixelBufferAttributes
                )

                if writer.canAdd(vInput) {
                    writer.add(vInput)
                }

                // Audio input
                let audioSettings: [String: Any] = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: 2,
                    AVSampleRateKey: 44100.0,
                    AVEncoderBitRateKey: 128000
                ]
                let aInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
                aInput.expectsMediaDataInRealTime = true
                if writer.canAdd(aInput) {
                    writer.add(aInput)
                }

                writer.startWriting()

                self.assetWriter = writer
                self.videoWriterInput = vInput
                self.audioWriterInput = aInput
                self.pixelBufferAdaptor = adaptor
                self.startSessionTime = .invalid
                self.lastVideoPts = .invalid
                self.isRecording = true
                self.isStopping = false

                DispatchQueue.main.async {
                    result(path)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    private func stopRecording(result: @escaping FlutterResult) {
        if !isRecording || isStopping {
            result(FlutterError(code: "NOT_RECORDING", message: "Not recording", details: nil))
            return
        }
        self.isStopping = true
        self.stopResultCallback = result

        captureQueue.async { [weak self] in
            guard let self = self else { return }
            self.videoWriterInput?.markAsFinished()
            self.audioWriterInput?.markAsFinished()
            self.assetWriter?.finishWriting { [weak self] in
                guard let self = self else { return }
                self.isRecording = false
                self.isStopping = false
                let path = self.recordingOutputPath ?? ""
                DispatchQueue.main.async {
                    self.stopResultCallback?(path)
                    self.stopResultCallback = nil
                }
            }
        }
    }

    // MARK: - SampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isRecording, !isStopping, let writer = assetWriter, writer.status == .writing else { return }

        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        guard pts.isValid else { return }

        if output == videoDataOutput {
            guard let vInput = videoWriterInput, vInput.isReadyForMoreMediaData,
                  let adaptor = pixelBufferAdaptor,
                  let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            if startSessionTime == .invalid {
                startSessionTime = pts
                writer.startSession(atSourceTime: pts)
            }

            if lastVideoPts != .invalid && CMTimeCompare(pts, lastVideoPts) <= 0 {
                return
            }

            if let compositedBuffer = renderFrameWithOverlay(sourceBuffer: imageBuffer, adaptor: adaptor) {
                if adaptor.append(compositedBuffer, withPresentationTime: pts) {
                    lastVideoPts = pts
                }
            }
        } else if output == audioDataOutput {
            // 첫 비디오 프레임으로 세션이 시작된 이후의 오디오 샘플만 기록하여 트랙 싱크 어긋남 방지
            guard startSessionTime != .invalid,
                  CMTimeCompare(pts, startSessionTime) >= 0,
                  let aInput = audioWriterInput,
                  aInput.isReadyForMoreMediaData else { return }
            aInput.append(sampleBuffer)
        }
    }

    private func renderFrameWithOverlay(sourceBuffer: CVPixelBuffer, adaptor: AVAssetWriterInputPixelBufferAdaptor) -> CVPixelBuffer? {
        CVPixelBufferLockBaseAddress(sourceBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(sourceBuffer, .readOnly) }

        guard let pool = adaptor.pixelBufferPool else { return nil }
        var targetBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &targetBuffer)
        guard status == kCVReturnSuccess, let outputBuffer = targetBuffer else { return nil }

        CVPixelBufferLockBaseAddress(outputBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(outputBuffer, []) }

        let targetW = CVPixelBufferGetWidth(outputBuffer)
        let targetH = CVPixelBufferGetHeight(outputBuffer)
        let targetBase = CVPixelBufferGetBaseAddress(outputBuffer)
        let targetBytesPerRow = CVPixelBufferGetBytesPerRow(outputBuffer)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: targetBase,
                width: targetW,
                height: targetH,
                bitsPerComponent: 8,
                bytesPerRow: targetBytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
              ) else { return nil }

        // 1. Draw camera sensor image (center-cropped to target aspect ratio)
        let srcW = CVPixelBufferGetWidth(sourceBuffer)
        let srcH = CVPixelBufferGetHeight(sourceBuffer)
        let srcBase = CVPixelBufferGetBaseAddress(sourceBuffer)
        let srcBytesPerRow = CVPixelBufferGetBytesPerRow(sourceBuffer)

        if let srcContext = CGContext(
            data: srcBase,
            width: srcW,
            height: srcH,
            bitsPerComponent: 8,
            bytesPerRow: srcBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ), let cameraImage = srcContext.makeImage() {
            // Center crop calculation
            let srcAspect = CGFloat(srcW) / CGFloat(srcH)
            let targetAspect = CGFloat(targetW) / CGFloat(targetH)
            var cropRect = CGRect(x: 0, y: 0, width: srcW, height: srcH)

            if srcAspect > targetAspect {
                let visibleW = CGFloat(srcH) * targetAspect
                cropRect.origin.x = (CGFloat(srcW) - visibleW) / 2.0
                cropRect.size.width = visibleW
            } else {
                let visibleH = CGFloat(srcW) / targetAspect
                cropRect.origin.y = (CGFloat(srcH) - visibleH) / 2.0
                cropRect.size.height = visibleH
            }

            if let croppedCameraImage = cameraImage.cropping(to: cropRect) {
                context.draw(croppedCameraImage, in: CGRect(x: 0, y: 0, width: targetW, height: targetH))
            }
        }

        // 2. Draw live timestamp overlay image on top
        // CGContext.draw(_:in:)는 croppedCameraImage와 동일하게 CGImage의 상단을 CVPixelBuffer의 상단(메모리 row 0)에 매핑하므로
        // 별도의 Y-flip 변환 없이 그대로 그리면 타임스탬프와 위치 정보가 정방향으로 합성됩니다.
        if let overlay = overlayImage {
            context.draw(overlay, in: CGRect(x: 0, y: 0, width: targetW, height: targetH))
        }

        return outputBuffer
    }

    func dispose() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.stopRunning()
            self.channel?.setMethodCallHandler(nil)
            self.channel = nil
        }
    }
}

