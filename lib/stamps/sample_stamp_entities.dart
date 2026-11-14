// 샘플 앱(timestamp_sample/now)의 Hive 엔티티를 동일한 생성자 시그니처로 재현한 클래스들입니다.
// sample_stamp_data.dart 가 원본 TimestampRepository 의 데이터 정의 코드를
// 수정 없이 그대로 사용할 수 있도록, 생성자 인자 순서와 기본값을 원본과 100% 동일하게 유지합니다.
//
// 좌표계: 가로 390 기준(baseDeviceWidth) 디자인 단위. ratio 는 항상 1.0 으로 생성하고,
// 실제 화면/영상 크기에 맞춘 스케일은 렌더러에서 적용합니다.

const int _white = 0xFFFFFFFF;

class TimestampGroupEntity {
  final String id;
  final String category;
  final String thumbnailPath;
  final Object? thumbnail;
  final int? thumbnailColor;
  final int exposureOrder;

  TimestampGroupEntity(this.id, this.category, this.thumbnailPath,
      this.thumbnail, this.thumbnailColor, this.exposureOrder);
}

class TimestampEntity {
  late String id;
  late String groupId;
  late double x;
  late double y;
  late double z;
  late double centerX;
  late double centerY;
  late double width;
  late double height;
  late double scale;
  late double opacity;
  late double rotate;
  late bool flip;
  late String fontFamily;
  late String regex;
  late double fontSize;
  late double fontHeight;
  late int color;
  late String align;
  late double strokeWidth;
  late int strokeColor;
  late double shadowWidth;
  late int shadowColor;
  late String fontLocale;
  String? regexReplaceType;
  String? fontWeight;
  late int groupScale;

  void _common(double ratio) {
    x = x * ratio;
    y = y * ratio;
    fontSize = fontSize * ratio;
    width = width * ratio;
    height = height * ratio;
    z = 100;
    centerX = x + (width / 2);
    centerY = y + (height / 2);
    scale = 1;
    opacity = 1;
    flip = false;
    fontHeight = 1;
    strokeWidth = 0;
    strokeColor = 0;
    shadowWidth = 0;
    shadowColor = 0;
  }

  TimestampEntity.init(double ratio, this.id, this.groupId, this.fontFamily,
      this.regex, this.align, this.fontLocale, this.x, this.y, this.width,
      this.height, this.fontSize, this.regexReplaceType, this.groupScale) {
    _common(ratio);
    rotate = 0;
    color = _white;
  }

  TimestampEntity.initWithRotate(
      double ratio,
      this.id,
      this.groupId,
      this.fontFamily,
      this.regex,
      this.align,
      this.fontLocale,
      this.x,
      this.y,
      this.width,
      this.height,
      this.fontSize,
      this.regexReplaceType,
      this.rotate,
      this.groupScale) {
    _common(ratio);
    color = _white;
  }

  TimestampEntity.initWithFontWeight(
      double ratio,
      this.id,
      this.groupId,
      this.fontFamily,
      this.regex,
      this.align,
      this.fontLocale,
      this.x,
      this.y,
      this.width,
      this.height,
      this.fontSize,
      this.regexReplaceType,
      this.fontWeight,
      this.groupScale) {
    _common(ratio);
    rotate = 0;
    color = _white;
  }

  TimestampEntity.initWithColor(
      double ratio,
      this.id,
      this.groupId,
      this.fontFamily,
      this.regex,
      this.align,
      this.fontLocale,
      this.x,
      this.y,
      this.width,
      this.height,
      this.fontSize,
      this.regexReplaceType,
      this.fontWeight,
      this.color,
      this.groupScale) {
    _common(ratio);
    rotate = 0;
  }

  TimestampEntity.initWithRotateColor(
      double ratio,
      this.id,
      this.groupId,
      this.fontFamily,
      this.regex,
      this.align,
      this.fontLocale,
      this.x,
      this.y,
      this.width,
      this.height,
      this.fontSize,
      this.regexReplaceType,
      this.rotate,
      this.color,
      this.groupScale) {
    _common(ratio);
  }
}

class StyleTimestampEntity {
  late String id;
  late String groupId;
  late String type;
  late double x;
  late double y;
  late double z;
  late double centerX;
  late double centerY;
  late double width;
  late double height;
  late double scale;
  late double opacity;
  late double rotate;
  late bool flip;
  late String fontFamily;
  late String regex;
  late double fontSize;
  late double fontHeight;
  late int color;
  late String align;
  late double strokeWidth;
  late int strokeColor;
  late double shadowWidth;
  late int shadowColor;
  late String fontLocale;
  String? regexReplaceType;
  String? fontWeight;
  late int groupScale;

