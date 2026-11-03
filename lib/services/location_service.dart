import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationOption {
  final String label;
  final String value;
  const LocationOption({required this.label, required this.value});
}

class LocationFetchResult {
  final bool success;
  final String? errorMessage;
  final String primaryAddress;
  final List<LocationOption> options;

  const LocationFetchResult({
    required this.success,
    this.errorMessage,
    this.primaryAddress = '',
    this.options = const [],
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// GPS 현재 위치를 요청하고 다양한 형태의 주소 옵션들을 생성합니다.
  Future<LocationFetchResult> fetchCurrentLocation() async {
    try {
      // 1. 위치 서비스(GPS) 활성화 확인
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationFetchResult(
          success: false,
          errorMessage: '기기의 위치 서비스(GPS)가 꺼져 있습니다. GPS를 켜주세요.',
        );
      }

      // 2. 권한 확인 및 요청
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationFetchResult(
            success: false,
            errorMessage: '위치 정보 접근 권한이 거부되었습니다.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationFetchResult(
          success: false,
          errorMessage: '위치 권한이 영구적으로 거부되어 있습니다. 앱 설정에서 권한을 허용해주세요.',
        );
      }

      // 3. 현재 위치 좌표 획득 (우선 빠른 캐시/마지막 위치 시도 후 정밀 측정)
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
        return const LocationFetchResult(
          success: false,
          errorMessage: '현재 GPS 위치 신호를 수신할 수 없습니다.',
        );
      }

      // 4. 역지오코딩 (위도/경도 -> 주소 텍스트)
      List<Placemark> placemarks = [];
      try {
        final geocoder = Geocoding(locale: const Locale('ko', 'KR'));
        placemarks = await geocoder.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      if (placemarks.isEmpty) {
        final fallback = '${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}';
        return LocationFetchResult(
          success: true,
          primaryAddress: fallback,
          options: [LocationOption(label: '위도/경도', value: fallback)],
        );
      }

      final place = placemarks.first;
      final options = _buildAddressOptions(place);
      final primary = options.isNotEmpty ? options.first.value : '대한민국';

      return LocationFetchResult(
        success: true,
        primaryAddress: primary,
        options: options,
      );
    } catch (e) {
      debugPrint('Location fetch error: $e');
      return LocationFetchResult(
        success: false,
        errorMessage: '위치 정보를 가져오는 중 오류가 발생했습니다: $e',
      );
    }
  }

  static const List<LocationOption> defaultOptions = [
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

  static String mergeAddressParts(List<String> parts) {
    final result = <String>[];
    for (final part in parts) {
      final tokens = part.trim().split(RegExp(r'\s+'));
      for (final token in tokens) {
        if (token.isNotEmpty && !result.contains(token)) {
          result.add(token);
        }
      }
    }
    return result.join(' ');
  }

  /// Placemark로부터 요청된 4가지 표준 GPS 주소 옵션을 생성:
  /// 1) 상세주소 (구/동/읍/면)
  /// 2) 국가 및 도시 + 상세주소
  /// 3) 더 상세한 주소 (도로명 + 번호 또는 지번/건물명)
  /// 4) 국가 및 도시 + 더 상세한 주소
  List<LocationOption> _buildAddressOptions(Placemark place) {
    final country = (place.country != null && place.country!.isNotEmpty) ? place.country! : '대한민국';
    final adminArea = place.administrativeArea ?? '';
    final subAdmin = place.subAdministrativeArea ?? '';
    final locality = place.locality ?? '';
    final subLocality = place.subLocality ?? '';
    final thoroughfare = place.thoroughfare ?? '';
    final subThoroughfare = place.subThoroughfare ?? '';
    final street = place.street ?? '';
    final name = place.name ?? '';

    // 1. 상세주소 (구/군 + 동/읍/면)
    final detailList = <String>[];
    if (subAdmin.isNotEmpty && !detailList.contains(subAdmin)) {
      detailList.add(subAdmin);
    } else if (locality.isNotEmpty && locality != adminArea && !detailList.contains(locality)) {
      detailList.add(locality);
    }
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
    final opt1Value = detailList.join(' ').trim();

    // 2. 국가 및 도시 + 상세주소 (예: 대한민국 서울특별시 광진구 구의동)
    final countryCityParts = <String>[country];
    if (adminArea.isNotEmpty && !countryCityParts.contains(adminArea)) {
      countryCityParts.add(adminArea);
    }
    final countryCityPrefix = countryCityParts.join(' ').trim();
    final opt2Value = mergeAddressParts([countryCityPrefix, opt1Value]);

    // 3. 더 상세한 주소 (도로명 + 번호 / 지번 / 건물명) - 중복 접두어 제거
    String opt3Value = '';
    if (thoroughfare.isNotEmpty) {
      if (subThoroughfare.isNotEmpty && !thoroughfare.contains(subThoroughfare)) {
        opt3Value = '$thoroughfare $subThoroughfare'.trim();
      } else if (name.isNotEmpty && !thoroughfare.contains(name) && name != subLocality) {
        opt3Value = '$thoroughfare $name'.trim();
      } else {
        opt3Value = thoroughfare;
      }
    }

    if (opt3Value.isEmpty && street.isNotEmpty) {
      String cleaned = street;
      if (country.isNotEmpty) cleaned = cleaned.replaceFirst(country, '').trim();
      if (adminArea.isNotEmpty) cleaned = cleaned.replaceFirst(adminArea, '').trim();
      if (subAdmin.isNotEmpty) cleaned = cleaned.replaceFirst(subAdmin, '').trim();
      if (locality.isNotEmpty && locality != subLocality) cleaned = cleaned.replaceFirst(locality, '').trim();
      opt3Value = cleaned.trim();
    }

    if (opt3Value.isEmpty && name.isNotEmpty && name != subLocality) {
      opt3Value = name;
    }

    if (opt3Value.isEmpty) {
      opt3Value = opt1Value.isNotEmpty ? opt1Value : '구의로 6길 24-8';
    }

    // 4. 국가 및 도시 + 더 상세한 주소 (예: 대한민국 서울특별시 구의로 6길 24-8)
    final opt4Value = mergeAddressParts([countryCityPrefix, opt3Value]);

    return [
      LocationOption(
        label: '상세주소',
        value: opt1Value.isNotEmpty ? opt1Value : '광진구 구의동',
      ),
      LocationOption(
        label: '국가 및 도시 + 상세주소',
        value: opt2Value.isNotEmpty ? opt2Value : '대한민국 서울특별시 광진구 구의동',
      ),
      LocationOption(
        label: '더 상세한 주소',
        value: opt3Value.isNotEmpty ? opt3Value : '구의로 6길 24-8',
      ),
      LocationOption(
        label: '국가 및 도시 + 더 상세한 주소',
        value: opt4Value.isNotEmpty ? opt4Value : '대한민국 서울특별시 구의로 6길 24-8',
      ),
    ];
  }
}
