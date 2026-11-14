import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' hide TextDirection;

import 'sample_stamp_assets.dart';
import 'sample_stamp_compat.dart' as sc;
import 'sample_stamp_data.dart';
import 'sample_stamp_entities.dart';
import 'stamp_text_store.dart';
import '../services/app_localizations.dart';

/// 샘플 앱의 기준 화면 가로 폭 (baseDeviceWidth). 모든 좌표는 이 폭 기준 디자인 단위입니다.
const double kSampleBaseWidth = 390.0;

/// 샘플 Canvas(TYPE_TIMESTAMP) 는 텍스트를 Container(padding: 4) 안에 두므로
/// 텍스트가 사용할 수 있는 최대 폭은 (캔버스 폭 - 8) 입니다.
const double _kTimestampMaxTextWidth = kSampleBaseWidth - 8;

/// 이 앱에 이미 등록되어 있던 폰트 → 기존 패밀리명 매핑 (동일한 폰트 파일)
const Map<String, String> _legacyFontFamilies = {
  'rubber_nipple_factory': 'RubberNippleFactory',
  'nixie_one': 'NixieOne',
  'cafe24_one_pretty_night': 'Cafe24OnePrettyNight',
  'nanum_amsterdam': 'NanumAmsterdam',
  'nanum_barunpen': 'NanumBarunpen',
  'cafe24_simplehae': 'Cafe24Simplehae',
  'tvn_fun_story': 'TvnFunStory',
  'cafe24_shiningstar': 'Cafe24Shiningstar',
  'rondal': 'Rondal',
  'rondal_bold': 'RondalBold',
  'lobster': 'Lobster',
  'lee_seoyun': 'LeeSeoyun',
};

String _fontFamily(String sampleFamily) =>
    _legacyFontFamilies[sampleFamily] ?? sampleFamily;

/// 샘플 Canvas.buildFontWeight 와 동일
FontWeight _fontWeight(String? fontWeight) {
  switch (fontWeight) {
    case 'w100':
      return FontWeight.w100;
    case 'w400':
      return FontWeight.w400;
    case 'w500':
      return FontWeight.w500;
    case 'w600':
      return FontWeight.w600;
    case 'w900':
      return FontWeight.w900;
    default:
      return FontWeight.normal;
  }
}

// ───────────────────────── Library ─────────────────────────

class SampleStampLibrary {
  SampleStampLibrary._();

  /// 이미 손으로 구현되어 있던 13종 (기존 구현을 유지하므로 이 렌더러에서는 제외)
  static const Set<String> legacyGroupIds = {
    'n1_1', 'n1_2', 'n2_1', 'n2_2', 'n3_1', 'n3_2',
    's1_1', 's1_2', 's2_1', 's2_2', 's3_1', 's3_2', 'style1',
  };

  /// 위치 이동 시에도 가로 위치를 항상 화면 중앙에 고정하는 스탬프 그룹
  static const Set<String> horizontalCenterLockedGroups = {
    's1_4',
    's1_8',
    's1_10',
    's1_11',
    's1_12',
  };

  /// 기본 배율(1A~3A)에서 폰트·스탬프 크기가 과도하게 큰 그룹의 축소 비율
  static const Map<String, double> groupSizeScale = {
    's2_5': 0.78,
    's2_6': 0.76,
    's3_3': 0.75,
    's3_4': 0.75,
    's3_5': 0.75,
    's3_6': 0.75,
  };

  /// 원본 데이터는 단일 크기(groupScale 0)이나 앱에서 3단계(1A/2A/3A) 크기 조절을 지원하는 스타일 그룹
  static const Set<String> syntheticThreeStepGroups = {
    'style2',
    'style3',
    'style4',
    'style5',
    'style7',
    'style9',
  };

  static Map<String, TimestampGroupEntity>? _groups;
  static final Map<String, List<int>> _scaleCache = {};

  static Map<String, TimestampGroupEntity> get _groupMap {
    if (_groups != null) return _groups!;
    SampleStampRepository.ensureLoaded();
    final map = <String, TimestampGroupEntity>{};
    for (final g in SampleStampRepository.timestampGroupBox.values) {
      map[g.id] = g;
    }
    _groups = map;
    return map;
  }

  /// 이 렌더러가 담당하는 스탬프인지 여부 (D-day 카테고리는 제공하지 않음)
  static bool isSampleGroup(String id) =>
      !legacyGroupIds.contains(id) &&
      _groupMap.containsKey(id) &&
      _groupMap[id]!.category != sc.Constants.TIMESTAMP_CATEGORY_DDAY;

  static String? categoryOf(String id) => _groupMap[id]?.category;

  /// 프레임/스타일리시 스탬프는 사진 전체를 덮는 레이아웃이므로 사진 전체 캔버스에 그대로 그립니다.
  static bool isCanvasMode(String id) {
    final c = categoryOf(id);
    return c == sc.Constants.TIMESTAMP_CATEGORY_FRAME ||
        c == sc.Constants.TIMESTAMP_CATEGORY_STYLISH;
  }

  /// 샘플에서 같은 스탬프를 다시 탭할 때 순환하던 크기 단계(groupScale 0/1/2) 목록
  static List<int> scalesOf(String id) {
    final cached = _scaleCache[id];
    if (cached != null) return cached;
    if (syntheticThreeStepGroups.contains(id)) {
      const list = <int>[0, 1, 2];
      _scaleCache[id] = list;
      return list;
    }
    SampleStampRepository.ensureLoaded();
    final set = <int>{};
    for (final t in SampleStampRepository.timestampBox.values) {
      if (t.groupId == id) set.add(t.groupScale);
    }
    for (final i in SampleStampRepository.timestampImageBox.values) {
      if (i.groupId == id) set.add(i.groupScale);
    }
    for (final a in SampleStampRepository.analogTimestampBox.values) {
      if (a.groupId == id) set.add(a.groupScale);
    }
    for (final t in SampleStampRepository.textBox.values) {
      if (t.groupId == id) set.add(t.groupScale);
    }
    final list = set.toList()..sort();
    if (list.isEmpty) list.add(0);
    _scaleCache[id] = list;
    return list;
  }

  static int scaleCount(String id) => scalesOf(id).length;

  /// 샘플 Database.getEatTime 과 동일 (style3 의 BREAKFAST/LUNCH/DINNER 문구)
  static String eatTime(DateTime now) {
    String eatTime = "LUNCH";
    if (now.hour >= 5 && now.hour <= 10) eatTime = "BREAKFAST";
    if (now.hour > 10 && now.hour <= 15) eatTime = "LUNCH";
    if (now.hour >= 16 && now.hour <= 22) eatTime = "DINNER";
    return eatTime;
  }