  StyleTimestampEntity.init(
      double ratio,
      this.id,
      this.groupId,
      this.type,
      this.fontFamily,
      this.regex,
      this.align,
      this.fontLocale,
      this.x,
      this.y,
      this.width,
      this.height,
      this.fontSize,
      this.regexReplaceType,
      this.fontWeight,
      this.groupScale) {
    x = x * ratio;
    y = y * ratio;
    fontSize = fontSize * ratio;
    width = width * ratio;
    height = height * ratio;
    z = 100;
    centerX = x + (width / 2);
    centerY = y + (height / 2);
    scale = 1;
    opacity = 1;
    rotate = 0;
    flip = false;
    color = _white;
    fontHeight = 1;
    strokeWidth = 0;
    strokeColor = 0;
    shadowWidth = 0;
    shadowColor = 0;
  }
}

class ImageEntity {
  late String id;
  late String groupId;
  late String category;
  late String path;
  late double x;
  late double y;
  late double z;
  late double centerX;
  late double centerY;
  late double width;
  late double height;
  late double scale;
  late double opacity;
  late double rotate;
  late bool flip;
  late int color;
  int? thumbnailColor;
  late int exposureOrder;
  late int groupScale;

  void _common(double ratio) {
    x = x * ratio;
    y = y * ratio;
    z = 50;
    width = width * ratio;
    height = height * ratio;
    centerX = x + (width / 2);
    centerY = y + (height / 2);
    scale = 1;
    opacity = 1;
    thumbnailColor = _white;
  }

  ImageEntity.init(double ratio, this.id, this.groupId, this.category,
      this.path, this.x, this.y, this.width, this.height, this.exposureOrder,
      this.groupScale) {
    _common(ratio);
    rotate = 0;
    flip = false;
    color = _white;
  }

  ImageEntity.initWithFlip(
      double ratio,
      this.id,
      this.groupId,
      this.category,
      this.path,
      this.x,
      this.y,
      this.width,
      this.height,
      this.exposureOrder,
      this.flip,
      this.groupScale) {
    _common(ratio);
    rotate = 0;
    color = _white;
  }

  ImageEntity.initWithRotateColor(
      double ratio,
      this.id,
      this.groupId,
      this.category,
      this.path,
      this.x,
      this.y,
      this.width,
      this.height,
      this.exposureOrder,
      this.rotate,
      this.color,
      this.groupScale) {
    _common(ratio);
    flip = false;
  }
}

class TextEntity {
  late String id;
  late String groupId;
  late double x;
  late double y;
  late double z;
  late double centerX;
  late double centerY;
  late double width;
  late double height;
  late double scale;
  late double opacity;
  late double rotate;
  late String fontFamily;
  late String text;
  double fontSize = 32;
  late int color;
  late int backgroundColor;
  late double backgroundOpacity;
  late double strokeWidth;
  late int strokeColor;
  late double shadowWidth;
  late int shadowColor;
  late int groupScale;
  late bool madeBySystem;
  String? fontWeight;

  void _common(double ratio) {
    x = x * ratio;
    y = y * ratio;
    z = 100;
    fontSize = fontSize * ratio;
    width = width * ratio;
    height = height * ratio;
    centerX = x + (width / 2);
    centerY = y + (height / 2);
    scale = 1;
    opacity = 1;
    rotate = 0;
    strokeWidth = 0;
    shadowWidth = 0;
    shadowColor = 0;
    madeBySystem = true;
  }

  TextEntity.init(double ratio, this.id, this.groupId, this.fontFamily,
      this.text, this.color, this.x, this.y, this.width, this.height,
      this.fontSize, this.groupScale) {
    _common(ratio);
    backgroundOpacity = 0;
    backgroundColor = 0;
    strokeColor = 0;
  }

  TextEntity.initWithBackgroundColor(
      double ratio,
      this.id,
      this.groupId,
      this.fontFamily,
      this.text,
      this.color,
      this.x,
      this.y,
      this.width,
      this.height,
      this.fontSize,
      this.groupScale,
      this.fontWeight,
      this.backgroundColor) {
    _common(ratio);
    backgroundOpacity = 1;
    strokeColor = 0;
  }

