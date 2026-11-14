// ignore_for_file: camel_case_types
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'services/app_localizations.dart';
import 'services/timestamp_access_manager.dart';
import 'services/app_settings_service.dart';
import 'stamps/sample_stamp_renderer.dart';
import 'stamps/stamp_text_store.dart';
import 'widgets/stamp_text_edit_dialog.dart';
import 'timestamp_metadata.dart';
import 'ux_config.dart';

List<String> get _kStampFallbackFonts => AppLocalizations.fontFallbackChain;

// ───── Timestamp Design Types ─────
enum TimestampDesign {
  n1_1,
  n1_2,
  n2_1,
  n2_2,
  n3_1,
  n3_2,
  s1_1,
  s1_2,
  s2_1,
  s2_2,
  s3_1,
  s3_2,
  style1,
  // ───── 샘플(timestamp_sample) 에서 이식한 스탬프 (lib/stamps/sample_stamp_renderer.dart 로 렌더링) ─────
  // 일반
  n1_3, n1_4, n1_5, n1_6, n1_7, n1_8, n1_9, n1_10, n1_11, n1_12, n1_13, n1_14,
  n1_15, n1_16, n1_17, n1_18,
  n2_3, n2_4, n2_5, n2_6, n2_7, n2_8, n2_9, n2_10, n2_11, n2_12, n2_13,
  n3_3, n3_4, n3_5,
  // 스탬프
  s1_3, s1_4, s1_5, s1_6, s1_7, s1_8, s1_9, s1_10, s1_11, s1_12,
  s2_3, s2_4, s2_5, s2_6,
  s3_3, s3_4, s3_5, s3_6,
  // 프레임
  f1, f2, f3, f4, f5, f6, f7, f8, f9,
  // 아날로그 시계
  a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13,
  // 스타일리시
  style2, style3, style4, style5, style6, style7, style8, style9, style10, style11,
  none,
}

extension TimestampDesignSampleExt on TimestampDesign {
  /// 샘플에서 이식한(데이터 기반 렌더러로 그리는) 스탬프인지 여부
  bool get isSampleStamp => SampleStampLibrary.isSampleGroup(name);
}

// ───── Aspect Ratio Types ─────
enum CameraAspectRatio { ratio1x1, ratio5x4, ratio16x9 }

extension CameraAspectRatioExt on CameraAspectRatio {
  double get value {
    switch (this) {
      case CameraAspectRatio.ratio1x1:
        return 1.0;
      case CameraAspectRatio.ratio5x4:
        return 4.0 / 5.0;
      case CameraAspectRatio.ratio16x9:
        return 9.0 / 16.0;
    }
  }

  String get label {
    switch (this) {
      case CameraAspectRatio.ratio1x1:
        return '1:1';
      case CameraAspectRatio.ratio5x4:
        return '4:5';
      case CameraAspectRatio.ratio16x9:
        return '9:16';
    }
  }
}

// ───── Timestamp Overlay Widget ─────
class TimestampOverlayWidget extends StatefulWidget {
  final TimestampDesign design;
  final Alignment alignment;
  final double opacity;
  final DateTime? baseTime;
  final bool isLive;
  final double fontSize;

  /// 스탬프 문구(예: style2 의 "On the table")를 탭해서 바꿀 수 있게 할지 여부
  final bool editableText;

  const TimestampOverlayWidget({
    super.key,
    required this.design,
    this.alignment = Alignment.bottomRight,
    this.opacity = 1.0,
    this.baseTime,
    this.isLive = true,
    this.fontSize = 25.0,
    this.editableText = true,
  });

  @override
  State<TimestampOverlayWidget> createState() => _TimestampOverlayWidgetState();
}

