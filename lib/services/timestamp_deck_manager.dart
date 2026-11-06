import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../timestamp_overlays.dart';

class TimestampDeckManager extends ChangeNotifier {
  static final TimestampDeckManager _instance =
      TimestampDeckManager._internal();
  factory TimestampDeckManager() => _instance;
  TimestampDeckManager._internal();

  static const int maxDeckSize = 8;
  static const int maxMainScreenCount = 8;
  static const String _storageKey = 'timestamp_deck_slots_v1';

  SharedPreferences? _prefs;

  /// 8개의 고정 슬롯 (비어있으면 null)
  final List<TimestampDesign?> _deckSlots =
      List<TimestampDesign?>.filled(maxDeckSize, null);

  List<TimestampDesign?> get deckSlots => List.unmodifiable(_deckSlots);

  /// 덱에 등록된 유효한 스탬프 개수
  int get filledCount => _deckSlots.where((d) => d != null).length;

  /// 초기화 및 로컬 저장소 로드
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final rawJson = _prefs?.getString(_storageKey);
    if (rawJson != null) {
      try {
        final List<dynamic> list = jsonDecode(rawJson);
        for (int i = 0; i < maxDeckSize; i++) {
          if (i < list.length && list[i] != null) {
            final name = list[i] as String;
            _deckSlots[i] = _findDesignByName(name);
          } else {
            _deckSlots[i] = null;
          }
        }
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('TimestampDeckManager: Error loading deck: $e');
      }
    }

    // 기본 초기 8개 세팅 (앱 첫 실행 시)
    _applyDefaultDeck();
  }

  /// 앱 최초 실행 시 기본 8개 세팅: n1_1부터 순서대로 8개 (none 제외)
  void _applyDefaultDeck() {
    final defaults = [
      TimestampDesign.n1_1,
      TimestampDesign.n1_2,
      TimestampDesign.n2_1,
      TimestampDesign.n2_2,
      TimestampDesign.n3_1,
      TimestampDesign.n3_2,
      TimestampDesign.s1_1,
      TimestampDesign.s1_2,
    ];

    for (int i = 0; i < maxDeckSize; i++) {
      if (i < defaults.length) {
        _deckSlots[i] = defaults[i];
      } else {
        _deckSlots[i] = null;
      }
    }
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    if (_prefs == null) return;
    final list = _deckSlots.map((d) => d?.name).toList();
    await _prefs!.setString(_storageKey, jsonEncode(list));
  }

  TimestampDesign? _findDesignByName(String name) {
    if (name == TimestampDesign.none.name) return null;
    try {
      return TimestampDesign.values.firstWhere(
        (d) => d.name == name && d != TimestampDesign.none,
      );
    } catch (_) {
      return null;
    }
  }

  /// 해당 스탬프가 덱에 포함되어 있는지 확인
  bool isInDeck(TimestampDesign design) {
    return _deckSlots.contains(design);
  }

  /// 해당 스탬프가 위치한 덱 슬롯 번호 (0~7, 없으면 -1)
  int getDeckSlotIndex(TimestampDesign design) {
    return _deckSlots.indexOf(design);
  }

  /// 비어있는 가장 첫 번째 슬롯 인덱스 반환 (없으면 -1)
  int getFirstEmptySlotIndex() {
    return _deckSlots.indexOf(null);
  }

  /// 덱의 특정 슬롯 비우기 (덱에서 제거)
  bool removeFromSlot(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= maxDeckSize) return false;
    if (_deckSlots[slotIndex] == null) return false;

    _deckSlots[slotIndex] = null;
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  /// 특정 디자인을 덱에서 제거
  bool removeDesign(TimestampDesign design) {
    final idx = _deckSlots.indexOf(design);
    if (idx != -1) {
      return removeFromSlot(idx);
    }
    return false;
  }

  /// 사용 가능한 전체 스탬프 리스트 (none 제외)
  static List<TimestampDesign> get availableDesigns => TimestampDesign.values
      .where((d) => d != TimestampDesign.none)
      .toList();

  /// 덱에 추가 (맨 앞의 빈 슬롯부터 채워짐)
  /// 이미 등록되어 있거나 빈 슬롯이 없으면 false 반환
  bool addToDeck(TimestampDesign design) {
    if (design == TimestampDesign.none) return false;
    if (isInDeck(design)) return false;

    final emptyIndex = getFirstEmptySlotIndex();
    if (emptyIndex == -1) return false; // 8개 꽉 참

    _deckSlots[emptyIndex] = design;
    _saveToPrefs();
    notifyListeners();
    return true;
  }

  /// 덱 토글 (이미 있으면 제거, 없으면 빈자리에 추가)
  /// 반환값: 추가되었으면 true, 제거되었으면 false, 덱이 꽉 차서 실패했으면 null
  bool? toggleDeck(TimestampDesign design) {
    if (design == TimestampDesign.none) return false;
    if (isInDeck(design)) {
      removeDesign(design);
      return false;
    } else {
      final success = addToDeck(design);
      if (!success) return null; // 꽉 참
      return true;
    }
  }

  /// 특정 슬롯에 직접 지정 (기존 슬롯 교체 또는 이동)
  void setSlot(int slotIndex, TimestampDesign? design) {
    if (slotIndex < 0 || slotIndex >= maxDeckSize) return;

    if (design == TimestampDesign.none) {
      design = null;
    }

    // 만약 이미 다른 슬롯에 같은 디자인이 있다면 그 슬롯은 비움
    if (design != null) {
      final existing = _deckSlots.indexOf(design);
      if (existing != -1 && existing != slotIndex) {
        _deckSlots[existing] = null;
      }
    }

    _deckSlots[slotIndex] = design;
    _saveToPrefs();
    notifyListeners();
  }

  /// 덱 순서 교환
  void swapSlots(int fromIndex, int toIndex) {
    if (fromIndex < 0 ||
        fromIndex >= maxDeckSize ||
        toIndex < 0 ||
        toIndex >= maxDeckSize) {
      return;
    }
    final temp = _deckSlots[fromIndex];
    _deckSlots[fromIndex] = _deckSlots[toIndex];
    _deckSlots[toIndex] = temp;
    _saveToPrefs();
    notifyListeners();
  }

  /// 기본 덱으로 초기화
  void resetToDefault() {
    _applyDefaultDeck();
  }

  /// 메인 화면(카메라/사진리뷰)에 노출될 타임스탬프 리스트 계산 (최대 8개, none 제외)
  /// 1. Deck에 등록된 스탬프들 (null 및 none 제외, 순서대로 최대 8개)
  /// 2. 빈 슬롯이 있으면 전체 스탬프 중 Deck에 없는 스탬프들을 순서대로 가져와 총 8개를 채움
  List<TimestampDesign> getMainScreenDesigns() {
    final List<TimestampDesign> result = [];

    // 1. Deck에 등록된 스탬프들을 순서대로 추가
    for (final design in _deckSlots) {
      if (design != null &&
          design != TimestampDesign.none &&
          !result.contains(design)) {
        result.add(design);
        if (result.length >= maxMainScreenCount) {
          return result;
        }
      }
    }

    // 2. Deck에 포함되지 않은 나머지 스탬프들 추가 (none 제외)
    for (final design in availableDesigns) {
      if (result.length >= maxMainScreenCount) {
        break;
      }
      if (!result.contains(design)) {
        result.add(design);
      }
    }

    return result;
  }
}
