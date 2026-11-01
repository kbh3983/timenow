import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../timestamp_overlays.dart';

class TimestampAccessManager extends ChangeNotifier {
  static final TimestampAccessManager _instance =
      TimestampAccessManager._internal();
  factory TimestampAccessManager() => _instance;
  TimestampAccessManager._internal();

  SharedPreferences? _prefs;

  /// 기본 무료로 제공되는 4가지 타임스탬프 디자인 (+ none 없음)
  static const Set<TimestampDesign> freeDesigns = {
    TimestampDesign.none,
    TimestampDesign.n1_1,
    TimestampDesign.n1_2,
    TimestampDesign.n2_1,
    TimestampDesign.n2_2,
  };

  /// 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  /// 해당 디자인이 현재 사용 가능한지 여부
  bool isUnlocked(TimestampDesign design) {
    // 1. 기본 무료 디자인은 항상 사용 가능
    if (freeDesigns.contains(design)) {
      return true;
    }

    if (_prefs == null) return false;

    // 2. 보상 광고로 해금된 만료 시간 확인
    final key = _getStorageKey(design);
    final expireMillis = _prefs!.getInt(key);
    if (expireMillis == null) return false;

    final expireDate = DateTime.fromMillisecondsSinceEpoch(expireMillis);
    return DateTime.now().isBefore(expireDate);
  }

  /// 보상 광고 시청 후 3일간 해금 (기존 남아있는 시간이 있다면 누적 연장)
  Future<void> unlockForDays(TimestampDesign design, {int days = 3}) async {
    _prefs ??= await SharedPreferences.getInstance();

    final key = _getStorageKey(design);
    final now = DateTime.now();

    DateTime newExpiry;
    final currentExpireMillis = _prefs!.getInt(key);
    if (currentExpireMillis != null) {
      final currentExpireDate =
          DateTime.fromMillisecondsSinceEpoch(currentExpireMillis);
      if (now.isBefore(currentExpireDate)) {
        // 기존 만료 시간이 남아있다면 그 시점으로부터 추가
        newExpiry = currentExpireDate.add(Duration(days: days));
      } else {
        newExpiry = now.add(Duration(days: days));
      }
    } else {
      newExpiry = now.add(Duration(days: days));
    }

    await _prefs!.setInt(key, newExpiry.millisecondsSinceEpoch);
    notifyListeners();
  }

  /// 잔여 기간 반환 (만료되었거나 무료인 경우 null)
  Duration? getRemainingDuration(TimestampDesign design) {
    if (freeDesigns.contains(design) || _prefs == null) return null;

    final key = _getStorageKey(design);
    final expireMillis = _prefs!.getInt(key);
    if (expireMillis == null) return null;

    final expireDate = DateTime.fromMillisecondsSinceEpoch(expireMillis);
    final diff = expireDate.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }

  /// 뱃지에 표시할 잔여 시간 텍스트 (예: 'D-3', 'D-1', '5h')
  String? getRemainingBadgeText(TimestampDesign design) {
    final remaining = getRemainingDuration(design);
    if (remaining == null) return null;

    final days = remaining.inDays;
    if (days >= 1) {
      return 'D-${days + 1}';
    } else {
      final hours = remaining.inHours;
      if (hours >= 1) {
        return '${hours}h';
      } else {
        return '${remaining.inMinutes}m';
      }
    }
  }

  String _getStorageKey(TimestampDesign design) {
    return 'unlocked_until_${design.name}';
  }
}
