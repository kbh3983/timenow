import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';

class AccentColorOption {
  final String name;
  final Color color;
  const AccentColorOption(this.name, this.color);
}

class AppSettingsService extends ChangeNotifier {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  static const List<AccentColorOption> accentColors = [
    AccentColorOption('네온 라임', Color(0xFFC6FF00)),
    AccentColorOption('골드 옐로우', Color(0xFFFFD700)),
    AccentColorOption('스카이 블루', Color(0xFF00E5FF)),
    AccentColorOption('네온 핑크', Color(0xFFFF2D55)),
    AccentColorOption('바이올렛', Color(0xFFB388FF)),
    AccentColorOption('코랄 오렌지', Color(0xFFFF6E40)),
  ];

  static const String _keyShowLocation = 'timenow_show_location';
  static const String _keyLocationText = 'timenow_location_text';
  static const String _keyLocationOptions = 'timenow_location_options';
  static const String _keyLocationPosition = 'timenow_location_position';
  static const String _keyAccentIndex = 'timenow_accent_index';
  static const String _keyCustomAccentColor = 'timenow_custom_accent_color';
  static const String _keyThemeMode = 'timenow_theme_mode';

  bool _showLocation = false;
  String _locationText = '';
  List<LocationOption> _locationOptions = [];
  bool _isFetchingLocation = false;
  String? _locationErrorMessage;
  String _locationPosition = 'bottomLeft'; // 'topLeft', 'topCenter', 'topRight', 'bottomLeft', 'bottomCenter', 'bottomRight'

  int _accentIndex = 0;
  int? _customAccentColor;
  String _themeMode = 'dark'; // 'dark' (charcoal) or 'pureBlack' (OLED)

  bool get showLocation => _showLocation;
  String get locationText => _locationText;
  List<LocationOption> get locationOptions => _locationOptions;
  bool get isFetchingLocation => _isFetchingLocation;
  String? get locationErrorMessage => _locationErrorMessage;
  String get locationPosition => _locationPosition;

