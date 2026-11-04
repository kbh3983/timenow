import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stamps/sample_stamp_renderer.dart';
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
      fontSizeSteps: [34.0],
      defaultFontSizeIndex: 0,
    ),
    TimestampDesign.none: TimestampDesignConfig(designName: '없음'),
  };

  /// 해당 스탬프가 위치(정렬) 변경을 지원하는지 여부
  /// (프레임 f1~f9 및 스타일 style1~style11 은 전체 레이아웃이 고정되어 위치 변경 불가)
  static bool supportsAlignment(TimestampDesign design) {
    if (design == TimestampDesign.none || design == TimestampDesign.style1) {
      return false;
    }
    if (design.isSampleStamp) {
      return !SampleStampLibrary.isCanvasMode(design.name);
    }
    return true;
  }

  /// 해당 스탬프가 크기 단계 변경(1A/2A/3A)을 지원하는지 여부
  static bool supportsFontSize(TimestampDesign design) {
    if (design == TimestampDesign.none || design == TimestampDesign.style1) {
      return false;
    }
    return getFontSizeSteps(design).length > 1;
  }

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
    return designs[design]?.designName ?? design.name;
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
    if (design.isSampleStamp) {
      // 샘플 스탬프는 글자 크기 대신 샘플의 크기 단계(groupScale 0/1/2)를 그대로 사용합니다.
      // 값 = 단계 번호 + 1 (1.0, 2.0, 3.0). 실제 글자/이미지 크기는 샘플 데이터에 정의된 값으로 그려집니다.
      final count = SampleStampLibrary.scaleCount(design.name);
      return List<double>.generate(count, (i) => (i + 1).toDouble());
    }
    return designs[design]?.fontSizeSteps ?? [18.0, 25.0, 30.0];
  }

  /// 샘플 스탬프의 크기 단계 인덱스 (fontSize 값 = 단계 + 1, 영상 렌더링 시에는 fontSize 에 배율이 곱해져 들어옴)
  static int sampleScaleIndexFor(TimestampDesign design, double fontSize, {double scale = 1.0}) {
    final count = SampleStampLibrary.scaleCount(design.name);
    final step = scale > 0 ? fontSize / scale : fontSize;
    return (step.round() - 1).clamp(0, count - 1);
  }

  static double getDefaultFontSize(TimestampDesign design) {
    if (design.isSampleStamp) {
      final steps = getFontSizeSteps(design);
      return steps[getDefaultFontSizeIndex(design).clamp(0, steps.length - 1)];
    }
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
    if (design.isSampleStamp) {
      // 다른 스탬프와 동일하게 3단계가 있으면 중간 크기를 기본값으로 사용
      return SampleStampLibrary.scaleCount(design.name) >= 3 ? 1 : 0;
    }
    return designs[design]?.defaultFontSizeIndex ?? 1;
  }
}
