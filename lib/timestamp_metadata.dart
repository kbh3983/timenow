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
    this.defaultFontSize = 25.0,
    this.color = CameraUX.defaultColor,
    this.shadows = CameraUX.defaultShadows,
    this.dateFormat,
    this.timeFormat,
    this.fontSizeSteps,
    this.defaultFontSizeIndex = 1,
  });
}

class TimestampMetadata {
  static const Map<TimestampDesign, TimestampDesignConfig> designs = {
    TimestampDesign.n1_1: TimestampDesignConfig(
      designName: 'n1_1',
      fontFamily: CameraUX.fontRubberNippleFactory,
      defaultFontSize: 20.0,
      dateFormat: 'yyyy.MM.dd',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [17.0, 20.0, 23.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.n1_2: TimestampDesignConfig(
      designName: 'n1_2',
      fontFamily: CameraUX.fontNixieOne,
      defaultFontSize: 25.0,
      dateFormat: 'yyyy/MM/dd',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [21.0, 25.0, 29.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.n2_1: TimestampDesignConfig(
      designName: 'n2_1',
      fontFamily: CameraUX.fontCafe24OnePrettyNight,
      defaultFontSize: 32.0,
      dateFormat: 'yyyy년 MM월 dd일 (E)',
      timeFormat: 'a h:mm',
      fontSizeSteps: [26.0, 32.0, 38.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.n2_2: TimestampDesignConfig(
      designName: 'n2_2',
      fontFamily: CameraUX.fontNanumAmsterdam,
      defaultFontSize: 30.0,
      dateFormat: 'yyyy년 MM월 dd일',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [24.0, 30.0, 36.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.n3_1: TimestampDesignConfig(
      designName: 'n3_1',
      fontFamily: CameraUX.fontNanumBarunpen,
      defaultFontSize: 22.5,
      dateFormat: 'dd MMM, yyyy',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [18.0, 22.5, 28.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.n3_2: TimestampDesignConfig(
      designName: 'n3_2',
      fontFamily: CameraUX.fontCafe24Simplehae,
      defaultFontSize: 22.0,
      dateFormat: 'yyyy',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [18.0, 22.0, 26.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.s1_1: TimestampDesignConfig(
      designName: 's1_1',
      fontFamily: CameraUX.fontTvnFunStory,
      defaultFontSize: 24.0,
      dateFormat: 'yyyy.MM.dd.E',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [20.0, 24.0, 28.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.s1_2: TimestampDesignConfig(
      designName: 's1_2',
      fontFamily: CameraUX.fontCafe24Shiningstar,
      defaultFontSize: 26.0,
      dateFormat: 'yyyy.MM.dd.E',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [22.0, 26.0, 30.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.s2_1: TimestampDesignConfig(
      designName: 's2_1',
      fontFamily: CameraUX.fontNanumBarunpen,
      defaultFontSize: 25.0,
      dateFormat: 'yyyy/MM/dd',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [20.0, 25.0, 30.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.s2_2: TimestampDesignConfig(
      designName: 's2_2',
      fontFamily: CameraUX.fontNanumBarunpen,
      defaultFontSize: 25.0,
      dateFormat: 'yyyy MMM dd',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [20.0, 25.0, 30.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.s3_1: TimestampDesignConfig(
      designName: 's3_1',
      fontFamily: CameraUX.fontTvnFunStory,
      defaultFontSize: 32.0,
      dateFormat: 'yyyy',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [26.0, 32.0, 38.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.s3_2: TimestampDesignConfig(
      designName: 's3_2',
      fontFamily: CameraUX.fontTvnFunStory,
      defaultFontSize: 26.0,
      dateFormat: 'yy/MM/dd',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [22.0, 26.0, 30.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.style1: TimestampDesignConfig(
      designName: 'style1',
      fontFamily: CameraUX.fontRondalBold,
      defaultFontSize: 34.0,
      dateFormat: 'EEEE',
      timeFormat: 'a hh:mm',
      fontSizeSteps: [28.0, 34.0, 40.0],
      defaultFontSizeIndex: 1,
    ),
    TimestampDesign.none: TimestampDesignConfig(designName: '없음'),
  };

  static bool isEnglishDesign(TimestampDesign design) {
    return design == TimestampDesign.n1_1 ||
        design == TimestampDesign.n1_2 ||
        design == TimestampDesign.n3_1 ||
        design == TimestampDesign.n3_2 ||
        design == TimestampDesign.style1;
  }

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

    final weekdaysKr = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayKr = weekdaysKr[now.weekday - 1];

    final isEng = isEnglishDesign(design);
    final period = isEng
        ? (now.hour < 12 ? 'AM' : 'PM')
        : (now.hour < 12 ? '오전' : '오후');

    String resolveFormat(String fmt) {
      String s = fmt;
      if (!isEng) {
        s = s.replaceAll('(E)', '($weekdayKr)');
        s = s.replaceAll('.E', '.$weekdayKr');
      }
      if (s.startsWith('a ')) {
        final rest = s.substring(2);
        return '$period ${DateFormat(rest, isEng ? 'en_US' : 'ko_KR').format(now)}';
      }
      return DateFormat(s, isEng ? 'en_US' : 'ko_KR').format(now);
    }

    final dateStr = resolveFormat(dateFormat);
    final timeStr = resolveFormat(timeFormat);

    return '$dateStr $timeStr'.trim();
  }

  static List<double> getFontSizeSteps(TimestampDesign design) {
    return designs[design]?.fontSizeSteps ?? [18.0, 25.0, 30.0];
  }

  static double getDefaultFontSize(TimestampDesign design) {
    final conf = designs[design];
    if (conf == null) return 25.0;
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
    return designs[design]?.defaultFontSizeIndex ?? 1;
  }
}
