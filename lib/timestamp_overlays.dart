import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timestamp_metadata.dart';
import 'ux_config.dart';

// ───── Timestamp Design Types ─────
enum TimestampDesign {
  custom01,
  custom02,
  custom03,
  none,
  analogClock,
  dateText,
  filmGrain,
  sample0,
  sample1,
  sample2,
  sample3,
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
    this.fontSize = 14.0,
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
        child: Stack(fit: StackFit.expand, children: [_buildDesign()]),
      ),
    );
  }

  Widget _buildDesign() {
    switch (widget.design) {
      case TimestampDesign.none:
        return const SizedBox.shrink();
      case TimestampDesign.custom01:
        return _Custom01Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.custom02:
        return _Custom02Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.custom03:
        return _Custom03Stamp(now: _now, alignment: widget.alignment, fontSize: widget.fontSize);
      case TimestampDesign.analogClock:
        return _AnalogClockStamp(now: _now, alignment: widget.alignment);
      case TimestampDesign.dateText:
        return _DateTextStamp(now: _now, alignment: widget.alignment);
      case TimestampDesign.filmGrain:
        return _FilmGrainStamp(now: _now, alignment: widget.alignment);
      case TimestampDesign.sample0:
        return _Sample0Stamp(now: _now, alignment: widget.alignment);
      case TimestampDesign.sample1:
        return _Sample1Stamp(now: _now, alignment: widget.alignment);
      case TimestampDesign.sample2:
        return _Sample2Stamp(now: _now, alignment: widget.alignment);
      case TimestampDesign.sample3:
        return _Sample3Stamp(now: _now, alignment: widget.alignment);
    }
  }
}

// ───── Analog Clock Stamp ─────
class _AnalogClockStamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  const _AnalogClockStamp({required this.now, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(20),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white60, width: 1.5),
          boxShadow: TimestampMetadata.getShadows(TimestampDesign.analogClock)?.map((s) => BoxShadow(
            color: s.color,
            offset: s.offset,
            blurRadius: s.blurRadius,
          )).toList(),
        ),
        child: CustomPaint(painter: _ClockPainter(now: now)),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final DateTime now;
  final Color color;
  _ClockPainter({required this.now, this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Hour ticks
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180 - math.pi / 2;
      final isMain = i % 3 == 0;
      final outerR = radius * 0.9;
      final innerR = radius * (isMain ? 0.70 : 0.80);
      paint.strokeWidth = isMain ? 2.0 : 1.0;
      canvas.drawLine(
        Offset(
          center.dx + innerR * math.cos(angle),
          center.dy + innerR * math.sin(angle),
        ),
        Offset(
          center.dx + outerR * math.cos(angle),
          center.dy + outerR * math.sin(angle),
        ),
        paint,
      );
    }

    // Hour hand
    final hourAngle =
        ((now.hour % 12) + now.minute / 60.0) * 30 * math.pi / 180 -
        math.pi / 2;
    paint.strokeWidth = 2.8;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.48 * math.cos(hourAngle),
        center.dy + radius * 0.48 * math.sin(hourAngle),
      ),
      paint,
    );

    // Minute hand
    final minAngle = now.minute * 6 * math.pi / 180 - math.pi / 2;
    paint.strokeWidth = 1.8;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.72 * math.cos(minAngle),
        center.dy + radius * 0.72 * math.sin(minAngle),
      ),
      paint,
    );

    // Center dot
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.now != now;
}