  /// 스탬프 한 개의 장면(Scene)을 디자인 좌표로 구성합니다.
  ///
  /// [canvasHeight] 는 390 폭 기준으로 환산한 사진 높이입니다 (1:1 이면 390).
  static SampleStampScene buildScene(
    String groupId, {
    required int scaleIndex,
    required DateTime now,
    double canvasHeight = kSampleBaseWidth,
    Alignment alignment = Alignment.centerLeft,
  }) {
    SampleStampRepository.ensureLoaded();
    final scales = scalesOf(groupId);
    final clampedIndex = scaleIndex.clamp(0, scales.length - 1);
    final isSynthetic3Step = syntheticThreeStepGroups.contains(groupId);
    final scale = isSynthetic3Step ? 0 : scales[clampedIndex];
    final canvasMode = isCanvasMode(groupId);
    final extra = canvasMode ? (canvasHeight - kSampleBaseWidth) : 0.0;
    const syntheticStepScales = <double>[0.85, 1.0, 1.15];
    final sizeScale = isSynthetic3Step
        ? syntheticStepScales[clampedIndex]
        : (groupSizeScale[groupId] ?? 1.0);

    Rect scaleBox(double x, double y, double w, double h) {
      if (sizeScale == 1.0) return Rect.fromLTWH(x, y, w, h);
      double ax = kSampleBaseWidth / 2;
      double ay = kSampleBaseWidth / 2;
      switch (groupId) {
        case 'style2':
          if (y < 135) {
            ax = kSampleBaseWidth / 2;
            ay = 20.0;
          } else if (x < kSampleBaseWidth / 2) {
            ax = 10.0;
            ay = 385.0 + extra;
          } else {
            ax = 380.0;
            ay = 385.0 + extra;
          }
          break;
        case 'style3':
          if (y < kSampleBaseWidth * 2 / 3 + extra / 2) {
            ax = kSampleBaseWidth / 2;
            ay = 180.0 + extra / 2;
          } else {
            ax = kSampleBaseWidth / 2;
            ay = 370.0 + extra;
          }
          break;
        case 'style4':
          if (y <= kSampleBaseWidth * 2 / 3) {
            ax = 28.0;
            ay = 15.0;
          } else {
            ax = kSampleBaseWidth / 2;
            ay = 384.0 + extra;
          }
          break;
        case 'style5':
          ax = kSampleBaseWidth / 2;
          ay = 170.0 + extra / 2;
          break;
        case 'style7':
          if (y < 140) {
            ax = 10.0;
            ay = 5.0;
          } else if (y < kSampleBaseWidth * 2 / 3 + extra / 2) {
            ax = kSampleBaseWidth / 2;
            ay = 192.5 + extra / 2;
          } else {
            ax = kSampleBaseWidth / 2;
            ay = 385.0 + extra;
          }
          break;
        case 'style9':
          if (y < 135) {
            ax = kSampleBaseWidth / 2;
            ay = 63.0;
          } else {
            ax = kSampleBaseWidth / 2;
            ay = 195.0 + extra / 2;
          }
          break;
      }
      return Rect.fromLTWH(
        ax + (x - ax) * sizeScale,
        ay + (y - ay) * sizeScale,
        w * sizeScale,
        h * sizeScale,
      );
    }

    // 1:1 이 아닌 사진에서 프레임/스타일 레이아웃의 세로 위치 보정
    // (상단 영역은 위쪽 고정, 하단 영역은 아래쪽 고정, 가운데는 중앙 유지)
    double dyFor(double top, double height) {
      if (groupId == 'style8') {
        // style8 은 가로 전체를 쓰는 밴드(y: 10..120) 구조로,
        // 위(topCenter, y=-1) / 가운데(center, y=0) / 아래(bottomCenter, y=1) 세로 위치를 지원합니다.
        return math.max(0.0, canvasHeight - 130.0) * (alignment.y + 1.0) / 2.0;
      }
      if (extra == 0) return 0;
      if (groupId == 'style5') return extra / 2;
      if (groupId == 'style4') {
        // style4 는 비율(4:5, 9:16 등)을 바꿔도 상단 문구(Good Morning.)와 시간(hh:mm a)의 간격을 1:1과 동일하게 유지
        return top > kSampleBaseWidth * 2 / 3 ? extra : 0;
      }
      final cy = top + height / 2;
      if (cy < 135) return 0;
      if (cy > kSampleBaseWidth * 2 / 3) return extra;
      return extra / 2;
    }

    final ordered = <_OrderedElement>[];
    int seq = 0;
    void add(double z, _SampleElement? e) {
      if (e != null) ordered.add(_OrderedElement(z, seq++, e));
    }

    // CanvasFactory.build 와 동일한 순서로 수집 후 z 로 정렬
    for (final t in SampleStampRepository.timestampBox.values) {
      if (t.groupId != groupId || t.groupScale != scale) continue;
      final text = TimestampLocaleFormatter.formatSampleStampEntity(
        regex: t.regex,
        i18nTypes: t.regexReplaceType,
        dt: now,
        entityId: t.id,
        groupId: t.groupId,
      );
      add(t.z, _TextElement.timestamp(
        id: StampTextStore.canonicalKey(t.id),
        text: text,
        box: scaleBox(t.x, t.y + dyFor(t.y, t.height), t.width, t.height),
        align: t.align,
        family: t.fontFamily,
        fontSize: t.fontSize * sizeScale,
        fontHeight: t.fontHeight,
        weight: t.fontWeight,
        color: t.color,
        rotate: t.rotate,
      ));
    }
    for (final i in SampleStampRepository.timestampImageBox.values) {
      if (i.groupId != groupId || i.groupScale != scale) continue;
      final dy = dyFor(i.y, i.height);
      final stretch = canvasMode && extra != 0 && i.height >= 300;
      add(i.z, _ImageElement(
        id: StampTextStore.canonicalKey(i.id),
        path: i.path,
        box: scaleBox(
          i.x,
          i.y + (stretch ? 0 : dy),
          i.width,
          math.max(20.0, i.height + (stretch ? extra : 0)),
        ),
        originalHeight: i.height * sizeScale,
        flip: i.flip,
        rotate: i.rotate,
        color: i.color,
        stretch: stretch,
      ));
    }
    for (final a in SampleStampRepository.analogTimestampBox.values) {
      if (a.groupId != groupId || a.groupScale != scale) continue;
      add(a.z, _AnalogElement(
        box: Rect.fromLTWH(a.x, a.y + dyFor(a.y, a.height), a.width, a.height),
        backgroundPath: a.backgroundImagePath,
        hourPath: a.hourImagePath,
        minutePath: a.minuteImagePath,
        hhmm: DateFormat("hhmm", 'en_US').format(now),
        rotate: a.rotate,
      ));
    }
    // D-day 스탬프(DdayTimestampEntity)는 앱에서 제공하지 않으므로 렌더링하지 않습니다.
    final textStore = StampTextStore();
    for (final t in SampleStampRepository.textBox.values) {
      if (t.groupId != groupId || t.groupScale != scale) continue;
      final key = StampTextStore.canonicalKey(t.id);
      var text = t.text;
      var fontSize = t.fontSize;
      // CanvasFactory.build 의 style3_txt1 특수 처리와 동일
      if (t.id == "style3_txt1") {
        text = eatTime(now);
        fontSize = text == "BREAKFAST" ? t.fontSize - 10 : t.fontSize;
      }
      final editable = StampTextStore.isEditable(key);
      final custom = editable ? textStore.customText(key) : null;
      final field = StampTextStore.fieldOf(key);
      add(t.z, _TextElement.staticText(
        id: key,
        text: custom ?? text,
        defaultText: text,
        isCustom: custom != null,
        anchorLeft: field?.anchorLeft ?? false,
        anchorRight: field?.anchorRight ?? false,
        maxCustomWidth: field?.maxWidth,
        editKey: editable ? key : null,
        box: scaleBox(t.x, t.y + dyFor(t.y, t.height), t.width, t.height),
        family: t.fontFamily,
        fontSize: fontSize * sizeScale,
        weight: t.fontWeight,
        color: t.color,
        backgroundColor: t.backgroundColor,
        backgroundOpacity: t.backgroundOpacity,
        rotate: t.rotate,
      ));
    }
    for (final r in SampleStampRepository.roundTextBox.values) {
      if (r.groupId != groupId) continue;
      final key = StampTextStore.canonicalKey(r.id);
      final editable = StampTextStore.isEditable(key);
      final custom = editable ? textStore.customText(key) : null;
      add(r.z, _ArcTextElement(
        text: custom ?? r.text,
        defaultText: r.text,
        isCustom: custom != null,
        editKey: editable ? key : null,
        box: scaleBox(r.x, r.y + dyFor(r.y, r.height), r.width, r.height),
        family: r.fontFamily,
        fontSize: r.fontSize * sizeScale,
        color: r.color,
        radius: r.radius * sizeScale,
        rotate: r.rotate,
      ));
    }
    for (final s in SampleStampRepository.styleTimestampBox.values) {
      if (s.groupId != groupId) continue;
      if (s.type != sc.Constants.STYLE_TYPE_DAY_ROLLER) continue;
      add(s.z, _DayRollerElement(
        box: Rect.fromLTWH(s.x, s.y + dyFor(s.y, s.height), s.width, s.height),
        regex: s.regex,
        family: s.fontFamily,
        fontSize: s.fontSize,
        weight: s.fontWeight,
        now: now,
      ));
    }

    ordered.sort((a, b) {
      final c = a.z.compareTo(b.z);
      return c != 0 ? c : a.seq.compareTo(b.seq);
    });
    final elements = ordered.map((o) => o.element).toList();
    _applyRelationalLayout(groupId, elements, alignment: alignment);

    // 캔버스 모드에서도 단일 텍스트 요소가 캔버스 안전 폭을 넘으면 줄바꿈 대신 한 줄 축소
    if (canvasMode) {
      for (int i = 0; i < elements.length; i++) {
        final e = elements[i];
        if (e is _TextElement && e.painter.width > _kTimestampMaxTextWidth) {
          elements[i] = e.withMaxWidth(_kTimestampMaxTextWidth);
        }
      }
    }

    Rect? bounds;
    for (final e in elements) {
      bounds = bounds == null ? e.bounds : bounds.expandToInclude(e.bounds);
    }
    return SampleStampScene(
      elements: elements,
      contentBounds: bounds ?? Rect.zero,
      canvasMode: canvasMode,
      canvasHeight: canvasHeight,
      lockHorizontalCenter: horizontalCenterLockedGroups.contains(groupId),
    );
  }

