import 'dart:io';
import 'package:flutter/material.dart';
import '../ux_config.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback onLeftActionPressed;
  final VoidCallback onRightActionPressed;
  final VoidCallback onCenterActionPressed;
  final File? rightThumbnail;
  final bool isLoading;
  final IconData? centerIcon;

  const CustomBottomNavBar({
    super.key,
    required this.onLeftActionPressed,
    required this.onRightActionPressed,
    required this.onCenterActionPressed,
    this.rightThumbnail,
    this.isLoading = false,
    this.centerIcon,
  });

  // 스타일 관련 상수들을 SharedUX에서 관리
  static const double kShutterSize = SharedUX.centerButtonSize;
  static const Color kShutterColor = SharedUX.centerButtonColor;

  @override
  Widget build(BuildContext context) {
    const shadow = [
      Shadow(
        blurRadius: 8,
        color: Colors.black45,
        offset: Offset(0, 2),
      )
    ];

    return SizedBox(
      height: SharedUX.containerHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Decorative Concave Line
          Positioned(
            left: 0,
            right: 0,
            bottom: SharedUX.linePosition,
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _ConcaveLinePainter(
                shutterSize: kShutterSize,
                color: Colors.white.withOpacity(0.35),
              ),
            ),
          ),

          // 2. The Content Row (Side Icons)
          Positioned(
            left: 0,
            right: 0,
            bottom: SharedUX.iconsPosition,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SharedUX.sidePadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Album Button
                  _labeledIconButton(
                    icon: Icons.calendar_today_outlined,
                    label: '앨범',
                    onPressed: onLeftActionPressed,
                    shadow: shadow,
                  ),
                  // Gallery Button
                  _labeledGalleryButton(
                    onPressed: onRightActionPressed,
                    shadow: shadow,
                  ),
                ],
              ),
            ),
          ),

          // 3. The Pop-out Action Button (Floating Shutter)
          Positioned(
            bottom: SharedUX.shutterPosition,
            child: GestureDetector(
              onTap: isLoading ? null : onCenterActionPressed,
              child: _buildCenterButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required List<Shadow> shadow,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: SharedUX.navIconSize,
            shadows: shadow,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: SharedUX.navLabelSize,
              fontWeight: FontWeight.w500,
              shadows: shadow,
              fontFamily: SharedUX.navLabelFontFamily,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledGalleryButton({
    required VoidCallback onPressed,
    required List<Shadow> shadow,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rightThumbnail != null)
            Container(
              width: SharedUX.navThumbnailSize,
              height: SharedUX.navThumbnailSize,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
                image: DecorationImage(
                  image: FileImage(rightThumbnail!),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            )
          else
            Icon(
              Icons.photo_library_outlined,
              color: Colors.white,
              size: SharedUX.navIconSize,
              shadows: shadow,
            ),
          const SizedBox(height: 6),
          Text(
            '갤러리',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SharedUX.navLabelSize,
              fontWeight: FontWeight.w500,
              shadows: shadow,
              fontFamily: SharedUX.navLabelFontFamily,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton() {
    return Container(
      width: kShutterSize,
      height: kShutterSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kShutterColor.withOpacity(SharedUX.centerOpacity),
        border: Border.all(
          color: kShutterColor,
          width: SharedUX.centerRingWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : (centerIcon != null
                ? Icon(centerIcon, color: Colors.white, size: SharedUX.centerIconSize)
                : null),
      ),
    );
  }
}

class _ConcaveLinePainter extends CustomPainter {
  final double shutterSize;
  final Color color;

  _ConcaveLinePainter({required this.shutterSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final centerY = 0.0;
    final centerX = size.width / 2;
    
    // Layout-specific parameters from SharedUX
    final dipWidth = shutterSize / 2 + SharedUX.lineDipWidthExtra;
    final dipDepth = SharedUX.lineDipDepth;
    final shoulderWidth = SharedUX.lineShoulderWidth;

    // Left straight line
    path.moveTo(0, centerY);
    path.lineTo(centerX - dipWidth - shoulderWidth, centerY);

    // Left smooth shoulder to dip
    path.cubicTo(
      centerX - dipWidth - shoulderWidth / 2, centerY, // Control point 1
      centerX - dipWidth, centerY,               // Control point 2
      centerX - dipWidth, centerY + dipDepth / 2, // End point
    );
    
    // Bottom curve around shutter
    path.arcToPoint(
      Offset(centerX + dipWidth, centerY + dipDepth / 2),
      radius: Radius.circular(dipWidth),
      clockwise: false,
    );

    // Right dip back to smooth shoulder
    path.cubicTo(
      centerX + dipWidth, centerY,               // Control point 1
      centerX + dipWidth + shoulderWidth / 2, centerY, // Control point 2
      centerX + dipWidth + shoulderWidth, centerY, // End point
    );

    // Right straight line
    path.lineTo(size.width, centerY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