// ───── Date Text Stamp ─────
class _DateTextStamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  const _DateTextStamp({required this.now, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final bool isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    final bool isCenter = alignment == Alignment.topCenter || alignment == Alignment.bottomCenter || alignment == Alignment.center;

    final shadows = TimestampMetadata.getShadows(TimestampDesign.dateText);

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: isCenter ? CrossAxisAlignment.center : (isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat(TimestampMetadata.getDateFormat(TimestampDesign.dateText)).format(now).toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                shadows: shadows,
              ),
            ),
            Text(
              DateFormat(TimestampMetadata.getTimeFormat(TimestampDesign.dateText)).format(now),
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
                shadows: shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───── Film Grain Stamp ─────
class _FilmGrainStamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  const _FilmGrainStamp({required this.now, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final shadows = TimestampMetadata.getShadows(TimestampDesign.filmGrain);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.42),
          borderRadius: BorderRadius.circular(4),
          boxShadow: shadows?.map((s) => BoxShadow(
            color: s.color,
            offset: s.offset,
            blurRadius: s.blurRadius,
          )).toList(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.grain, color: Colors.white70, size: 13),
            const SizedBox(width: 6),
            Text(
              'FILM  ${DateFormat(TimestampMetadata.getDateFormat(TimestampDesign.filmGrain)).format(now).toUpperCase()}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                shadows: shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───── Timestamp Picker Thumbnail ─────
class TimestampThumbnail extends StatelessWidget {
  final TimestampDesign design;
  final bool isSelected;
  final VoidCallback onTap;

  const TimestampThumbnail({
    super.key,
    required this.design,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.zero,
              border: Border.all(
                color: isSelected ? Colors.deepOrange : Colors.white24,
                width: isSelected ? 2.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontFamily: 'Pretendard'),
                child: _thumbnail(design),
              ),
            ),
          ),
        ),
      ),
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
      case TimestampDesign.custom01:
        return Image.asset(
          'assets/images/timestamp/timestamp_01.png',
          color: Colors.white,
          colorBlendMode: BlendMode.srcIn,
          fit: BoxFit.contain,
          errorBuilder: (ctx, _, __) => const Icon(Icons.image, color: Colors.white),
        );
      case TimestampDesign.custom02:
        return Image.asset(
          CameraUX.stampImage02,
          color: Colors.white,
          colorBlendMode: BlendMode.srcIn,
          fit: BoxFit.contain,
          errorBuilder: (ctx, _, __) => const Icon(Icons.image, color: Colors.white),
        );
      case TimestampDesign.custom03:
        return Image.asset(
          CameraUX.stampImage03,
          color: Colors.white,
          colorBlendMode: BlendMode.srcIn,
          fit: BoxFit.contain,
          errorBuilder: (ctx, _, __) => const Icon(Icons.image, color: Colors.white),
        );
      case TimestampDesign.analogClock:
        return Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(
              painter: _ClockPainter(now: now, color: Colors.white),
            ),
          ),
        );
      case TimestampDesign.dateText:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'JAN 28,',
                  style: TextStyle(
                    color: TimestampMetadata.getColor(design),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    shadows: shadow,
                  ),
                ),
                Text(
                  '2024',
                  style: TextStyle(
                    color: TimestampMetadata.getColor(design).withOpacity(0.8),
                    fontSize: 8,
                    letterSpacing: 0.8,
                    shadows: shadow,
                  ),
                ),
                Text(
                  '10:30 AM',
                  style: TextStyle(
                    color: TimestampMetadata.getColor(design).withOpacity(0.7),
                    fontSize: 7,
                    letterSpacing: 0.5,
                    shadows: shadow,
                  ),
                ),
              ],
            ),
          ),
        );
      case TimestampDesign.filmGrain:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grain, color: TimestampMetadata.getColor(design).withOpacity(0.8), size: 16),
              const SizedBox(height: 2),
              Text(
                'FILM\nGRAIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TimestampMetadata.getColor(design).withOpacity(0.8),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  shadows: shadow,
                ),
              ),
            ],
          ),
        );
      case TimestampDesign.sample0:
      case TimestampDesign.sample1:
      case TimestampDesign.sample2:
      case TimestampDesign.sample3:
        final name = TimestampMetadata.getName(design);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                shadows: shadow,
              ),
            ),
          ),
        );
    }
  }
}

// ───── Sample 0 Design (Rec + Corners + Center Text) ─────
class _Sample0Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  const _Sample0Stamp({required this.now, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final shadows = TimestampMetadata.getShadows(TimestampDesign.sample0);

    return Stack(
      children: [
        // Corners stay fixed as they are "frame" elements
        const Positioned(top: 20, left: 20, child: _Corner(angle: 0)),
        const Positioned(top: 20, right: 20, child: _Corner(angle: 90)),
        const Positioned(bottom: 20, left: 20, child: _Corner(angle: 270)),
        const Positioned(bottom: 20, right: 20, child: _Corner(angle: 180)),

        // REC and Time move together based on alignment
        Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(40), // More padding for viewfinder style
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('REC', style: TextStyle(
                      color: Colors.white, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      shadows: shadows,
                    )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(TimestampMetadata.getTimeFormat(TimestampDesign.sample0)).format(now),
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.w300, 
                    letterSpacing: 1,
                    shadows: shadows,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final double angle; // Angle in degrees for rotation
  const _Corner({required this.angle});

  @override
  Widget build(BuildContext context) {
    const double size = 24.0;
    const double thickness = 2.5;
    return Transform.rotate(
      angle: angle * (math.pi / 180), // Convert degrees to radians
      alignment: Alignment.topLeft,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white, width: thickness),
            left: BorderSide(color: Colors.white, width: thickness),
          ),
        ),
      ),
    );
  }
}