  /// 날짜/요일/월 이름이나 사용자 편집 문구의 길이가 달라져도
  /// 나란히 놓인 요소들이 항상 가운데 정렬·균형 간격을 유지하도록 보정합니다.
  static void _applyRelationalLayout(
    String groupId,
    List<_SampleElement> elements, {
    Alignment alignment = Alignment.centerLeft,
  }) {
    int indexOfText(String id) =>
        elements.indexWhere((e) => e is _TextElement && e.id == id);
    int indexOfImage(String id) =>
        elements.indexWhere((e) => e is _ImageElement && e.id == id);

    switch (groupId) {
      case 'style4':
        // 1) 하단 "Recorded in <MMMM dd, yyyy>" (style4_txt3 + style4_t3):
        //    날짜(MMMM dd, yyyy)나 편집 문구(style4_txt3) 길이가 달라져도
        //    두 요소를 합친 전체 문장이 캔버스 가로 중앙(195.0)에 오도록 배치합니다.
        final iTxt3 = indexOfText('style4_txt3');
        final iT3 = indexOfText('style4_t3');
        if (iTxt3 != -1 && iT3 != -1) {
          var txt3 = elements[iTxt3] as _TextElement;
          final t3 = elements[iT3] as _TextElement;
          final rowTop = t3.box.top;
          final rowH = t3.box.height;
          final gap = txt3.painter.width > 0 && t3.painter.width > 0 ? 5.0 : 0.0;
          const maxRowW = kSampleBaseWidth - 20.0;
          if (txt3.painter.width + gap + t3.painter.width > maxRowW &&
              txt3.painter.width > 0) {
            final availTxtW = math.max(40.0, maxRowW - gap - t3.painter.width);
            txt3 = txt3.withMaxWidth(availTxtW);
          }
          final totalW = txt3.painter.width + gap + t3.painter.width;
          final startX = (kSampleBaseWidth - totalW) / 2;
          elements[iTxt3] = txt3.withOrigin(
            Offset(startX, rowTop + (rowH - txt3.painter.height) / 2),
          );
          elements[iT3] = t3.withOrigin(
            Offset(
              startX + txt3.painter.width + gap,
              rowTop + (rowH - t3.painter.height) / 2,
            ),
          );
        }
        // 2) 좌측 시간 "hh:mm" + "am/pm" (style4_t1 + style4_t2):
        //    숫자 폭에 관계없이 일정한 간격(5.0)으로 이어지게 배치합니다.
        final iT1 = indexOfText('style4_t1');
        final iT2 = indexOfText('style4_t2');
        if (iT1 != -1 && iT2 != -1) {
          final t1 = elements[iT1] as _TextElement;
          final t2 = elements[iT2] as _TextElement;
          elements[iT2] = t2.withOrigin(
            Offset(t1.origin.dx + t1.painter.width + 5.0, t2.origin.dy),
          );
        }
        break;

      case 'style10':
        // "AM/PM" (style10_t3) 이 중앙의 "hh:mm" (style10_t4) 왼쪽에
        // 숫자 폭과 무관하게 일정한 간격(6.0)으로 놓이도록 배치합니다.
        final iT3 = indexOfText('style10_t3');
        final iT4 = indexOfText('style10_t4');
        if (iT3 != -1 && iT4 != -1) {
          final t3 = elements[iT3] as _TextElement;
          final t4 = elements[iT4] as _TextElement;
          elements[iT3] = t3.withOrigin(
            Offset(t4.origin.dx - t3.painter.width - 6.0, t3.origin.dy),
          );
        }
        break;

      case 'n1_16':
      case 'n1_17':
      case 'n2_6':
      case 'n2_8':
      case 'n2_9':
      case 'n3_5':
        // 위치 이동 시 왼쪽(및 기본) 위치에서는 왼쪽 정렬, 오른쪽(alignment.x > 0.2) 위치에서는 오른쪽 정렬
        final textIndices = <int>[];
        double minLeft = double.infinity;
        double maxW = 0.0;
        for (int i = 0; i < elements.length; i++) {
          final e = elements[i];
          if (e is _TextElement) {
            textIndices.add(i);
            minLeft = math.min(minLeft, e.origin.dx);
            maxW = math.max(maxW, e.painter.width);
          }
        }
        if (textIndices.length >= 2 && minLeft.isFinite) {
          final alignRight = alignment.x > 0.2;
          for (final idx in textIndices) {
            final t = elements[idx] as _TextElement;
            final newX = alignRight
                ? (minLeft + maxW - t.painter.width)
                : minLeft;
            elements[idx] = t.withOrigin(Offset(newX, t.origin.dy));
          }
        }
        break;

      case 's1_10':
        // "hh:mm a, MMMM dd, yyyy" (s1_10_t1) 양옆의 꽃 장식(s1_10_i1, s1_10_i2)이
        // 월 이름(May ~ September) 길이에 맞춰 대칭 간격(8.0)으로 감싸도록 배치합니다.
        final iT1 = indexOfText('s1_10_t1');
        final iI1 = indexOfImage('s1_10_i1');
        final iI2 = indexOfImage('s1_10_i2');
        if (iT1 != -1 && iI1 != -1 && iI2 != -1) {
          final t1 = elements[iT1] as _TextElement;
          final img1 = elements[iI1] as _ImageElement;
          final img2 = elements[iI2] as _ImageElement;
          const gap = 8.0;
          elements[iI1] = img1.withHorizontalLeft(
            t1.origin.dx - gap - img1.dst.width,
          );
          elements[iI2] = img2.withHorizontalLeft(
            t1.origin.dx + t1.painter.width + gap,
          );
        }
        break;

      case 's1_8':
        // 밑줄 이미지(s1_8_i1)는 항상 가로 중앙(195.0)에 고정하고,
        // 글자(s1_8_t1)는 위치에 따라 밑줄 기준 좌, 가운데, 우로 정렬합니다.
        final iT1 = indexOfText('s1_8_t1');
        final iI1 = indexOfImage('s1_8_i1');
        if (iT1 != -1 && iI1 != -1) {
          var t1 = elements[iT1] as _TextElement;
          final img1 = elements[iI1] as _ImageElement;
          final centeredImg = img1.withHorizontalLeft(
            (kSampleBaseWidth - img1.dst.width) / 2,
          );
          elements[iI1] = centeredImg;
          if (t1.painter.width > centeredImg.dst.width) {
            t1 = t1.withMaxWidth(centeredImg.dst.width);
          }
          final double textX;
          if (alignment.x < -0.2) {
            // 좌측 정렬: 밑줄 좌측 시작점에 맞춤
            textX = centeredImg.dst.left;
          } else if (alignment.x > 0.2) {
            // 우측 정렬: 밑줄 우측 끝점에 맞춤
            textX = centeredImg.dst.right - t1.painter.width;
          } else {
            // 가운데 정렬: 밑줄 정중앙에 배치
            textX = centeredImg.dst.left +
                (centeredImg.dst.width - t1.painter.width) / 2;
          }
          elements[iT1] = t1.withOrigin(Offset(textX, t1.origin.dy));
        }
        break;

      case 'style1':
        // 요일(style1_t1) 양옆의 월(style1_t2)과 일(style1_t3)이
        // 요일 길이에 맞춰 대칭 간격(10.0)으로 놓이도록 배치합니다.
        final iT1 = indexOfText('style1_t1');
        final iT2 = indexOfText('style1_t2');
        final iT3 = indexOfText('style1_t3');
        if (iT1 != -1 && iT2 != -1 && iT3 != -1) {
          final t1 = elements[iT1] as _TextElement;
          final t2 = elements[iT2] as _TextElement;
          final t3 = elements[iT3] as _TextElement;
          const gap = 10.0;
          elements[iT2] = t2.withOrigin(
            Offset(t1.origin.dx - gap - t2.painter.width, t2.origin.dy),
          );
          elements[iT3] = t3.withOrigin(
            Offset(t1.origin.dx + t1.painter.width + gap, t3.origin.dy),
          );
        }
        break;
    }
  }
}