  TextEntity.initWithFontWeight(
      double ratio,
      this.id,
      this.groupId,
      this.fontFamily,
      this.text,
      this.color,
      this.x,
      this.y,
      this.width,
      this.height,
      this.fontSize,
      this.groupScale,
      this.fontWeight) {
    _common(ratio);
    backgroundOpacity = 0;
    backgroundColor = 0;
    strokeColor = 0;
  }
}

class RoundTextEntity {
  late String id;
  late String groupId;
  late double x;
  late double y;
  late double z;
  late double centerX;
  late double centerY;
  late double width;
  late double height;
  late double scale;
  late double opacity;
  late double rotate;
  late String fontFamily;
  late String text;
  double fontSize = 32;
  late int color;
  late int backgroundColor;
  late double backgroundOpacity;
  late double strokeWidth;
  late int strokeColor;
  late double shadowWidth;
  late int shadowColor;
  late double radius;
  late bool madeBySystem;
  late int groupScale;

  void _common(double ratio) {
    x = x * ratio;
    y = y * ratio;
    z = 100;
    fontSize = fontSize * ratio;
    width = width * ratio;
    height = height * ratio;
    centerX = x + (width / 2);
    centerY = y + (height / 2);
    scale = 1;
    opacity = 1;
    backgroundOpacity = 0;
    backgroundColor = 0;
    strokeWidth = 0;
    strokeColor = 0;
    shadowWidth = 0;
    shadowColor = 0;
    madeBySystem = true;
  }

  RoundTextEntity.init(double ratio, this.id, this.groupId, this.fontFamily,
      this.text, this.color, this.x, this.y, this.width, this.height,
      this.fontSize, this.radius, this.groupScale) {
    _common(ratio);
    rotate = 0;
  }

  RoundTextEntity.initWithRotate(
      double ratio,
      this.id,
      this.groupId,
      this.fontFamily,
      this.text,
      this.color,
      this.x,
      this.y,
      this.width,
      this.height,
      this.fontSize,
      this.radius,
      this.rotate,
      this.groupScale) {
    _common(ratio);
  }
}

class AnalogTimestampEntity {
  late String id;
  late String groupId;
  late String hourImagePath;
  late String minuteImagePath;
  late String backgroundImagePath;
  late double x;
  late double y;
  late double z;
  late double centerX;
  late double centerY;
  late double width;
  late double height;
  late double scale;
  late double opacity;
  late double rotate;
  late int color;
  late int groupScale;

  AnalogTimestampEntity.init(
      double ratio,
      this.id,
      this.groupId,
      this.hourImagePath,
      this.minuteImagePath,
      this.backgroundImagePath,
      this.x,
      this.y,
      this.width,
      this.height,
      this.groupScale) {
    x = x * ratio;
    y = y * ratio;
    z = 100;
    width = width * ratio;
    height = height * ratio;
    centerX = x + (width / 2);
    centerY = y + (height / 2);
    scale = 1;
    opacity = 1;
    rotate = 0;
    color = _white;
  }
}

class DdayTimestampEntity {
  late String id;
  late String groupId;
  late String fontFamily;
  late double fontSize;
  late double x;
  late double y;
  late double z;
  late double centerX;
  late double centerY;
  late double width;
  late double height;
  late double scale;
  late double opacity;
  late double rotate;
  late int color;
  late int backgroundColor;
  late double backgroundOpacity;
  late double strokeWidth;
  late int strokeColor;
  late double shadowWidth;
  late int shadowColor;
  late String align;
  late String fontLocale;

  DdayTimestampEntity.init(double ratio, this.id, this.groupId,
      this.fontFamily, this.align, this.x, this.y, this.width, this.height,
      this.fontSize) {
    x = x * ratio;
    y = y * ratio;
    z = 100;
    fontSize = fontSize * ratio;
    width = width * ratio;
    height = height * ratio;
    centerX = x + (width / 2);
    centerY = y + (height / 2);
    scale = 1;
    opacity = 1;
    rotate = 0;
    color = _white;
    backgroundColor = 0;
    backgroundOpacity = 0;
    strokeWidth = 0;
    strokeColor = 0;
    shadowWidth = 0;
    shadowColor = 0;
    fontLocale = "ALL";
  }
}

/// 샘플의 Hive Box 를 대신하는 메모리 저장소. put/delete 의미를 그대로 유지합니다.
class SampleBox<T> {
  final Map<String, T> _map = <String, T>{};

  void put(String key, T value) => _map[key] = value;

  void delete(String key) => _map.remove(key);

  void clear() => _map.clear();

  Iterable<T> get values => _map.values;
}