// ───── Sample 1 Design (Center Bold Bubble) ─────
class _Sample1Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  const _Sample1Stamp({required this.now, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final shadows = TimestampMetadata.getShadows(TimestampDesign.sample1);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: shadows?.map((s) => BoxShadow(
            color: s.color,
            offset: s.offset,
            blurRadius: s.blurRadius,
          )).toList(),
        ),
        child: Text(
          DateFormat(TimestampMetadata.getDateFormat(TimestampDesign.sample1)).format(now),
          style: TextStyle(
            color: Colors.white, 
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 4,
            shadows: shadows,
          ),
        ),
      ),
    );
  }
}

// ───── Sample 2 Design (Large Time + Small Date below) ─────
// ───── Sample 2 Design (Large Time + Small Date below) ─────
class _Sample2Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  const _Sample2Stamp({required this.now, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final shadows = TimestampMetadata.getShadows(TimestampDesign.sample2);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment == Alignment.center || alignment == Alignment.topCenter || alignment == Alignment.bottomCenter
              ? CrossAxisAlignment.center
              : (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end),
          children: [
            Text(
              DateFormat(TimestampMetadata.getDateFormat(TimestampDesign.sample2).split('\n')[0]).format(now).toUpperCase(),
              style: TextStyle(
                color: Colors.white, 
                fontSize: 42, 
                fontWeight: FontWeight.w900, 
                fontStyle: FontStyle.italic,
                shadows: shadows,
              ),
            ),
            Text(
              DateFormat(TimestampMetadata.getDateFormat(TimestampDesign.sample2).split('\n')[1]).format(now).toUpperCase(),
              style: TextStyle(
                color: Colors.white, 
                fontSize: 18, 
                fontWeight: FontWeight.w300, 
                letterSpacing: 8,
                shadows: shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───── Sample 3 Design (Korean Style thin) ─────
class _Sample3Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  const _Sample3Stamp({required this.now, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final shadows = TimestampMetadata.getShadows(TimestampDesign.sample3);

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment == Alignment.center || alignment == Alignment.topCenter || alignment == Alignment.bottomCenter
              ? CrossAxisAlignment.center
              : (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end),
          children: [
            Text(
              DateFormat(TimestampMetadata.getTimeFormat(TimestampDesign.sample3), 'ko_KR').format(now),
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w200,
                shadows: shadows,
              ),
            ),
            Text(
              DateFormat(TimestampMetadata.getDateFormat(TimestampDesign.sample3), 'ko_KR').format(now),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w300,
                shadows: shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ───── Custom 01 Design (Korean Style from image) ─────
class _Custom01Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _Custom01Stamp({required this.now, required this.alignment, this.fontSize = 14.0});

  @override
  Widget build(BuildContext context) {
    final displayStr = TimestampMetadata.getFormattedDateTime(TimestampDesign.custom01, now);
    final shadows = TimestampMetadata.getShadows(TimestampDesign.custom01);

    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(10),
        child: Text(
          displayStr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: TimestampMetadata.getColor(TimestampDesign.custom01),
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            fontFamily: TimestampMetadata.getFontFamily(TimestampDesign.custom01),
            letterSpacing: -0.5,
            shadows: shadows,
          ),
        ),
      ),
    );
  }
}

// ───── Custom 02 Design (LeeSeoyun) ─────
class _Custom02Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _Custom02Stamp({required this.now, required this.alignment, this.fontSize = 14.0});

  @override
  Widget build(BuildContext context) {
    final displayStr = TimestampMetadata.getFormattedDateTime(TimestampDesign.custom02, now);
    final shadows = TimestampMetadata.getShadows(TimestampDesign.custom02);

    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(10),
        child: Text(
          displayStr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            fontFamily: CameraUX.stampFont02,
            letterSpacing: -0.5,
            shadows: shadows,
          ),
        ),
      ),
    );
  }
}

// ───── Custom 03 Design (RubberNippleFactory) ─────
class _Custom03Stamp extends StatelessWidget {
  final DateTime now;
  final Alignment alignment;
  final double fontSize;
  const _Custom03Stamp({required this.now, required this.alignment, this.fontSize = 14.0});

  @override
  Widget build(BuildContext context) {
    final displayStr = TimestampMetadata.getFormattedDateTime(TimestampDesign.custom03, now);
    final shadows = TimestampMetadata.getShadows(TimestampDesign.custom03);

    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(10),
        child: Text(
          displayStr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            fontFamily: CameraUX.stampFont03,
            letterSpacing: -0.5,
            shadows: shadows,
          ),
        ),
      ),
    );
  }
}
