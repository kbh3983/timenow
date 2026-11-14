import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_localizations.dart';

/// 스탬프 안에서 사용자가 바꿀 수 있는 문구 한 칸
class StampTextField {
  /// 저장 키 (크기 접미사 _x0 등을 뗀 기준 키. 예: style2_txt1, f4_txt1)
  final String key;

  final String _label;
  final String _defaultText;
  final String? _hint;

  /// 편집 창에 보여줄 이름 (현재 설정된 언어로 반환)
  String get label {
    final l = AppStrings.stampFieldLabel(key);
    return l.isNotEmpty ? l : _label;
  }

  /// 기본 문구 (사용자가 비워두면 이 문구로 표시, 다국어 변환 대상 키는 현재 언어로 반환)
  String get defaultText {
    switch (key) {
      case 'f4_txt1':
      case 'style3_txt2':
      case 'style7_txt1':
      case 'style7_txt2':
      case 'style11_txt1':
        return AppStrings.stampI18nDefault(key);
      default:
        return _defaultText;
    }
  }

  /// 입력란 안내 문구 (현재 설정된 언어로 반환)
  String? get hint {
    if (key == 'style3_txt1') return AppStrings.style3Txt1AutoHint;
    return _hint;
  }

  /// 문구가 길어질 때 왼쪽 끝을 고정할지 여부 (기본은 가운데 기준으로 양쪽으로 늘어남)
  final bool anchorLeft;

  /// 문구가 길어질 때 오른쪽 끝을 고정할지 여부 (오른쪽에 붙은 날짜와 겹치지 않게 할 때 사용)
  final bool anchorRight;

  /// 사용자 문구의 최대 가로 폭 (390 디자인 좌표 기준, 지정하지 않으면 화면 폭 기준)
  final double? maxWidth;

  /// 기본값이 안내 문구인 경우, 편집 창을 열 때 입력란을 비워서 바로 입력할 수 있게 할지 여부
  final bool clearOnEditIfDefault;

  const StampTextField({
    required this.key,
    required String label,
    required String defaultText,
    String? hint,
    this.anchorLeft = false,
    this.anchorRight = false,
    this.maxWidth,
    this.clearOnEditIfDefault = false,
  })  : _label = label,
        _defaultText = defaultText,
        _hint = hint;
}

/// 스탬프 문구 사용자 설정 저장소 (앱 전체 공유, 기기에 저장)
class StampTextStore extends ChangeNotifier {
  static final StampTextStore _instance = StampTextStore._internal();
  factory StampTextStore() => _instance;
  StampTextStore._internal();

  static const String _prefsKey = 'timenow_stamp_custom_texts_v1';

  static final RegExp _scaleSuffix = RegExp(r'_x\d+$');

  /// 크기 단계 접미사(`_x0`, `_x1`, `_x2`)를 제거한 공통 저장 키
  static String canonicalKey(String id) => id.replaceFirst(_scaleSuffix, '');

  static const List<StampTextField> _f4 = [
    StampTextField(
      key: 'f4_txt1',
      label: '문구',
      defaultText: '누르면 글을 작성할 수 있어요!',
      clearOnEditIfDefault: true,
    ),
  ];

  static const List<StampTextField> _style1 = [
    StampTextField(key: 'style1_rtxt1', label: '문구', defaultText: 'Many a little makes a miracle'),
  ];

  static const List<StampTextField> _style2 = [
    StampTextField(key: 'style2_txt1', label: '문구', defaultText: 'On the table', maxWidth: 200),
  ];

  static const List<StampTextField> _style3Title = [
    StampTextField(
      key: 'style3_txt1',
      label: '문구',
      // 기본값은 시간대에 따라 자동(BREAKFAST/LUNCH/DINNER)이므로 고정 문구 없음
      defaultText: '',
      hint: '비워두면 시간대에 따라 BREAKFAST / LUNCH / DINNER 로 자동 표시돼요',
    ),
  ];
  static const List<StampTextField> _style3Tag = [
    StampTextField(key: 'style3_txt2', label: '문구', defaultText: '#오늘의 식단기록'),
  ];

  static const List<StampTextField> _style4Title = [
    StampTextField(key: 'style4_txt1', label: '첫째 줄', defaultText: 'Good', anchorLeft: true),
    StampTextField(key: 'style4_txt2', label: '둘째 줄', defaultText: 'Morning.', anchorLeft: true),
  ];
  static const List<StampTextField> _style4Footer = [
    StampTextField(
      key: 'style4_txt3',
      label: '문구',
      defaultText: 'Recorded in',
      anchorRight: true,
    ),
  ];