  Alignment get locationAlignment {
    switch (_locationPosition) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      case 'bottomLeft':
      default:
        return Alignment.bottomLeft;
    }
  }

  int get accentIndex => _accentIndex;
  bool get isCustomAccent => _customAccentColor != null;
  int? get customAccentColorValue => _customAccentColor;
  Color get accentColor => _customAccentColor != null
      ? Color(_customAccentColor!)
      : accentColors[_accentIndex.clamp(0, accentColors.length - 1)].color;
  String get themeMode => _themeMode;
  bool get isPureBlack => _themeMode == 'pureBlack';
  bool get isLight => _themeMode == 'light';
  bool get isDark => _themeMode == 'dark';

  Color get scaffoldBackgroundColor => isLight
      ? const Color(0xFFF7F8FA)
      : (isPureBlack ? Colors.black : const Color(0xFF0F1013));

  Color get cardBackgroundColor => isLight
      ? Colors.white
      : (isPureBlack ? const Color(0xFF141416) : const Color(0xFF1A1C22));

  Color get surfaceColor => isLight
      ? const Color(0xFFEDEFF2)
      : (isPureBlack ? const Color(0xFF1E1E20) : const Color(0xFF242730));

  Color get textColor => isLight ? const Color(0xFF111418) : Colors.white;

  Color get subTextColor => isLight ? const Color(0xFF6B7280) : Colors.white60;

  Color get dividerColor => isLight ? const Color(0xFFE5E7EB) : Colors.white10;

  Color get borderColor => isLight ? const Color(0xFFE2E4E8) : Colors.white.withValues(alpha: 0.08);

  Color get appBarColor => isLight ? Colors.white : (isPureBlack ? Colors.black : const Color(0xFF0F1013));

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _showLocation = prefs.getBool(_keyShowLocation) ?? false;
      _locationText = prefs.getString(_keyLocationText) ?? '';
      _locationPosition = prefs.getString(_keyLocationPosition) ?? 'bottomLeft';
      _accentIndex = prefs.getInt(_keyAccentIndex) ?? 0;
      if (prefs.containsKey(_keyCustomAccentColor)) {
        _customAccentColor = prefs.getInt(_keyCustomAccentColor);
      }
      _themeMode = prefs.getString(_keyThemeMode) ?? 'dark';

      final rawOptions = prefs.getStringList(_keyLocationOptions);
      if (rawOptions != null && rawOptions.isNotEmpty) {
        _locationOptions = rawOptions.map((str) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            return LocationOption(
              label: map['label'] as String? ?? '주소',
              value: map['value'] as String? ?? '',
            );
          } catch (_) {
            return LocationOption(label: '주소', value: str);
          }
        }).where((opt) => opt.value.isNotEmpty).toList();
      }

      // 만약 기존 저장된 옵션이 3개뿐이거나 4번째 옵션이 누락된 경우 4번째 옵션 자동 합성 추가
      if (_locationOptions.isNotEmpty && _locationOptions.length == 3) {
        final opt2 = _locationOptions[1].value;
        final opt3 = _locationOptions[2].value;
        final opt2Tokens = opt2.split(RegExp(r'\s+'));
        final prefix = opt2Tokens.take(2).join(' ');
        final opt4Value = LocationService.mergeAddressParts([prefix, opt3]);
        _locationOptions.add(LocationOption(
          label: '국가 및 도시 + 더 상세한 주소',
          value: opt4Value,
        ));
        final rawList = _locationOptions
            .map((o) => jsonEncode({'label': o.label, 'value': o.value}))
            .toList();
        prefs.setStringList(_keyLocationOptions, rawList);
      } else if (_locationOptions.isEmpty) {
        _locationOptions = List.from(LocationService.defaultOptions);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('AppSettingsService init error: $e');
    }
  }

  Future<void> setShowLocation(bool value) async {
    _showLocation = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowLocation, value);

    // 위치 표시를 켰는데 아직 설정된 위치 문구가 없으면 자동으로 현재 GPS 위치 가져오기
    if (value && _locationText.isEmpty && !_isFetchingLocation) {
      await fetchAndApplyGpsLocation(overwrite: true);
    }
  }

  Future<void> setLocationText(String text) async {
    _locationText = text;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocationText, text);
  }

  Future<void> setLocationPosition(String position) async {
    _locationPosition = position;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocationPosition, position);
  }

  /// 실제 GPS 위치를 가져와 주소 옵션들을 생성하고 위치 문구로 적용
  Future<LocationFetchResult> fetchAndApplyGpsLocation({bool overwrite = true}) async {
    _isFetchingLocation = true;
    _locationErrorMessage = null;
    notifyListeners();

    try {
      final result = await LocationService().fetchCurrentLocation();
      _isFetchingLocation = false;

      if (result.success) {
        _locationOptions = result.options;
        if (overwrite || _locationText.isEmpty) {
          _locationText = result.primaryAddress;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyLocationText, _locationText);

        final rawList = _locationOptions
            .map((o) => jsonEncode({'label': o.label, 'value': o.value}))
            .toList();
        await prefs.setStringList(_keyLocationOptions, rawList);
      } else {
        _locationErrorMessage = result.errorMessage;
      }

      notifyListeners();
      return result;
    } catch (e) {
      _isFetchingLocation = false;
      _locationErrorMessage = '위치를 가져오는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return LocationFetchResult(success: false, errorMessage: _locationErrorMessage);
    }
  }

  Future<void> setAccentIndex(int index) async {
    if (index >= 0 && index < accentColors.length) {
      _accentIndex = index;
      _customAccentColor = null;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyAccentIndex, index);
      await prefs.remove(_keyCustomAccentColor);
    }
  }

  Future<void> setCustomAccentColor(int colorValue) async {
    _customAccentColor = colorValue;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCustomAccentColor, colorValue);
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }
}