class _OrderedElement {
  final double z;
  final int seq;
  final _SampleElement element;
  _OrderedElement(this.z, this.seq, this.element);
}

// ───────────────────────── Scene ─────────────────────────

class SampleStampScene {
  // ignore: library_private_types_in_public_api
  final List<_SampleElement> elements;

  /// 실제로 그려지는 내용의 외곽 (디자인 좌표)
  final Rect contentBounds;

  /// 사진 전체 캔버스 모드 (프레임/스타일리시)
  final bool canvasMode;

  /// 390 폭 기준 캔버스 높이
  final double canvasHeight;

  /// 위치 이동 시에도 전체 스탬프의 가로 위치를 중앙에 고정할지 여부 (예: s1_8 밑줄)
  final bool lockHorizontalCenter;

  SampleStampScene({
    required this.elements,
    required this.contentBounds,
    required this.canvasMode,
    required this.canvasHeight,
    this.lockHorizontalCenter = false,
  });

  Set<String> get imagePaths {
    final set = <String>{};
    for (final e in elements) {
      set.addAll(e.imagePaths);
    }
    return set;
  }

  /// 디자인 좌표 → [area] 좌표 변환: area.topLeft + (p + offset) * scale
  ({double scale, Offset offset}) _transformFor(
    Rect area, {
    required Alignment alignment,
    required double marginDesign,
  }) {
    final s = area.width / kSampleBaseWidth;
    if (canvasMode) return (scale: s, offset: Offset.zero);
    final designH = area.height / s;
    final b = contentBounds;
    final availW = kSampleBaseWidth - marginDesign * 2;
    final availH = designH - marginDesign * 2;
    // 배율(1A/2A/3A)이나 긴 월/요일 이름 등으로 인해 스탬프 외곽이 가용 안전 영역(availW/availH)을
    // 초과할 경우, 다음 줄로 넘기거나 잘라내지 않고 스탬프 전체 비율을 유지하며 안전 영역 안에 자동 축소
    final fitW = (b.width > availW && b.width > 0 && availW > 0)
        ? (availW / b.width)
        : 1.0;
    final fitH = (b.height > availH && b.height > 0 && availH > 0)
        ? (availH / b.height)
        : 1.0;
    final fit = math.min(fitW, fitH);
    final scaledW = b.width * fit;
    final scaledH = b.height * fit;
    final alignX = lockHorizontalCenter ? 0.0 : alignment.x;
    final left = marginDesign + (availW - scaledW) * (alignX + 1) / 2;
    final top = marginDesign + (availH - scaledH) * (alignment.y + 1) / 2;
    return (
      scale: s * fit,
      offset: Offset(left / fit - b.left, top / fit - b.top),
    );
  }

  /// [size] 영역(사진/오버레이)에 장면을 그립니다.
  ///
  /// - 캔버스 모드: 390 폭 디자인 캔버스를 사진 폭에 맞춰 그대로 그림
  /// - 일반 모드: 내용 외곽을 [alignment] 위치(여백 [marginDesign])에 배치
  void paintInto(
    Canvas canvas,
    Rect area,
    Map<String, ui.Image> images, {
    required Alignment alignment,
    required double marginDesign,
  }) {
    if (elements.isEmpty || area.width <= 0) return;
    final t = _transformFor(area, alignment: alignment, marginDesign: marginDesign);
    canvas.save();
    canvas.translate(area.left, area.top);
    canvas.scale(t.scale);
    canvas.translate(t.offset.dx, t.offset.dy);
    for (final e in elements) {
      e.paint(canvas, images);
    }
    canvas.restore();
  }

  /// 탭해서 문구를 바꿀 수 있는 요소들의 영역 ([area] 좌표)
  List<({String key, Rect rect})> editableRegions(
    Rect area, {
    required Alignment alignment,
    required double marginDesign,
  }) {
    if (elements.isEmpty || area.width <= 0) return const [];
    final t = _transformFor(area, alignment: alignment, marginDesign: marginDesign);
    final result = <({String key, Rect rect})>[];
    for (final e in elements) {
      final key = e is _TextElement
          ? e.editKey
          : (e is _ArcTextElement ? e.editKey : null);
      if (key != null) {
        final b = e.bounds.shift(t.offset);
        result.add((
          key: key,
          rect: Rect.fromLTRB(
            area.left + b.left * t.scale,
            area.top + b.top * t.scale,
            area.left + b.right * t.scale,
            area.top + b.bottom * t.scale,
          ),
        ));
      }
    }
    return result;
  }