  static const List<StampTextField> _style5Arc = [
    StampTextField(
      key: 'style5_rtxt1',
      label: '문구',
      defaultText: '⦁ Life is full of possibilities ⦁',
    ),
  ];
  static const List<StampTextField> _style5Title = [
    StampTextField(
      key: 'style5_txt1',
      label: '문구',
      defaultText: 'Morning Vibes.',
    ),
  ];

  static const List<StampTextField> _style7Quote = [
    StampTextField(key: 'style7_txt1', label: '첫째 줄', defaultText: '“별이 아름다운 이유는'),
    StampTextField(key: 'style7_txt2', label: '둘째 줄', defaultText: '보이지 않는 꽃이 있기 때문이다”'),
  ];
  static const List<StampTextField> _style7Footer = [
    StampTextField(key: 'style7_txt3', label: '문구', defaultText: "Today's reading"),
  ];

  static const List<StampTextField> _style8Title = [
    StampTextField(
      key: 'style8_txt1',
      label: '첫째 줄',
      defaultText: 'Today',
      anchorLeft: true,
      maxWidth: 230,
    ),
    StampTextField(
      key: 'style8_txt2',
      label: '둘째 줄',
      defaultText: 'Activity.',
      anchorLeft: true,
      maxWidth: 230,
    ),
  ];
  static const List<StampTextField> _style8Arc = [
    StampTextField(
      key: 'style8_rtxt1',
      label: '문구',
      defaultText: "Today's activity record",
    ),
  ];

  static const List<StampTextField> _style11Title = [
    StampTextField(key: 'style11_txt1', label: '문구', defaultText: '오늘의 브런치', maxWidth: 230),
  ];

  /// 탭한 요소 키 → 함께 편집할 문구 목록
  static const Map<String, List<StampTextField>> _editableGroups = {
    'f4_txt1': _f4,
    'style1_rtxt1': _style1,
    'style2_txt1': _style2,
    'style3_txt1': _style3Title,
    'style3_txt2': _style3Tag,
    'style4_txt1': _style4Title,
    'style4_txt2': _style4Title,
    'style4_txt3': _style4Footer,
    'style5_rtxt1': _style5Arc,
    'style5_txt1': _style5Title,
    'style7_txt1': _style7Quote,
    'style7_txt2': _style7Quote,
    'style7_txt3': _style7Footer,
    'style8_txt1': _style8Title,
    'style8_txt2': _style8Title,
    'style8_rtxt1': _style8Arc,
    'style11_txt1': _style11Title,
  };

  /// 해당 요소를 탭했을 때 편집할 문구 목록 (편집 불가면 null)
  static List<StampTextField>? fieldsFor(String key) => _editableGroups[canonicalKey(key)];

  static bool isEditable(String key) => _editableGroups.containsKey(canonicalKey(key));

  /// 문구 키에 해당하는 필드 정의
  static StampTextField? fieldOf(String key) {
    final k = canonicalKey(key);
    for (final group in _editableGroups.values) {
      for (final f in group) {
        if (f.key == k) return f;
      }
    }
    return null;
  }

  final Map<String, String> _texts = {};
  SharedPreferences? _prefs;
  int _version = 0;

  /// 문구 변경 횟수 (캐시 무효화용)
  int get version => _version;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _texts
          ..clear()
          ..addAll(map.map((k, v) => MapEntry(k, v as String)));
      } catch (e) {
        debugPrint('StampTextStore: load error $e');
      }
    }
    _version++;
    notifyListeners();
  }

  /// 사용자가 바꾼 문구 (바꾸지 않았으면 null)
  String? customText(String key) => _texts[canonicalKey(key)];

  /// 여러 문구를 한 번에 저장. 빈 문자열이거나 기본 문구와 같으면 기본값으로 되돌립니다.
  Future<void> saveAll(Map<String, String> values) async {
    for (final entry in values.entries) {
      final k = canonicalKey(entry.key);
      final value = entry.value.trim();
      final def = fieldOf(k)?.defaultText;
      if (value.isEmpty || value == def) {
        _texts.remove(k);
      } else {
        _texts[k] = value;
      }
    }
    _version++;
    notifyListeners();
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_prefsKey, jsonEncode(_texts));
  }
}
