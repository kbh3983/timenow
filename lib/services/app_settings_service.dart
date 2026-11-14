import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'location_service.dart';
import '../stamps/sample_stamp_compat.dart' show I18n;
import '../stamps/sample_stamp_data.dart';

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
  static const String _keyLocationOptionsKo = 'timenow_location_options_ko';
  static const String _keyLocationSelectedIdx = 'timenow_location_selected_idx';
  static const String _keyLastLatitude = 'timenow_last_latitude';
  static const String _keyLastLongitude = 'timenow_last_longitude';
  static const String _keyLocationPosition = 'timenow_location_position';
  static const String _keyAccentIndex = 'timenow_accent_index';
  static const String _keyCustomAccentColor = 'timenow_custom_accent_color';
  static const String _keyThemeMode = 'timenow_theme_mode';
  static const String _keyLanguageMode = 'timenow_language_mode';

  bool _showLocation = false;
  String _locationText = '';
  List<LocationOption> _locationOptions = [];
  List<LocationOption> _locationOptionsKo = [];
  int _selectedLocationOptionIndex = 0; // 0..3: GPS/기본 옵션, -1: 사용자 직접 입력 문구
  double? _lastLatitude;
  double? _lastLongitude;
  bool _isFetchingLocation = false;
  String? _locationErrorMessage;
  String _locationPosition =
      'bottomLeft'; // 'topLeft', 'topCenter', 'topRight', 'bottomLeft', 'bottomCenter', 'bottomRight'

  int _accentIndex = 0;
  int? _customAccentColor;
  String _themeMode = 'dark'; // 'dark' (charcoal) or 'pureBlack' (OLED)
  String _languageMode =
      'system'; // 'system' or 'ko', 'en', 'zh', 'ja', 'es', 'de', 'fr'

  bool get showLocation => _showLocation;
  String get locationText => _locationText;
  List<LocationOption> get locationOptions => _locationOptions;
  bool get isFetchingLocation => _isFetchingLocation;
  String? get locationErrorMessage => _locationErrorMessage;
  String get locationPosition => _locationPosition;
  String get languageMode => _languageMode;
  String get languageCode => AppLocalizations.languageCode;
  Locale get locale => AppLocalizations.currentInfo.locale;

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

  Color get subTextColor =>
      isLight ? const Color(0xFF6B7280) : Colors.white60;

  Color get dividerColor =>
      isLight ? const Color(0xFFE5E7EB) : Colors.white10;

  Color get borderColor => isLight
      ? const Color(0xFFE2E4E8)
      : Colors.white.withValues(alpha: 0.08);

  Color get appBarColor => isLight
      ? Colors.white
      : (isPureBlack ? Colors.black : const Color(0xFF0F1013));

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1) 빌드 타임 언어 오버라이드(--dart-define=APP_LANG=...) 최우선 확인
      final buildOverride = AppLocalizations.getBuildTimeLanguageOverride();
      if (buildOverride != null && buildOverride.isNotEmpty) {
        _languageMode = buildOverride;
        AppLocalizations.setCurrentLanguageCode(buildOverride);
      } else {
        _languageMode = prefs.getString(_keyLanguageMode) ?? 'system';
        if (_languageMode == 'system') {
          AppLocalizations.setCurrentLanguageCode(
            AppLocalizations.detectDeviceLanguageCode(),
          );
        } else {
          AppLocalizations.setCurrentLanguageCode(_languageMode);
        }
      }
      I18n.locale = AppLocalizations.languageCode == 'ko'
          ? I18n.LOCALE_KO_KR
          : I18n.LOCALE_EN_US;
      SampleStampRepository.reload();

      // 앱 실행 중 휴대폰 시스템 언어를 변경했을 때도 위치 정보와 스탬프를 즉시 반영
      PlatformDispatcher.instance.onLocaleChanged = () {
        if (_languageMode == 'system' &&
            (buildOverride == null || buildOverride.isEmpty)) {
          final detected = AppLocalizations.detectDeviceLanguageCode();
          if (detected != AppLocalizations.languageCode) {
            AppLocalizations.setCurrentLanguageCode(detected);
            I18n.locale =
                detected == 'ko' ? I18n.LOCALE_KO_KR : I18n.LOCALE_EN_US;
            SampleStampRepository.reload();
            _localizeSavedLocationForLanguage(detected);
            notifyListeners();
          }
        }
      };

      _showLocation = prefs.getBool(_keyShowLocation) ?? false;
      _locationText = prefs.getString(_keyLocationText) ?? '';
      _locationPosition =
          prefs.getString(_keyLocationPosition) ?? 'bottomLeft';
      _accentIndex = prefs.getInt(_keyAccentIndex) ?? 0;
      if (prefs.containsKey(_keyCustomAccentColor)) {
        _customAccentColor = prefs.getInt(_keyCustomAccentColor);
      }
      _themeMode = prefs.getString(_keyThemeMode) ?? 'dark';

      if (prefs.containsKey(_keyLastLatitude) &&
          prefs.containsKey(_keyLastLongitude)) {
        _lastLatitude = prefs.getDouble(_keyLastLatitude);
        _lastLongitude = prefs.getDouble(_keyLastLongitude);
      }

      final rawOptions = prefs.getStringList(_keyLocationOptions);
      if (rawOptions != null && rawOptions.isNotEmpty) {
        _locationOptions = _decodeLocationOptions(rawOptions);
      }

      final rawOptionsKo = prefs.getStringList(_keyLocationOptionsKo);
      if (rawOptionsKo != null && rawOptionsKo.isNotEmpty) {
        _locationOptionsKo = _decodeLocationOptions(rawOptionsKo);
      }

      // 만약 기존 저장된 옵션이 3개뿐이거나 4번째 옵션이 누락된 경우 4번째 옵션 자동 합성 추가
      if (_locationOptions.isNotEmpty && _locationOptions.length == 3) {
        final opt2 = _locationOptions[1].value;
        final opt3 = _locationOptions[2].value;
        final opt2Tokens = opt2.split(RegExp(r'\s+'));
        final prefix = opt2Tokens.take(2).join(' ');
        final opt4Value = LocationService.mergeAddressParts([prefix, opt3]);
        _locationOptions.add(
          LocationOption(
            label: '국가 및 도시 + 더 상세한 주소',
            value: opt4Value,
          ),
        );
      } else if (_locationOptions.isEmpty) {
        _locationOptions = List.from(
          LocationService.getDefaultOptions(AppLocalizations.languageCode),
        );
      }

      // 만약 한국어 원본 옵션이 비어있고 현재 옵션에 한글이 있다면 보존
      if (_locationOptionsKo.isEmpty &&
          _locationOptions.isNotEmpty &&
          RegExp(r'[가-힣]').hasMatch(_locationOptions.first.value)) {
        _locationOptionsKo = List.from(_locationOptions);
      }

      // 현재 선택된 옵션 인덱스 복원 또는 추론
      if (prefs.containsKey(_keyLocationSelectedIdx)) {
        _selectedLocationOptionIndex =
            prefs.getInt(_keyLocationSelectedIdx) ?? 0;
      } else {
        _selectedLocationOptionIndex = _inferSelectedOptionIndex(_locationText);
      }

      // 앱 시작 시 현재 언어에 맞게 위치 옵션 및 텍스트 즉시 다국어화
      await _localizeSavedLocationForLanguage(
        AppLocalizations.languageCode,
        persist: true,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('AppSettingsService init error: $e');
    }
  }

  List<LocationOption> _decodeLocationOptions(List<String> rawOptions) {
    return rawOptions
        .map((str) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            return LocationOption(
              label:
                  map['label'] as String? ?? AppStrings.locLabelAddressDefault,
              value: map['value'] as String? ?? '',
            );
          } catch (_) {
            return LocationOption(
              label: AppStrings.locLabelAddressDefault,
              value: str,
            );
          }
        })
        .where((opt) => opt.value.isNotEmpty)
        .toList();
  }

  int _inferSelectedOptionIndex(String text) {
    if (text.trim().isEmpty) return 0;
    final defaultIdx = LocationService.matchDefaultOptionIndex(text);
    if (defaultIdx != -1) return defaultIdx;
    for (int i = 0; i < _locationOptions.length; i++) {
      if (_locationOptions[i].value == text) return i;
    }
    for (int i = 0; i < _locationOptionsKo.length; i++) {
      if (_locationOptionsKo[i].value == text) return i;
    }
    return -1;
  }

  /// 언어가 변경되었을 때 저장된 위치 옵션과 표시 문구를 새 언어로 즉시 변환하고,
  /// GPS 좌표가 있는 경우 백그라운드에서 해당 언어로 역지오코딩을 갱신합니다.
  Future<void> _localizeSavedLocationForLanguage(
    String targetLang, {
    bool persist = true,
  }) async {
    // 1. 기본 예시 옵션인 경우 해당 언어의 기본 옵션으로 교체
    if (_locationOptions.isEmpty ||
        LocationService.isDefaultOptionsList(_locationOptions)) {
      _locationOptions = List.from(
        LocationService.getDefaultOptions(targetLang),
      );
    } else if (targetLang == 'ko' && _locationOptionsKo.isNotEmpty) {
      // 한국어로 돌아온 경우 보존된 한국어 옵션 복원
      _locationOptions = List.from(_locationOptionsKo);
    } else if (_locationOptionsKo.isNotEmpty) {
      // 한국어 원본으로부터 대상 언어로 즉시 변환
      _locationOptions = LocationService.localizeOptionsList(
        _locationOptionsKo,
        targetLang,
      );
    } else {
      _locationOptions = LocationService.localizeOptionsList(
        _locationOptions,
        targetLang,
      );
    }

    // 2. 현재 선택된 위치 텍스트도 새 언어의 동일 옵션 인덱스로 즉시 업데이트 (직접 입력 문구(-1) 제외)
    if (_selectedLocationOptionIndex >= 0 &&
        _selectedLocationOptionIndex < _locationOptions.length) {
      if (_locationText.isNotEmpty) {
        _locationText = _locationOptions[_selectedLocationOptionIndex].value;
      }
    } else if (_locationText.isNotEmpty) {
      final defIdx = LocationService.matchDefaultOptionIndex(_locationText);
      if (defIdx != -1 && defIdx < _locationOptions.length) {
        _selectedLocationOptionIndex = defIdx;
        _locationText = _locationOptions[defIdx].value;
      }
    }

    if (persist) {
      await _persistLocationState();
    }

    // 3. 실제 측정된 GPS 좌표가 있으면 해당 언어로 정식 다국어 역지오코딩을 비동기로 수행하여 갱신
    if (_lastLatitude != null && _lastLongitude != null) {
      _refreshCoordinatesInBackground(_lastLatitude!, _lastLongitude!, targetLang);
    } else if (_showLocation &&
        _selectedLocationOptionIndex != -1 &&
        !_isFetchingLocation &&
        LocationService.isDefaultOptionsList(_locationOptions)) {
      // 위치 표시가 켜져 있는데 아직 GPS 좌표가 없다면 자동으로 현재 언어 기준 GPS 측정
      fetchAndApplyGpsLocation(overwrite: true);
    }
  }

  Future<void> _refreshCoordinatesInBackground(
    double lat,
    double lng,
    String targetLang,
  ) async {
    try {
      final res = await LocationService().fetchOptionsForCoordinates(
        lat,
        lng,
        langCode: targetLang,
      );
      if (res.success &&
          res.options.isNotEmpty &&
          AppLocalizations.languageCode == targetLang) {
        _locationOptions = res.options;
        if (targetLang == 'ko') {
          _locationOptionsKo = List.from(res.options);
        }
        if (_selectedLocationOptionIndex >= 0 &&
            _selectedLocationOptionIndex < _locationOptions.length &&
            _locationText.isNotEmpty) {
          _locationText = _locationOptions[_selectedLocationOptionIndex].value;
        }
        await _persistLocationState();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Background location language refresh error: $e');
    }
  }

  Future<void> _persistLocationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLocationText, _locationText);
      await prefs.setInt(_keyLocationSelectedIdx, _selectedLocationOptionIndex);
      final rawList = _locationOptions
          .map((o) => jsonEncode({'label': o.rawLabel, 'value': o.value}))
          .toList();
      await prefs.setStringList(_keyLocationOptions, rawList);
      if (_locationOptionsKo.isNotEmpty) {
        final rawListKo = _locationOptionsKo
            .map((o) => jsonEncode({'label': o.rawLabel, 'value': o.value}))
            .toList();
        await prefs.setStringList(_keyLocationOptionsKo, rawListKo);
      }
      if (_lastLatitude != null && _lastLongitude != null) {
        await prefs.setDouble(_keyLastLatitude, _lastLatitude!);
        await prefs.setDouble(_keyLastLongitude, _lastLongitude!);
      }
    } catch (e) {
      debugPrint('Persist location state error: $e');
    }
  }

  Future<void> setLanguageMode(String mode) async {
    _languageMode = mode;
    final resolved = mode == 'system'
        ? AppLocalizations.detectDeviceLanguageCode()
        : AppLocalizations.normalizeLanguageCode(mode);
    AppLocalizations.setCurrentLanguageCode(resolved);
    I18n.locale = resolved == 'ko' ? I18n.LOCALE_KO_KR : I18n.LOCALE_EN_US;
    SampleStampRepository.reload();

    // 언어 변경 즉시 위치 옵션 및 표시할 위치 텍스트도 새 언어로 자동 전환
    await _localizeSavedLocationForLanguage(resolved, persist: true);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageMode, mode);
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
    // 사용자가 선택한 문구가 4가지 GPS 옵션 중 몇 번째인지 기록 (직접 입력이면 -1)
    int matchedIdx = -1;
    for (int i = 0; i < _locationOptions.length; i++) {
      if (_locationOptions[i].value == text) {
        matchedIdx = i;
        break;
      }
    }
    _selectedLocationOptionIndex = matchedIdx;
    notifyListeners();
    await _persistLocationState();
  }

  Future<void> setLocationPosition(String position) async {
    _locationPosition = position;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocationPosition, position);
  }

  /// 실제 GPS 위치를 가져와 현재 언어로 주소 옵션들을 생성하고 위치 문구로 적용
  Future<LocationFetchResult> fetchAndApplyGpsLocation({
    bool overwrite = true,
  }) async {
    _isFetchingLocation = true;
    _locationErrorMessage = null;
    notifyListeners();

    try {
      final currentLang = AppLocalizations.languageCode;
      final result = await LocationService().fetchCurrentLocation(
        langCode: currentLang,
      );
      _isFetchingLocation = false;

      if (result.success) {
        _locationOptions = result.options;
        if (result.latitude != null && result.longitude != null) {
          _lastLatitude = result.latitude;
          _lastLongitude = result.longitude;
        }
        if (currentLang == 'ko') {
          _locationOptionsKo = List.from(result.options);
        } else if (_lastLatitude != null && _lastLongitude != null) {
          // 비한국어 상태에서 측정한 경우에도 한국어 원본 옵션을 백그라운드에서 함께 확보해 둠
          LocationService()
              .fetchOptionsForCoordinates(
                _lastLatitude!,
                _lastLongitude!,
                langCode: 'ko',
              )
              .then((koRes) {
            if (koRes.success && koRes.options.isNotEmpty) {
              _locationOptionsKo = koRes.options;
              _persistLocationState();
            }
          });
        }

        if (overwrite || _locationText.isEmpty) {
          final idx = (_selectedLocationOptionIndex >= 0 &&
                  _selectedLocationOptionIndex < _locationOptions.length)
              ? _selectedLocationOptionIndex
              : 0;
          _selectedLocationOptionIndex = idx;
          _locationText = _locationOptions[idx].value;
        } else if (_selectedLocationOptionIndex >= 0 &&
            _selectedLocationOptionIndex < _locationOptions.length) {
          _locationText = _locationOptions[_selectedLocationOptionIndex].value;
        }

        await _persistLocationState();
      } else {
        _locationErrorMessage = result.errorMessage;
      }

      notifyListeners();
      return result;
    } catch (e) {
      _isFetchingLocation = false;
      _locationErrorMessage = AppStrings.locErrUnexpected('$e');
      notifyListeners();
      return LocationFetchResult(
        success: false,
        errorMessage: _locationErrorMessage,
      );
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