  /// 썸네일: 내용(캔버스 모드는 캔버스 전체)을 [area] 안에 비율 유지로 맞춰 그림
  void paintFitted(Canvas canvas, Rect area, Map<String, ui.Image> images) {
    if (elements.isEmpty) return;
    final src = canvasMode
        ? Rect.fromLTWH(0, 0, kSampleBaseWidth, canvasHeight)
        : contentBounds;
    if (src.width <= 0 || src.height <= 0) return;
    final s = math.min(area.width / src.width, area.height / src.height);
    canvas.save();
    canvas.translate(
      area.left + (area.width - src.width * s) / 2,
      area.top + (area.height - src.height * s) / 2,
    );
    canvas.scale(s);
    canvas.translate(-src.left, -src.top);
    for (final e in elements) {
      e.paint(canvas, images);
    }
    canvas.restore();
  }
}

// ───────────────────────── Elements ─────────────────────────

abstract class _SampleElement {
  Rect get bounds;
  Iterable<String> get imagePaths => const [];
  void paint(Canvas canvas, Map<String, ui.Image> images);
}

Rect _rotatedBounds(Rect r, double angle, Offset pivot) {
  if (angle == 0) return r;
  final cosA = math.cos(angle);
  final sinA = math.sin(angle);
  Offset rot(Offset p) {
    final dx = p.dx - pivot.dx;
    final dy = p.dy - pivot.dy;
    return Offset(pivot.dx + dx * cosA - dy * sinA, pivot.dy + dx * sinA + dy * cosA);
  }

  final pts = [rot(r.topLeft), rot(r.topRight), rot(r.bottomLeft), rot(r.bottomRight)];
  double minX = pts.first.dx, maxX = pts.first.dx, minY = pts.first.dy, maxY = pts.first.dy;
  for (final p in pts) {
    minX = math.min(minX, p.dx);
    maxX = math.max(maxX, p.dx);
    minY = math.min(minY, p.dy);
    maxY = math.max(maxY, p.dy);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

void _withRotation(Canvas canvas, double angle, Offset pivot, VoidCallback draw) {
  if (angle == 0) {
    draw();
    return;
  }
  canvas.save();
  canvas.translate(pivot.dx, pivot.dy);
  canvas.rotate(angle);
  canvas.translate(-pivot.dx, -pivot.dy);
  draw();
  canvas.restore();
}

/// 샘플 Canvas 의 TYPE_TIMESTAMP / TYPE_TEXT 를 재현
class _TextElement extends _SampleElement {
  final String id;
  final TextPainter painter;
  final Offset origin;
  final Rect box;
  final double rotate;
  final Color? background;

  /// 배경(둥근 사각형)이 그려지는 영역
  final Rect? backgroundRect;

  /// 사용자가 탭해서 문구를 바꿀 수 있는 요소의 키 (StampTextStore 키)
  final String? editKey;

  _TextElement._({
    required this.id,
    required this.painter,
    required this.origin,
    required this.box,
    required this.rotate,
    this.background,
    this.backgroundRect,
    this.editKey,
  });

  _TextElement withOrigin(Offset newOrigin) {
    final dx = newOrigin.dx - origin.dx;
    final dy = newOrigin.dy - origin.dy;
    return _TextElement._(
      id: id,
      painter: painter,
      origin: newOrigin,
      box: box.shift(Offset(dx, dy)),
      rotate: rotate,
      background: background,
      backgroundRect: backgroundRect?.shift(Offset(dx, dy)),
      editKey: editKey,
    );
  }

  _TextElement withMaxWidth(double maxWidth) {
    if (painter.width <= maxWidth || maxWidth <= 0) return this;
    final span = painter.text as TextSpan;
    final style = span.style ?? const TextStyle();
    final curSize = style.fontSize ?? 16.0;
    final shrunkSize = curSize * maxWidth / painter.width;
    final newTp = TextPainter(
      text: TextSpan(
        text: span.text,
        style: style.copyWith(fontSize: shrunkSize),
      ),
      textAlign: painter.textAlign,
      textDirection: TextDirection.ltr,
    )..layout();
    final newOrigin = Offset(
      origin.dx + (painter.width - newTp.width) / 2,
      origin.dy + (painter.height - newTp.height) / 2,
    );
    return _TextElement._(
      id: id,
      painter: newTp,
      origin: newOrigin,
      box: box,
      rotate: rotate,
      background: background,
      backgroundRect: backgroundRect,
      editKey: editKey,
    );
  }

  static TextPainter _layout(
    String text, {
    required String family,
    required double fontSize,
    double height = 1.0,
    String? weight,
    required int color,
    TextAlign align = TextAlign.start,
    double maxWidth = double.infinity,
  }) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Color(color),
          fontSize: fontSize,
          fontFamily: AppLocalizations.resolveFontFamily(
            _fontFamily(family),
            text,
          ),
          fontFamilyFallback: AppLocalizations.fontFallbackChain,
          height: height,
          fontWeight: _fontWeight(weight),
        ),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
  }

  /// SizedOverflowBox(size: box) + alignTo(align) + 세로 중앙 정렬
  static double _alignedX(Rect box, String align, double textWidth) {
    if (align == sc.Constants.ALIGN_LEFT) return box.left;
    if (align == sc.Constants.ALIGN_RIGHT) return box.right - textWidth;
    return box.left + (box.width - textWidth) / 2;
  }

  factory _TextElement.timestamp({
    required String id,
    required String text,
    required Rect box,
    required String align,
    required String family,
    required double fontSize,
    required double fontHeight,
    required String? weight,
    required int color,
    required double rotate,
  }) {
    // 배율(1A/2A/3A)이나 긴 월/요일 이름(예: n1_11 3A + November/September)에서도
    // 절대 다음 줄로 줄바꿈되지 않도록 무제한 가로폭(한 줄)으로 레이아웃합니다.
    // (전체 스탬프 폭이 화면 안전 여백을 넘으면 SampleStampScene._transformFor 에서 비율 유지 축소)
    final tp = _layout(
      text,
      family: family,
      fontSize: fontSize,
      height: fontHeight,
      weight: weight,
      color: color,
    );
    final origin = Offset(
      _alignedX(box, align, tp.width),
      box.top + (box.height - tp.height) / 2,
    );
    return _TextElement._(id: id, painter: tp, origin: origin, box: box, rotate: rotate);
  }

  /// TYPE_TEXT: SizedBox(box) 안에서 padding(top: 2), 가운데 정렬, 박스 폭에서 줄바꿈.
  ///
  /// 사용자가 문구를 바꾼 경우([isCustom])에는 원래 문구의 위치(가운데, 왼쪽 끝, 오른쪽 끝)를 기준으로
  /// 사진 밖으로 나가지 않도록 폭에 맞춰 글자 크기를 줄여 한 줄로 그립니다.
  factory _TextElement.staticText({
    required String id,
    required String text,
    required String defaultText,
    required bool isCustom,
    required bool anchorLeft,
    required bool anchorRight,
    required double? maxCustomWidth,
    required String? editKey,
    required Rect box,
    required String family,
    required double fontSize,
    required String? weight,
    required int color,
    required int backgroundColor,
    required double backgroundOpacity,
    required double rotate,
  }) {
    Color? bg;
    final bgColor = Color(backgroundColor);
    if (backgroundOpacity > 0 && bgColor.a > 0) {
      bg = bgColor.withValues(alpha: bgColor.a * backgroundOpacity);
    }

    if (!isCustom) {
      final tp = _layout(
        text,
        family: family,
        fontSize: fontSize,
        weight: weight,
        color: color,
        align: TextAlign.center,
        maxWidth: box.width,
      );
      final origin = Offset(
        box.left + (box.width - tp.width) / 2,
        box.top + 2 + (box.height - 2 - tp.height) / 2,
      );
      return _TextElement._(
        id: id,
        painter: tp,
        origin: origin,
        box: box,
        rotate: rotate,
        background: bg,
        backgroundRect: bg != null ? box : null,
        editKey: editKey,
      );
    }

    // 원래 문구의 배치 (기준점과 배경 여백 계산용)
    final defTp = _layout(
      defaultText,
      family: family,
      fontSize: fontSize,
      weight: weight,
      color: color,
      align: TextAlign.center,
      maxWidth: box.width,
    );
    final defLeft = box.left + (box.width - defTp.width) / 2;
    final defRight = defLeft + defTp.width;
    const edge = 10.0;
    double maxW;
    if (anchorLeft) {
      maxW = kSampleBaseWidth - edge - defLeft;
    } else if (anchorRight) {
      maxW = defRight - edge;
    } else {
      maxW = 2 * math.min(box.center.dx, kSampleBaseWidth - box.center.dx) - edge * 2;
    }
    if (maxCustomWidth != null) {
      maxW = math.min(maxW, maxCustomWidth);
    }
    final bgPad = bg != null ? math.max(0.0, box.width - defTp.width) : 0.0;
    final textMax = math.max(1.0, maxW - bgPad);

    var tp = _layout(text,
        family: family, fontSize: fontSize, weight: weight, color: color, align: TextAlign.center);
    if (tp.width > textMax) {
      final shrunk = fontSize * textMax / tp.width;
      tp = _layout(
        text,
        family: family,
        fontSize: shrunk,
        weight: weight,
        color: color,
        align: TextAlign.center,
      );
    }
    final double x;
    if (anchorLeft) {
      x = defLeft;
    } else if (anchorRight) {
      x = defRight - tp.width;
    } else {
      x = box.center.dx - tp.width / 2;
    }
    final origin = Offset(x, box.top + 2 + (box.height - 2 - tp.height) / 2);
    final bgRect = bg != null
        ? Rect.fromCenter(
            center: Offset(x + tp.width / 2, box.center.dy),
            width: tp.width + bgPad,
            height: math.max(box.height, tp.height + 4),
          )
        : null;
    return _TextElement._(
      id: id,
      painter: tp,
      origin: origin,
      box: box,
      rotate: rotate,
      background: bg,
      backgroundRect: bgRect,
      editKey: editKey,
    );
  }

  @override
  Rect get bounds {
    final textRect = origin & painter.size;
    final r = backgroundRect != null ? textRect.expandToInclude(backgroundRect!) : textRect;
    return _rotatedBounds(r, rotate, box.center);
  }

  @override
  void paint(Canvas canvas, Map<String, ui.Image> images) {
    _withRotation(canvas, rotate, box.center, () {
      if (background != null && backgroundRect != null) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(backgroundRect!, const Radius.circular(10)),
          Paint()..color = background!,
        );
      }
      painter.paint(canvas, origin);
    });
  }
}

