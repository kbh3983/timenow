import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ───── Timestamp Design Types ─────
enum TimestampDesign {
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
  final double opacity;
  final DateTime? baseTime;
  final bool isLive;

  const TimestampOverlayWidget({
    super.key,
    required this.design,
    this.opacity = 1.0,
    this.baseTime,
    this.isLive = true,
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
      child: Stack(fit: StackFit.expand, children: [_buildDesign()]),
    );
  }

  Widget _buildDesign() {
    switch (widget.design) {
      case TimestampDesign.none:
        return const SizedBox.shrink();
      case TimestampDesign.analogClock:
        return _AnalogClockStamp(now: _now);
      case TimestampDesign.dateText:
        return _DateTextStamp(now: _now);
      case TimestampDesign.filmGrain:
        return _FilmGrainStamp(now: _now);
      case TimestampDesign.sample0:
        return _Sample0Stamp(now: _now);
      case TimestampDesign.sample1:
        return _Sample1Stamp(now: _now);
      case TimestampDesign.sample2:
        return _Sample2Stamp(now: _now);
      case TimestampDesign.sample3:
        return _Sample3Stamp(now: _now);
    }
  }
}

// ───── Analog Clock Stamp ─────
class _AnalogClockStamp extends StatelessWidget {
  final DateTime now;
  const _AnalogClockStamp({required this.now});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white60, width: 1.5),
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
  const _DateTextStamp({required this.now});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('MMM dd, yyyy').format(now).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              shadows: [Shadow(blurRadius: 6, color: Colors.black87)],
            ),
          ),
          Text(
            DateFormat('hh:mm a').format(now),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
              shadows: [Shadow(blurRadius: 6, color: Colors.black87)],
            ),
          ),
        ],
      ),
    );
  }
}

// ───── Film Grain Stamp ─────
class _FilmGrainStamp extends StatelessWidget {
  final DateTime now;
  const _FilmGrainStamp({required this.now});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.42),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.grain, color: Colors.white70, size: 13),
            const SizedBox(width: 6),
            Text(
              'FILM  ${DateFormat('MMM dd').format(now).toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
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
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
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
              child: _thumbnail(design),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _thumbnail(TimestampDesign design) {
    final now = DateTime.now();
    const shadow = [Shadow(blurRadius: 4, color: Colors.black54)];

    switch (design) {
      case TimestampDesign.none:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, color: Colors.white60, size: 28),
            SizedBox(height: 4),
            Text(
              'None',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                shadows: shadow,
              ),
            ),
          ],
        );
      case TimestampDesign.analogClock:
        return Center(
          child: SizedBox(
            width: 54,
            height: 54,
            child: CustomPaint(
              painter: _ClockPainter(now: now, color: Colors.white),
            ),
          ),
        );
      case TimestampDesign.dateText:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'JAN 28,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    shadows: shadow,
                  ),
                ),
                Text(
                  '2024',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 1,
                    shadows: shadow,
                  ),
                ),
                Text(
                  '10:30 AM',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                    letterSpacing: 0.8,
                    shadows: shadow,
                  ),
                ),
              ],
            ),
          ),
        );
      case TimestampDesign.filmGrain:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.grain, color: Colors.white70, size: 20),
              SizedBox(height: 4),
              Text(
                'FILM\nGRAIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
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
        final index = design.index - TimestampDesign.sample0.index;
        return Image.asset(
          'assets/images/sample_$index.jpg',
          fit: BoxFit.cover,
          errorBuilder: (ctx, _, __) => Container(
            color: Colors.white.withOpacity(0.05),
            child: Center(
              child: Text(
                'Sample $index',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  shadows: shadow,
                ),
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
  const _Sample0Stamp({required this.now});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Corners
        const Positioned(
          top: 20,
          left: 20,
          child: _Corner(isTop: true, isLeft: true),
        ),
        const Positioned(
          top: 20,
          right: 20,
          child: _Corner(isTop: true, isLeft: false),
        ),
        const Positioned(
          bottom: 20,
          left: 20,
          child: _Corner(isTop: false, isLeft: true),
        ),
        const Positioned(
          bottom: 20,
          right: 20,
          child: _Corner(isTop: false, isLeft: false),
        ),

        // Rec Dot
        Positioned(
          top: 30,
          left: 40,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Rec',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Center Timestamp
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('yyyy/MM/dd').format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                ),
              ),
              Text(
                DateFormat('HH:mm').format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  const _Corner({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    const double size = 24.0;
    const double thickness = 2.5;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.white, width: thickness)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.white, width: thickness)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.white, width: thickness)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.white, width: thickness)
              : BorderSide.none,
        ),
      ),
    );
  }
}

// ───── Sample 1 Design (Center Bold Bubble) ─────
class _Sample1Stamp extends StatelessWidget {
  final DateTime now;
  const _Sample1Stamp({required this.now});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        DateFormat('yyyy.MM.dd PM hh:mm').format(now).toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          shadows: [
            Shadow(blurRadius: 12, color: Colors.black.withOpacity(0.5)),
            Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

// ───── Sample 2 Design (Large Time + Small Date below) ─────
class _Sample2Stamp extends StatelessWidget {
  final DateTime now;
  const _Sample2Stamp({required this.now});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('hh:mm').format(now),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
              letterSpacing: -2,
            ),
          ),
          Text(
            '${DateFormat('yyyy.MM.dd').format(now)} (${DateFormat('E').format(now)})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ───── Sample 3 Design (Korean Style thin) ─────
class _Sample3Stamp extends StatelessWidget {
  final DateTime now;
  const _Sample3Stamp({required this.now});

  @override
  Widget build(BuildContext context) {
    final period = now.hour < 12 ? '오전' : '오후';
    final timeStr = DateFormat('h:mm').format(now);
    final dateStr = DateFormat('yyyy년 M월 d일').format(now);
    final weekday = ['월', '화', '수', '목', '금', '토', '일'][now.weekday - 1];

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$period $timeStr',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w200,
            ),
          ),
          Text(
            '$dateStr ($weekday)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
