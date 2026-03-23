import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timestamp_overlays.dart';
import 'ux_config.dart';

class TimestampDesignConfig {
  final String designName;
  final String? fontFamily;
  final double defaultFontSize;
  final Color color;
  final List<Shadow>? shadows;

  final String? dateFormat;
  final String? timeFormat;
  final List<double>? fontSizeSteps;
  final int defaultFontSizeIndex;

  const TimestampDesignConfig({
    required this.designName,
    this.fontFamily,
    this.defaultFontSize = 22.0,
    this.color = CameraUX.defaultColor,
    this.shadows = CameraUX.defaultShadows,
    this.dateFormat,
    this.timeFormat,
    this.fontSizeSteps,
    this.defaultFontSizeIndex = 0,
  });
}

class TimestampMetadata {
  static const Map<TimestampDesign, TimestampDesignConfig> designs = {
    TimestampDesign.custom01: TimestampDesignConfig(
      designName: '감성 한글',
      fontFamily: 'NanumSquareB',
      defaultFontSize: 16.0,
      dateFormat: 'yyyy년 MM월 dd일 (E)',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [16.0, 20.0, 24.0],
      defaultFontSizeIndex: 1, // Start with 20.0
    ),
    TimestampDesign.custom02: TimestampDesignConfig(
      designName: '이서윤체',
      fontFamily: CameraUX.stampFont02,
      defaultFontSize: 24.0,
      dateFormat: 'yyyy/MM/dd (E)',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [20.0, 24.0, 28.0],
      defaultFontSizeIndex: 1, // Start with 24.0
    ),
    TimestampDesign.custom03: TimestampDesignConfig(
      designName: '고무인자',
      fontFamily: CameraUX.stampFont03,
      defaultFontSize: 26.0,
      dateFormat: 'yyyy.MM.dd',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [20.0, 25.0, 30.0],
      defaultFontSizeIndex: 1, // Start with 25.0
    ),
    TimestampDesign.none: TimestampDesignConfig(designName: '없음'),
    TimestampDesign.analogClock: TimestampDesignConfig(designName: '아날로그'),
    TimestampDesign.dateText: TimestampDesignConfig(
      designName: '심플',
      dateFormat: 'MMM dd, yyyy',
      timeFormat: 'hh:mm a',
    ),
    TimestampDesign.filmGrain: TimestampDesignConfig(
      designName: '필름',
      dateFormat: 'MMM dd',
    ),
    TimestampDesign.sample0: TimestampDesignConfig(
      designName: '뷰파인더',
      timeFormat: 'HH:mm:ss',
    ),
    TimestampDesign.sample1: TimestampDesignConfig(
      designName: '타자기',
      dateFormat: 'yyyy.MM.dd',
    ),
    TimestampDesign.sample2: TimestampDesignConfig(
      designName: '모던 볼드',
      dateFormat: 'EEEE\nMMMM dd',
    ),
    TimestampDesign.sample3: TimestampDesignConfig(
      designName: '네온',
      dateFormat: 'yyyy년 M월 d일 (E)',
      timeFormat: 'a h:mm',
    ),
  };

  static String? getFontFamily(TimestampDesign design) {
    return designs[design]?.fontFamily;
  }

  static String getName(TimestampDesign design) {
    return designs[design]?.designName ?? '';
  }

  static Color getColor(TimestampDesign design) {
    return designs[design]?.color ?? CameraUX.defaultColor;
  }

  static List<Shadow>? getShadows(TimestampDesign design) {
    return designs[design]?.shadows ?? CameraUX.defaultShadows;
  }

  static String getDateFormat(TimestampDesign design) {
    return designs[design]?.dateFormat ?? 'yyyy.MM.dd';
  }

  static String getTimeFormat(TimestampDesign design) {
    return designs[design]?.timeFormat ?? 'HH:mm';
  }

  static String getFormattedDateTime(TimestampDesign design, DateTime now) {
    final dateFormat = getDateFormat(design);
    final timeFormat = getTimeFormat(design);

    // Korean values
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    final period = now.hour < 12 ? '오전' : '오후';

    // Replace Korean placeholder tokens before passing to DateFormat
    String resolveFormat(String fmt) {
      // Replace (E) with the actual weekday
      String s = fmt.replaceAll('(E)', '($weekday)');
      // If format starts with 'a ' (AM/PM prefix), handle separately
      if (s.startsWith('a ')) {
        final rest = s.substring(2); // e.g. 'hh:mm'
        return '$period ${DateFormat(rest).format(now)}';
      }
      return DateFormat(s).format(now);
    }

    final dateStr = resolveFormat(dateFormat);
    final timeStr = resolveFormat(timeFormat);

    return '$dateStr $timeStr'.trim();
  }

  static List<double> getFontSizeSteps(TimestampDesign design) {
    return designs[design]?.fontSizeSteps ?? [14.0, 22.0, 24.0];
  }

  static double getDefaultFontSize(TimestampDesign design) {
    final conf = designs[design];
    if (conf == null) return 14.0;
    if (conf.fontSizeSteps != null && conf.fontSizeSteps!.isNotEmpty) {
      final idx = conf.defaultFontSizeIndex.clamp(
        0,
        conf.fontSizeSteps!.length - 1,
      );
      return conf.fontSizeSteps![idx];
    }
    return conf.defaultFontSize;
  }

  static int getDefaultFontSizeIndex(TimestampDesign design) {
    return designs[design]?.defaultFontSizeIndex ?? 0;
  }
}