/// 샘플 Image.asset(width, height) 기본 동작(BoxFit.scaleDown, 가운데 정렬) 재현
Rect _scaleDownRect(String path, Rect box) {
  final native = sampleStampImageSizes[path];
  if (native == null || native.width <= 0 || native.height <= 0) return box;
  final s = math.min(1.0, math.min(box.width / native.width, box.height / native.height));
  final w = native.width * s;
  final h = native.height * s;
  return Rect.fromLTWH(box.left + (box.width - w) / 2, box.top + (box.height - h) / 2, w, h);
}

final Paint _imagePaint = Paint()
  ..filterQuality = FilterQuality.high
  ..isAntiAlias = true;

void _drawImage(Canvas canvas, ui.Image? image, Rect dst, {int color = 0xFFFFFFFF}) {
  if (image == null) return;
  final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  Paint paint = _imagePaint;
  if (color != 0xFFFFFFFF) {
    paint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true
      ..colorFilter = ColorFilter.mode(Color(color), BlendMode.modulate);
  }
  canvas.drawImageRect(image, src, dst, paint);
}

class _ImageElement extends _SampleElement {
  final String id;
  final String path;
  final Rect box;
  final double originalHeight;
  final bool flip;
  final double rotate;
  final int color;

  /// 1:1 이 아닌 사진에서 프레임을 세로로 늘려야 하는 경우 (상/하단 1/3 은 비율 유지, 가운데만 늘림)
  final bool stretch;
  late final Rect dst;

  _ImageElement({
    required this.id,
    required this.path,
    required this.box,
    required this.originalHeight,
    required this.flip,
    required this.rotate,
    required this.color,
    required this.stretch,
  }) {
    if (stretch) {
      final fitted = _scaleDownRect(path, Rect.fromLTWH(box.left, box.top, box.width, originalHeight));
      final extra = box.height - originalHeight;
      dst = Rect.fromLTWH(fitted.left, fitted.top, fitted.width, math.max(10.0, fitted.height + extra));
    } else {
      dst = _scaleDownRect(path, box);
    }
  }

  _ImageElement withHorizontalLeft(double newDstLeft) {
    final dx = newDstLeft - dst.left;
    return _ImageElement(
      id: id,
      path: path,
      box: box.shift(Offset(dx, 0)),
      originalHeight: originalHeight,
      flip: flip,
      rotate: rotate,
      color: color,
      stretch: stretch,
    );
  }

  @override
  Iterable<String> get imagePaths => [path];

  @override
  Rect get bounds => _rotatedBounds(dst, rotate, box.center);

  @override
  void paint(Canvas canvas, Map<String, ui.Image> images) {
    if (path == 'assets/timestamp/image/frame/frame_6.png') {
      _withRotation(canvas, rotate, box.center, () {
        _drawSmoothOvalFrame(canvas, dst, color: color);
      });
      return;
    }
    final image = images[path];
    if (image == null) return;
    _withRotation(canvas, rotate, box.center, () {
      if (flip) {
        canvas.save();
        canvas.translate(dst.center.dx, 0);
        canvas.scale(-1, 1);
        canvas.translate(-dst.center.dx, 0);
      }
      if (stretch) {
        _drawThreeSlice(canvas, image, dst);
      } else {
        _drawImage(canvas, image, dst, color: color);
      }
      if (flip) canvas.restore();
    });
  }

  /// f6(원형/타원 프레임)은 4:5, 9:16 비율에서 3분할 늘림 시 곡률이 꺾이지 않도록
  /// 일정한 선 두께의 매끄러운 벡터 원/타원으로 그립니다.
  void _drawSmoothOvalFrame(Canvas canvas, Rect dst, {int color = 0xFFFFFFFF}) {
    final strokeWidth = dst.width * (7.0 / 1000.0);
    final inset = dst.width * (5.5 / 1000.0);
    final ovalRect = dst.deflate(inset);
    final paint = Paint()
      ..color = Color(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawOval(ovalRect, paint);
  }

  /// 상단/하단 1/3 은 가로 기준 배율로 그대로, 가운데 1/3 만 세로로 늘려서 그림
  void _drawThreeSlice(Canvas canvas, ui.Image image, Rect dst) {
    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    final f = dst.width / iw;
    final band = ih / 3;
    final topH = math.min(band * f, dst.height / 2);
    final bottomH = math.min(band * f, dst.height / 2);
    final midH = math.max(0.0, dst.height - topH - bottomH);
    final p = _imagePaint;
    canvas.drawImageRect(image, Rect.fromLTWH(0, 0, iw, band),
        Rect.fromLTWH(dst.left, dst.top, dst.width, topH), p);
    canvas.drawImageRect(image, Rect.fromLTWH(0, band, iw, band),
        Rect.fromLTWH(dst.left, dst.top + topH, dst.width, midH), p);
    canvas.drawImageRect(image, Rect.fromLTWH(0, ih - band, iw, band),
        Rect.fromLTWH(dst.left, dst.bottom - bottomH, dst.width, bottomH), p);
  }
}

/// 샘플 Canvas.drawAnalog 재현 (배경 + 시침 + 분침)
class _AnalogElement extends _SampleElement {
  final Rect box;
  final String backgroundPath;
  final String hourPath;
  final String minutePath;
  final String hhmm;
  final double rotate;

