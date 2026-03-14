import 'package:flutter/material.dart';

/// UI/UX Configuration Constants for Timenow App
class UXConfig {
  // --- Camera Screen ---

  /// Opacity of the mask area outside the active aspect ratio
  static const double kCameraMaskOpacity = 0.85;

  // --- Bottom Navigation Bar ---

  /// The width of the white capsule bar
  static const double kBottomBarWidth = 288.0;

  /// The height of the white capsule bar
  static const double kBottomBarHeight = 68.0;

  /// The corner radius of the white capsule bar
  static const double kBottomBarBorderRadius = 28.0;

  /// The size of the centered pop-out action button
  static const double kBottomBarCenterButtonSize = 80.0;

  /// The size of the inner ring of the centered button
  static const double kBottomBarInnerRingSize = 64.0;

  /// The main color of the centered action button
  static const Color kBottomBarCenterButtonColor = Color(0xFF2A2A2A);

  // --- Timer ---

  /// Asset paths for timer PNG icons
  static const String kTimerIconOff = 'assets/icons/timer.png';
  static const String kTimerIcon3s = 'assets/icons/timer_3.png';
  static const String kTimerIcon5s = 'assets/icons/timer_5.png';
  static const String kTimerIcon7s = 'assets/icons/timer_7.png';

  // --- Top Menu Icons ---

  /// Top menu icon color for 1:1 aspect ratio
  static const Color kTopIconColor1x1 = Colors.white;

  /// Top menu icon color for 4:5 aspect ratio
  static const Color kTopIconColor4x5 = Colors.white;

  /// Top menu icon color for 9:16 aspect ratio
  static const Color kTopIconColor9x16 = Colors.white;

  /// Helper to get the top icon color by aspect ratio value
  static Color getTopIconColor(double aspectRatio) {
    if ((aspectRatio - 1.0).abs() < 0.01) {
      return kTopIconColor1x1;
    } else if ((aspectRatio - (4.0 / 5.0)).abs() < 0.01) {
      return kTopIconColor4x5;
    } else if ((aspectRatio - (9.0 / 16.0)).abs() < 0.01) {
      return kTopIconColor9x16;
    }
    return Colors.white;
  }

  /// Sequential timer durations in seconds
  static const List<int> kTimerCycle = [0, 3, 5, 7];

  // --- Calendar Screen ---

  /// Color of the selected day circle in the calendar
  static const Color kCalendarSelectedDayColor = Color(0xFF81C784);

  /// Vertical spacing between weeks in the calendar grid
  static const double kCalendarWeekSpacing = 6.0;

  /// Vertical padding for the weekday header (일, 월, 화...)
  static const double kCalendarWeekdayVerticalPadding = 8.0;
}
