// ignore_for_file: constant_identifier_names, non_constant_identifier_names
//
// 샘플 앱(timestamp_sample/now)의 Constants / RegexUtil / I18n / Colors 를
// 스탬프 데이터 이식에 필요한 범위만큼 그대로 재현한 호환 레이어입니다.
// sample_stamp_data.dart 가 원본 TimestampRepository 코드를 그대로 사용할 수 있도록
// 동일한 이름과 값을 유지합니다. (한국어 로케일 고정)

/// 샘플의 `Colors.xxx.value` 표현을 그대로 쓰기 위한 최소 색상 값 클래스.
class SampleColor {
  final int value;
  const SampleColor(this.value);
}

/// 샘플 데이터에서 사용하는 Material 색상 값 (Flutter Colors 와 동일한 ARGB).
class Colors {
  static const SampleColor white = SampleColor(0xFFFFFFFF);
  static const SampleColor black = SampleColor(0xFF000000);
  static const SampleColor grey = SampleColor(0xFF9E9E9E);
  static const SampleColor yellow = SampleColor(0xFFFFEB3B);
}

class Constants {
  static const String TIMESTAMP_CATEGORY_NORMAL = "normal";
  static const String TIMESTAMP_CATEGORY_STAMP = "stamp";
  static const String TIMESTAMP_CATEGORY_FRAME = "frame";
  static const String TIMESTAMP_CATEGORY_ANALOG = "analog";
  static const String TIMESTAMP_CATEGORY_DDAY = "dday";
  static const String TIMESTAMP_CATEGORY_STYLISH = "stylish";
  static const String STYLE_TYPE_DAY_ROLLER = "day_roller";
  static const String LOCALE_KR = "KR";
  static const String LOCALE_EN = "EN";
  static const String LOCALE_KR_EN = "KR,EN";
  static const String LOCALE_ALL = "ALL";
  static const String ALIGN_CENTER = "center";
  static const String ALIGN_LEFT = "left";
  static const String ALIGN_RIGHT = "right";

  /// 샘플에서 사용자가 직접 입력하는 텍스트 자리표시자.
  static final String INPUT_TEXT = I18n.get(I18n.locale, "input_text");
}

class I18n {
  static String locale = LOCALE_KO_KR;
  static const String LOCALE_EN_US = "en";
  static const String LOCALE_KO_KR = "kr";

  static const Map<String, String> koKrMap = <String, String>{
    "input_text": "누르면 글을 작성할 수 있어요!",
    "today_dish_record": "#오늘의 식단기록",
    "style7_default_text1": "“별이 아름다운 이유는",
    "style7_default_text2": "보이지 않는 꽃이 있기 때문이다”",
    "am": "오전",
    "pm": "오후",
    "mon": "월",
    "tue": "화",
    "wed": "수",
    "thu": "목",
    "fri": "금",
    "sat": "토",
    "sun": "일",
    "monday": "월요일",
    "tuesday": "화요일",
    "wednesday": "수요일",
    "thursday": "목요일",
    "friday": "금요일",
    "saturday": "토요일",
    "sunday": "일요일",
    "year": "년",
    "month": "월",
    "day": "일",
    "hour": "시",
    "minute": "분",
    "second": "초",
    "today_brunch": "오늘의 브런치",
    "shrimp": "새우",
    "egg": "계란",
    "cherry_tomato": "방울토마토",
    "rucola": "루꼴라",
  };

  static String get(String locale, String key) => koKrMap[key] ?? '';
}

/// 샘플 RegexUtil 과 동일한 치환 로직.
class RegexUtil {
  static const String TYPE_DAY_TO_KR = "DAY_TO_KR";
  static const String TYPE_FULL_DAY_TO_KR = "FULL_DAY_TO_KR";
  static const String TYPE_AMPM_TO_KR = "AMPM_TO_KR";
  static const String TYPE_ALL_TO_CAPITAL = "ALL_TO_CAPITAL";
  static const String TYPE_ALL_TO_LOWERCASE = "ALL_TO_LOWERCASE";

  static String replace(String time, String? regexReplaceType) {
    if (regexReplaceType == null || regexReplaceType.isEmpty) {
      return applyI18n(time);
    }
    for (final replaceType in regexReplaceType.split(",")) {
      if (TYPE_ALL_TO_LOWERCASE == replaceType) {
        time = time.toLowerCase();
      }
      if (TYPE_ALL_TO_CAPITAL == replaceType) {
        time = time.toUpperCase();
      }
      if (TYPE_DAY_TO_KR == replaceType) {
        time = replaceDayToLocal(time);
      }
      if (TYPE_AMPM_TO_KR == replaceType) {
        time = replaceAmpmToLocal(time);
      }
      if (TYPE_FULL_DAY_TO_KR == replaceType) {
        time = replaceFullDayToLocal(time);
      }
    }
    return applyI18n(time);
  }

  static String applyI18n(String time) {
    return time
        .replaceAll("년", I18n.get(I18n.locale, "year"))
        .replaceAll("월", I18n.get(I18n.locale, "month"))
        .replaceAll("일", I18n.get(I18n.locale, "day"))
        .replaceAll("시", I18n.get(I18n.locale, "hour"))
        .replaceAll("분", I18n.get(I18n.locale, "minute"))
        .replaceAll("초", I18n.get(I18n.locale, "second"));
  }

  static String replaceAmpmToLocal(String time) {
    return time
        .replaceAll("AM", I18n.get(I18n.locale, "am"))
        .replaceAll("PM", I18n.get(I18n.locale, "pm"));
  }

  static String replaceDayToLocal(String time) {
    return time
        .replaceAll("Mon", I18n.get(I18n.locale, "mon"))
        .replaceAll("Tue", I18n.get(I18n.locale, "tue"))
        .replaceAll("Wed", I18n.get(I18n.locale, "wed"))
        .replaceAll("Thu", I18n.get(I18n.locale, "thu"))
        .replaceAll("Fri", I18n.get(I18n.locale, "fri"))
        .replaceAll("Sat", I18n.get(I18n.locale, "sat"))
        .replaceAll("Sun", I18n.get(I18n.locale, "sun"));
  }

  static String replaceFullDayToLocal(String time) {
    return time
        .replaceAll("Monday", I18n.get(I18n.locale, "monday"))
        .replaceAll("Tuesday", I18n.get(I18n.locale, "tuesday"))
        .replaceAll("Wednesday", I18n.get(I18n.locale, "wednesday"))
        .replaceAll("Thursday", I18n.get(I18n.locale, "thursday"))
        .replaceAll("Friday", I18n.get(I18n.locale, "friday"))
        .replaceAll("Saturday", I18n.get(I18n.locale, "saturday"))
        .replaceAll("Sunday", I18n.get(I18n.locale, "sunday"));
  }
}