  _AnalogElement({
    required this.box,
    required this.backgroundPath,
    required this.hourPath,
    required this.minutePath,
    required this.hhmm,
    required this.rotate,
  });

  double get _hourAngle {
    final hour = int.parse(hhmm.substring(0, 2));
    final minute = int.parse(hhmm.substring(2));
    return (math.pi / 6) * hour + (math.pi / 360) * minute;
  }

  double get _minuteAngle => (math.pi / 30) * int.parse(hhmm.substring(2));

  @override
  Iterable<String> get imagePaths => [backgroundPath, hourPath, minutePath];

  @override
  Rect get bounds => _rotatedBounds(box, rotate, box.center);

  @override
  void paint(Canvas canvas, Map<String, ui.Image> images) {
    _withRotation(canvas, rotate, box.center, () {
      _drawImage(canvas, images[backgroundPath], _scaleDownRect(backgroundPath, box));
      _withRotation(canvas, _hourAngle, box.center, () {
        _drawImage(canvas, images[hourPath], _scaleDownRect(hourPath, box));
      });
      _withRotation(canvas, _minuteAngle, box.center, () {
        _drawImage(canvas, images[minutePath], _scaleDownRect(minutePath, box));
      });
    });
  }
}

/// 샘플 TYPE_ROUND_TEXT (flutter_arc_text ArcText: startAngle 0, center 정렬,
/// Placement.outside, 시계방향) 재현. 원의 중심은 박스 중심에서 radius 만큼 아래.
class _ArcTextElement extends _SampleElement {
  final Rect box;
  final double radius;
  final double rotate;
  final String? editKey;
  final List<TextPainter> letters = [];
  final List<double> angles = [];

  _ArcTextElement({
    required String text,
    String? defaultText,
    bool isCustom = false,
    this.editKey,
    required this.box,
    required String family,
    required double fontSize,
    required int color,
    required this.radius,
    required this.rotate,
  }) {
    void buildLetters(double size) {
      letters.clear();
      angles.clear();
      final style = TextStyle(
        height: 1.0,
        fontFamily: AppLocalizations.resolveFontFamily(
          _fontFamily(family),
          text,
        ),
        fontFamilyFallback: AppLocalizations.fontFallbackChain,
        color: Color(color),
        fontSize: size,
      );
      for (final ch in text.runes) {
        final tp = TextPainter(
          text: TextSpan(text: String.fromCharCode(ch), style: style),
          textDirection: TextDirection.ltr,
        )..layout();
        letters.add(tp);
        final ratio = (tp.width / (2 * radius)).clamp(-1.0, 1.0);
        angles.add(2 * math.asin(ratio));
      }
    }

    buildLetters(fontSize);
    if (isCustom) {
      // 원호를 따라 너무 길게 늘어나 화면 밖으로 나가거나 겹치지 않도록 최대 각도 제한
      final maxAngle = radius < 100 ? math.pi : 1.45;
      final total = _totalAngle;
      if (total > maxAngle && total > 0) {
        buildLetters(math.max(fontSize * 0.4, fontSize * maxAngle / total));
      }
    }
  }

  Offset get _center => Offset(box.center.dx, box.center.dy + radius);

  double get _totalAngle => angles.fold(0.0, (a, b) => a + b);

  @override
  Rect get bounds {
    Rect? r;
    double angle = -_totalAngle / 2;
    final c = _center;
    for (var i = 0; i < letters.length; i++) {
      final tp = letters[i];
      angle += angles[i] / 2;
      final letterRect = Rect.fromLTWH(
          c.dx - tp.width / 2, c.dy - radius - tp.height, tp.width, tp.height);
      final rb = _rotatedBounds(letterRect, angle, c);
      r = r == null ? rb : r.expandToInclude(rb);
      angle += angles[i] / 2;
    }
    return _rotatedBounds(r ?? box, rotate, box.center);
  }

  @override
  void paint(Canvas canvas, Map<String, ui.Image> images) {
    _withRotation(canvas, rotate, box.center, () {
      final c = _center;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-_totalAngle / 2);
      for (var i = 0; i < letters.length; i++) {
        final tp = letters[i];
        canvas.rotate(angles[i] / 2);
        tp.paint(canvas, Offset(-tp.width / 2, -radius - tp.height));
        canvas.rotate(angles[i] / 2);
      }
      canvas.restore();
    });
  }
}

/// 샘플 buildTimesampStyle(day_roller) 재현: 그제/어제/[오늘]/내일/모레 를 Wrap(spacing 30) 으로 배치
class _DayRollerElement extends _SampleElement {
  final Rect box;
  final List<TextPainter> painters = [];
  late final Rect pillRect;
  late final List<Offset> origins;
  late final Rect contentRect;

  static const double _spacing = 30;
  static const double _pillPadH = 10;
  static const double _pillPadV = 8;

  _DayRollerElement({
    required this.box,
    required String regex,
    required String family,
    required double fontSize,
    required String? weight,
    required DateTime now,
  }) {
    final fmt = DateFormat(regex, 'en_US');
    final days = [
      now.subtract(const Duration(days: 2)),
      now.subtract(const Duration(days: 1)),
      now,
      now.add(const Duration(days: 1)),
      now.add(const Duration(days: 2)),
    ];
    for (var i = 0; i < days.length; i++) {
      painters.add(TextPainter(
        text: TextSpan(
          text: fmt.format(days[i]),
          style: TextStyle(
            fontWeight: _fontWeight(weight),
            height: 1.0,
            fontFamily: AppLocalizations.resolveFontFamily(
              _fontFamily(family),
              fmt.format(days[i]),
            ),
            fontFamilyFallback: AppLocalizations.fontFallbackChain,
            color: i == 2 ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
            fontSize: fontSize,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout());
    }
    final widths = <double>[];
    final heights = <double>[];
    for (var i = 0; i < painters.length; i++) {
      final tp = painters[i];
      if (i == 2) {
        widths.add(tp.width + _pillPadH * 2);
        heights.add(tp.height + _pillPadV * 2);
      } else {
        widths.add(tp.width);
        heights.add(tp.height);
      }
    }
    final totalW = widths.fold(0.0, (a, b) => a + b) + _spacing * (widths.length - 1);
    final rowH = heights.fold<double>(0.0, (a, b) => math.max(a, b));
    final left = box.left + (box.width - totalW) / 2;
    final top = box.top + (box.height - rowH) / 2;
    contentRect = Rect.fromLTWH(left, top, totalW, rowH);

    final list = <Offset>[];
    double x = left;
    for (var i = 0; i < painters.length; i++) {
      final itemTop = top + (rowH - heights[i]) / 2;
      if (i == 2) {
        pillRect = Rect.fromLTWH(x, itemTop, widths[i], heights[i]);
        list.add(Offset(x + _pillPadH, itemTop + _pillPadV));
      } else {
        list.add(Offset(x, itemTop));
      }
      x += widths[i] + _spacing;
    }
    origins = list;
  }

  @override
  Rect get bounds => contentRect;

  @override
  void paint(Canvas canvas, Map<String, ui.Image> images) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(300)),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    for (var i = 0; i < painters.length; i++) {
      painters[i].paint(canvas, origins[i]);
    }
  }
}

// ───────────────────────── Image cache ─────────────────────────

class SampleStampImageCache {
  SampleStampImageCache._();

