import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import 'package:intl/intl.dart' hide TextDirection;
import '../stamps/sample_stamp_renderer.dart';
import '../stamps/stamp_text_store.dart';
import '../timestamp_overlays.dart';
import '../timestamp_metadata.dart';
import '../ux_config.dart';
import 'app_settings_service.dart';

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
          scale: 2.7,
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

      // 오디오 하드웨어 팝 노이즈(마이크 전원 인가 0.0~0.5초 쿵/뚝 소리 & 녹화 종료 버튼 클릭 시 끝 0.08초 뚝 소리) 원천 제거
      // 1. 시작 0.5초 완전 무음 후 0.08초 페이드인
      // 2. areverse로 뒤집어 끝 0.08초 완전 무음 후 0.10초 페이드인
      // 3. aresample=async=1:first_pts=0 으로 비디오-오디오 타임스탬프 동기화 보장
      const cleanAudioFilter =
          "volume=0:enable='between(t\\,0\\,0.5)',afade=t=in:ss=0.5:d=0.08,areverse,volume=0:enable='between(t\\,0\\,0.08)',afade=t=in:ss=0.08:d=0.1,areverse,aresample=async=1:first_pts=0";

      final inputPattern = '${overlayDir.path}/frame_%d.png';
      final command =
          '-y -i "${rawVideoFile.path}" -framerate 1 -i "$inputPattern" '
          '-filter_complex "$filterComplex" -map "[outv]" -map 0:a? '
          '-af "$cleanAudioFilter" '
          '-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 192k -pix_fmt yuv420p '
          '-avoid_negative_ts make_zero -max_muxing_queue_size 1024 "$outputPath"';

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

  /// 비디오를 지정된 비율(1:1, 4:5 등)로 크롭하고, 전면 카메라일 경우 수평 반전(hflip)하며,
  /// 마이크 전원 인가 및 종료 시 발생하는 팝 노이즈("뚝!" 소리)를 원천 제거하여 반환합니다.
  Future<File> processRecordedVideo({
    required File rawVideoFile,
    double? aspectRatioValue, // 1.0 (1:1), 0.8 (4:5), 9/16, etc.
    bool mirrorHorizontally = false,
  }) async {
    try {
      final bool needsRatioCrop = aspectRatioValue != null &&
          (aspectRatioValue - (9.0 / 16.0)).abs() > 0.05;

      final List<String> vFilters = [];
      if (needsRatioCrop) {
        if ((aspectRatioValue - 1.0).abs() < 0.05) {
          // 1:1 square crop from 9:16 (1080x1920 -> 1080x1080)
          vFilters.add('crop=min(iw\\,ih):min(iw\\,ih)');
        } else if ((aspectRatioValue - 0.8).abs() < 0.05) {
          // 4:5 crop (universal for 4:3 or 16:9 recorded stream)
          vFilters.add('crop=min(iw\\,ih*4/5):min(iw*5/4\\,ih)');
        }
      }

      if (mirrorHorizontally) {
        vFilters.add('hflip');
      }

      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // 오디오 시작 하드웨어 팝 노이즈(0.0~0.5초) 및 녹화 종료 팝(마지막 0.08초) 원천 제거
      const audioFilter =
          "volume=0:enable='between(t\\,0\\,0.5)',afade=t=in:ss=0.5:d=0.08,areverse,volume=0:enable='between(t\\,0\\,0.08)',afade=t=in:ss=0.08:d=0.1,areverse,aresample=async=1:first_pts=0";

      final String command;
      if (vFilters.isNotEmpty) {
        final vf = vFilters.join(',');
        command =
            '-y -i "${rawVideoFile.path}" -vf "$vf" -af "$audioFilter" -c:v libx264 -preset ultrafast -crf 20 -pix_fmt yuv420p -c:a aac -b:a 192k -avoid_negative_ts make_zero -max_muxing_queue_size 1024 "$outputPath"';
      } else {
        // 비디오 필터가 없으면 비디오 스트림은 copy하여 0.05초 만에 오디오만 고속 클린업 (타임스탬프 동기화 보장)
        command =
            '-y -i "${rawVideoFile.path}" -c:v copy -af "$audioFilter" -c:a aac -b:a 192k -avoid_negative_ts make_zero -max_muxing_queue_size 1024 "$outputPath"';
      }

      debugPrint('VideoProcessingService: processing video with FFmpeg: $command');
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        return File(outputPath);
      } else {
        final logs = await session.getAllLogsAsString();
        debugPrint(
            'VideoProcessingService: process video failed: $logs, returning original');
        return rawVideoFile;
      }
    } catch (e) {
      debugPrint('VideoProcessingService process error: $e');
      return rawVideoFile;
    }
  }

  /// 하위 호환성을 위한 메서드
  Future<File> cropVideoToAspectRatio({
    required File rawVideoFile,
    required double aspectRatioValue,
  }) =>
      processRecordedVideo(
        rawVideoFile: rawVideoFile,
        aspectRatioValue: aspectRatioValue,
      );

  /// Canvas를 이용해 타임스탬프를 투명 PNG 바이트로 초고속 렌더링 (공개 메서드)
  Future<List<int>> renderTimestampBytes({
    required DateTime currentTime,
    required TimestampDesign design,
    required Alignment alignment,
    required double fontSize,
    required double canvasWidth,
    required double canvasHeight,
    Rect? cropRect,
    double? scale,
  }) =>
      _renderTimestampToPng(
        currentTime: currentTime,
        design: design,
        alignment: alignment,
        fontSize: fontSize,
        canvasWidth: canvasWidth,
        canvasHeight: canvasHeight,
        cropRect: cropRect,
        scale: scale,
      );

  static final Map<String, ui.Image> _uiImageCache = {};

  Future<ui.Image?> _loadUiImage(String assetPath) async {
    if (_uiImageCache.containsKey(assetPath)) {
      return _uiImageCache[assetPath];
    }
    try {
      final byteData = await rootBundle.load(assetPath);
      final codec =
          await ui.instantiateImageCodec(byteData.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _uiImageCache[assetPath] = frame.image;
      return frame.image;
    } catch (e) {
      debugPrint('Error loading UI image $assetPath: $e');
      return null;
    }
  }

  Offset _calcPos(
    Alignment alignment,
    Rect activeBox,
    double w,
    double h, {
    double padding = 40.0,
  }) {
    double x;
    double y;

    if (alignment == Alignment.topLeft) {
      x = activeBox.left + padding;
      y = activeBox.top + padding;
    } else if (alignment == Alignment.topCenter) {
      x = activeBox.left + (activeBox.width - w) / 2;
      y = activeBox.top + padding;
    } else if (alignment == Alignment.topRight) {
      x = activeBox.right - w - padding;
      y = activeBox.top + padding;
    } else if (alignment == Alignment.bottomLeft) {
      x = activeBox.left + padding;
      y = activeBox.bottom - h - padding;
    } else if (alignment == Alignment.bottomCenter) {
      x = activeBox.left + (activeBox.width - w) / 2;
      y = activeBox.bottom - h - padding;
    } else if (alignment == Alignment.bottomRight) {
      x = activeBox.right - w - padding;
      y = activeBox.bottom - h - padding;
    } else if (alignment == Alignment.center) {
      x = activeBox.left + (activeBox.width - w) / 2;
      y = activeBox.top + (activeBox.height - h) / 2;
    } else {
      final normX = (alignment.x + 1) / 2;
      final normY = (alignment.y + 1) / 2;
      x = activeBox.left +
          padding +
          (activeBox.width - w - 2 * padding) * normX;
      y = activeBox.top +
          padding +
          (activeBox.height - h - 2 * padding) * normY;
    }
    return Offset(x, y);
  }

  void _drawCurvedText({
    required Canvas canvas,
    required String text,
    required TextStyle textStyle,
    required double radius,
    required Offset centerOffset,
    required double boxWidth,
    required double boxHeight,
  }) {
    double totalTextLength = 0.0;
    final textPainters = <TextPainter>[];
    for (int i = 0; i < text.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainters.add(tp);
      totalTextLength += tp.width;
    }

    final totalAngle = totalTextLength / radius;
    final center = Offset(
      centerOffset.dx + boxWidth / 2,
      centerOffset.dy + radius + (textStyle.fontSize ?? 10) * 0.3,
    );

    double currentAngle = -math.pi / 2 - (totalAngle / 2);

    for (final tp in textPainters) {
      final charAngle = tp.width / radius;
      final midAngle = currentAngle + (charAngle / 2);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(midAngle + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -radius - tp.height / 2));
      canvas.restore();

      currentAngle += charAngle;
    }
  }

  void _drawLocationPin(
    Canvas canvas,
    Offset offset,
    double size,
    Paint paint, {
    Shadow? shadow,
  }) {
    final scale = size / 24.0;
    final path = Path();
    path.moveTo(offset.dx + 12.0 * scale, offset.dy + 2.0 * scale);
    path.cubicTo(
      offset.dx + 8.13 * scale, offset.dy + 2.0 * scale,
      offset.dx + 5.0 * scale, offset.dy + 5.13 * scale,
      offset.dx + 5.0 * scale, offset.dy + 9.0 * scale,
    );
    path.cubicTo(
      offset.dx + 5.0 * scale, offset.dy + 14.25 * scale,
      offset.dx + 12.0 * scale, offset.dy + 22.0 * scale,
      offset.dx + 12.0 * scale, offset.dy + 22.0 * scale,
    );
    path.cubicTo(
      offset.dx + 12.0 * scale, offset.dy + 22.0 * scale,
      offset.dx + 19.0 * scale, offset.dy + 14.25 * scale,
      offset.dx + 19.0 * scale, offset.dy + 9.0 * scale,
    );
    path.cubicTo(
      offset.dx + 19.0 * scale, offset.dy + 5.13 * scale,
      offset.dx + 15.87 * scale, offset.dy + 2.0 * scale,
      offset.dx + 12.0 * scale, offset.dy + 2.0 * scale,
    );
    path.close();

    final holePath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(offset.dx + 12.0 * scale, offset.dy + 9.0 * scale),
        radius: 2.5 * scale,
      ));

    final finalPath = Path.combine(PathOperation.difference, path, holePath);

    if (shadow != null) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
      canvas.drawPath(finalPath.shift(shadow.offset), shadowPaint);
    }
    canvas.drawPath(finalPath, paint);
  }

  /// Canvas를 이용해 타임스탬프를 투명 PNG 바이트로 초고속 렌더링
  Future<List<int>> _renderTimestampToPng({
    required DateTime currentTime,
    required TimestampDesign design,
    required Alignment alignment,
    required double fontSize,
    required double canvasWidth,
    required double canvasHeight,
    Rect? cropRect,
    double? scale,
  }) async {
    if (design == TimestampDesign.none) {
      return const [];
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasWidth, canvasHeight),
    );

    final activeBox =
        cropRect ?? Rect.fromLTWH(0, 0, canvasWidth, canvasHeight);
    // 사진 모드의 390 기준 좌표계(viewScale = width / 390.0)와 100% 동일한 비례 스케일
    final double baseScale = activeBox.width / kSampleBaseWidth;
    final double incomingScale = (scale != null && scale > 0) ? scale : baseScale;
    final double logicalFontSize = fontSize / incomingScale;
    final double effectiveFontSize = logicalFontSize * baseScale;
    final double effectiveScale = baseScale;
    // 사진 모드의 Container(margin: EdgeInsets.all(16 * viewScale))와 동일한 여백 스케일
    final double edgePadding = 16.0 * effectiveScale;

    final rawShadows =
        TimestampMetadata.getShadows(design) ?? CameraUX.defaultShadows;
    final shadows = rawShadows
        .map(
          (s) => Shadow(
            color: s.color,
            offset: s.offset * effectiveScale,
            blurRadius: s.blurRadius * effectiveScale,
          ),
        )
        .toList();

    final maxTextWidth = math.max(0.0, activeBox.width - edgePadding * 2);

    // 스탬프 가로폭(w)이 가용 안전 폭(maxTextWidth)을 초과할 경우,
    // 줄바꿈이나 말줄임표('...') 없이 한 줄 비율을 유지하며 안전 영역 안에 맞추는 헬퍼
    void paintFittedStamp(
      double w,
      double h,
      void Function(Offset origin) draw,
    ) {
      final fit = (w > maxTextWidth && w > 0 && maxTextWidth > 0)
          ? (maxTextWidth / w)
          : 1.0;
      final pos = _calcPos(
        alignment,
        activeBox,
        w * fit,
        h * fit,
        padding: edgePadding,
      );
      if (fit == 1.0) {
        draw(pos);
      } else {
        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.scale(fit);
        draw(Offset.zero);
        canvas.restore();
      }
    }

    TextAlign textAlign = TextAlign.center;
    if (alignment.x < -0.2) {
      textAlign = TextAlign.left;
    } else if (alignment.x > 0.2) {
      textAlign = TextAlign.right;
    }

    switch (design) {
      case TimestampDesign.none:
        return const [];

      case TimestampDesign.n1_1: {
        final text = TimestampMetadata.getFormattedDateTime(design, currentTime);
        final tp = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: CameraUX.fontRubberNippleFactory,
              fontSize: effectiveFontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textAlign: textAlign,
        )..layout();
        paintFittedStamp(tp.width, tp.height, (pos) {
          tp.paint(canvas, pos);
        });
        break;
      }

      case TimestampDesign.n1_2: {
        final text = TimestampMetadata.getFormattedDateTime(design, currentTime);
        final tp = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: CameraUX.fontNixieOne,
              fontSize: effectiveFontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textAlign: textAlign,
        )..layout();
        paintFittedStamp(tp.width, tp.height, (pos) {
          tp.paint(canvas, pos);
        });
        break;
      }

      case TimestampDesign.n2_1: {
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        final weekday = weekdays[currentTime.weekday - 1];
        final dateStr =
            '${DateFormat('yyyy년 MM월 dd일').format(currentTime)} ($weekday)';
        final period = currentTime.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('h:mm').format(currentTime)}';
        final dateTp = TextPainter(
          text: TextSpan(
            text: dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24OnePrettyNight,
              fontSize: effectiveFontSize * 0.36,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        final timeTp = TextPainter(
          text: TextSpan(
            text: timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24OnePrettyNight,
              fontSize: effectiveFontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        final gap = 2.0 * effectiveScale;
        final totalW = math.max(dateTp.width, timeTp.width);
        final totalH = dateTp.height + gap + timeTp.height;
        paintFittedStamp(totalW, totalH, (pos) {
          dateTp.paint(
            canvas,
            Offset(pos.dx + (totalW - dateTp.width) / 2, pos.dy),
          );
          timeTp.paint(
            canvas,
            Offset(
              pos.dx + (totalW - timeTp.width) / 2,
              pos.dy + dateTp.height + gap,
            ),
          );
        });
        break;
      }

      case TimestampDesign.n2_2: {
        final dateStr = DateFormat('yyyy년 MM월 dd일').format(currentTime);
        final period = currentTime.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(currentTime)}';
        final dateTp = TextPainter(
          text: TextSpan(
            text: dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumAmsterdam,
              fontSize: effectiveFontSize * 0.52,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        final timeTp = TextPainter(
          text: TextSpan(
            text: timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumAmsterdam,
              fontSize: effectiveFontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        final gap = 2.0 * effectiveScale;
        final totalW = math.max(dateTp.width, timeTp.width);
        final totalH = dateTp.height + gap + timeTp.height;
        paintFittedStamp(totalW, totalH, (pos) {
          dateTp.paint(
            canvas,
            Offset(pos.dx + (totalW - dateTp.width) / 2, pos.dy),
          );
          timeTp.paint(
            canvas,
            Offset(
              pos.dx + (totalW - timeTp.width) / 2,
              pos.dy + dateTp.height + gap,
            ),
          );
        });
        break;
      }

      case TimestampDesign.n3_1: {
        final dateStr = DateFormat('dd MMM, yyyy', 'en_US').format(currentTime);
        final dayStr = DateFormat('EEEE', 'en_US').format(currentTime);
        final period = currentTime.hour < 12 ? 'AM' : 'PM';
        final timeStr = '$period ${DateFormat('hh:mm').format(currentTime)}';
        final lineStyle = TextStyle(
          fontFamily: CameraUX.fontNanumBarunpen,
          shadows: shadows,
          color: Colors.white,
          fontSize: effectiveFontSize,
          height: 1.1,
        );
        final line1Tp = TextPainter(
          text: TextSpan(text: dateStr, style: lineStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final line2Tp = TextPainter(
          text: TextSpan(text: dayStr, style: lineStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final line3Tp = TextPainter(
          text: TextSpan(text: timeStr, style: lineStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        final totalW = math.max(
          line1Tp.width,
          math.max(line2Tp.width, line3Tp.width),
        );
        final totalH = line1Tp.height + line2Tp.height + line3Tp.height;
        paintFittedStamp(totalW, totalH, (pos) {
          double getX(double w) {
            if (alignment.x < -0.2) return pos.dx;
            if (alignment.x > 0.2) return pos.dx + (totalW - w);
            return pos.dx + (totalW - w) / 2;
          }

          line1Tp.paint(canvas, Offset(getX(line1Tp.width), pos.dy));
          line2Tp.paint(
            canvas,
            Offset(getX(line2Tp.width), pos.dy + line1Tp.height),
          );
          line3Tp.paint(
            canvas,
            Offset(
              getX(line3Tp.width),
              pos.dy + line1Tp.height + line2Tp.height,
            ),
          );
        });
        break;
      }

      case TimestampDesign.n3_2: {
        final yearStr = DateFormat('yyyy').format(currentTime);
        final dateStr = DateFormat('MMMM dd', 'en_US').format(currentTime);
        final period = currentTime.hour < 12 ? 'AM' : 'PM';
        final timeStr = '$period ${DateFormat('hh:mm').format(currentTime)}';
        final lineStyle = TextStyle(
          fontFamily: CameraUX.fontCafe24Simplehae,
          shadows: shadows,
          color: Colors.white,
          fontSize: effectiveFontSize,
          height: 1.0,
        );
        final line1Tp = TextPainter(
          text: TextSpan(text: yearStr, style: lineStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final line2Tp = TextPainter(
          text: TextSpan(text: dateStr, style: lineStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final line3Tp = TextPainter(
          text: TextSpan(text: timeStr, style: lineStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        final gap = 2.0 * effectiveScale;
        final totalW = math.max(
          line1Tp.width,
          math.max(line2Tp.width, line3Tp.width),
        );
        final totalH =
            line1Tp.height + gap + line2Tp.height + gap + line3Tp.height;
        paintFittedStamp(totalW, totalH, (pos) {
          double getX(double w) {
            if (alignment.x < -0.2) return pos.dx;
            if (alignment.x > 0.2) return pos.dx + (totalW - w);
            return pos.dx + (totalW - w) / 2;
          }

          line1Tp.paint(canvas, Offset(getX(line1Tp.width), pos.dy));
          line2Tp.paint(
            canvas,
            Offset(getX(line2Tp.width), pos.dy + line1Tp.height + gap),
          );
          line3Tp.paint(
            canvas,
            Offset(
              getX(line3Tp.width),
              pos.dy + line1Tp.height + gap + line2Tp.height + gap,
            ),
          );
        });
        break;
      }

      case TimestampDesign.s1_1: {
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        final weekday = weekdays[currentTime.weekday - 1];
        final period = currentTime.hour < 12 ? '오전' : '오후';
        final text =
            '${DateFormat('yyyy.MM.dd').format(currentTime)}.$weekday $period ${DateFormat('hh:mm').format(currentTime)}';
        final scale = effectiveFontSize / 24.0;
        final frameW = 280.0 * scale;
        final frameH = 50.0 * scale;

        final tp = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontSize: effectiveFontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        final frameImg = await _loadUiImage(CameraUX.stampImg1);
        paintFittedStamp(frameW, frameH, (pos) {
          final dstRect = Rect.fromLTWH(pos.dx, pos.dy, frameW, frameH);
          if (frameImg != null) {
            final paint = Paint()
              ..colorFilter =
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn);
            canvas.drawImageRect(
              frameImg,
              Rect.fromLTWH(0, 0, frameImg.width.toDouble(),
                  frameImg.height.toDouble()),
              dstRect,
              paint,
            );
          }

          tp.paint(
            canvas,
            Offset(
              dstRect.left + (frameW - tp.width) / 2,
              dstRect.top + (frameH - tp.height) / 2,
            ),
          );
        });
        break;
      }

      case TimestampDesign.s1_2: {
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        final weekday = weekdays[currentTime.weekday - 1];
        final period = currentTime.hour < 12 ? '오전' : '오후';
        final text =
            '${DateFormat('yyyy.MM.dd').format(currentTime)}.$weekday $period ${DateFormat('hh:mm').format(currentTime)}';
        final scale = effectiveFontSize / 26.0;
        final frameW = 280.0 * scale;
        final frameH = 50.0 * scale;

        final tp = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24Shiningstar,
              fontSize: effectiveFontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

        final frameImg = await _loadUiImage(CameraUX.stampImg2);
        paintFittedStamp(frameW, frameH, (pos) {
          final dstRect = Rect.fromLTWH(pos.dx, pos.dy, frameW, frameH);
          if (frameImg != null) {
            final paint = Paint()
              ..colorFilter =
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn);
            canvas.drawImageRect(
              frameImg,
              Rect.fromLTWH(0, 0, frameImg.width.toDouble(),
                  frameImg.height.toDouble()),
              dstRect,
              paint,
            );
          }

          tp.paint(
            canvas,
            Offset(
              dstRect.left + (frameW - tp.width) / 2,
              dstRect.top + (frameH - tp.height) / 2,
            ),
          );
        });
        break;
      }

      case TimestampDesign.s2_1: {
        final dateStr = DateFormat('yyyy/MM/dd').format(currentTime);
        final period = currentTime.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(currentTime)}';
        final scale = effectiveFontSize / 25.0;
        final barW = 100.0 * scale;
        final barH = 2.2 * scale;
        final barMargin = 5.0 * scale;

        final dateTp = TextPainter(
          text: TextSpan(
            text: dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontSize: effectiveFontSize * 0.9,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: textAlign,
        )..layout();

        final timeTp = TextPainter(
          text: TextSpan(
            text: timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontSize: effectiveFontSize * 0.9,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: textAlign,
        )..layout();

        final totalW = math.max(dateTp.width, math.max(barW, timeTp.width));
        final totalH = dateTp.height + (barMargin * 2) + barH + timeTp.height;

        paintFittedStamp(totalW, totalH, (pos) {
          double getElementX(double elementW) {
            if (alignment.x < -0.2) return pos.dx;
            if (alignment.x > 0.2) return pos.dx + (totalW - elementW);
            return pos.dx + (totalW - elementW) / 2;
          }

          dateTp.paint(canvas, Offset(getElementX(dateTp.width), pos.dy));

          final barY = pos.dy + dateTp.height + barMargin;
          final barX = getElementX(barW);
          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTWH(barX, barY, barW, barH),
            Radius.circular(1.0 * scale),
          );
          for (final s in shadows) {
            final shadowPaint = Paint()
              ..color = s.color
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurRadius);
            canvas.drawRRect(rrect.shift(s.offset), shadowPaint);
          }
          canvas.drawRRect(rrect, Paint()..color = Colors.white);

          final timeY = barY + barH + barMargin;
          timeTp.paint(canvas, Offset(getElementX(timeTp.width), timeY));
        });
        break;
      }

      case TimestampDesign.s2_2: {
        final period = currentTime.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(currentTime)}';
        final dateStr = DateFormat('yyyy MMM dd', 'en_US').format(currentTime);
        final scale = effectiveFontSize / 25.0;

        final timeTp = TextPainter(
          text: TextSpan(
            text: timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontSize: effectiveFontSize * 0.82,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final pillW = timeTp.width + (20 * scale);
        final pillH = timeTp.height + (6 * scale);

        final dateTp = TextPainter(
          text: TextSpan(
            text: dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontSize: effectiveFontSize * 0.85,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: textAlign,
        )..layout();

        final totalW = math.max(pillW, dateTp.width);
        final totalH = pillH + (4 * scale) + dateTp.height;

        paintFittedStamp(totalW, totalH, (pos) {
          double getElementX(double elementW) {
            if (alignment.x < -0.2) return pos.dx;
            if (alignment.x > 0.2) return pos.dx + (totalW - elementW);
            return pos.dx + (totalW - elementW) / 2;
          }

          final pillX = getElementX(pillW);
          final pillRRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(pillX, pos.dy, pillW, pillH),
            Radius.circular(pillH / 2),
          );
          canvas.drawRRect(pillRRect, Paint()..color = Colors.white);

          timeTp.paint(
            canvas,
            Offset(
              pillX + (pillW - timeTp.width) / 2,
              pos.dy + (pillH - timeTp.height) / 2,
            ),
          );

          final dateY = pos.dy + pillH + (4 * scale);
          dateTp.paint(canvas, Offset(getElementX(dateTp.width), dateY));
        });
        break;
      }

      case TimestampDesign.s3_1: {
        final yearStr = DateFormat('yyyy').format(currentTime);
        final dateStr = DateFormat('MMMM dd', 'en_US').format(currentTime);
        final period = currentTime.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(currentTime)}';
        final scale = effectiveFontSize / 32.0;
        final dividerW = 140.0 * scale;
        final dividerH = 20.0 * scale;

        final yearTp = TextPainter(
          text: TextSpan(
            text: yearStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontSize: effectiveFontSize * 0.85,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final dateTp = TextPainter(
          text: TextSpan(
            text: dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontSize: effectiveFontSize * 0.85,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final timeTp = TextPainter(
          text: TextSpan(
            text: timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontSize: effectiveFontSize * 0.85,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final totalW = math.max(dividerW, math.max(yearTp.width, math.max(dateTp.width, timeTp.width)));
        final totalH = yearTp.height + dividerH + dateTp.height + dividerH + timeTp.height;

        final ribbonImg = await _loadUiImage(CameraUX.stampImg10);
        final ribbonPaint = Paint()
          ..colorFilter =
              const ColorFilter.mode(Colors.white, BlendMode.srcIn);

        paintFittedStamp(totalW, totalH, (pos) {
          // 1. Year
          yearTp.paint(canvas, Offset(pos.dx + (totalW - yearTp.width) / 2, pos.dy));

          // 2. Ribbon 1
          final ribbon1Y = pos.dy + yearTp.height;
          if (ribbonImg != null) {
            canvas.drawImageRect(
              ribbonImg,
              Rect.fromLTWH(0, 0, ribbonImg.width.toDouble(), ribbonImg.height.toDouble()),
              Rect.fromLTWH(pos.dx + (totalW - dividerW) / 2, ribbon1Y, dividerW, dividerH),
              ribbonPaint,
            );
          }

          // 3. Date
          final dateY = ribbon1Y + dividerH;
          dateTp.paint(canvas, Offset(pos.dx + (totalW - dateTp.width) / 2, dateY));

          // 4. Ribbon 2
          final ribbon2Y = dateY + dateTp.height;
          if (ribbonImg != null) {
            canvas.drawImageRect(
              ribbonImg,
              Rect.fromLTWH(0, 0, ribbonImg.width.toDouble(), ribbonImg.height.toDouble()),
              Rect.fromLTWH(pos.dx + (totalW - dividerW) / 2, ribbon2Y, dividerW, dividerH),
              ribbonPaint,
            );
          }

          // 5. Time
          final timeY = ribbon2Y + dividerH;
          timeTp.paint(canvas, Offset(pos.dx + (totalW - timeTp.width) / 2, timeY));
        });
        break;
      }

      case TimestampDesign.s3_2: {
        final dateStr = DateFormat('yy/MM/dd').format(currentTime);
        final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
        final weekdayStr = weekdays[currentTime.weekday - 1];
        final period = currentTime.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(currentTime)}';
        final scale = effectiveFontSize / 26.0;
        final bracketW = 100.0 * scale;
        final bracketH = 22.0 * scale;
        final flowerGap = 2.0 * effectiveScale;

        final dateTp = TextPainter(
          text: TextSpan(
            text: dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontSize: effectiveFontSize * 0.75,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final weekdayTp = TextPainter(
          text: TextSpan(
            text: weekdayStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontSize: effectiveFontSize * 1.15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final timeTp = TextPainter(
          text: TextSpan(
            text: timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontSize: effectiveFontSize * 0.75,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final totalW = math.max(bracketW, math.max(dateTp.width, math.max(weekdayTp.width, timeTp.width)));
        final totalH = bracketH + flowerGap + dateTp.height + weekdayTp.height + timeTp.height + flowerGap + bracketH;

        final flowerImg = await _loadUiImage(CameraUX.stampImg11);

        paintFittedStamp(totalW, totalH, (pos) {
          // 1. Top Flower (original colors)
          final topFlowerRect = Rect.fromLTWH(pos.dx + (totalW - bracketW) / 2, pos.dy, bracketW, bracketH);
          if (flowerImg != null) {
            canvas.drawImageRect(
              flowerImg,
              Rect.fromLTWH(0, 0, flowerImg.width.toDouble(), flowerImg.height.toDouble()),
              topFlowerRect,
              Paint(),
            );
          }

          // 2. Date
          final dateY = pos.dy + bracketH + flowerGap;
          dateTp.paint(canvas, Offset(pos.dx + (totalW - dateTp.width) / 2, dateY));

          // 3. Weekday
          final weekdayY = dateY + dateTp.height;
          weekdayTp.paint(canvas, Offset(pos.dx + (totalW - weekdayTp.width) / 2, weekdayY));

          // 4. Time
          final timeY = weekdayY + weekdayTp.height;
          timeTp.paint(canvas, Offset(pos.dx + (totalW - timeTp.width) / 2, timeY));

          // 5. Bottom Flower (flipped vertically)
          final bottomFlowerY = timeY + timeTp.height + flowerGap;
          final bottomFlowerRect = Rect.fromLTWH(pos.dx + (totalW - bracketW) / 2, bottomFlowerY, bracketW, bracketH);
          if (flowerImg != null) {
            canvas.save();
            canvas.translate(0, bottomFlowerRect.top + bottomFlowerRect.height);
            canvas.scale(1.0, -1.0);
            canvas.drawImageRect(
              flowerImg,
              Rect.fromLTWH(0, 0, flowerImg.width.toDouble(), flowerImg.height.toDouble()),
              Rect.fromLTWH(bottomFlowerRect.left, 0, bottomFlowerRect.width, bottomFlowerRect.height),
              Paint(),
            );
            canvas.restore();
          }
        });
        break;
      }

      case TimestampDesign.style1: {
        final dayStr = DateFormat('EEEE', 'en_US').format(currentTime);
        final monthStr = DateFormat('MM').format(currentTime);
        final dateStr = DateFormat('dd').format(currentTime);
        final period = currentTime.hour < 12 ? 'AM' : 'PM';
        final timeStr = '$period ${DateFormat('hh:mm').format(currentTime)}';
        final scale = effectiveFontSize / 34.0;
        final pillW = 85.0 * scale;
        final pillH = 34.0 * scale;
        final arcRadius = 240.0 * scale;

        var curvedStyle = TextStyle(
          fontFamily: CameraUX.fontRondal,
          fontFamilyFallback: const ['stamp_nanum_myeongjo', 'stamp_nanum_square'],
          fontSize: effectiveFontSize * 0.32,
          color: Colors.white.withValues(alpha: 0.92),
          letterSpacing: 0.8 * scale,
          shadows: shadows,
        );

        // 사용자가 바꾼 곡선 문구가 있으면 사용 (기본: Many a little makes a miracle)
        final curvedText = StampTextStore().customText('style1_rtxt1') ??
            StampTextStore.fieldOf('style1_rtxt1')!.defaultText;
        double totalTextLength = 0.0;
        double maxCharHeight = 0.0;
        for (int i = 0; i < curvedText.length; i++) {
          final tp = TextPainter(
            text: TextSpan(text: curvedText[i], style: curvedStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          totalTextLength += tp.width;
          if (tp.height > maxCharHeight) maxCharHeight = tp.height;
        }
        var totalAngle = totalTextLength / arcRadius;
        const maxAngle = 1.45;
        if (totalAngle > maxAngle && totalAngle > 0) {
          final baseSize = curvedStyle.fontSize ?? 10.0;
          curvedStyle = curvedStyle.copyWith(
            fontSize: math.max(baseSize * 0.4, baseSize * maxAngle / totalAngle),
          );
          totalTextLength = 0.0;
          maxCharHeight = 0.0;
          for (int i = 0; i < curvedText.length; i++) {
            final tp = TextPainter(
              text: TextSpan(text: curvedText[i], style: curvedStyle),
              textDirection: TextDirection.ltr,
            )..layout();
            totalTextLength += tp.width;
            if (tp.height > maxCharHeight) maxCharHeight = tp.height;
          }
          totalAngle = totalTextLength / arcRadius;
        }
        final curvedFontSize = curvedStyle.fontSize ?? 10.0;
        final arcWidth = (2 * arcRadius * math.sin(totalAngle / 2)) + (curvedFontSize * 0.9);
        final arcHeight = (arcRadius * (1 - math.cos(totalAngle / 2)) + maxCharHeight * 1.3)
            .clamp(maxCharHeight * 1.4, double.infinity);

        final monthTp = TextPainter(
          text: TextSpan(
            text: monthStr,
            style: TextStyle(
              fontFamily: CameraUX.fontLobster,
              fontSize: effectiveFontSize * 0.42,
              color: Colors.white,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final dayTp = TextPainter(
          text: TextSpan(
            text: dayStr,
            style: TextStyle(
              fontFamily: CameraUX.fontRondalBold,
              fontSize: effectiveFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0 * scale,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final dateTp = TextPainter(
          text: TextSpan(
            text: dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontLobster,
              fontSize: effectiveFontSize * 0.42,
              color: Colors.white,
              shadows: shadows,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final timeTp = TextPainter(
          text: TextSpan(
            text: timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontRondal,
              fontSize: effectiveFontSize * 0.34,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: shadows,
              height: 1.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final sideW = 26.0 * scale;
        final rowW = sideW + (8 * scale) + dayTp.width + (8 * scale) + sideW;
        final rowH = math.max(dayTp.height, math.max(monthTp.height, dateTp.height));

        final totalW = math.max(arcWidth, math.max(rowW, pillW));
        final totalH = arcHeight + rowH + (18 * scale) + pillH;

        final pillImg = await _loadUiImage(CameraUX.stampImgCircle1);

        paintFittedStamp(totalW, totalH, (pos) {
          // 1. Curved text
          _drawCurvedText(
            canvas: canvas,
            text: curvedText,
            textStyle: curvedStyle,
            radius: arcRadius,
            centerOffset: Offset(pos.dx + (totalW - arcWidth) / 2, pos.dy),
            boxWidth: arcWidth,
            boxHeight: arcHeight,
          );

          // 2. Middle row (Month, Day, Date) — 양옆 폭을 동일하게 맞춰 요일이 정중앙에 오도록 배치
          final rowY = pos.dy + arcHeight;
          final rowStartX = pos.dx + (totalW - rowW) / 2;
          monthTp.paint(canvas, Offset(rowStartX + sideW - monthTp.width, rowY + (rowH - monthTp.height) / 2));
          dayTp.paint(canvas, Offset(rowStartX + sideW + (8 * scale), rowY + (rowH - dayTp.height) / 2));
          dateTp.paint(canvas, Offset(rowStartX + sideW + (8 * scale) + dayTp.width + (8 * scale), rowY + (rowH - dateTp.height) / 2));

          // 3. Bottom Pill
          final pillY = rowY + rowH + (18 * scale);
          final pillX = pos.dx + (totalW - pillW) / 2;
          final pillDst = Rect.fromLTWH(pillX, pillY, pillW, pillH);

          if (pillImg != null) {
            final paint = Paint()
              ..colorFilter =
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn);
            canvas.drawImageRect(
              pillImg,
              Rect.fromLTWH(0, 0, pillImg.width.toDouble(), pillImg.height.toDouble()),
              pillDst,
              paint,
            );
          } else {
            final rrect = RRect.fromRectAndRadius(pillDst, Radius.circular(pillH / 2));
            canvas.drawRRect(rrect, Paint()..color = Colors.white.withValues(alpha: 0.25));
          }

          timeTp.paint(
            canvas,
            Offset(
              pillDst.left + (pillW - timeTp.width) / 2,
              pillDst.top + (pillH - timeTp.height) / 2,
            ),
          );
        });
        break;
      }

      default:
        // 샘플에서 이식한 스탬프: 사진 모드와 동일한 데이터 기반 렌더러로 그림
        if (design.isSampleStamp) {
          final logicalScale = scale ?? 2.7;
          await paintSampleStampForVideo(
            canvas,
            groupId: design.name,
            scaleIndex: TimestampMetadata.sampleScaleIndexFor(
              design,
              fontSize,
              scale: logicalScale,
            ),
            now: currentTime,
            alignment: alignment,
            area: activeBox,
            logicalScale: logicalScale,
          );
        }
        break;
    }

    // 위치 정보 표시가 켜져 있는 경우 비디오 오버레이 캔버스에도 위치 태그 렌더링 (사진 모드와 100% 동일한 디자인, 크기, 비율)
    if (AppSettingsService().showLocation) {
      final locText = AppSettingsService().locationText.isEmpty
          ? 'GPS 위치 확인 중'
          : AppSettingsService().locationText;

      final double S = scale ?? (canvasWidth / 390.0);

      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.location_on.codePoint),
          style: TextStyle(
            inherit: false,
            fontFamily: Icons.location_on.fontFamily,
            package: Icons.location_on.fontPackage,
            fontSize: 12.0 * S,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 4.0 * S, color: Colors.black),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double iconW = iconPainter.width > 0 ? iconPainter.width : (12.0 * S);
      final double iconH = iconPainter.height > 0 ? iconPainter.height : (12.0 * S);
      final double iconGap = 4.0 * S;
      final double padH = 8.0 * S;
      final double padV = 3.5 * S;

      final textPainter = TextPainter(
        text: TextSpan(
          text: locText,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11.0 * S,
            fontWeight: FontWeight.w600,
            height: 1.25,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 4.0 * S, color: Colors.black),
            ],
          ),
        ),
        maxLines: 2,
        ellipsis: '...',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: math.max(0.0, activeBox.width - (48.0 + 16.0 + 24.0) * S));

      final double contentH = math.max(iconH, textPainter.height);
      final double capsuleW = padH * 2 + iconW + iconGap + textPainter.width;
      final double capsuleH = padV * 2 + contentH;

      final locAlign = AppSettingsService().locationAlignment;
      final isTop = locAlign.y < 0;
      final isRight = locAlign.x > 0;
      final isLeft = locAlign.x < 0;

      double capsuleX;
      if (isLeft) {
        capsuleX = activeBox.left + 24.0 * S;
      } else if (isRight) {
        capsuleX = activeBox.right - capsuleW - 24.0 * S;
      } else {
        capsuleX = activeBox.left + (activeBox.width - capsuleW) / 2;
      }

      double capsuleY;
      if (isTop) {
        capsuleY = activeBox.top + 20.0 * S;
      } else if (locAlign.y > 0) {
        capsuleY = activeBox.bottom - capsuleH - 20.0 * S;
      } else {
        capsuleY = activeBox.top + (activeBox.height - capsuleH) / 2;
      }

      final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
      final borderPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 * S;

      final capsuleRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(capsuleX, capsuleY, capsuleW, capsuleH),
        Radius.circular(12.0 * S),
      );
      canvas.drawRRect(capsuleRRect, bgPaint);
      canvas.drawRRect(capsuleRRect, borderPaint);

      final double iconX = capsuleX + padH;
      final double iconY = capsuleY + padV + (contentH - iconH) / 2;
      if (iconPainter.width > 0) {
        iconPainter.paint(canvas, Offset(iconX, iconY));
      } else {
        _drawLocationPin(
          canvas,
          Offset(iconX, iconY),
          12.0 * S,
          Paint()..color = Colors.white,
          shadow: Shadow(blurRadius: 4.0 * S, color: Colors.black),
        );
      }

      final double textX = iconX + iconW + iconGap;
      final double textY = capsuleY + padV + (contentH - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(textX, textY));
    }

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(canvasWidth.toInt(), canvasHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }
}
