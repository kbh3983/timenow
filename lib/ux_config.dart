import 'package:flutter/material.dart';

/// UI/UX Configuration Constants for Timenow App
// Screen-specific configurations are split into CameraUX, CalendarUX, ReviewUX, and SharedUX.
// UXConfig is maintained for backward compatibility during transition.
class UXConfig {}

class CameraUX {
  // --- Mask ---
  static const double maskOpacity = 0.85;

  // --- Layout & Spacing ---
  static const double gapRatioToPicker = 8.0;
  static const double gapPickerToShutterTop = 8.0;
  static const double ratioButtonsHeight = 52.0;

  static const double timestampPickerHeight = 92.0;

  // --- Aspect Ratio Buttons ---
  static const double ratioButtonWidth = 54.0;
  static const double ratioButtonPaddingVertical = 4.0;
  static const double ratioButtonMarginHorizontal = 4.0;
  static const double ratioButtonContainerVertical = 4.0;
  static const double ratioButtonContainerHorizontal = 8.0;

  // --- Top Menu Icons ---

  static const Color iconColor1x1 = Colors.white;
  static const Color iconColor4x5 = Colors.white;
  static const Color iconColor9x16 = Colors.white;

  static Color getTopIconColor(double aspectRatio) {
    if ((aspectRatio - 1.0).abs() < 0.01) return iconColor1x1;
    if ((aspectRatio - (4.0 / 5.0)).abs() < 0.01) return iconColor4x5;
    if ((aspectRatio - (9.0 / 16.0)).abs() < 0.01) return iconColor9x16;
    return Colors.white;
  }

  // --- Timer ---
  static const List<int> timerCycle = [0, 3, 5, 7];
  static const String timerIconOff = 'assets/icons/timer.png';
  static const String timerIcon3s = 'assets/icons/timer_3.png';
  static const String timerIcon5s = 'assets/icons/timer_5.png';
  static const String timerIcon7s = 'assets/icons/timer_7.png';

  // --- Timestamp Core ---
  static const Alignment defaultAlignment = Alignment.center;
  static const List<Alignment> alignments = [
    Alignment.center,
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.bottomCenter,
    Alignment.bottomRight,
  ];
  static const Color defaultColor = Colors.white;
  static const List<Shadow> defaultShadows = [
    Shadow(offset: Offset(0, 1), blurRadius: 4.0, color: Colors.black54),
    Shadow(offset: Offset(0, 2), blurRadius: 10.0, color: Colors.black26),
  ];

  // --- Custom Stamp Assets ---
  static const String stampImage02 = 'assets/images/timestamp/timestamp_02.png';
  static const String stampFont02 = 'LeeSeoyun';
  static const String stampImage03 = 'assets/images/timestamp/timestamp_03.png';
  static const String stampFont03 = 'RubberNippleFactory';
}

/// Calendar Screen Specific Configurations
class CalendarUX {
  static const Color selectedDayColor = Color(0xFF81C784);
  static const double weekSpacing = 3.0;
  static const double weekdayVerticalPadding = 6.0;
  static const double calendarHorizontalPadding = 6.0;
  static const double initialSheetSize = 0.45;
  static const double albumTitleFontSize = 16.0;
  static const double monthHeaderFontSize = 14.0;
  static const double calendarDayFontSize = 16.0;
  static const double calendarGridAspectRatio = 1.0;

  static const double calendarDotSize = 4.0;
  static const double calendarDotBorderWidth = 0.8;
  static const double calendarDotDarkenAmount = 0.25; // 0.0 to 1.0 (25% darker)
}

/// Photo Review/Edit Screen Specific Configurations
class ReviewUX {
  static const double albumSelectorHeight = 36.0;
  static const double albumButtonHorizontalPadding = 12.0;

  static const double albumButtonVerticalPadding = 6.0;
  static const double albumButtonMarginHorizontal = 4.0;
  static const double albumButtonBorderRadius = 10.0;
  static const double albumButtonFontSize = 11.0;

  static const Color albumButtonSelectedBg = Color(0xFF333333);
  static const Color albumButtonBg = Colors.black45; // withOpacity(0.4)
  static const Color albumButtonSelectedText = Color(0xFFFFD700);
  static const Color albumButtonText = Colors.white70;
}

/// Navigation Bar & Shutter Button Configurations
class SharedUX {
  // --- Outer Capsule Bar ---
  static const double barWidth = 288.0;
  static const double barHeight = 40.0;
  static const double barBorderRadius = 28.0;

  // --- Shutter / Center Button ---
  static const double centerButtonSize = 68.0;
  static const double innerRingSize = 60.0;
  static const Color centerButtonColor = Color(0xFFC4E800);
  static const double centerRingWidth = 6.0;
  static const double centerOpacity = 0.25;
  static const double centerIconSize = 36.0;

  // --- Layout & Spacing ---
  static const double stackBottomOffset = 4.0;

  // --- Bottom Navigation Set (Album, Shutter, Gallery) ---
  static const double containerHeight = 60.0;
  static const double linePosition = 24.0; // Decorative line vertical pos
  static const double iconsPosition = 8.0; // Album/Gallery icons vertical pos
  static const double shutterPosition = 20.0; // Shutter button vertical pos
  static const double sidePadding = 60.0; // Horizontal padding for icons
  static const double navIconSize = 24;
  static const double navThumbnailSize = 24.0;
  static const double navLabelSize = 8.0;
  static const String navLabelFontFamily = 'NanumSquareB';

  static const double lineDipDepth = 24.0;
  static const double lineDipWidthExtra = 4.0;
  static const double lineShoulderWidth = 40.0;
}
