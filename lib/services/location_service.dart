import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'app_localizations.dart';

class LocationOption {
  final String _label;
  final String value;
  const LocationOption({required String label, required this.value})
      : _label = label;

  String get rawLabel => _label;
  String get label => AppStrings.localizeLocationOptionLabel(_label);
}

class LocationFetchResult {
  final bool success;
  final String? errorMessage;
  final String primaryAddress;
  final List<LocationOption> options;
  final double? latitude;
  final double? longitude;

  const LocationFetchResult({
    required this.success,
    this.errorMessage,
    this.primaryAddress = '',
    this.options = const [],
    this.latitude,
    this.longitude,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 언어별 기본 예시 주소 옵션 (GPS 미측정 시 초기값)
  static List<LocationOption> getDefaultOptions([String? langCode]) {
    final code = langCode ?? AppLocalizations.languageCode;
    switch (code) {
      case 'en':
        return const [
          LocationOption(
            label: '상세주소',
            value: 'Guui-dong, Gwangjin-gu',
          ),
          LocationOption(
            label: '국가 및 도시 + 상세주소',
            value: 'Guui-dong, Gwangjin-gu, Seoul, South Korea',
          ),
          LocationOption(
            label: '더 상세한 주소',
            value: '24-8, Guui-ro 6-gil',
          ),
          LocationOption(
            label: '국가 및 도시 + 더 상세한 주소',
            value: '24-8, Guui-ro 6-gil, Seoul, South Korea',
          ),
        ];
      case 'zh':
        return const [
          LocationOption(
            label: '상세주소',
            value: '广津区 九宜洞',
          ),
          LocationOption(
            label: '국가 및 도시 + 상세주소',
            value: '韩国 首尔特别市 广津区 九宜洞',
          ),
          LocationOption(
            label: '더 상세한 주소',
            value: '九宜路6街 24-8',
          ),
          LocationOption(
            label: '국가 및 도시 + 더 상세한 주소',
            value: '韩国 首尔特别市 九宜路6街 24-8',
          ),
        ];
      case 'ja':
        return const [
          LocationOption(
            label: '상세주소',
            value: '広津区 九宜洞',
          ),
          LocationOption(
            label: '국가 및 도시 + 상세주소',
            value: '大韓民国 ソウル特別市 広津区 九宜洞',
          ),
          LocationOption(
            label: '더 상세한 주소',
            value: '九宜路6キル 24-8',
          ),
          LocationOption(
            label: '국가 및 도시 + 더 상세한 주소',
            value: '大韓民国 ソウル特別市 九宜路6キル 24-8',
          ),
        ];
      case 'es':
        return const [
          LocationOption(
            label: '상세주소',
            value: 'Guui-dong, Gwangjin-gu',
          ),
          LocationOption(
            label: '국가 및 도시 + 상세주소',
            value: 'Guui-dong, Gwangjin-gu, Seúl, Corea del Sur',
          ),
          LocationOption(
            label: '더 상세한 주소',
            value: '24-8, Guui-ro 6-gil',
          ),
          LocationOption(
            label: '국가 및 도시 + 더 상세한 주소',
            value: '24-8, Guui-ro 6-gil, Seúl, Corea del Sur',
          ),
        ];
      case 'de':
        return const [
          LocationOption(
            label: '상세주소',
            value: 'Guui-dong, Gwangjin-gu',
          ),
          LocationOption(
            label: '국가 및 도시 + 상세주소',
            value: 'Guui-dong, Gwangjin-gu, Seoul, Südkorea',
          ),
          LocationOption(
            label: '더 상세한 주소',
            value: '24-8, Guui-ro 6-gil',
          ),
          LocationOption(
            label: '국가 및 도시 + 더 상세한 주소',
            value: '24-8, Guui-ro 6-gil, Seoul, Südkorea',
          ),
        ];
      case 'fr':
        return const [
          LocationOption(
            label: '상세주소',
            value: 'Guui-dong, Gwangjin-gu',
          ),
          LocationOption(
            label: '국가 및 도시 + 상세주소',
            value: 'Guui-dong, Gwangjin-gu, Séoul, Corée du Sud',
          ),
          LocationOption(
            label: '더 상세한 주소',
            value: '24-8, Guui-ro 6-gil',
          ),
          LocationOption(
            label: '국가 및 도시 + 더 상세한 주소',
            value: '24-8, Guui-ro 6-gil, Séoul, Corée du Sud',
          ),
        ];
      case 'ko':
      default:
        return const [
          LocationOption(
            label: '상세주소',
            value: '광진구 구의동',
          ),
          LocationOption(
            label: '국가 및 도시 + 상세주소',
            value: '대한민국 서울특별시 광진구 구의동',
          ),
          LocationOption(
            label: '더 상세한 주소',
            value: '구의로 6길 24-8',
          ),
          LocationOption(
            label: '국가 및 도시 + 더 상세한 주소',
            value: '대한민국 서울특별시 구의로 6길 24-8',
          ),
        ];
    }
  }

  static List<LocationOption> get defaultOptions => getDefaultOptions();

  /// 기본 예시 주소 중 하나인지 판별하고, 맞다면 몇 번째 옵션(0..3)인지 반환 (아니면 -1)
  static int matchDefaultOptionIndex(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return -1;
    for (final lang in const ['ko', 'en', 'zh', 'ja', 'es', 'de', 'fr']) {
      final opts = getDefaultOptions(lang);
      for (int i = 0; i < opts.length; i++) {
        if (opts[i].value == trimmed) return i;
      }
    }
    return -1;
  }

  /// 옵션 리스트가 기본 예시 주소 리스트인지 확인
  static bool isDefaultOptionsList(List<LocationOption> options) {
    if (options.isEmpty) return true;
    return matchDefaultOptionIndex(options.first.value) != -1;
  }

  /// GPS 현재 위치를 요청하고 현재 설정된 언어로 4가지 주소 옵션을 생성합니다.
  Future<LocationFetchResult> fetchCurrentLocation({String? langCode}) async {
    try {
      // 1. 위치 서비스(GPS) 활성화 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationFetchResult(
          success: false,
          errorMessage: AppStrings.locErrServiceDisabled,
        );
      }

      // 2. 권한 확인 및 요청
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationFetchResult(
            success: false,
            errorMessage: AppStrings.locErrDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationFetchResult(
          success: false,
          errorMessage: AppStrings.locErrDeniedForever,
        );
      }

      // 3. 현재 위치 좌표 획득 (우선 빠른 측정 시도 후 마지막 위치 폴백)
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return LocationFetchResult(
          success: false,
          errorMessage: AppStrings.locErrFailed,
        );
      }

      return await fetchOptionsForCoordinates(
        position.latitude,
        position.longitude,
        langCode: langCode,
      );
    } catch (e) {
      debugPrint('Location fetch error: $e');
      return LocationFetchResult(
        success: false,
        errorMessage: AppStrings.locErrUnexpected('$e'),
      );
    }
  }

  /// 주어진 위도/경도 좌표를 지정된 언어(기본값: 현재 앱 언어)의 주소 옵션 4가지로 역지오코딩합니다.
  Future<LocationFetchResult> fetchOptionsForCoordinates(
    double latitude,
    double longitude, {
    String? langCode,
  }) async {
    final targetLang = langCode ?? AppLocalizations.languageCode;
    final targetInfo = AppLocalizations.getInfo(targetLang);

    // 1) 다국어 역지오코딩: 한국어가 아닐 때는 다국어 지원이 정확한 OpenStreetMap Nominatim / BigDataCloud를
    //    네이티브 Geocoder와 병행하여 호출합니다 (안드로이드 기본 Geocoder가 국내 주소를 한글로만 반환하는 현상 방지).
    List<LocationOption>? webOptions;
    if (targetLang != 'ko') {
      webOptions = await _fetchMultilingualWebGeocoding(
        latitude,
        longitude,
        targetLang,
      );
    }

    // 2) 네이티브 Geocoding 호출
    List<Placemark> placemarks = [];
    try {
      final geocoder = Geocoding(locale: targetInfo.locale);
      placemarks = await geocoder.placemarkFromCoordinates(
        latitude,
        longitude,
      );
    } catch (e) {
      debugPrint('Native Geocoding error: $e');
    }

    // 3) 만약 한국어 모드인데 네이티브 Geocoding이 실패했다면 웹 역지오코딩 폴백 시도
    if (placemarks.isEmpty && webOptions == null) {
      webOptions = await _fetchMultilingualWebGeocoding(
        latitude,
        longitude,
        targetLang,
      );
    }

    if (webOptions != null && webOptions.isNotEmpty) {
      // 만약 네이티브 Placemark에 상세 도로명/번지가 있고 웹 옵션에 번지가 없다면 보완
      return LocationFetchResult(
        success: true,
        primaryAddress: webOptions.first.value,
        options: webOptions,
        latitude: latitude,
        longitude: longitude,
      );
    }

    if (placemarks.isEmpty) {
      final fallback =
          '${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}';
      return LocationFetchResult(
        success: true,
        primaryAddress: fallback,
        options: [
          LocationOption(label: AppStrings.locLabelLatLng, value: fallback),
        ],
        latitude: latitude,
        longitude: longitude,
      );
    }

    final place = placemarks.first;
    final options = _buildAddressOptions(place, targetLang: targetLang);
    final primary = options.isNotEmpty ? options.first.value : '';

    return LocationFetchResult(
      success: true,
      primaryAddress: primary,
      options: options,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// OpenStreetMap Nominatim / BigDataCloud 다국어 역지오코딩
  Future<List<LocationOption>?> _fetchMultilingualWebGeocoding(
    double lat,
    double lng,
    String langCode,
  ) async {
    final acceptLang = switch (langCode) {
      'zh' => 'zh-CN,zh;q=0.9,en;q=0.5',
      'ja' => 'ja,en;q=0.5',
      'es' => 'es,en;q=0.5',
      'de' => 'de,en;q=0.5',
      'fr' => 'fr,en;q=0.5',
      'en' => 'en',
      _ => 'ko,en;q=0.5',
    };

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(milliseconds: 3200);
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&accept-language=${Uri.encodeQueryComponent(acceptLang)}&addressdetails=1',
      );
      final req = await client.getUrl(uri);
      req.headers.set('User-Agent', 'LOGTimestampCamera/1.0.2 (com.bebong.log)');
      req.headers.set('Accept-Language', acceptLang);
      final resp = await req.close().timeout(const Duration(milliseconds: 3500));
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final rawCountry = (addr['country'] as String? ?? '').trim();
          final rawCity = (addr['city'] ??
                  addr['state'] ??
                  addr['province'] ??
                  addr['town'] ??
                  '')
              .toString()
              .trim();
          final rawDistrict = (addr['borough'] ??
                  addr['city_district'] ??
                  addr['county'] ??
                  addr['municipality'] ??
                  '')
              .toString()
              .trim();
          final rawSubLocality = (addr['suburb'] ??
                  addr['quarter'] ??
                  addr['neighbourhood'] ??
                  addr['village'] ??
                  addr['hamlet'] ??
                  '')
              .toString()
              .trim();
          final rawRoad = (addr['road'] ??
                  addr['pedestrian'] ??
                  addr['footway'] ??
                  addr['amenity'] ??
                  '')
              .toString()
              .trim();
          final rawHouseNo = (addr['house_number'] ?? '').toString().trim();

          final placemark = Placemark(
            country: rawCountry,
            administrativeArea: rawCity,
            subAdministrativeArea: rawDistrict,
            locality: rawDistrict.isNotEmpty ? rawDistrict : rawCity,
            subLocality: rawSubLocality,
            thoroughfare: rawRoad,
            subThoroughfare: rawHouseNo,
          );
          final built = _buildAddressOptions(placemark, targetLang: langCode);
          if (built.isNotEmpty) {
            client.close(force: true);
            return built;
          }
        }
      }
      client.close(force: true);
    } catch (e) {
      debugPrint('Nominatim geocoding fallback: $e');
    }
    return null;
  }

  static String mergeAddressParts(List<String> parts, {String sep = ' '}) {
    final result = <String>[];
    for (final part in parts) {
      final cleaned = part.trim();
      if (cleaned.isEmpty) continue;
      if (sep == ', ') {
        final tokens = cleaned.split(RegExp(r'\s*,\s*'));
        for (final token in tokens) {
          final t = token.trim();
          if (t.isNotEmpty &&
              !result.any((r) => r.toLowerCase() == t.toLowerCase())) {
            result.add(t);
          }
        }
      } else {
        final tokens = cleaned.split(RegExp(r'\s+'));
        for (final token in tokens) {
          if (token.isNotEmpty && !result.contains(token)) {
            result.add(token);
          }
        }
      }
    }
    return result.join(sep);
  }

  /// Placemark로부터 요청된 4가지 표준 GPS 주소 옵션을 언어별 주소 체계(동양식/서양식)로 생성:
  /// 1) 상세주소 (구/동/읍/면)
  /// 2) 국가 및 도시 + 상세주소
  /// 3) 더 상세한 주소 (도로명 + 번호 또는 지번/건물명)
  /// 4) 국가 및 도시 + 더 상세한 주소
  List<LocationOption> _buildAddressOptions(
    Placemark place, {
    String? targetLang,
  }) {
    final lang = targetLang ?? AppLocalizations.languageCode;
    final isWesternOrder =
        lang == 'en' || lang == 'es' || lang == 'de' || lang == 'fr';

    String country = (place.country != null && place.country!.isNotEmpty)
        ? place.country!
        : _defaultCountryName(lang);
    String adminArea = place.administrativeArea ?? '';
    String subAdmin = place.subAdministrativeArea ?? '';
    String locality = place.locality ?? '';
    String subLocality = place.subLocality ?? '';
    String thoroughfare = place.thoroughfare ?? '';
    String subThoroughfare = place.subThoroughfare ?? '';
    String street = place.street ?? '';
    String name = place.name ?? '';

    // 한국어가 아닌데 주소 컴포넌트에 한글이 남아있는 경우(안드로이드 기본 지오코더 등) 해당 언어로 자동 변환
    if (lang != 'ko') {
      country = localizeAddressComponent(country, lang);
      adminArea = localizeAddressComponent(adminArea, lang);
      subAdmin = localizeAddressComponent(subAdmin, lang);
      locality = localizeAddressComponent(locality, lang);
      subLocality = localizeAddressComponent(subLocality, lang);
      thoroughfare = localizeAddressComponent(thoroughfare, lang);
      subThoroughfare = localizeAddressComponent(subThoroughfare, lang);
      street = localizeAddressComponent(street, lang);
      name = localizeAddressComponent(name, lang);
    }

    final district = subAdmin.isNotEmpty
        ? subAdmin
        : (locality.isNotEmpty && locality != adminArea ? locality : '');

    // 1. 상세주소 (구/군 + 동/읍/면)
    String opt1Value;
    if (isWesternOrder) {
      final parts = <String>[];
      if (subLocality.isNotEmpty) parts.add(subLocality);
      if (district.isNotEmpty &&
          district.toLowerCase() != subLocality.toLowerCase()) {
        parts.add(district);
      }
      if (parts.isEmpty) {
        if (thoroughfare.isNotEmpty) {
          parts.add(thoroughfare);
        } else if (adminArea.isNotEmpty) {
          parts.add(adminArea);
        }
      }
      opt1Value = mergeAddressParts(parts, sep: ', ');
    } else {
      final detailList = <String>[];
      if (district.isNotEmpty) detailList.add(district);
      if (subLocality.isNotEmpty && !detailList.contains(subLocality)) {
        detailList.add(subLocality);
      }
      if (detailList.isEmpty) {
        if (thoroughfare.isNotEmpty) {
          detailList.add(thoroughfare);
        } else if (adminArea.isNotEmpty) {
          detailList.add(adminArea);
        }
      }
      opt1Value = detailList.join(' ').trim();
    }

    // 2. 국가 및 도시 + 상세주소
    String opt2Value;
    if (isWesternOrder) {
      final parts = <String>[];
      if (opt1Value.isNotEmpty) parts.add(opt1Value);
      if (adminArea.isNotEmpty) parts.add(adminArea);
      if (country.isNotEmpty) parts.add(country);
      opt2Value = mergeAddressParts(parts, sep: ', ');
    } else {
      final countryCityParts = <String>[country];
      if (adminArea.isNotEmpty && !countryCityParts.contains(adminArea)) {
        countryCityParts.add(adminArea);
      }
      final countryCityPrefix = countryCityParts.join(' ').trim();
      opt2Value = mergeAddressParts([countryCityPrefix, opt1Value]);
    }

    // 3. 더 상세한 주소 (도로명 + 번호 / 지번 / 건물명)
    String opt3Value = '';
    if (thoroughfare.isNotEmpty) {
      if (subThoroughfare.isNotEmpty &&
          !thoroughfare.contains(subThoroughfare)) {
        opt3Value = isWesternOrder
            ? '$subThoroughfare, $thoroughfare'.trim()
            : '$thoroughfare $subThoroughfare'.trim();
      } else if (name.isNotEmpty &&
          !thoroughfare.contains(name) &&
          name != subLocality) {
        opt3Value = isWesternOrder
            ? '$name, $thoroughfare'.trim()
            : '$thoroughfare $name'.trim();
      } else {
        opt3Value = thoroughfare;
      }
    }

    if (opt3Value.isEmpty && street.isNotEmpty) {
      String cleaned = street;
      if (country.isNotEmpty) {
        cleaned = cleaned.replaceFirst(country, '').trim();
      }
      if (adminArea.isNotEmpty) {
        cleaned = cleaned.replaceFirst(adminArea, '').trim();
      }
      if (subAdmin.isNotEmpty) {
        cleaned = cleaned.replaceFirst(subAdmin, '').trim();
      }
      if (locality.isNotEmpty && locality != subLocality) {
        cleaned = cleaned.replaceFirst(locality, '').trim();
      }
      opt3Value = cleaned.replaceAll(RegExp(r'^[,.\s]+|[,.\s]+$'), '').trim();
    }

    if (opt3Value.isEmpty && name.isNotEmpty && name != subLocality) {
      opt3Value = name;
    }

    final defaults = getDefaultOptions(lang);
    if (opt1Value.isEmpty) opt1Value = defaults[0].value;
    if (opt2Value.isEmpty) opt2Value = defaults[1].value;
    if (opt3Value.isEmpty) {
      opt3Value = opt1Value.isNotEmpty ? opt1Value : defaults[2].value;
    }

    // 4. 국가 및 도시 + 더 상세한 주소
    String opt4Value;
    if (isWesternOrder) {
      final parts = <String>[opt3Value];
      if (adminArea.isNotEmpty) parts.add(adminArea);
      if (country.isNotEmpty) parts.add(country);
      opt4Value = mergeAddressParts(parts, sep: ', ');
    } else {
      final countryCityParts = <String>[country];
      if (adminArea.isNotEmpty && !countryCityParts.contains(adminArea)) {
        countryCityParts.add(adminArea);
      }
      final countryCityPrefix = countryCityParts.join(' ').trim();
      opt4Value = mergeAddressParts([countryCityPrefix, opt3Value]);
    }
    if (opt4Value.isEmpty) opt4Value = defaults[3].value;

    return [
      LocationOption(label: '상세주소', value: opt1Value),
      LocationOption(label: '국가 및 도시 + 상세주소', value: opt2Value),
      LocationOption(label: '더 상세한 주소', value: opt3Value),
      LocationOption(label: '국가 및 도시 + 더 상세한 주소', value: opt4Value),
    ];
  }

  static String _defaultCountryName(String lang) {
    switch (lang) {
      case 'en':
        return 'South Korea';
      case 'zh':
        return '韩国';
      case 'ja':
        return '大韓民国';
      case 'es':
        return 'Corea del Sur';
      case 'de':
        return 'Südkorea';
      case 'fr':
        return 'Corée du Sud';
      case 'ko':
      default:
        return '대한민국';
    }
  }

  /// 이미 저장되어 있는 주소 옵션 리스트를 변경된 언어로 즉시 변환
  static List<LocationOption> localizeOptionsList(
    List<LocationOption> currentOptions,
    String targetLang,
  ) {
    if (currentOptions.isEmpty || isDefaultOptionsList(currentOptions)) {
      return getDefaultOptions(targetLang);
    }
    return currentOptions
        .map(
          (opt) => LocationOption(
            label: opt.rawLabel,
            value: localizeFullAddressString(opt.value, targetLang),
          ),
        )
        .toList();
  }

  /// 전체 주소 문자열을 대상 언어로 즉시 변환 (예: "대한민국 서울특별시 광진구 구의동" -> "Guui-dong, Gwangjin-gu, Seoul, South Korea" / "広津区 九宜洞")
  static String localizeFullAddressString(String address, String targetLang) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return trimmed;

    // 1) 기본 예시 주소 중 하나라면 해당 언어의 동일 인덱스 기본 주소로 즉시 치환
    final defaultIdx = matchDefaultOptionIndex(trimmed);
    if (defaultIdx != -1) {
      return getDefaultOptions(targetLang)[defaultIdx].value;
    }

    // 2) 한글이 포함된 주소인데 targetLang != 'ko' 인 경우 토큰별로 번역/로마자화 및 어순 정렬
    if (targetLang != 'ko' && _containsHangul(trimmed)) {
      final isWestern = targetLang == 'en' ||
          targetLang == 'es' ||
          targetLang == 'de' ||
          targetLang == 'fr';

      // 도로명 + 번지 패턴 ("구의로 6길 24-8" 등) 우선 처리
      final tokens = trimmed.split(RegExp(r'\s+'));
      final convertedGroups = <String>[];

      int i = 0;
      while (i < tokens.length) {
        final t = tokens[i];
        // "구의로" + "6길" + "24-8" 같은 연속 도로명+번지 결합
        if (i + 2 < tokens.length &&
            _isRoadToken(t) &&
            _isGilToken(tokens[i + 1]) &&
            _isBuildingNumber(tokens[i + 2])) {
          final roadPart =
              '${localizeAddressComponent(t, targetLang)} ${localizeAddressComponent(tokens[i + 1], targetLang)}';
          final numPart = tokens[i + 2];
          convertedGroups.add(
            isWestern ? '$numPart, $roadPart' : '$roadPart $numPart',
          );
          i += 3;
          continue;
        }
        // "구의로" + "24-8" 또는 "구의로6길" + "24-8"
        if (i + 1 < tokens.length &&
            (_isRoadToken(t) || _isGilToken(t)) &&
            _isBuildingNumber(tokens[i + 1])) {
          final roadPart = localizeAddressComponent(t, targetLang);
          final numPart = tokens[i + 1];
          convertedGroups.add(
            isWestern ? '$numPart, $roadPart' : '$roadPart $numPart',
          );
          i += 2;
          continue;
        }
        convertedGroups.add(localizeAddressComponent(t, targetLang));
        i++;
      }

      if (isWestern) {
        return convertedGroups.reversed.join(', ');
      } else {
        return convertedGroups.join(' ');
      }
    }

    return trimmed;
  }

  static bool _containsHangul(String s) => RegExp(r'[가-힣]').hasMatch(s);
  static bool _isRoadToken(String s) =>
      s.endsWith('로') || s.endsWith('대로');
  static bool _isGilToken(String s) =>
      s.endsWith('길') || s.endsWith('번길');
  static bool _isBuildingNumber(String s) =>
      RegExp(r'^\d+(-\d+)?$').hasMatch(s);

  /// 개별 주소 컴포넌트(국가, 시/도, 구/군, 동/읍/면, 도로명)를 대상 언어로 변환
  static String localizeAddressComponent(String raw, String targetLang) {
    final text = raw.trim();
    if (text.isEmpty || targetLang == 'ko' || !_containsHangul(text)) {
      return text;
    }

    // 1. 국가명 매핑
    if (text == '대한민국' || text == '한국') {
      return _defaultCountryName(targetLang);
    }

    // 2. 광역시/도 매핑
    final adminTranslated = _translateKoreanAdminArea(text, targetLang);
    if (adminTranslated != null) return adminTranslated;

    // 3. 주요 구/시/동 사전 매핑 (일본어/중국어 한자 및 로마자)
    final dictTranslated = _translateKnownKoreanPlace(text, targetLang);
    if (dictTranslated != null) return dictTranslated;

    // 4. 공백으로 나뉜 복합 토큰인 경우 각각 변환
    if (text.contains(' ')) {
      return localizeFullAddressString(text, targetLang);
    }

    // 5. 일본어(ja) / 중국어(zh) 행정구역 접미사 + 지명 변환
    if (targetLang == 'ja' || targetLang == 'zh') {
      return _convertKoreanTokenToCjk(text, targetLang);
    }

    // 6. 서양 언어(en, es, de, fr): 국립국어원 로마자 표기법 + 행정구역 하이픈 표기
    return _romanizeKoreanAddressToken(text);
  }

  static String? _translateKoreanAdminArea(String text, String lang) {
    const map = <String, Map<String, String>>{
      '서울특별시': {
        'en': 'Seoul',
        'es': 'Seúl',
        'de': 'Seoul',
        'fr': 'Séoul',
        'ja': 'ソウル特別市',
        'zh': '首尔特别市',
      },
      '서울': {
        'en': 'Seoul',
        'es': 'Seúl',
        'de': 'Seoul',
        'fr': 'Séoul',
        'ja': 'ソウル',
        'zh': '首尔',
      },
      '부산광역시': {
        'en': 'Busan',
        'es': 'Busan',
        'de': 'Busan',
        'fr': 'Busan',
        'ja': '釜山広域市',
        'zh': '釜山广域市',
      },
      '부산': {
        'en': 'Busan',
        'es': 'Busan',
        'de': 'Busan',
        'fr': 'Busan',
        'ja': '釜山',
        'zh': '釜山',
      },
      '인천광역시': {
        'en': 'Incheon',
        'es': 'Incheon',
        'de': 'Incheon',
        'fr': 'Incheon',
        'ja': '仁川広域市',
        'zh': '仁川广域市',
      },
      '대구광역시': {
        'en': 'Daegu',
        'es': 'Daegu',
        'de': 'Daegu',
        'fr': 'Daegu',
        'ja': '大邱広域市',
        'zh': '大邱广域市',
      },
      '대전광역시': {
        'en': 'Daejeon',
        'es': 'Daejeon',
        'de': 'Daejeon',
        'fr': 'Daejeon',
        'ja': '大田広域市',
        'zh': '大田广域市',
      },
      '광주광역시': {
        'en': 'Gwangju',
        'es': 'Gwangju',
        'de': 'Gwangju',
        'fr': 'Gwangju',
        'ja': '光州広域市',
        'zh': '光州广域市',
      },
      '울산광역시': {
        'en': 'Ulsan',
        'es': 'Ulsan',
        'de': 'Ulsan',
        'fr': 'Ulsan',
        'ja': '蔚山広域市',
        'zh': '蔚山广域市',
      },
      '세종특별자치시': {
        'en': 'Sejong',
        'es': 'Sejong',
        'de': 'Sejong',
        'fr': 'Sejong',
        'ja': '世宗特別自治市',
        'zh': '世宗特别自治市',
      },
      '경기도': {
        'en': 'Gyeonggi-do',
        'es': 'Gyeonggi-do',
        'de': 'Gyeonggi-do',
        'fr': 'Gyeonggi-do',
        'ja': '京畿道',
        'zh': '京畿道',
      },
      '강원특별자치도': {
        'en': 'Gangwon-do',
        'es': 'Gangwon-do',
        'de': 'Gangwon-do',
        'fr': 'Gangwon-do',
        'ja': '江原特別自治道',
        'zh': '江原特别自治道',
      },
      '강원도': {
        'en': 'Gangwon-do',
        'es': 'Gangwon-do',
        'de': 'Gangwon-do',
        'fr': 'Gangwon-do',
        'ja': '江原道',
        'zh': '江原道',
      },
      '충청북도': {
        'en': 'Chungcheongbuk-do',
        'es': 'Chungcheongbuk-do',
        'de': 'Chungcheongbuk-do',
        'fr': 'Chungcheongbuk-do',
        'ja': '忠清北道',
        'zh': '忠清北道',
      },
      '충청남도': {
        'en': 'Chungcheongnam-do',
        'es': 'Chungcheongnam-do',
        'de': 'Chungcheongnam-do',
        'fr': 'Chungcheongnam-do',
        'ja': '忠清南道',
        'zh': '忠清南道',
      },
      '전북특별자치도': {
        'en': 'Jeonbuk-do',
        'es': 'Jeonbuk-do',
        'de': 'Jeonbuk-do',
        'fr': 'Jeonbuk-do',
        'ja': '全北特別自治道',
        'zh': '全北特别自治道',
      },
      '전라북도': {
        'en': 'Jeollabuk-do',
        'es': 'Jeollabuk-do',
        'de': 'Jeollabuk-do',
        'fr': 'Jeollabuk-do',
        'ja': '全羅北道',
        'zh': '全罗北道',
      },
      '전라남도': {
        'en': 'Jeollanam-do',
        'es': 'Jeollanam-do',
        'de': 'Jeollanam-do',
        'fr': 'Jeollanam-do',
        'ja': '全羅南道',
        'zh': '全罗南道',
      },
      '경상북도': {
        'en': 'Gyeongsangbuk-do',
        'es': 'Gyeongsangbuk-do',
        'de': 'Gyeongsangbuk-do',
        'fr': 'Gyeongsangbuk-do',
        'ja': '慶尚北道',
        'zh': '庆尚北道',
      },
      '경상남도': {
        'en': 'Gyeongsangnam-do',
        'es': 'Gyeongsangnam-do',
        'de': 'Gyeongsangnam-do',
        'fr': 'Gyeongsangnam-do',
        'ja': '慶尚南道',
        'zh': '庆尚南道',
      },
      '제주특별자치도': {
        'en': 'Jeju-do',
        'es': 'Isla de Jeju',
        'de': 'Jeju-do',
        'fr': 'Île de Jeju',
        'ja': '済州特別自治道',
        'zh': '济州特别自治道',
      },
      '제주도': {
        'en': 'Jeju-do',
        'es': 'Isla de Jeju',
        'de': 'Jeju-do',
        'fr': 'Île de Jeju',
        'ja': '済州道',
        'zh': '济州道',
      },
    };
    return map[text]?[lang];
  }

  static String? _translateKnownKoreanPlace(String text, String lang) {
    const cjkMap = <String, Map<String, String>>{
      '광진구': {'ja': '広津区', 'zh': '广津区'},
      '강남구': {'ja': '江南区', 'zh': '江南区'},
      '서초구': {'ja': '瑞草区', 'zh': '瑞草区'},
      '송파구': {'ja': '松坡区', 'zh': '松坡区'},
      '강동구': {'ja': '江東区', 'zh': '江东区'},
      '마포구': {'ja': '麻浦区', 'zh': '麻浦区'},
      '용산구': {'ja': '龍山区', 'zh': '龙山区'},
      '종로구': {'ja': '鍾路区', 'zh': '钟路区'},
      '중구': {'ja': '中区', 'zh': '中区'},
      '성동구': {'ja': '城東区', 'zh': '城东区'},
      '동대문구': {'ja': '東大門区', 'zh': '东大门区'},
      '중랑구': {'ja': '中浪区', 'zh': '中浪区'},
      '성북구': {'ja': '城北区', 'zh': '城北区'},
      '강북구': {'ja': '江北区', 'zh': '江北区'},
      '도봉구': {'ja': '道峰区', 'zh': '道峰区'},
      '노원구': {'ja': '蘆原区', 'zh': '芦原区'},
      '은평구': {'ja': '恩平区', 'zh': '恩平区'},
      '서대문구': {'ja': '西大門区', 'zh': '西大门区'},
      '양천구': {'ja': '陽川区', 'zh': '阳川区'},
      '강서구': {'ja': '江西区', 'zh': '江西区'},
      '구로구': {'ja': '九老区', 'zh': '九老区'},
      '금천구': {'ja': '衿川区', 'zh': '衿川区'},
      '영등포구': {'ja': '永登浦区', 'zh': '永登浦区'},
      '동작구': {'ja': '銅雀区', 'zh': '铜雀区'},
      '관악구': {'ja': '冠岳区', 'zh': '冠岳区'},
      '구의동': {'ja': '九宜洞', 'zh': '九宜洞'},
      '자양동': {'ja': '紫陽洞', 'zh': '紫阳洞'},
      '화양동': {'ja': '華陽洞', 'zh': '华阳洞'},
      '성수동': {'ja': '聖水洞', 'zh': '圣水洞'},
      '역삼동': {'ja': '駅三洞', 'zh': '驿三洞'},
      '삼성동': {'ja': '三成洞', 'zh': '三成洞'},
      '청담동': {'ja': '清潭洞', 'zh': '清潭洞'},
      '논현동': {'ja': '論峴洞', 'zh': '论岘洞'},
      '신사동': {'ja': '新沙洞', 'zh': '新沙洞'},
      '압구정동': {'ja': '狎鴎亭洞', 'zh': '狎鸥亭洞'},
      '서초동': {'ja': '瑞草洞', 'zh': ' 서초동'},
      '반포동': {'ja': '盤浦洞', 'zh': '盘浦洞'},
      '잠실동': {'ja': '蚕室洞', 'zh': '蚕室洞'},
      '여의도동': {'ja': '汝矣島洞', 'zh': '汝矣岛洞'},
      '홍대': {'ja': '弘大', 'zh': '弘大'},
      '서교동': {'ja': '西橋洞', 'zh': '西桥洞'},
      '연남동': {'ja': '延南洞', 'zh': '延南洞'},
      '합정동': {'ja': '合井洞', 'zh': '合井洞'},
      '이태원동': {'ja': '梨泰院洞', 'zh': '梨泰院洞'},
      '한남동': {'ja': '漢南洞', 'zh': '汉南洞'},
      '명동': {'ja': '明洞', 'zh': '明洞'},
      '구의로': {'ja': '九宜路', 'zh': '九宜路'},
    };
    if (lang == 'ja' || lang == 'zh') {
      return cjkMap[text]?[lang]?.trim();
    }
    return null;
  }

  static String _convertKoreanTokenToCjk(String token, String lang) {
    // 예: "6길" -> ja: "6キル" / zh: "6街", "24번길" -> ja: "24番キル" / zh: "24番街"
    final gilMatch = RegExp(r'^(\d+)번길$').firstMatch(token);
    if (gilMatch != null) {
      return lang == 'ja'
          ? '${gilMatch.group(1)}番キル'
          : '${gilMatch.group(1)}番街';
    }
    final numGilMatch = RegExp(r'^(\d+)길$').firstMatch(token);
    if (numGilMatch != null) {
      return lang == 'ja'
          ? '${numGilMatch.group(1)}キル'
          : '${numGilMatch.group(1)}街';
    }
    // 사전에 없는 지명은 로마자+한자 접미사로 깔끔하게 변환하여 한글이 남지 않도록 처리
    const suffixMap = <String, Map<String, String>>{
      '특별자치시': {'ja': '特別自治市', 'zh': '特别自治市'},
      '특별자치도': {'ja': '特別自治道', 'zh': '特别自治道'},
      '특별시': {'ja': '特別市', 'zh': '特别市'},
      '광역시': {'ja': '広域市', 'zh': '广域市'},
      '번길': {'ja': '番キル', 'zh': '番街'},
      '대로': {'ja': '大路', 'zh': '大路'},
      '구': {'ja': '区', 'zh': '区'},
      '시': {'ja': '市', 'zh': '市'},
      '군': {'ja': '郡', 'zh': '郡'},
      '동': {'ja': '洞', 'zh': '洞'},
      '읍': {'ja': '邑', 'zh': '邑'},
      '면': {'ja': '面', 'zh': '面'},
      '리': {'ja': '里', 'zh': '里'},
      '로': {'ja': '路', 'zh': '路'},
      '길': {'ja': 'キル', 'zh': '街'},
    };
    for (final entry in suffixMap.entries) {
      if (token.endsWith(entry.key) && token.length > entry.key.length) {
        final stem = token.substring(0, token.length - entry.key.length);
        final knownStem = _translateKnownKoreanPlace(stem, lang) ??
            _romanizeHangulString(stem);
        return '$knownStem${entry.value[lang]}';
      }
    }
    return _romanizeHangulString(token);
  }

  /// 한국어 주소 토큰을 국립국어원 로마자 표기법(예: 광진구 -> Gwangjin-gu, 구의동 -> Guui-dong, 6길 -> 6-gil)으로 변환
  static String _romanizeKoreanAddressToken(String token) {
    final numBanGil = RegExp(r'^(\d+)번길$').firstMatch(token);
    if (numBanGil != null) {
      return '${numBanGil.group(1)}-beongil';
    }
    final numGil = RegExp(r'^(\d+)길$').firstMatch(token);
    if (numGil != null) {
      return '${numGil.group(1)}-gil';
    }

    const suffixes = <String, String>{
      '특별자치시': '-si',
      '특별자치도': '-do',
      '특별시': '',
      '광역시': '',
      '번길': '-beongil',
      '대로': '-daero',
      '구': '-gu',
      '시': '-si',
      '군': '-gun',
      '동': '-dong',
      '읍': '-eup',
      '면': '-myeon',
      '리': '-ri',
      '가': '-ga',
      '로': '-ro',
      '길': '-gil',
    };

    for (final entry in suffixes.entries) {
      if (token.endsWith(entry.key) && token.length > entry.key.length) {
        final stem = token.substring(0, token.length - entry.key.length);
        final romStem = _romanizeHangulString(stem);
        return '$romStem${entry.value}';
      }
    }
    return _romanizeHangulString(token);
  }

  /// 국립국어원 국어의 로마자 표기법 (Revised Romanization of Korean)
  static String _romanizeHangulString(String input) {
    const choseong = [
      'g', 'kk', 'n', 'd', 'tt', 'r', 'm', 'b', 'pp', 's',
      'ss', '', 'j', 'jj', 'ch', 'k', 't', 'p', 'h',
    ];
    const jungseong = [
      'a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye', 'o', 'wa',
      'wae', 'oe', 'yo', 'u', 'wo', 'we', 'wi', 'yu', 'eu', 'ui', 'i',
    ];
    const jongseong = [
      '', 'k', 'k', 'ks', 'n', 'nj', 'nh', 't', 'l', 'lk',
      'lm', 'lb', 'ls', 'lt', 'lp', 'lh', 'm', 'p', 'ps', 't',
      't', 'ng', 't', 't', 'k', 't', 'p', 't',
    ];

    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      if (code >= 0xAC00 && code <= 0xD7A3) {
        final offset = code - 0xAC00;
        final c = offset ~/ (21 * 28);
        final v = (offset % (21 * 28)) ~/ 28;
        final f = offset % 28;
        sb.write(choseong[c]);
        sb.write(jungseong[v]);
        sb.write(jongseong[f]);
      } else {
        sb.write(input[i]);
      }
    }
    final raw = sb.toString();
    if (raw.isEmpty) return raw;
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }
}