  static final Map<String, ui.Image> _images = {};
  static final Map<String, Future<ui.Image?>> _pending = {};

  static Map<String, ui.Image> get images => _images;

  static bool hasAll(Iterable<String> paths) => paths.every(_images.containsKey);

  static Future<ui.Image?> load(String path) {
    final cached = _images[path];
    if (cached != null) return Future.value(cached);
    return _pending.putIfAbsent(path, () async {
      try {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _images[path] = frame.image;
        return frame.image;
      } catch (e) {
        debugPrint('SampleStampImageCache: failed to load $path: $e');
        return null;
      } finally {
        _pending.remove(path);
      }
    });
  }

  static Future<void> loadAll(Iterable<String> paths) async {
    await Future.wait(paths.map(load));
  }
}

// ───────────────────────── Widgets ─────────────────────────

/// 카메라 프리뷰/사진 리뷰 위에 올라가는 샘플 스탬프 오버레이 (사진 저장 시 그대로 캡처됨)
class SampleStampOverlay extends StatefulWidget {
  final String groupId;
  final int scaleIndex;
  final DateTime now;
  final Alignment alignment;

  /// 일반 스탬프의 가장자리 여백 (논리 픽셀). 기존 스탬프의 _wrapAlign margin(16)과 동일.
  final double margin;

  /// 문구를 바꿀 수 있는 요소를 탭했을 때 호출 (null 이면 탭 영역 없음)
  final void Function(String editKey)? onEditText;

  const SampleStampOverlay({
    super.key,
    required this.groupId,
    required this.scaleIndex,
    required this.now,
    required this.alignment,
    this.margin = 16,
    this.onEditText,
  });

  @override
  State<SampleStampOverlay> createState() => _SampleStampOverlayState();
}

class _SampleStampOverlayState extends State<SampleStampOverlay> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StampTextStore(),
      builder: (context, _) => LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (!w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
          return const SizedBox.shrink();
        }
        final s = w / kSampleBaseWidth;
        final scene = SampleStampLibrary.buildScene(
          widget.groupId,
          scaleIndex: widget.scaleIndex,
          now: widget.now,
          canvasHeight: h / s,
          alignment: widget.alignment,
        );
        _ensureImages(scene.imagePaths);
        final marginDesign = widget.margin / s;
        final paint = CustomPaint(
          size: Size(w, h),
          painter: _SampleScenePainter(
            scene: scene,
            alignment: widget.alignment,
            marginDesign: marginDesign,
            fitted: false,
          ),
        );
        final onEdit = widget.onEditText;
        if (onEdit == null) return paint;
        final regions = scene.editableRegions(
          Offset.zero & Size(w, h),
          alignment: widget.alignment,
          marginDesign: marginDesign,
        );
        if (regions.isEmpty) return paint;
        return Stack(
          children: [
            Positioned.fill(child: IgnorePointer(child: paint)),
            for (final r in regions)
              Positioned.fromRect(
                rect: r.rect.inflate(8),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onEdit(r.key),
                ),
              ),
          ],
        );
      }),
    );
  }

  void _ensureImages(Set<String> paths) {
    if (paths.isEmpty || SampleStampImageCache.hasAll(paths)) return;
    SampleStampImageCache.loadAll(paths).then((_) {
      if (mounted) setState(() {});
    });
  }
}

/// 스탬프 목록/피커용 썸네일 (대표 고정 시각으로 렌더링하여 스크롤 시 부하 제거)
class SampleStampThumbnail extends StatefulWidget {
  final String groupId;
  final EdgeInsets padding;
  final DateTime? time;

  const SampleStampThumbnail({
    super.key,
    required this.groupId,
    this.padding = const EdgeInsets.all(6),
    this.time,
  });

  @override
  State<SampleStampThumbnail> createState() => _SampleStampThumbnailState();
}

class _SampleStampThumbnailState extends State<SampleStampThumbnail> {
  late final DateTime _entryMinuteTime = _toMinute(DateTime.now());

  static DateTime _toMinute(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);

  SampleStampScene? _cachedScene;
  int? _cachedScaleIndex;
  DateTime? _cachedTime;
  String? _cachedLang;

  @override
  Widget build(BuildContext context) {
    final count = SampleStampLibrary.scaleCount(widget.groupId);
    final scaleIndex = count >= 3 ? 1 : 0;
    final targetTime = widget.time != null
        ? _toMinute(widget.time!)
        : _entryMinuteTime;
    final currentLang = AppLocalizations.languageCode;

    if (_cachedScene == null ||
        _cachedScaleIndex != scaleIndex ||
        _cachedTime != targetTime ||
        _cachedLang != currentLang) {
      _cachedScaleIndex = scaleIndex;
      _cachedTime = targetTime;
      _cachedLang = currentLang;
      _cachedScene = SampleStampLibrary.buildScene(
        widget.groupId,
        scaleIndex: scaleIndex,
        now: targetTime,
      );
    }
    final scene = _cachedScene!;
    final paths = scene.imagePaths;
    if (paths.isNotEmpty && !SampleStampImageCache.hasAll(paths)) {
      SampleStampImageCache.loadAll(paths).then((_) {
        if (mounted) setState(() {});
      });
    }
    return RepaintBoundary(
      child: Padding(
        padding: widget.padding,
        child: CustomPaint(
          size: Size.infinite,
          painter: _SampleScenePainter(
            scene: scene,
            alignment: Alignment.center,
            marginDesign: 0,
            fitted: true,
          ),
        ),
      ),
    );
  }
}

class _SampleScenePainter extends CustomPainter {
  final SampleStampScene scene;
  final Alignment alignment;
  final double marginDesign;
  final bool fitted;

  _SampleScenePainter({
    required this.scene,
    required this.alignment,
    required this.marginDesign,
    required this.fitted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    if (fitted) {
      scene.paintFitted(canvas, area, SampleStampImageCache.images);
    } else {
      scene.paintInto(canvas, area, SampleStampImageCache.images,
          alignment: alignment, marginDesign: marginDesign);
    }
  }

  @override
  bool shouldRepaint(covariant _SampleScenePainter oldDelegate) {
    return scene != oldDelegate.scene ||
        alignment != oldDelegate.alignment ||
        marginDesign != oldDelegate.marginDesign ||
        fitted != oldDelegate.fitted;
  }
}

/// 영상 오버레이(PNG) 렌더링용: 이미지 로딩 후 [area] 에 그립니다.
///
/// [logicalScale] 은 (캔버스 픽셀 / 화면 논리 픽셀) 비율로, 여백(16 논리 px)을 동일하게 맞추는 데 사용합니다.
Future<void> paintSampleStampForVideo(
  Canvas canvas, {
  required String groupId,
  required int scaleIndex,
  required DateTime now,
  required Alignment alignment,
  required Rect area,
  required double logicalScale,
  double marginLogical = 16,
}) async {
  final s = area.width / kSampleBaseWidth;
  final scene = SampleStampLibrary.buildScene(
    groupId,
    scaleIndex: scaleIndex,
    now: now,
    canvasHeight: area.height / s,
    alignment: alignment,
  );
  await SampleStampImageCache.loadAll(scene.imagePaths);
  scene.paintInto(
    canvas,
    area,
    SampleStampImageCache.images,
    alignment: alignment,
    marginDesign: marginLogical * logicalScale / s,
  );
}
