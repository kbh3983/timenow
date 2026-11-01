import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../timestamp_overlays.dart';
import '../timestamp_metadata.dart';

class VideoProcessingService {
  static final VideoProcessingService _instance =
      VideoProcessingService._internal();
  factory VideoProcessingService() => _instance;
  VideoProcessingService._internal();

  /// 비디오 파일에 타임스탬프를 실시간(초 단위 업데이트)으로 합성하여 새 파일로 저장
  Future<File> processVideoWithTimestamp({
    required File rawVideoFile,
    required DateTime startTime,
    required Duration duration,
    required TimestampDesign design,
    required Alignment alignment,
    required double fontSize,
    required CameraAspectRatio aspectRatio,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final overlayDir = Directory('${tempDir.path}/overlays_$uniqueId');
    await overlayDir.create(recursive: true);

    final outputPath = '${tempDir.path}/timenow_video_$uniqueId.mp4';
    final totalSeconds = duration.inSeconds.clamp(1, 3600);

    try {
      // 1. 비디오 해상도 기준 캔버스 크기 결정 (일반 세로 비디오 1080x1920 기준)
      // FFmpeg가 비디오 크기에 맞게 오버레이하도록 표준 타임스탬프 렌더링 너비/높이 설정
      const double canvasW = 1080.0;
      double canvasH;
      switch (aspectRatio) {
        case CameraAspectRatio.ratio1x1:
          canvasH = 1080.0;
          break;
        case CameraAspectRatio.ratio5x4:
          canvasH = 1350.0; // 4:5
          break;
        case CameraAspectRatio.ratio16x9:
          canvasH = 1920.0; // 9:16
          break;
      }

      // 폰트 크기 비율 보정 (화면 픽셀 대비 캔버스 1080p 기준 스케일)
      // 모바일 프리뷰(약 390px 기준)에서 캔버스(1080px)로 변환 시 약 2.7배 스케일
      final double scaledFontSize = fontSize * 2.7;

      // 2. 각 초마다 타임스탬프 투명 PNG 이미지 생성
      for (int s = 0; s <= totalSeconds; s++) {
        final currentTime = startTime.add(Duration(seconds: s));
        final pngBytes = await _renderTimestampToPng(
          currentTime: currentTime,
          design: design,
          alignment: alignment,
          fontSize: scaledFontSize,
          canvasWidth: canvasW,
          canvasHeight: canvasH,
        );

        final frameFile = File('${overlayDir.path}/frame_$s.png');
        await frameFile.writeAsBytes(pngBytes);
      }

      // 3. FFmpeg 필터 체인 구성
      // - 원본 비디오를 선택한 비율로 크롭
      // - 1fps 이미지 시퀀스를 오버레이
      String cropFilter;
      switch (aspectRatio) {
        case CameraAspectRatio.ratio1x1:
          cropFilter = 'crop=min(iw\\,ih):min(iw\\,ih)';
          break;
        case CameraAspectRatio.ratio5x4:
          cropFilter = 'crop=ih*4/5:ih';
          break;
        case CameraAspectRatio.ratio16x9:
          cropFilter = 'null'; // 원본 비율 그대로
          break;
      }

      // FFmpeg 명령어:
      // 입력 0: 원본 비디오
      // 입력 1: 초당 1장의 타임스탬프 이미지 시퀀스
      // filter_complex: 크롭 후 오버레이 합성, 해상도 1080p 맞춤
      String filterComplex;
      if (cropFilter == 'null') {
        filterComplex =
            '[0:v]scale=${canvasW.toInt()}:${canvasH.toInt()}[base];[base][1:v]overlay=0:0[outv]';
      } else {
        filterComplex =
            '[0:v]$cropFilter,scale=${canvasW.toInt()}:${canvasH.toInt()}[base];[base][1:v]overlay=0:0[outv]';
      }

      final inputPattern = '${overlayDir.path}/frame_%d.png';
      final command =
          '-y -i "${rawVideoFile.path}" -framerate 1 -i "$inputPattern" '
          '-filter_complex "$filterComplex" -map "[outv]" -map 0:a? '
          '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -pix_fmt yuv420p "$outputPath"';

      debugPrint('VideoProcessingService: executing FFmpeg...');
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('VideoProcessingService: FFmpeg success!');
        return File(outputPath);
      } else {
        final logs = await session.getAllLogsAsString();
        debugPrint('VideoProcessingService: FFmpeg failed: $logs');
        // 실패 시 원본 비디오 폴백
        return rawVideoFile;
      }
    } catch (e) {
      debugPrint('VideoProcessingService error: $e');
      return rawVideoFile;
    } finally {
      // 임시 오버레이 이미지 정리
      try {
        if (await overlayDir.exists()) {
          await overlayDir.delete(recursive: true);
        }
      } catch (_) {}
    }
  }

  /// Canvas를 이용해 타임스탬프를 투명 PNG 바이트로 초고속 렌더링
  Future<List<int>> _renderTimestampToPng({
    required DateTime currentTime,
    required TimestampDesign design,
    required Alignment alignment,
    required double fontSize,
    required double canvasWidth,
    required double canvasHeight,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasWidth, canvasHeight));

    final text = TimestampMetadata.getFormattedDateTime(design, currentTime);
    final fontFamily = TimestampMetadata.getFontFamily(design) ?? 'NanumSquareB';
    final shadows = TimestampMetadata.getShadows(design);

    final textStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      shadows: shadows ??
          const [
            Shadow(
              color: Colors.black54,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: canvasWidth - 80);

    // Alignment에 따른 좌표 계산 (여백 40px)
    const padding = 40.0;
    double x = padding;
    double y = canvasHeight - textPainter.height - padding;

    if (alignment == Alignment.topLeft) {
      x = padding;
      y = padding;
    } else if (alignment == Alignment.topRight) {
      x = canvasWidth - textPainter.width - padding;
      y = padding;
    } else if (alignment == Alignment.bottomLeft) {
      x = padding;
      y = canvasHeight - textPainter.height - padding;
    } else if (alignment == Alignment.bottomRight) {
      x = canvasWidth - textPainter.width - padding;
      y = canvasHeight - textPainter.height - padding;
    } else if (alignment == Alignment.center) {
      x = (canvasWidth - textPainter.width) / 2;
      y = (canvasHeight - textPainter.height) / 2;
    }

    textPainter.paint(canvas, Offset(x, y));

    final picture = recorder.endRecording();
    final image = await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}
