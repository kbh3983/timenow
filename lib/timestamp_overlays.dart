// ignore_for_file: camel_case_types
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'services/timestamp_access_manager.dart';
import 'services/app_settings_service.dart';
import 'timestamp_metadata.dart';
import 'ux_config.dart';

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
  none,
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

  const TimestampOverlayWidget({
    super.key,
    required this.design,
    this.alignment = Alignment.bottomRight,
    this.opacity = 1.0,
    this.baseTime,
    this.isLive = true,
    this.fontSize = 25.0,
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
    return Opacity(
      opacity: widget.opacity,
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: 'Pretendard'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildDesign(),
            if (AppSettingsService().showLocation)
              _buildLocationOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOverlay() {
    final location = AppSettingsService().locationText.isEmpty
        ? 'GPS 위치 확인 중'
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
    switch (widget.design) {
      case TimestampDesign.none:
        return const SizedBox.shrink();
      case TimestampDesign.n1_1:
        return _N1_1Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.n1_2:
        return _N1_2Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.n2_1:
        return _N2_1Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.n2_2:
        return _N2_2Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.n3_1:
        return _N3_1Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.n3_2:
        return _N3_2Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.s1_1:
        return _S1_1Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.s1_2:
        return _S1_2Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.s2_1:
        return _S2_1Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.s2_2:
        return _S2_2Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.s3_1:
        return _S3_1Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.s3_2:
        return _S3_2Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.style1:
        return _Style1Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
    }
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
  EdgeInsetsGeometry margin = const EdgeInsets.all(16),
}) {
  return Align(
    alignment: alignment,
    child: Container(
      margin: margin,
      child: child,
    ),
  );
}

// ───── Timestamp Picker Thumbnail ─────
class TimestampThumbnail extends StatelessWidget {
  final TimestampDesign design;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const TimestampThumbnail({
    super.key,
    required this.design,
    required this.isSelected,
    required this.onTap,
    this.margin,
    this.borderRadius,
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
                          style: const TextStyle(fontFamily: 'Pretendard'),
                          child: _thumbnail(design),
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

  static Widget _thumbnail(TimestampDesign design) {
    final now = DateTime.now();
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
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        final weekday = weekdays[now.weekday - 1];
        final dateStr = '${DateFormat('yyyy년 MM월 dd일').format(now)} ($weekday)';
        final period = now.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('h:mm').format(now)}';
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
        final dateStr = DateFormat('yyyy년 MM월 dd일').format(now);
        final period = now.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
        final dateStr = DateFormat('dd MMM, yyyy', 'en_US').format(now);
        final dayStr = DateFormat('EEEE', 'en_US').format(now);
        final period = now.hour < 12 ? 'AM' : 'PM';
        final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(dateStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Text(dayStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Text(timeStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontSize: 8, color: Colors.white, shadows: shadow)),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.n3_2:
        final yearStr = DateFormat('yyyy').format(now);
        final dateStr = DateFormat('MMMM dd', 'en_US').format(now);
        final period = now.hour < 12 ? 'AM' : 'PM';
        final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(yearStr, style: TextStyle(fontFamily: CameraUX.fontCafe24Simplehae, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Text(dateStr, style: TextStyle(fontFamily: CameraUX.fontCafe24Simplehae, fontSize: 8, color: Colors.white, shadows: shadow)),
                  Text(timeStr, style: TextStyle(fontFamily: CameraUX.fontCafe24Simplehae, fontSize: 8, color: Colors.white, shadows: shadow)),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.s1_1:
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        final weekday = weekdays[now.weekday - 1];
        final period = now.hour < 12 ? '오전' : '오후';
        final text = '${DateFormat('yy.MM.dd').format(now)}.$weekday $period ${DateFormat('h:mm').format(now)}';
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
                      style: TextStyle(fontFamily: CameraUX.fontTvnFunStory, fontSize: 9.5, color: Colors.white, shadows: shadow),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case TimestampDesign.s1_2:
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        final weekday = weekdays[now.weekday - 1];
        final period = now.hour < 12 ? '오전' : '오후';
        final text = '${DateFormat('yy.MM.dd').format(now)}.$weekday $period ${DateFormat('h:mm').format(now)}';
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
                      style: TextStyle(fontFamily: CameraUX.fontCafe24Shiningstar, fontSize: 10, color: Colors.white, shadows: shadow),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

      case TimestampDesign.s2_1:
        final dateStr = DateFormat('yyyy/MM/dd').format(now);
        final period = now.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(dateStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontSize: 8, color: Colors.white, shadows: shadow)),
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
                  Text(timeStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontSize: 8, color: Colors.white, shadows: shadow)),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.s2_2:
        final period = now.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('h:mm').format(now)}';
        final dateStr = DateFormat('yyyy MMM dd', 'en_US').format(now);
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
                    child: Text(timeStr, style: const TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontSize: 7.5, color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 2),
                  Text(dateStr, style: TextStyle(fontFamily: CameraUX.fontNanumBarunpen, fontSize: 7.5, color: Colors.white, shadows: shadow)),
                ],
              ),
            ),
          ),
        );

      case TimestampDesign.s3_1:
        final yearStr = DateFormat('yyyy').format(now);
        final dateStr = DateFormat('MMMM dd', 'en_US').format(now);
        final period = now.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
                    yearStr,
                    style: TextStyle(
                      fontFamily: CameraUX.fontTvnFunStory,
                      fontSize: 8,
                      color: Colors.white,
                      height: 1.0,
                      shadows: shadow,
                    ),
                  ),
                  buildDivider(),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontFamily: CameraUX.fontTvnFunStory,
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
        final dateStr = DateFormat('yy/MM/dd').format(now);
        final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
        final weekdayStr = weekdays[now.weekday - 1];
        final period = now.hour < 12 ? '오전' : '오후';
        final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
        final dayStr = DateFormat('EEEE', 'en_US').format(now);
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
                    text: 'Many a little makes a miracle',
                    textStyle: TextStyle(
                      fontFamily: CameraUX.fontRondal,
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
                        DateFormat('MM').format(now),
                        style: TextStyle(
                          fontFamily: CameraUX.fontLobster,
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
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            shadows: shadow,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('dd').format(now),
                        style: TextStyle(
                          fontFamily: CameraUX.fontLobster,
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
                          '${now.hour < 12 ? 'AM' : 'PM'} ${DateFormat('hh:mm').format(now)}',
                          style: TextStyle(
                            fontFamily: CameraUX.fontRondal,
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
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: CameraUX.fontRubberNippleFactory,
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
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: CameraUX.fontNixieOne,
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
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    final dateStr = '${DateFormat('yyyy년 MM월 dd일').format(now)} ($weekday)';
    final period = now.hour < 12 ? '오전' : '오후';
    final timeStr = '$period ${DateFormat('h:mm').format(now)}';
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
    final dateStr = DateFormat('yyyy년 MM월 dd일').format(now);
    final period = now.hour < 12 ? '오전' : '오후';
    final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
    final dateStr = DateFormat('dd MMM, yyyy', 'en_US').format(now);
    final dayStr = DateFormat('EEEE', 'en_US').format(now);
    final period = now.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
    final yearStr = DateFormat('yyyy').format(now);
    final dateStr = DateFormat('MMMM dd', 'en_US').format(now);
    final period = now.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
            yearStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24Simplehae,
              fontSize: fontSize,
              color: Colors.white,
              height: 1.0,
              shadows: shadows,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateStr,
            textAlign: textAlign,
            style: TextStyle(
              fontFamily: CameraUX.fontCafe24Simplehae,
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
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    final period = now.hour < 12 ? '오전' : '오후';
    final text = '${DateFormat('yyyy.MM.dd').format(now)}.$weekday $period ${DateFormat('hh:mm').format(now)}';
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
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    final period = now.hour < 12 ? '오전' : '오후';
    final text = '${DateFormat('yyyy.MM.dd').format(now)}.$weekday $period ${DateFormat('hh:mm').format(now)}';
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
    final dateStr = DateFormat('yyyy/MM/dd').format(now);
    final period = now.hour < 12 ? '오전' : '오후';
    final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
    final period = now.hour < 12 ? '오전' : '오후';
    final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
    final dateStr = DateFormat('yyyy MMM dd', 'en_US').format(now);
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
    final yearStr = DateFormat('yyyy').format(now);
    final dateStr = DateFormat('MMMM dd', 'en_US').format(now);
    final period = now.hour < 12 ? '오전' : '오후';
    final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
            yearStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
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
            dateStr,
            style: TextStyle(
              fontFamily: CameraUX.fontTvnFunStory,
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
    final dateStr = DateFormat('yy/MM/dd').format(now);
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final weekdayStr = weekdays[now.weekday - 1];
    final period = now.hour < 12 ? '오전' : '오후';
    final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
  const _Style1Stamp({required this.now, required this.alignment, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    // Title Case (e.g. Tuesday, Saturday)
    final dayStr = DateFormat('EEEE', 'en_US').format(now);
    final monthStr = DateFormat('MM').format(now);
    final dateStr = DateFormat('dd').format(now);
    final period = now.hour < 12 ? 'AM' : 'PM';
    final timeStr = '$period ${DateFormat('hh:mm').format(now)}';
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
          // Circular Arc Text: "Many a little makes a miracle" with exact bounding width
          _CurvedTextWidget(
            text: 'Many a little makes a miracle',
            textStyle: TextStyle(
              fontFamily: CameraUX.fontRondal,
              fontSize: fontSize * 0.32,
              color: Colors.white.withValues(alpha: 0.92),
              letterSpacing: 0.8,
              shadows: shadows,
            ),
            radius: arcRadius,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                monthStr,
                style: TextStyle(
                  fontFamily: CameraUX.fontLobster,
                  fontSize: fontSize * 0.42,
                  color: Colors.white,
                  shadows: shadows,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: Text(
                  dayStr,
                  style: TextStyle(
                    fontFamily: CameraUX.fontRondalBold,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                    height: 1.0,
                    shadows: shadows,
                  ),
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                  fontFamily: CameraUX.fontLobster,
                  fontSize: fontSize * 0.42,
                  color: Colors.white,
                  shadows: shadows,
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
    // 텍스트 호의 실제 시각적 가로 너비(양 끝점 간격)를 정밀 측정하여 불필요한 좌우 여백을 완전히 제거
    double totalTextLength = 0.0;
    double maxCharHeight = 0.0;
    for (int i = 0; i < text.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: text[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      totalTextLength += tp.width;
      if (tp.height > maxCharHeight) maxCharHeight = tp.height;
    }

    final totalAngle = totalTextLength / radius;
    final fontSize = textStyle.fontSize ?? 10.0;
    // 호의 양 끝점 사이의 chord 너비 + 양 끝 글자 너비 보정
    final exactArcWidth = (2 * radius * math.sin(totalAngle / 2)) + (fontSize * 0.9);
    final arcHeight = radius * (1 - math.cos(totalAngle / 2)) + maxCharHeight * 1.3;

    return SizedBox(
      width: exactArcWidth,
      height: arcHeight.clamp(maxCharHeight * 1.4, double.infinity),
      child: CustomPaint(
        painter: _CurvedTextPainter(
          text: text,
          textStyle: textStyle,
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