class _TimestampOverlayWidgetState extends State<TimestampOverlayWidget> {
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = widget.baseTime ?? DateTime.now();
    if (widget.isLive) {
      _tick();
    }
  }

  void _editText(String key) {
    showStampTextEditDialog(context, key);
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _now = DateTime.now());
        _tick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.design == TimestampDesign.none) return const SizedBox.shrink();
    return MediaQuery.withNoTextScaling(
      child: Opacity(
        opacity: widget.opacity,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontFamily: AppLocalizations.uiFontFamily,
            fontFamilyFallback: _kStampFallbackFonts,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildDesign(),
              if (AppSettingsService().showLocation)
                _buildLocationOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationOverlay() {
    final location = AppSettingsService().locationText.isEmpty
        ? AppStrings.gpsCheckingOverlay
        : AppSettingsService().locationText;

    final locAlign = AppSettingsService().locationAlignment;
    final isTop = locAlign.y < 0;
    final isLeft = locAlign.x < 0;
    final isRight = locAlign.x > 0;

    return Align(
      alignment: locAlign,
      child: Padding(
        padding: EdgeInsets.only(
          left: isLeft ? 24 : 16,
          right: isRight ? 24 : 16,
          top: isTop ? 20 : 0,
          bottom: !isTop ? 20 : 0,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - (isLeft || isRight ? 48 : 32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  location,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesign() {
    if (widget.design.isSampleStamp) {
      return SampleStampOverlay(
        groupId: widget.design.name,
        scaleIndex: TimestampMetadata.sampleScaleIndexFor(widget.design, widget.fontSize),
        now: _now,
        alignment: widget.alignment,
        onEditText: widget.editableText ? _editText : null,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // 80종 샘플 스탬프와 동일하게, 기기 화면 폭이나 앱 화면 비율(1:1, 4:5, 9:16)에 따른
        // 실제 뷰파인더 가로폭을 390 기준 좌표계로 비례 스케일링합니다.
        final viewScale = (constraints.maxWidth.isFinite && constraints.maxWidth > 0)
            ? (constraints.maxWidth / kSampleBaseWidth)
            : 1.0;
        final scaledFontSize = widget.fontSize * viewScale;

        switch (widget.design) {
          case TimestampDesign.none:
            return const SizedBox.shrink();
          case TimestampDesign.n1_1:
            return _N1_1Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.n1_2:
            return _N1_2Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.n2_1:
            return _N2_1Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.n2_2:
            return _N2_2Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.n3_1:
            return _N3_1Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.n3_2:
            return _N3_2Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.s1_1:
            return _S1_1Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.s1_2:
            return _S1_2Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.s2_1:
            return _S2_1Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.s2_2:
            return _S2_2Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.s3_1:
            return _S3_1Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.s3_2:
            return _S3_2Stamp(now: _now, alignment: widget.alignment, fontSize: scaledFontSize);
          case TimestampDesign.style1:
            return ListenableBuilder(
              listenable: StampTextStore(),
              builder: (context, _) => _Style1Stamp(
                now: _now,
                alignment: widget.alignment,
                fontSize: scaledFontSize,
                onEditText: widget.editableText ? _editText : null,
              ),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

// ───── Alignment Helpers ─────
CrossAxisAlignment _getCrossAxis(Alignment alignment) {
  if (alignment.x < -0.2) return CrossAxisAlignment.start;
  if (alignment.x > 0.2) return CrossAxisAlignment.end;
  return CrossAxisAlignment.center;
}

TextAlign _getTextAlign(Alignment alignment) {
  if (alignment.x < -0.2) return TextAlign.left;
  if (alignment.x > 0.2) return TextAlign.right;
  return TextAlign.center;
}

Widget _wrapAlign({
  required Alignment alignment,
  required Widget child,
  EdgeInsetsGeometry? margin,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final viewScale = (constraints.maxWidth.isFinite && constraints.maxWidth > 0)
          ? (constraints.maxWidth / kSampleBaseWidth)
          : 1.0;
      final effectiveMargin = margin ?? EdgeInsets.all(16.0 * viewScale);
      return Align(
        alignment: alignment,
        child: Container(
          margin: effectiveMargin,
          // 배율(3A 등)이나 긴 텍스트로 인해 가용 가로폭을 넘더라도
          // 다음 줄로 줄바꿈되거나 잘리지 않고 한 줄 비율 그대로 안전 영역 안에 맞춤
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: child,
          ),
        ),
      );
    },
  );
}

// ───── Timestamp Picker Thumbnail ─────
class TimestampThumbnail extends StatelessWidget {
  final TimestampDesign design;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final DateTime? time;

  /// 초 단위 재렌더링으로 인한 프레임 드랍을 막기 위해 분(minute) 단위로 정규화된 현재 시각 반환
  static DateTime currentMinuteTime([DateTime? source]) {
    final n = source ?? DateTime.now();
    return DateTime(n.year, n.month, n.day, n.hour, n.minute);
  }

  static DateTime get defaultThumbnailTime => currentMinuteTime();

  const TimestampThumbnail({
    super.key,
    required this.design,
    required this.isSelected,
    required this.onTap,
    this.margin,
    this.borderRadius,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TimestampAccessManager(),
      builder: (context, _) {
        final isUnlocked = TimestampAccessManager().isUnlocked(design);
        final isFree = TimestampAccessManager.freeDesigns.contains(design);
        final badgeText = !isFree && isUnlocked
            ? TimestampAccessManager().getRemainingBadgeText(design)
            : null;
        final isLocked = !isUnlocked;

        final effectiveBorderRadius = borderRadius ?? BorderRadius.zero;

        final settings = AppSettingsService();
        final isLight = settings.isLight;
        final accent = settings.accentColor;

        final Color cardBg = isSelected
            ? const Color(0xFF222530)
            : const Color(0xFF16181F);

        final Border border = isSelected
            ? Border.all(color: accent, width: 2.2)
            : Border.all(
                color: isLight
                    ? const Color(0xFFCBD5E1)
                    : Colors.white.withValues(alpha: 0.2),
                width: isLight ? 1.2 : 0.8,
              );

        final List<BoxShadow> shadows = isLight
            ? [
                BoxShadow(
                  color: isSelected
                      ? accent.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 1.5),
                ),
              ]
            : (isSelected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : []);

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: margin ?? const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: effectiveBorderRadius,
                      border: border,
                      boxShadow: shadows,
                    ),
                    child: ClipRRect(
                      borderRadius: effectiveBorderRadius,
                      child: Opacity(
                        opacity: isLocked ? 0.65 : 1.0,
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            fontFamily: AppLocalizations.uiFontFamily,
                            fontFamilyFallback: _kStampFallbackFonts,
                          ),
                          child: _thumbnail(
                            design,
                            currentMinuteTime(time),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 잠금 아이콘
                  if (isLocked)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 11,
                          color: AppSettingsService().accentColor,
                        ),
                      ),
                    ),

                  // 잔여 일수 뱃지 (예: D-3, D-1)
                  if (badgeText != null)
                    Positioned(
                      top: 3,
                      right: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppSettingsService().accentColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _thumbnail(TimestampDesign design, [DateTime? targetTime]) {
    final now = targetTime ?? defaultThumbnailTime;
    if (design.isSampleStamp) {
      return SampleStampThumbnail(groupId: design.name, time: now);
    }
    final shadow = TimestampMetadata.getShadows(design);

    switch (design) {
      case TimestampDesign.none:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              'None',
              style: TextStyle(
                color: TimestampMetadata.getColor(design),
                fontSize: 10,
                shadows: shadow,
              ),
            ),
          ],
        );

      case TimestampDesign.n1_1:
        final text = TimestampMetadata.getFormattedDateTime(design, now);
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: CameraUX.fontRubberNippleFactory,
                  fontFamilyFallback: _kStampFallbackFonts,
                  color: Colors.white,
                  fontSize: 10.5,
                  height: 1.0,
                  shadows: shadow,
                ),
              ),
            ),
          ),
        );

      case TimestampDesign.n1_2:
        final text = TimestampMetadata.getFormattedDateTime(design, now);
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: CameraUX.fontNixieOne,
                  fontFamilyFallback: _kStampFallbackFonts,
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.0,
                  shadows: shadow,
                ),
              ),
            ),
          ),
        );

      case TimestampDesign.n2_1:
        final dateStr = TimestampLocaleFormatter.formatLegacyN2_1Date(now);
        final timeStr = TimestampLocaleFormatter.format12hTime(
          now,
          padHour: false,
          localizePeriod: true,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    dateStr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: CameraUX.fontCafe24OnePrettyNight,
                      fontFamilyFallback: _kStampFallbackFonts,
                      color: Colors.white,
                      fontSize: 5.8,
                      shadows: shadow,
                    ),
                  ),
                  Text(
                    timeStr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: CameraUX.fontCafe24OnePrettyNight,
                      fontFamilyFallback: _kStampFallbackFonts,
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      shadows: shadow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.n2_2:
        final dateStr = TimestampLocaleFormatter.formatWordDate(
          now,
          padMonthDay: true,
        );
        final timeStr = TimestampLocaleFormatter.format12hTime(
          now,
          padHour: true,
          localizePeriod: true,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    dateStr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: CameraUX.fontNanumAmsterdam,
                      fontFamilyFallback: _kStampFallbackFonts,
                      color: Colors.white,
                      fontSize: 7.0,
                      shadows: shadow,
                    ),
                  ),
                  Text(
                    timeStr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: CameraUX.fontNanumAmsterdam,
                      fontFamilyFallback: _kStampFallbackFonts,
                      color: Colors.white,
                      fontSize: 13.0,
                      shadows: shadow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.n3_1:
        final dateStr = TimestampLocaleFormatter.formatWordDate(
          now,
          padMonthDay: true,
        );
        final dayStr = TimestampLocaleFormatter.fullWeekday(now);
        final timeStr = TimestampLocaleFormatter.format12hTime(
          now,
          padHour: true,
          localizePeriod: false,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(dateStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontFamilyFallback: _kStampFallbackFonts, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Text(dayStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontFamilyFallback: _kStampFallbackFonts, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Text(timeStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontFamilyFallback: _kStampFallbackFonts, fontSize: 8, color: Colors.white, shadows: shadow)),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.n3_2:
        final isYmd = TimestampLocaleFormatter.dateOrder == DateOrderType.ymd;
        final yearStr = '${now.year}';
        final dateStr = TimestampLocaleFormatter.formatWordMonthDay(
          now,
          fullMonth: true,
          padDay: true,
        );
        final line1 = isYmd ? yearStr : dateStr;
        final line2 = isYmd ? dateStr : yearStr;
        final timeStr = TimestampLocaleFormatter.format12hTime(
          now,
          padHour: true,
          localizePeriod: false,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(line1, style: TextStyle(fontFamily: CameraUX.fontCafe24Simplehae, fontFamilyFallback: _kStampFallbackFonts, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Text(line2, style: TextStyle(fontFamily: CameraUX.fontCafe24Simplehae, fontFamilyFallback: _kStampFallbackFonts, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Text(timeStr, style: TextStyle(fontFamily: CameraUX.fontCafe24Simplehae, fontFamilyFallback: _kStampFallbackFonts, fontSize: 8, color: Colors.white, shadows: shadow)),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.s1_1:
        final text = TimestampLocaleFormatter.formatLegacyS1_2(
          now,
          shortYear: true,
          padHour: false,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 130,
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(CameraUX.stampImg1, width: 130, height: 30, fit: BoxFit.fill, color: Colors.white),
                    Text(
                      text,
                      style: TextStyle(fontFamily: CameraUX.fontTvnFunStory, fontFamilyFallback: _kStampFallbackFonts, fontSize: 9.5, color: Colors.white, shadows: shadow),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case TimestampDesign.s1_2:
        final text = TimestampLocaleFormatter.formatLegacyS1_2(
          now,
          shortYear: true,
          padHour: false,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 130,
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(CameraUX.stampImg2, width: 130, height: 30, fit: BoxFit.fill, color: Colors.white),
                    Text(
                      text,
                      style: TextStyle(fontFamily: CameraUX.fontCafe24Shiningstar, fontFamilyFallback: _kStampFallbackFonts, fontSize: 10, color: Colors.white, shadows: shadow),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case TimestampDesign.s2_1:
        final dateStr = TimestampLocaleFormatter.formatNumericDate(now, sep: '/');
        final timeStr = TimestampLocaleFormatter.format12hTime(
          now,
          padHour: true,
          localizePeriod: true,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dateStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontFamilyFallback: _kStampFallbackFonts, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.5),
                    width: 52,
                    height: 2.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: shadow
                          ?.map((s) => BoxShadow(
                                color: s.color,
                                offset: s.offset,
                                blurRadius: s.blurRadius,
                              ))
                          .toList(),
                    ),
                  ),
                  Text(timeStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontFamilyFallback: _kStampFallbackFonts, fontSize: 8, color: Colors.white, shadows: shadow)),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.s2_2:
        final timeStr = TimestampLocaleFormatter.format12hTime(
          now,
          padHour: false,
          localizePeriod: true,
        );
        final dateStr = TimestampLocaleFormatter.formatLegacyS2_2Date(now);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(timeStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontFamilyFallback: _kStampFallbackFonts, fontSize: 7.5, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 2),
                  Text(dateStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontFamilyFallback: _kStampFallbackFonts, fontSize: 7.5, color: Colors.white, shadows: shadow)),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.s3_1:
        final isYmd = TimestampLocaleFormatter.dateOrder == DateOrderType.ymd;
        final yearStr = '${now.year}';
        final dateStr = TimestampLocaleFormatter.formatLegacyS3_1MonthDay(now);
        final line1 = isYmd ? yearStr : dateStr;
        final line2 = isYmd ? dateStr : yearStr;
        final timeStr = TimestampLocaleFormatter.format12hTime(
          now,
          padHour: true,
          localizePeriod: true,
        );
        Widget buildDivider() => Container(
              margin: const EdgeInsets.symmetric(vertical: 2.0),
              width: 52,
              height: 1.2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
                boxShadow: shadow
                    ?.map((s) => BoxShadow(
                          color: s.color,
                          offset: s.offset,
                          blurRadius: s.blurRadius,
                        ))
                    .toList(),
              ),
            );
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    line1,
                    style: TextStyle(
                      fontFamily: CameraUX.fontTvnFunStory,
                      fontFamilyFallback: _kStampFallbackFonts,
                      fontSize: 8,
                      color: Colors.white,
                      height: 1.0,
                      shadows: shadow,
                    ),
                  ),
                  buildDivider(),
                  Text(
                    line2,
                    style: TextStyle(
                      fontFamily: CameraUX.fontTvnFunStory,
                      fontFamilyFallback: _kStampFallbackFonts,
                      fontSize: 8,
                      color: Colors.white,
                      height: 1.0,
                      shadows: shadow,
                    ),
                  ),
                  buildDivider(),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontFamily: CameraUX.fontTvnFunStory,
                      fontFamilyFallback: _kStampFallbackFonts,
                      fontSize: 8,
                      color: Colors.white,
                      height: 1.0,
                      shadows: shadow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.s3_2:
        final dateStr = TimestampLocaleFormatter.formatNumericDate(
          now,
          sep: '/',
          shortYear: true,
        );
        final weekdayStr = TimestampLocaleFormatter.fullWeekday(now);
        final timeStr = TimestampLocaleFormatter.format12hTime(
          now,
          padHour: true,
          localizePeriod: true,
        );
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    CameraUX.stampImg11,
                    width: 38,
                    height: 8.5,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontFamily: CameraUX.fontTvnFunStory,
                      fontFamilyFallback: _kStampFallbackFonts,
                      fontSize: 6.0,
                      color: Colors.white,
                      height: 1.0,
                      shadows: shadow,
                    ),
                  ),
                  Text(
                    weekdayStr,
                    style: TextStyle(
                      fontFamily: CameraUX.fontTvnFunStory,
                      fontFamilyFallback: _kStampFallbackFonts,
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      shadows: shadow,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontFamily: CameraUX.fontTvnFunStory,
                      fontFamilyFallback: _kStampFallbackFonts,
                      fontSize: 6.0,
                      color: Colors.white,
                      height: 1.0,
                      shadows: shadow,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Transform.flip(
                    flipY: true,
                    child: Image.asset(
                      CameraUX.stampImg11,
                      width: 38,
                      height: 8.5,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.style1:
        final dayStr = TimestampLocaleFormatter.fullWeekday(now);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _CurvedTextWidget(
                    text: _Style1Stamp.arcText(),
                    textStyle: TextStyle(
                      fontFamily: CameraUX.fontRondal,
                      fontFamilyFallback: _kStampFallbackFonts,
                      fontSize: 4.8,
                      color: Colors.white.withValues(alpha: 0.92),
                      letterSpacing: 0.2,
                    ),
                    radius: 65.0,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        TimestampLocaleFormatter.formatStyle1LeftNumber(now),
                        style: TextStyle(
                          fontFamily: CameraUX.fontLobster,
                          fontFamilyFallback: _kStampFallbackFonts,
                          fontSize: 5.5,
                          color: Colors.white,
                          shadows: shadow,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          dayStr,
                          style: TextStyle(
                            fontFamily: CameraUX.fontRondalBold,
                            fontFamilyFallback: _kStampFallbackFonts,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: shadow,
                          ),
                        ),
                      ),
                      Text(
                        TimestampLocaleFormatter.formatStyle1RightNumber(now),
                        style: TextStyle(
                          fontFamily: CameraUX.fontLobster,
                          fontFamilyFallback: _kStampFallbackFonts,
                          fontSize: 5.5,
                          color: Colors.white,
                          shadows: shadow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 38,
                    height: 14,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          CameraUX.stampImgCircle1,
                          width: 38,
                          height: 14,
                          fit: BoxFit.fill,
                          color: Colors.white,
                        ),
                        Text(
                          TimestampLocaleFormatter.format12hTime(
                            now,
                            padHour: true,
                            localizePeriod: false,
                          ),
                          style: TextStyle(
                            fontFamily: CameraUX.fontRondal,
                            fontFamilyFallback: _kStampFallbackFonts,
                            fontSize: 5.2,
                            color: Colors.white,
                            shadows: shadow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ───── 1. n1_1 (Normal 1-line Center) ─────
class _N1_1Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _N1_1Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final text = TimestampMetadata.getFormattedDateTime(TimestampDesign.n1_1, now);
    final shadows = TimestampMetadata.getShadows(TimestampDesign.n1_1);
    return _wrapAlign(
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontFamily: CameraUX.fontRubberNippleFactory,
          fontFamilyFallback: _kStampFallbackFonts,
          fontSize: fontSize,
          color: Colors.white,
          height: 1.0,
          shadows: shadows,
        ),
      ),
    );
  }
}

// ───── 2. n1_2 (Normal 1-line Left) ─────
class _N1_2Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _N1_2Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final text = TimestampMetadata.getFormattedDateTime(TimestampDesign.n1_2, now);
    final shadows = TimestampMetadata.getShadows(TimestampDesign.n1_2);
    return _wrapAlign(
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontFamily: CameraUX.fontNixieOne,
          fontFamilyFallback: _kStampFallbackFonts,
          fontSize: fontSize,
          color: Colors.white,
          height: 1.0,
          shadows: shadows,
        ),
      ),
    );
  }
}

// ───── 3. n2_1 (Normal 2-line: Date smaller to match Time width, always center-aligned) ─────
class _N2_1Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _N2_1Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final dateStr = TimestampLocaleFormatter.formatLegacyN2_1Date(now);
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: false,
      localizePeriod: true,
    );
    final shadows = TimestampMetadata.getShadows(TimestampDesign.n2_1);
    final dateFontSize = fontSize * 0.36;

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dateStr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24OnePrettyNight,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: dateFontSize,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeStr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24OnePrettyNight,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── 4. n2_2 (Normal 2-line Amsterdam: Date smaller to match Time width, always center-aligned) ─────
class _N2_2Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _N2_2Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final dateStr = TimestampLocaleFormatter.formatWordDate(
      now,
      padMonthDay: true,
    );
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: true,
      localizePeriod: true,
    );
    final shadows = TimestampMetadata.getShadows(TimestampDesign.n2_2);
    final dateFontSize = fontSize * 0.52;

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dateStr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumAmsterdam,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: dateFontSize,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeStr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumAmsterdam,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── 5. n3_1 (Normal 3-line Left/Center/Right dynamic alignment) ─────
class _N3_1Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _N3_1Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final dateStr = TimestampLocaleFormatter.formatWordDate(
      now,
      padMonthDay: true,
    );
    final dayStr = TimestampLocaleFormatter.fullWeekday(now);
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: true,
      localizePeriod: false,
    );
    final shadows = TimestampMetadata.getShadows(TimestampDesign.n3_1);
    final crossAxis = _getCrossAxis(alignment);
    final textAlign = _getTextAlign(alignment);

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxis,
        children: [
          Text(
            dateStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
          Text(
            dayStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
          Text(
            timeStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── 6. n3_2 (Normal 3-line Simplehae: smaller size & dynamic alignment) ─────
class _N3_2Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _N3_2Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final isYmd = TimestampLocaleFormatter.dateOrder == DateOrderType.ymd;
    final yearStr = '${now.year}';
    final dateStr = TimestampLocaleFormatter.formatWordMonthDay(
      now,
      fullMonth: true,
      padDay: true,
    );
    final line1 = isYmd ? yearStr : dateStr;
    final line2 = isYmd ? dateStr : yearStr;
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: true,
      localizePeriod: false,
    );
    final shadows = TimestampMetadata.getShadows(TimestampDesign.n3_2);
    final crossAxis = _getCrossAxis(alignment);
    final textAlign = _getTextAlign(alignment);

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxis,
        children: [
          Text(
            line1,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24Simplehae,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            line2,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24Simplehae,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24Simplehae,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── 7. s1_1 (Stamp Frame 1: adjusted compact size) ─────
class _S1_1Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _S1_1Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final text = TimestampLocaleFormatter.formatLegacyS1_2(now);
    final shadows = TimestampMetadata.getShadows(TimestampDesign.s1_1);
    final scale = fontSize / 24.0;
    final frameW = 280.0 * scale;
    final frameH = 50.0 * scale;

    return _wrapAlign(
      alignment: alignment,
      child: SizedBox(
        width: frameW,
        height: frameH,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              CameraUX.stampImg1,
              width: frameW,
              height: frameH,
              fit: BoxFit.fill,
              color: Colors.white,
            ),
            Text(
              text,
              style: TextStyle(
                fontFamily: CameraUX.fontTvnFunStory,
                fontFamilyFallback: _kStampFallbackFonts,
                fontSize: fontSize,
                color: Colors.white,
                height: 1.0,
                shadows: shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───── 8. s1_2 (Stamp Frame 2: adjusted compact size) ─────
class _S1_2Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _S1_2Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final text = TimestampLocaleFormatter.formatLegacyS1_2(now);
    final shadows = TimestampMetadata.getShadows(TimestampDesign.s1_2);
    final scale = fontSize / 26.0;
    final frameW = 280.0 * scale;
    final frameH = 50.0 * scale;

    return _wrapAlign(
      alignment: alignment,
      child: SizedBox(
        width: frameW,
        height: frameH,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              CameraUX.stampImg2,
              width: frameW,
              height: frameH,
              fit: BoxFit.fill,
              color: Colors.white,
            ),
            Text(
              text,
              style: TextStyle(
                fontFamily: CameraUX.fontCafe24Shiningstar,
                fontFamilyFallback: _kStampFallbackFonts,
                fontSize: fontSize,
                color: Colors.white,
                height: 1.0,
                shadows: shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───── 9. s2_1 (Divider bar exactly centered between Date & Time, dynamic alignment) ─────
class _S2_1Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _S2_1Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final dateStr = TimestampLocaleFormatter.formatNumericDate(now, sep: '/');
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: true,
      localizePeriod: true,
    );
    final shadows = TimestampMetadata.getShadows(TimestampDesign.s2_1);
    final scale = fontSize / 25.0;
    final crossAxis = _getCrossAxis(alignment);
    final textAlign = _getTextAlign(alignment);
    final barW = 100.0 * scale;

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxis,
        children: [
          Text(
            dateStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 0.9,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5 * scale),
            width: barW,
            height: 2.2 * scale,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.0 * scale),
              boxShadow: shadows
                  ?.map((s) => BoxShadow(
                        color: s.color,
                        offset: s.offset,
                        blurRadius: s.blurRadius,
                      ))
                  .toList(),
            ),
          ),
          Text(
            timeStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 0.9,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── 10. s2_2 (Slender pill badge, dynamic alignment) ─────
class _S2_2Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _S2_2Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: true,
      localizePeriod: true,
    );
    final dateStr = TimestampLocaleFormatter.formatLegacyS2_2Date(now);
    final shadows = TimestampMetadata.getShadows(TimestampDesign.s2_2);
    final scale = fontSize / 25.0;
    final crossAxis = _getCrossAxis(alignment);
    final textAlign = _getTextAlign(alignment);

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxis,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              timeStr,
              style: TextStyle(
                fontFamily: CameraUX.fontNanumBarunpen,
                fontFamilyFallback: _kStampFallbackFonts,
                fontSize: fontSize * 0.82,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            dateStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontNanumBarunpen,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 0.85,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── 11. s3_1 (Stamp 3-line dividers: adjusted compact size) ─────
class _S3_1Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _S3_1Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final isYmd = TimestampLocaleFormatter.dateOrder == DateOrderType.ymd;
    final yearStr = '${now.year}';
    final dateStr = TimestampLocaleFormatter.formatLegacyS3_1MonthDay(now);
    final line1 = isYmd ? yearStr : dateStr;
    final line2 = isYmd ? dateStr : yearStr;
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: true,
      localizePeriod: true,
    );
    final shadows = TimestampMetadata.getShadows(TimestampDesign.s3_1);
    final scale = fontSize / 32.0;
    final dividerW = 140.0 * scale;
    final dividerH = 20.0 * scale;

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            line1,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 0.85,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          Image.asset(
            CameraUX.stampImg10,
            width: dividerW,
            height: dividerH,
            fit: BoxFit.fill,
            color: Colors.white,
          ),
          Text(
            line2,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 0.85,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          Image.asset(
            CameraUX.stampImg10,
            width: dividerW,
            height: dividerH,
            fit: BoxFit.fill,
            color: Colors.white,
          ),
          Text(
            timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 0.85,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── 12. s3_2 (Colored Flowers with adjusted compact size) ─────
class _S3_2Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _S3_2Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final dateStr = TimestampLocaleFormatter.formatNumericDate(
      now,
      sep: '/',
      shortYear: true,
    );
    final weekdayStr = TimestampLocaleFormatter.fullWeekday(now);
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: true,
      localizePeriod: true,
    );
    final shadows = TimestampMetadata.getShadows(TimestampDesign.s3_2);
    final scale = fontSize / 26.0;
    final bracketW = 100.0 * scale;
    final bracketH = 22.0 * scale;

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Original colored flowers without color tint
          Image.asset(
            CameraUX.stampImg11,
            width: bracketW,
            height: bracketH,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 2),
          Text(
            dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 0.75,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          Text(
            weekdayStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 1.15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              shadows: shadows,
            ),
          ),
          Text(
            timeStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
              fontFamilyFallback: _kStampFallbackFonts,
              fontSize: fontSize * 0.75,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 2),
          // Flipped colored flowers
          Transform.flip(
            flipY: true,
            child: Image.asset(
              CameraUX.stampImg11,
              width: bracketW,
              height: bracketH,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── 13. style1 (Circular Arc Text, Title Case Tuesday, White time text, reduced size) ─────
class _Style1Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  final void Function(String editKey)? onEditText;
  const _Style1Stamp({
    required this.now,
    required this.alignment,
    required this.fontSize,
    this.onEditText,
  });

  /// 곡선 문구 (사용자가 바꾼 문구가 있으면 그 문구)
  static String arcText() =>
      StampTextStore().customText('style1_rtxt1') ??
      StampTextStore.fieldOf('style1_rtxt1')!.defaultText;

  @override
  Widget build(BuildContext context) {
    final dayStr = TimestampLocaleFormatter.fullWeekday(now);
    final leftNumStr = TimestampLocaleFormatter.formatStyle1LeftNumber(now);
    final rightNumStr = TimestampLocaleFormatter.formatStyle1RightNumber(now);
    final timeStr = TimestampLocaleFormatter.format12hTime(
      now,
      padHour: true,
      localizePeriod: false,
    );
    final shadows = TimestampMetadata.getShadows(TimestampDesign.style1);
    final scale = fontSize / 34.0;
    final pillW = 85.0 * scale;
    final pillH = 34.0 * scale;
    final arcRadius = 240.0 * scale;

    return _wrapAlign(
      alignment: alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Arc Text: 기본 "Many a little makes a miracle" (탭하면 문구 변경)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onEditText == null ? null : () => onEditText!('style1_rtxt1'),
            child: _CurvedTextWidget(
              text: arcText(),
              textStyle: TextStyle(
                fontFamily: CameraUX.fontRondal,
                fontFamilyFallback: _kStampFallbackFonts,
                fontSize: fontSize * 0.32,
                color: Colors.white.withValues(alpha: 0.92),
                letterSpacing: 0.8 * scale,
                shadows: shadows,
              ),
              radius: arcRadius,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 26 * scale,
                child: Text(
                  leftNumStr,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: CameraUX.fontLobster,
                    fontFamilyFallback: _kStampFallbackFonts,
                    fontSize: fontSize * 0.42,
                    color: Colors.white,
                    shadows: shadows,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  dayStr,
                  style: TextStyle(
                    fontFamily: CameraUX.fontRondalBold,
                    fontFamilyFallback: _kStampFallbackFonts,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0 * scale,
                    height: 1.0,
                    shadows: shadows,
                  ),
                ),
              ),
              SizedBox(
                width: 26 * scale,
                child: Text(
                  rightNumStr,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: CameraUX.fontLobster,
                    fontFamilyFallback: _kStampFallbackFonts,
                    fontSize: fontSize * 0.42,
                    color: Colors.white,
                    shadows: shadows,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * scale),
          SizedBox(
            width: pillW,
            height: pillH,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  CameraUX.stampImgCircle1,
                  width: pillW,
                  height: pillH,
                  fit: BoxFit.fill,
                  color: Colors.white,
                ),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontFamily: CameraUX.fontRondal,
                    fontFamilyFallback: _kStampFallbackFonts,
                    fontSize: fontSize * 0.34,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: shadows,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───── Circular Arc Text Widget for Style1 ─────
class _CurvedTextWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final double radius;

  const _CurvedTextWidget({
    required this.text,
    required this.textStyle,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    var effectiveStyle = textStyle.copyWith(
      fontFamilyFallback: _kStampFallbackFonts,
    );
    // 텍스트 호의 실제 시각적 가로 너비(양 끝점 간격)를 정밀 측정하여 불필요한 좌우 여백을 완전히 제거
    double totalTextLength = 0.0;
    double maxCharHeight = 0.0;
    for (int i = 0; i < text.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: text[i], style: effectiveStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      totalTextLength += tp.width;
      if (tp.height > maxCharHeight) maxCharHeight = tp.height;
    }

    var totalAngle = totalTextLength / radius;
    const maxAngle = 1.45;
    if (totalAngle > maxAngle && totalAngle > 0) {
      final baseSize = effectiveStyle.fontSize ?? 10.0;
      effectiveStyle = effectiveStyle.copyWith(
        fontSize: math.max(baseSize * 0.4, baseSize * maxAngle / totalAngle),
      );
      totalTextLength = 0.0;
      maxCharHeight = 0.0;
      for (int i = 0; i < text.length; i++) {
        final tp = TextPainter(
          text: TextSpan(text: text[i], style: effectiveStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        totalTextLength += tp.width;
        if (tp.height > maxCharHeight) maxCharHeight = tp.height;
      }
      totalAngle = totalTextLength / radius;
    }

    final fontSize = effectiveStyle.fontSize ?? 10.0;
    // 호의 양 끝점 사이의 chord 너비 + 양 끝 글자 너비 보정
    final exactArcWidth = (2 * radius * math.sin(totalAngle / 2)) + (fontSize * 0.9);
    final arcHeight = radius * (1 - math.cos(totalAngle / 2)) + maxCharHeight * 1.3;

    return SizedBox(
      width: exactArcWidth,
      height: arcHeight.clamp(maxCharHeight * 1.4, double.infinity),
      child: CustomPaint(
        painter: _CurvedTextPainter(
          text: text,
          textStyle: effectiveStyle,
          radius: radius,
          totalAngle: totalAngle,
        ),
      ),
    );
  }
}

// ───── Circular Arc Text Painter for Style1 ─────
class _CurvedTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final double radius;
  final double totalAngle;

  _CurvedTextPainter({
    required this.text,
    required this.textStyle,
    required this.radius,
    required this.totalAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 호의 꼭짓점이 박스 상단에 딱 닿고 가로 중앙에 오도록 중심점 계산
    final center = Offset(size.width / 2, radius + (textStyle.fontSize ?? 10) * 0.3);

    final textPainters = <TextPainter>[];
    for (int i = 0; i < text.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainters.add(tp);
    }

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

  @override
  bool shouldRepaint(covariant _CurvedTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.radius != radius ||
        oldDelegate.totalAngle != totalAngle;
  }
}
