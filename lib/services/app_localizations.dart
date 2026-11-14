import 'dart:ui' show Locale, PlatformDispatcher;
import 'package:intl/intl.dart';

/// 날짜 표시 순서 (국가/언어별 표준)
enum DateOrderType {
  ymd, // 년-월-일 (한국어, 중국어 간체, 일본어)
  mdy, // 월-일-년 (영어 - 미국/글로벌 표준)
  dmy, // 일-월-년 (스페인어, 독일어, 프랑스어)
}

/// 앱에서 지원하는 언어 정의
class AppLanguageInfo {
  final String code; // 'ko', 'en', 'zh', 'ja', 'es', 'de', 'fr'
  final String localeString; // 'ko_KR', 'en_US', 'zh_CN', 'ja_JP', 'es_ES', 'de_DE', 'fr_FR'
  final Locale locale;
  final String nativeName;
  final String englishName;
  final String flagEmoji;
  final DateOrderType dateOrder;
  final bool amPmBeforeTime;

  const AppLanguageInfo({
    required this.code,
    required this.localeString,
    required this.locale,
    required this.nativeName,
    required this.englishName,
    required this.flagEmoji,
    required this.dateOrder,
    required this.amPmBeforeTime,
  });
}

class AppLocalizations {
  /// 빌드 타임 언어 주입 지원:
  /// 예) flutter build appbundle --release --dart-define=APP_LANG=en
  /// 예) flutter run --dart-define=APP_LANG=ja
  static const String buildTimeAppLang = String.fromEnvironment(
    'APP_LANG',
    defaultValue: '',
  );
  static const String buildTimeDefaultLang = String.fromEnvironment(
    'DEFAULT_LANG',
    defaultValue: '',
  );
  static const String buildTimeForceLang = String.fromEnvironment(
    'FORCE_LANG',
    defaultValue: '',
  );

  /// 현재 내장 폰트(UI + 46종 스탬프 폰트 전체)로 100% 완벽 지원되어 즉시 배포 가능한 언어 목록
  static const List<AppLanguageInfo> supportedLanguages = [
    AppLanguageInfo(
      code: 'ko',
      localeString: 'ko_KR',
      locale: Locale('ko', 'KR'),
      nativeName: '한국어',
      englishName: 'Korean',
      flagEmoji: '🇰🇷',
      dateOrder: DateOrderType.ymd,
      amPmBeforeTime: true,
    ),
    AppLanguageInfo(
      code: 'en',
      localeString: 'en_US',
      locale: Locale('en', 'US'),
      nativeName: 'English',
      englishName: 'English',
      flagEmoji: '🇺🇸',
      dateOrder: DateOrderType.mdy,
      amPmBeforeTime: false,
    ),
  ];

  /// 번역 및 날짜·시간 포맷은 100% 구현 완료되었으나,
  /// 스탬프 전용 감성/손글씨 폰트 추가 후 활성화할 대기 언어 목록
  static const List<AppLanguageInfo> pendingFontLanguages = [
    AppLanguageInfo(
      code: 'zh',
      localeString: 'zh_CN',
      locale: Locale('zh', 'CN'),
      nativeName: '简体中文',
      englishName: 'Chinese (Simplified)',
      flagEmoji: '🇨🇳',
      dateOrder: DateOrderType.ymd,
      amPmBeforeTime: true,
    ),
    AppLanguageInfo(
      code: 'ja',
      localeString: 'ja_JP',
      locale: Locale('ja', 'JP'),
      nativeName: '日本語',
      englishName: 'Japanese',
      flagEmoji: '🇯🇵',
      dateOrder: DateOrderType.ymd,
      amPmBeforeTime: true,
    ),
    AppLanguageInfo(
      code: 'es',
      localeString: 'es_ES',
      locale: Locale('es', 'ES'),
      nativeName: 'Español',
      englishName: 'Spanish',
      flagEmoji: '🇪🇸',
      dateOrder: DateOrderType.dmy,
      amPmBeforeTime: false,
    ),
    AppLanguageInfo(
      code: 'de',
      localeString: 'de_DE',
      locale: Locale('de', 'DE'),
      nativeName: 'Deutsch',
      englishName: 'German',
      flagEmoji: '🇩🇪',
      dateOrder: DateOrderType.dmy,
      amPmBeforeTime: false,
    ),
    AppLanguageInfo(
      code: 'fr',
      localeString: 'fr_FR',
      locale: Locale('fr', 'FR'),
      nativeName: 'Français',
      englishName: 'French',
      flagEmoji: '🇫🇷',
      dateOrder: DateOrderType.dmy,
      amPmBeforeTime: false,
    ),
  ];

  static String _currentCode = 'ko';

  static String get languageCode => _currentCode;

  static AppLanguageInfo get currentInfo =>
      getInfo(_currentCode);

  static AppLanguageInfo getInfo(String code) {
    final normalized = normalizeLangCode(code, allowPending: true);
    for (final lang in supportedLanguages) {
      if (lang.code == normalized) return lang;
    }
    for (final lang in pendingFontLanguages) {
      if (lang.code == normalized) return lang;
    }
    return supportedLanguages.first;
  }

  static AppLanguageInfo infoFor(String code) => getInfo(code);

  static void setCurrentLanguageCode(String code) {
    _currentCode = normalizeLangCode(code);
  }

  static final RegExp _cjkOrKanaRegExp = RegExp(
    r'[\u3040-\u30FF\u31F0-\u31FF\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF]',
  );

  /// 텍스트에 일본어 가나(히라가나/가타카나) 또는 한자(CJK Unified Ideographs)가 포함되어 있는지 여부
  static bool containsCjkOrKana(String text) {
    if (text.isEmpty) return false;
    return _cjkOrKanaRegExp.hasMatch(text);
  }

  /// 현재 앱 언어에 맞는 기본 UI 폰트 패밀리
  /// - 한국어(ko): NanumSquareB
  /// - 일본어(ja), 중국어(zh): null (OS 네이티브 CJK 시스템 폰트를 최우선 사용하여 한자/가나 누락 및 폰트 섞임 방지)
  /// - 영어/스페인어/독일어/프랑스어: Pretendard (유럽 악센트 문자 완벽 지원)
  static String? get uiFontFamily {
    switch (_currentCode) {
      case 'ko':
        return 'NanumSquareB';
      case 'ja':
      case 'zh':
        return null;
      default:
        return 'Pretendard';
    }
  }

  /// 다국어 UI 및 스탬프 공통 폰트 폴백 체인
  static List<String> get fontFallbackChain {
    switch (_currentCode) {
      case 'ja':
        return const [
          'Hiragino Sans',
          'Hiragino Kaku Gothic ProN',
          'Noto Sans CJK JP',
          'Noto Sans JP',
          'Pretendard',
          'sans-serif',
        ];
      case 'zh':
        return const [
          'PingFang SC',
          'Heiti SC',
          'Noto Sans CJK SC',
          'Noto Sans SC',
          'Pretendard',
          'sans-serif',
        ];
      default:
        return const [
          'Pretendard',
          'Apple SD Gothic Neo',
          'Noto Sans CJK KR',
          'Noto Sans CJK JP',
          'Noto Sans CJK SC',
          'Hiragino Sans',
          'PingFang SC',
          'sans-serif',
        ];
    }
  }

  /// 스탬프/UI에서 특정 텍스트를 그릴 때 사용할 폰트 패밀리 결정.
  /// - 텍스트에 일본어 가나 또는 한자(年, 月, 日, 午後, 曜日, 문구 등)가 포함된 경우,
  ///   한국어/영문 전용 장식 폰트(NanumBarunpen, Cafe24, Oswald 등)는 일본 신자체/중국 간체자를
  ///   전부 포함하지 못해 글자마다 폰트가 섞이거나 누락될 수 있으므로 OS 시스템 CJK 폰트(null)를 사용합니다.
  /// - 숫자/영문/한글만 있는 경우(예: "12:34", "2026.11.14", "AM", "SATURDAY")에는
  ///   스탬프 고유의 장식 폰트(requestedFamily)를 그대로 유지합니다.
  static String? resolveFontFamily(String? requestedFamily, [String? text]) {
    if (text != null && text.isNotEmpty && containsCjkOrKana(text)) {
      return null;
    }
    if ((_currentCode == 'ja' || _currentCode == 'zh') &&
        (requestedFamily == 'NanumSquareB' || requestedFamily == 'Pretendard')) {
      return null;
    }
    return requestedFamily;
  }

  static String normalizeLanguageCode(
    String? raw, {
    String fallback = 'en',
    bool allowPending = false,
  }) =>
      normalizeLangCode(raw, fallback: fallback, allowPending: allowPending);

  /// 입력된 언어 코드('en_US', 'zh-Hans', 'jp', 'kr' 등)를 표준 코드로 정규화.
  /// - 기본(`allowPending: false`): 현재 폰트가 100% 완비된 `supportedLanguages`('ko', 'en')만 허용하며,
  ///   그 외 언어는 글로벌 기본값 `fallback`('en')으로 처리합니다.
  /// - `allowPending: true` (예: `--dart-define=APP_LANG=ja` 테스트 빌드 시): 대기 언어('zh','ja','es','de','fr')도 허용합니다.
  static String normalizeLangCode(
    String? raw, {
    String fallback = 'en',
    bool allowPending = false,
  }) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    final lower = raw.trim().toLowerCase().replaceAll('-', '_');
    String? matched;
    if (lower == 'kr' || lower.startsWith('ko')) {
      matched = 'ko';
    } else if (lower.startsWith('en')) {
      matched = 'en';
    } else if (lower == 'cn' || lower.startsWith('zh')) {
      matched = 'zh';
    } else if (lower == 'jp' || lower.startsWith('ja')) {
      matched = 'ja';
    } else if (lower.startsWith('es')) {
      matched = 'es';
    } else if (lower.startsWith('de')) {
      matched = 'de';
    } else if (lower.startsWith('fr')) {
      matched = 'fr';
    }
    if (matched == null) return fallback;
    if (allowPending) return matched;
    final isSupported = supportedLanguages.any((l) => l.code == matched);
    return isSupported ? matched : fallback;
  }

  /// 기기 시스템 로케일로부터 지원 언어 코드 감지 (한국어 OS는 'ko', 그 외 전 세계 국가는 100% 폰트 지원되는 'en')
  static String detectDeviceLanguageCode() {
    try {
      final deviceLocale = PlatformDispatcher.instance.locale;
      return normalizeLangCode(deviceLocale.languageCode, fallback: 'en');
    } catch (_) {
      return 'ko';
    }
  }

  /// 빌드 타임 `--dart-define`으로 전달된 언어 코드 확인 (없으면 null)
  static String? getBuildTimeLanguageOverride() {
    if (buildTimeForceLang.trim().isNotEmpty) {
      return normalizeLangCode(buildTimeForceLang, allowPending: true);
    }
    if (buildTimeAppLang.trim().isNotEmpty) {
      return normalizeLangCode(buildTimeAppLang, allowPending: true);
    }
    if (buildTimeDefaultLang.trim().isNotEmpty) {
      return normalizeLangCode(buildTimeDefaultLang, allowPending: true);
    }
    return null;
  }
}

/// 앱 전역 다국어 문자열 사전 (7개 언어 완벽 대응: ko, en, zh, ja, es, de, fr)
class AppStrings {
  static String get lang => AppLocalizations.languageCode;

  static String _pick({
    required String ko,
    required String en,
    required String zh,
    required String ja,
    required String es,
    required String de,
    required String fr,
  }) {
    switch (lang) {
      case 'en':
        return en;
      case 'zh':
        return zh;
      case 'ja':
        return ja;
      case 'es':
        return es;
      case 'de':
        return de;
      case 'fr':
        return fr;
      case 'ko':
      default:
        return ko;
    }
  }

  // ─── 기본 폴더명 표시 (내부 키 '전체', '일상'은 유지하면서 화면 표시만 다국어화) ───
  static String displayAlbumName(String rawName) {
    if (rawName == '전체') return albumAll;
    if (rawName == '일상') return albumDaily;
    return rawName;
  }

  static String get albumAll => _pick(
        ko: '전체',
        en: 'All',
        zh: '全部',
        ja: 'すべて',
        es: 'Todo',
        de: 'Alle',
        fr: 'Tout',
      );

  static String get albumDaily => _pick(
        ko: '일상',
        en: 'Daily',
        zh: '日常',
        ja: '日常',
        es: 'Diario',
        de: 'Alltag',
        fr: 'Quotidien',
      );

  // ─── 카메라 및 촬영/리뷰 화면 ───
  static String get modePhoto => _pick(
        ko: '사진',
        en: 'Photo',
        zh: '照片',
        ja: '写真',
        es: 'Foto',
        de: 'Foto',
        fr: 'Photo',
      );

  static String get modeVideo => _pick(
        ko: '동영상',
        en: 'Video',
        zh: '视频',
        ja: '動画',
        es: 'Video',
        de: 'Video',
        fr: 'Vidéo',
      );

  static String get stampManageTwoLine => _pick(
        ko: '스탬프\n관리',
        en: 'Manage\nStamps',
        zh: '印章\n管理',
        ja: 'スタンプ\n管理',
        es: 'Gestionar\nsellos',
        de: 'Stempel\nverwalten',
        fr: 'Gérer\ntampons',
      );

  static String get photoSavedSnackbar => _pick(
        ko: '사진이 저장되었습니다!',
        en: 'Photo saved!',
        zh: '照片已保存！',
        ja: '写真が保存されました！',
        es: '¡Foto guardada!',
        de: 'Foto gespeichert!',
        fr: 'Photo enregistrée !',
      );

  static String get videoSavedSnackbar => _pick(
        ko: '동영상이 저장되었습니다!',
        en: 'Video saved!',
        zh: '视频已保存！',
        ja: '動画が保存されました！',
        es: '¡Video guardado!',
        de: 'Video gespeichert!',
        fr: 'Vidéo enregistrée !',
      );

  static String videoRecordStartError(Object e) => _pick(
        ko: '동영상 촬영 시작 실패: $e',
        en: 'Failed to start video recording: $e',
        zh: '开始录制视频失败: $e',
        ja: '動画撮影の開始に失敗しました: $e',
        es: 'Error al iniciar la grabación de video: $e',
        de: 'Videoaufnahme konnte nicht gestartet werden: $e',
        fr: 'Échec du démarrage de l\'enregistrement vidéo : $e',
      );

  static String videoSaveError(Object e) => _pick(
        ko: '영상 저장 실패: $e',
        en: 'Failed to save video: $e',
        zh: '保存视频失败: $e',
        ja: '動画の保存に失敗しました: $e',
        es: 'Error al guardar el video: $e',
        de: 'Fehler beim Speichern des Videos: $e',
        fr: 'Échec de l\'enregistrement de la vidéo : $e',
      );

  static String photoSaveError(Object e) => _pick(
        ko: '저장 중 오류가 발생했습니다: $e',
        en: 'An error occurred while saving: $e',
        zh: '保存时出错: $e',
        ja: '保存中にエラーが発生しました: $e',
        es: 'Ocurrió un error al guardar: $e',
        de: 'Beim Speichern ist ein Fehler aufgetreten: $e',
        fr: 'Une erreur est survenue lors de l\'enregistrement : $e',
      );

  // ─── 사진 고르기 (갤러리 피커) ───
  static String get galleryPickerTitle => _pick(
        ko: '사진 고르기',
        en: 'Select Photo',
        zh: '选择照片',
        ja: '写真を選択',
        es: 'Seleccionar foto',
        de: 'Foto auswählen',
        fr: 'Choisir une photo',
      );

  static String get recentAlbumName => _pick(
        ko: '최근 항목',
        en: 'Recents',
        zh: '最近项目',
        ja: '最近の項目',
        es: 'Recientes',
        de: 'Zuletzt',
        fr: 'Récents',
      );

  static String get noPhotosInGallery => _pick(
        ko: '사진이 없습니다',
        en: 'No photos found',
        zh: '没有照片',
        ja: '写真がありません',
        es: 'No hay fotos',
        de: 'Keine Fotos vorhanden',
        fr: 'Aucune photo',
      );

  static String get bannerPermissionDenied => _pick(
        ko: '사진 접근 권한이 필요합니다 · 설정에서 모든 사진 허용하기',
        en: 'Photo access required · Allow full access in Settings',
        zh: '需要照片访问权限 · 在设置中允许访问所有照片',
        ja: '写真へのアクセス権限が必要です · 設定ですべての写真を許可',
        es: 'Se requiere acceso a fotos · Permitir todas en Ajustes',
        de: 'Fotozugriff erforderlich · Alle Fotos in Einstellungen erlauben',
        fr: 'Accès aux photos requis · Autoriser tout dans les Réglages',
      );

  static String get bannerPermissionLimited => _pick(
        ko: '일부 사진만 허용됨 · 설정에서 \'항상 모두 허용\'으로 변경하기',
        en: 'Limited photo access · Change to \'Allow All\' in Settings',
        zh: '仅允许部分照片 · 在设置中更改为“允许完全访问”',
        ja: '一部の写真のみ許可 · 設定で「すべて許可」に変更',
        es: 'Acceso limitado · Cambiar a \'Permitir todas\' en Ajustes',
        de: 'Eingeschränkter Zugriff · In Einstellungen auf \'Alle erlauben\' ändern',
        fr: 'Accès limité · Passer à « Tout autoriser » dans les Réglages',
      );

  static String get permTitleLimited => _pick(
        ko: '모든 사진 접근 권한이 필요합니다',
        en: 'Full Photo Access Required',
        zh: '需要所有照片的访问权限',
        ja: 'すべての写真へのアクセス権限が必要です',
        es: 'Se requiere acceso a todas las fotos',
        de: 'Vollständiger Fotozugriff erforderlich',
        fr: 'Accès complet aux photos requis',
      );

  static String get permTitleDenied => _pick(
        ko: '사진 접근 권한이 필요합니다',
        en: 'Photo Access Required',
        zh: '需要照片访问权限',
        ja: '写真へのアクセス権限が必要です',
        es: 'Se requiere acceso a las fotos',
        de: 'Fotozugriff erforderlich',
        fr: 'Accès aux photos requis',
      );

  static String get permDescLimited => _pick(
        ko: '현재 일부 사진만 선택되어 있어 Log 앨범만 표시되고 있습니다.\n\n카메라, 다운로드, 스크린샷 등 기기의 모든 앨범을 확인하시려면 사진 접근 권한을 \'모두 허용\'으로 변경해주세요.',
        en: 'Only selected photos are currently accessible.\n\nTo browse all albums on your device (Camera, Downloads, Screenshots, etc.), please change photo permission to \'Allow All\'.',
        zh: '当前仅选择了部分照片。\n\n若要查看设备上的所有相册（相机、下载、截图等），请将照片访问权限更改为“允许完全访问”。',
        ja: '現在一部の写真のみ選択されているため、一部のアルバムのみ表示されています。\n\nカメラやダウンロード、スクリーンショットなどすべてのアルバムを表示するには、権限を「すべて許可」に変更してください。',
        es: 'Actualmente solo se permite el acceso a algunas fotos.\n\nPara ver todos los álbumes de tu dispositivo, cambia el permiso de fotos a \'Permitir todas\'.',
        de: 'Derzeit sind nur ausgewählte Fotos freigegeben.\n\nUm alle Alben auf Ihrem Gerät zu sehen, ändern Sie die Berechtigung bitte auf \'Alle erlauben\'.',
        fr: 'Seules certaines photos sont actuellement accessibles.\n\nPour afficher tous les albums de votre appareil, veuillez modifier l\'autorisation sur « Tout autoriser ».',
      );

  static String get permDescDenied => _pick(
        ko: '기기에 저장된 모든 사진 앨범을 불러오고 타임스탬프를 적용하려면 사진 접근 권한이 필요합니다.',
        en: 'Photo library access is required to load your albums and apply timestamps to your photos.',
        zh: '需要照片访问权限才能加载设备上的相册并添加时间戳。',
        ja: '端末の写真アルバムを読み込んでタイムスタンプを適用するには、写真へのアクセス権限が必要です。',
        es: 'Se requiere acceso a la galería para cargar tus álbumes y aplicar marcas de tiempo.',
        de: 'Der Zugriff auf die Fotomediathek ist erforderlich, um Ihre Alben zu laden und Zeitstempel anzuwenden.',
        fr: 'L\'accès à la photothèque est requis pour charger vos albums et appliquer un horodatage.',
      );

  static String get permBtnLimited => _pick(
        ko: '설정에서 \'모두 허용\'으로 변경',
        en: 'Change to \'Allow All\' in Settings',
        zh: '在设置中更改为“允许完全访问”',
        ja: '設定で「すべて許可」に変更',
        es: 'Cambiar a \'Permitir todas\' en Ajustes',
        de: 'In Einstellungen auf \'Alle erlauben\' ändern',
        fr: 'Passer à « Tout autoriser » dans les Réglages',
      );

  static String get permBtnDenied => _pick(
        ko: '권한 설정하러 가기',
        en: 'Open Settings',
        zh: '前往权限设置',
        ja: '権限設定を開く',
        es: 'Ir a Ajustes de permisos',
        de: 'Berechtigungseinstellungen öffnen',
        fr: 'Ouvrir les réglages',
      );

  static String get permGuideFooter => _pick(
        ko: '설정 > 권한 > 사진 및 동영상 > \'모두 허용\' 선택 후 앱으로 돌아오시면 자동으로 모든 앨범이 나타납니다.',
        en: 'Settings > Permissions > Photos & Videos > Select \'Allow All\', then return to the app.',
        zh: '设置 > 权限 > 照片和视频 > 选择“允许完全访问”，返回应用后将自动显示所有相册。',
        ja: '設定 > 権限 > 写真と動画 > 「すべて許可」を選択してアプリに戻ると、自動的にすべてのアルバムが表示されます。',
        es: 'Ajustes > Permisos > Fotos y videos > Selecciona \'Permitir todas\' y vuelve a la aplicación.',
        de: 'Einstellungen > Berechtigungen > Fotos & Videos > \'Alle erlauben\' wählen und zur App zurückkehren.',
        fr: 'Réglages > Autorisations > Photos et vidéos > Sélectionnez « Tout autoriser » puis revenez à l\'application.',
      );

  // ─── 캘린더 & 앨범 화면 ───
  static String get tooltipCalendarView => _pick(
        ko: '달력 보기',
        en: 'Calendar View',
        zh: '日历视图',
        ja: 'カレンダー表示',
        es: 'Vista de calendario',
        de: 'Kalenderansicht',
        fr: 'Vue calendrier',
      );

  static String get tooltipGridView => _pick(
        ko: '모아보기',
        en: 'Grid View',
        zh: '网格视图',
        ja: '一覧表示',
        es: 'Vista de cuadrícula',
        de: 'Rasteransicht',
        fr: 'Vue grille',
      );

  static String get btnRecord => _pick(
        ko: '기록',
        en: 'Log',
        zh: '记录',
        ja: '記録',
        es: 'Capturar',
        de: 'Aufnahme',
        fr: 'Noter',
      );

  static List<String> get calendarWeekdayHeaders => TimestampLocaleFormatter.calendarSunToSatWeekdays;

  static String get emptyTodayTitle => _pick(
        ko: '오늘의 기록이 아직 없어요 📷',
        en: 'No logs for today yet 📷',
        zh: '今天还没有记录哦 📷',
        ja: '今日の記録はまだありません 📷',
        es: 'Aún no hay registros de hoy 📷',
        de: 'Noch keine Einträge für heute 📷',
        fr: 'Aucun souvenir pour aujourd\'hui 📷',
      );

  static String get emptyFutureTitle => _pick(
        ko: '아직 다가오지 않은 날이에요 ⏳',
        en: 'This day hasn\'t arrived yet ⏳',
        zh: '这一天还没有到来 ⏳',
        ja: 'まだ来ていない日です ⏳',
        es: 'Este día aún no ha llegado ⏳',
        de: 'Dieser Tag liegt in der Zukunft ⏳',
        fr: 'Ce jour n\'est pas encore arrivé ⏳',
      );

  static String get emptyPastTitle => _pick(
        ko: '이 날은 기록이 없어요 📷',
        en: 'No logs on this day 📷',
        zh: '这一天没有记录 📷',
        ja: 'この日の記録はありません 📷',
        es: 'No hay registros en este día 📷',
        de: 'Keine Einträge an diesem Tag 📷',
        fr: 'Aucun souvenir ce jour-là 📷',
      );

  static String get emptyTodaySubtitle => _pick(
        ko: '상단 "기록" 버튼을 눌러 지금 순간을 남겨보세요',
        en: 'Tap the "Log" button above to capture this moment',
        zh: '点击上方的“记录”按钮，留下此刻的瞬间吧',
        ja: '右上の「記録」ボタンを押して、今の瞬間を残しましょう',
        es: 'Toca el botón "Capturar" arriba para guardar este momento',
        de: 'Tippe oben auf „Aufnahme“, um diesen Moment festzuhalten',
        fr: 'Appuyez sur « Noter » en haut pour capturer cet instant',
      );

  static String get emptyGridTitle => _pick(
        ko: '아직 기록이 없어요',
        en: 'No logs yet',
        zh: '还没有记录',
        ja: 'まだ記録がありません',
        es: 'Aún no hay registros',
        de: 'Noch keine Einträge',
        fr: 'Aucun souvenir pour le moment',
      );

  static String get emptyGridSubtitle => _pick(
        ko: '상단 "기록" 버튼을 눌러 첫 기록을 남겨보세요',
        en: 'Tap the "Log" button above to create your first log',
        zh: '点击上方的“记录”按钮，留下第一条记录吧',
        ja: '右上の「記録」ボタンを押して、最初の記録を残しましょう',
        es: 'Toca el botón "Capturar" arriba para crear tu primer registro',
        de: 'Tippe oben auf „Aufnahme“, um deinen ersten Eintrag zu erstellen',
        fr: 'Appuyez sur « Noter » en haut pour créer votre premier souvenir',
      );

  static String get selectFolderTitle => _pick(
        ko: '폴더 선택',
        en: 'Select Folder',
        zh: '选择文件夹',
        ja: 'フォルダを選択',
        es: 'Seleccionar carpeta',
        de: 'Ordner auswählen',
        fr: 'Choisir un dossier',
      );

  static String get createNewFolder => _pick(
        ko: '새 폴더 만들기',
        en: 'Create New Folder',
        zh: '新建文件夹',
        ja: '新しいフォルダを作成',
        es: 'Crear nueva carpeta',
        de: 'Neuen Ordner erstellen',
        fr: 'Nouveau dossier',
      );

  static String get createFolderSubtitle => _pick(
        ko: '사진을 분류할 새 폴더의 이름과 색상을 지정하세요',
        en: 'Set a name and color theme for your new folder',
        zh: '为分类照片的新文件夹设置名称和颜色',
        ja: '写真を分類する新しいフォルダの名前と色を指定してください',
        es: 'Elige un nombre y color para tu nueva carpeta',
        de: 'Name und Farbe für den neuen Ordner festlegen',
        fr: 'Choisissez un nom et une couleur pour votre nouveau dossier',
      );

  static String get folderNameHint => _pick(
        ko: '폴더 이름 입력 (최대 15자)',
        en: 'Folder name (max 15 chars)',
        zh: '输入文件夹名称（最多15个字符）',
        ja: 'フォルダ名を入力（最大15文字）',
        es: 'Nombre de carpeta (máx. 15 caracteres)',
        de: 'Ordnername (max. 15 Zeichen)',
        fr: 'Nom du dossier (max. 15 caractères)',
      );

  static String get folderColorTheme => _pick(
        ko: '폴더 색상 테마',
        en: 'Folder Color Theme',
        zh: '文件夹颜色主题',
        ja: 'フォルダのカラーテーマ',
        es: 'Color de la carpeta',
        de: 'Ordnerfarbe',
        fr: 'Couleur du dossier',
      );

  static String get customColorPick => _pick(
        ko: '직접 선택',
        en: 'Custom',
        zh: '自定义',
        ja: 'カスタム',
        es: 'Personalizar',
        de: 'Anpassen',
        fr: 'Personnaliser',
      );

  static String get selectColorTitle => _pick(
        ko: '색상 선택',
        en: 'Select Color',
        zh: '选择颜色',
        ja: '色を選択',
        es: 'Seleccionar color',
        de: 'Farbe auswählen',
        fr: 'Choisir une couleur',
      );

  static String get selectAccentColorTitle => _pick(
        ko: '포인트 색상 선택',
        en: 'Select Accent Color',
        zh: '选择强调色',
        ja: 'アクセントカラーを選択',
        es: 'Seleccionar color de acento',
        de: 'Akzentfarbe auswählen',
        fr: 'Choisir la couleur d\'accentuation',
      );

  static String get editFolderTitle => _pick(
        ko: '폴더 편집',
        en: 'Edit Folder',
        zh: '编辑文件夹',
        ja: 'フォルダを編集',
        es: 'Editar carpeta',
        de: 'Ordner bearbeiten',
        fr: 'Modifier le dossier',
      );

  static String get editDefaultFolderSubtitle => _pick(
        ko: '기본 앨범의 색상 테마를 변경합니다',
        en: 'Change the color theme of the default folder',
        zh: '更改默认相册的颜色主题',
        ja: 'デフォルトアルバムのカラーテーマを変更します',
        es: 'Cambia el color del álbum predeterminado',
        de: 'Farbthema des Standardordners ändern',
        fr: 'Modifier la couleur du dossier par défaut',
      );

  static String get editCustomFolderSubtitle => _pick(
        ko: '폴더의 이름과 색상 테마를 변경합니다',
        en: 'Change the folder name and color theme',
        zh: '更改文件夹的名称和颜色主题',
        ja: 'フォルダの名前とカラーテーマを変更します',
        es: 'Cambia el nombre y color de la carpeta',
        de: 'Ordnername und Farbthema ändern',
        fr: 'Modifier le nom et la couleur du dossier',
      );

  static String get defaultFolderRenameDisabled => _pick(
        ko: '기본 앨범의 이름은 변경할 수 없습니다.',
        en: 'The default folder name cannot be changed.',
        zh: '默认相册的名称无法更改。',
        ja: 'デフォルトアルバムの名前は変更できません。',
        es: 'El nombre del álbum predeterminado no se puede cambiar.',
        de: 'Der Name des Standardordners kann nicht geändert werden.',
        fr: 'Le nom du dossier par défaut ne peut pas être modifié.',
      );

  static String get deleteFolderTitle => _pick(
        ko: '폴더 삭제',
        en: 'Delete Folder',
        zh: '删除文件夹',
        ja: 'フォルダを削除',
        es: 'Eliminar carpeta',
        de: 'Ordner löschen',
        fr: 'Supprimer le dossier',
      );

  static String deleteFolderConfirmMessage(String name) => _pick(
        ko: '\'${displayAlbumName(name)}\' 폴더를 삭제하시겠습니까?\n사진은 기기 앨범에 안전하게 유지되며 폴더만 삭제됩니다.',
        en: 'Delete folder \'${displayAlbumName(name)}\'?\nYour photos remain safely in your device gallery.',
        zh: '确定要删除“${displayAlbumName(name)}”文件夹吗？\n照片仍安全保存在设备相册中，仅删除该文件夹。',
        ja: '「${displayAlbumName(name)}」フォルダを削除しますか？\n写真は端末のアルバムに安全に残ります。',
        es: '¿Eliminar la carpeta \'${displayAlbumName(name)}\'?\nLas fotos se mantendrán seguras en la galería de tu dispositivo.',
        de: 'Ordner \'${displayAlbumName(name)}\' löschen?\nFotos bleiben sicher in Ihrer Gerätegalerie erhalten.',
        fr: 'Supprimer le dossier « ${displayAlbumName(name)} » ?\nVos photos restent conservées dans la galerie de votre appareil.',
      );

  static String folderDeletedSnackbar(String name) => _pick(
        ko: '\'${displayAlbumName(name)}\' 폴더가 삭제되었습니다.',
        en: 'Folder \'${displayAlbumName(name)}\' deleted.',
        zh: '已删除“${displayAlbumName(name)}”文件夹。',
        ja: '「${displayAlbumName(name)}」フォルダを削除しました。',
        es: 'Carpeta \'${displayAlbumName(name)}\' eliminada.',
        de: 'Ordner \'${displayAlbumName(name)}\' wurde gelöscht.',
        fr: 'Dossier « ${displayAlbumName(name)} » supprimé.',
      );

  static String get folderAlreadyExistsSnackbar => _pick(
        ko: '이미 존재하는 폴더 이름입니다.',
        en: 'A folder with this name already exists.',
        zh: '该文件夹名称已存在。',
        ja: 'すでに存在するフォルダ名です。',
        es: 'Ya existe una carpeta con este nombre.',
        de: 'Ein Ordner mit diesem Namen existiert bereits.',
        fr: 'Un dossier portant ce nom existe déjà.',
      );

  static String get folderUpdateFailedSnackbar => _pick(
        ko: '폴더 수정에 실패했습니다.',
        en: 'Failed to update folder.',
        zh: '修改文件夹失败。',
        ja: 'フォルダの更新に失敗しました。',
        es: 'Error al actualizar la carpeta.',
        de: 'Ordner konnte nicht aktualisiert werden.',
        fr: 'Échec de la modification du dossier.',
      );

  // ─── 공통 버튼 ───
  static String get cancel => _pick(
        ko: '취소',
        en: 'Cancel',
        zh: '取消',
        ja: 'キャンセル',
        es: 'Cancelar',
        de: 'Abbrechen',
        fr: 'Annuler',
      );

  static String get delete => _pick(
        ko: '삭제',
        en: 'Delete',
        zh: '删除',
        ja: '削除',
        es: 'Eliminar',
        de: 'Löschen',
        fr: 'Supprimer',
      );

  static String get save => _pick(
        ko: '저장',
        en: 'Save',
        zh: '保存',
        ja: '保存',
        es: 'Guardar',
        de: 'Speichern',
        fr: 'Enregistrer',
      );

  static String get saveAction => _pick(
        ko: '저장하기',
        en: 'Save',
        zh: '保存',
        ja: '保存する',
        es: 'Guardar',
        de: 'Speichern',
        fr: 'Enregistrer',
      );

  static String get applyAction => _pick(
        ko: '적용하기',
        en: 'Apply',
        zh: '应用',
        ja: '適用する',
        es: 'Aplicar',
        de: 'Anwenden',
        fr: 'Appliquer',
      );

  static String get confirm => _pick(
        ko: '확인',
        en: 'OK',
        zh: '确定',
        ja: '確認',
        es: 'Aceptar',
        de: 'OK',
        fr: 'OK',
      );

  static String get reset => _pick(
        ko: '초기화',
        en: 'Reset',
        zh: '重置',
        ja: 'リセット',
        es: 'Restablecer',
        de: 'Zurücksetzen',
        fr: 'Réinitialiser',
      );

  // ─── 사진/영상 상세 화면 (PhotoDetailScreen) ───
  static String get defaultShareText => _pick(
        ko: 'Just Log it - 나의 기록을 공유합니다.',
        en: 'Just Log it - Sharing my moment.',
        zh: 'Just Log it - 分享我的记录。',
        ja: 'Just Log it - 私の記録をシェアします。',
        es: 'Just Log it - Compartiendo mi momento.',
        de: 'Just Log it - Ich teile meinen Moment.',
        fr: 'Just Log it - Je partage mon souvenir.',
      );

  static String shareError(Object e) => _pick(
        ko: '공유 중 오류가 발생했습니다: $e',
        en: 'Error sharing media: $e',
        zh: '分享时出错: $e',
        ja: '共有中にエラーが発生しました: $e',
        es: 'Error al compartir: $e',
        de: 'Fehler beim Teilen: $e',
        fr: 'Erreur lors du partage : $e',
      );

  static String deleteError(Object e) => _pick(
        ko: '삭제 중 오류가 발생했습니다: $e',
        en: 'Error deleting media: $e',
        zh: '删除时出错: $e',
        ja: '削除中にエラーが発生しました: $e',
        es: 'Error al eliminar: $e',
        de: 'Fehler beim Löschen: $e',
        fr: 'Erreur lors de la suppression : $e',
      );

  static String get addMemoPlaceholder => _pick(
        ko: '메모 추가...',
        en: 'Add a note...',
        zh: '添加备注...',
        ja: 'メモを追加...',
        es: 'Añadir nota...',
        de: 'Notiz hinzufügen...',
        fr: 'Ajouter une note...',
      );

  static String get deleteMemoTitle => _pick(
        ko: '메모를 삭제할까요?',
        en: 'Delete this note?',
        zh: '要删除这条备注吗？',
        ja: 'メモを削除しますか？',
        es: '¿Eliminar esta nota?',
        de: 'Diese Notiz löschen?',
        fr: 'Supprimer cette note ?',
      );

  static String get deleteMemoWarning => _pick(
        ko: '삭제된 메모는 복구할 수 없어요',
        en: 'Deleted notes cannot be recovered.',
        zh: '删除后的备注无法恢复',
        ja: '削除されたメモは元に戻せません',
        es: 'Las notas eliminadas no se pueden recuperar.',
        de: 'Gelöschte Notizen können nicht wiederhergestellt werden.',
        fr: 'Les notes supprimées ne peuvent pas être récupérées.',
      );

  static String get memoDeletedSnackbar => _pick(
        ko: '메모가 삭제되었습니다.',
        en: 'Note deleted.',
        zh: '备注已删除。',
        ja: 'メモを削除しました。',
        es: 'Nota eliminada.',
        de: 'Notiz gelöscht.',
        fr: 'Note supprimée.',
      );

  static String get photoMemoTitle => _pick(
        ko: '사진 메모',
        en: 'Photo Note',
        zh: '照片备注',
        ja: '写真メモ',
        es: 'Nota de la foto',
        de: 'Fotonotiz',
        fr: 'Note photo',
      );

  static String get photoMemoSubtitle => _pick(
        ko: '오늘의 사진에 대한 생각이나 메모를 남겨보세요',
        en: 'Write your thoughts or notes about this moment',
        zh: '写下关于这张照片的想法或记录吧',
        ja: '今日の写真についての想いやメモを残しましょう',
        es: 'Escribe tus pensamientos o notas sobre esta foto',
        de: 'Halte deine Gedanken oder Notizen zu diesem Foto fest',
        fr: 'Écrivez vos pensées ou notes sur cette photo',
      );

  static String get photoMemoHint => _pick(
        ko: '이 사진에 대한 생각을 자유롭게 적어보세요.',
        en: 'Write freely about this photo...',
        zh: '自由写下你对这张照片的想法...',
        ja: 'この写真についての想いを自由に書いてみてください。',
        es: 'Escribe libremente sobre esta foto...',
        de: 'Schreibe deine Gedanken zu diesem Foto...',
        fr: 'Écrivez librement à propos de cette photo...',
      );

  static List<String> get memoQuickTags {
    switch (lang) {
      case 'en':
        return const [
          '☀️ Sunny day',
          '☕ Daily life',
          '🌿 Relaxing',
          '✨ Special moment',
          '🏃 Workout',
          '🍽️ Delicious meal',
          '🌅 Scenery',
        ];
      case 'zh':
        return const [
          '☀️ 晴朗的一天',
          '☕ 日常',
          '🌿 治愈时刻',
          '✨ 特别瞬间',
          '🏃 运动打卡',
          '🍽️ 美食记录',
          '🌅 风景',
        ];
      case 'ja':
        return const [
          '☀️ 晴れの日',
          '☕ 日常',
          '🌿 癒やし',
          '✨ 特別な瞬間',
          '🏃 ワークアウト',
          '🍽️ 美味しい一日',
          '🌅 風景',
        ];
      case 'es':
        return const [
          '☀️ Día soleado',
          '☕ Diario',
          '🌿 Relax',
          '✨ Momento especial',
          '🏃 Entrenamiento',
          '🍽️ Comida deliciosa',
          '🌅 Paisaje',
        ];
      case 'de':
        return const [
          '☀️ Sonniger Tag',
          '☕ Alltag',
          '🌿 Entspannung',
          '✨ Besonderer Moment',
          '🏃 Workout',
          '🍽️ Leckeres Essen',
          '🌅 Landschaft',
        ];
      case 'fr':
        return const [
          '☀️ Jour ensoleillé',
          '☕ Quotidien',
          '🌿 Détente',
          '✨ Moment spécial',
          '🏃 Sport',
          '🍽️ Bon repas',
          '🌅 Paysage',
        ];
      case 'ko':
      default:
        return const [
          '☀️ 맑은 날',
          '☕ 일상',
          '🌿 힐링',
          '✨ 특별한 순간',
          '🏃 운동',
          '🍽️ 맛있는 하루',
          '🌅 풍경',
        ];
    }
  }

  static String deleteMediaConfirmTitle(bool isVideo) => isVideo
      ? _pick(
          ko: '영상을 삭제할까요?',
          en: 'Delete this video?',
          zh: '要删除这段视频吗？',
          ja: '動画を削除しますか？',
          es: '¿Eliminar este video?',
          de: 'Dieses Video löschen?',
          fr: 'Supprimer cette vidéo ?',
        )
      : _pick(
          ko: '사진을 삭제할까요?',
          en: 'Delete this photo?',
          zh: '要删除这张照片吗？',
          ja: '写真を削除しますか？',
          es: '¿Eliminar esta foto?',
          de: 'Dieses Foto löschen?',
          fr: 'Supprimer cette photo ?',
        );

  static String deleteMediaWarning(bool isVideo) => isVideo
      ? _pick(
          ko: '삭제된 영상은 보관함에서 완전히 삭제되며 복구할 수 없어요',
          en: 'Deleted videos are permanently removed from the app archive and cannot be recovered.',
          zh: '删除的视频将从应用存档中彻底移除，且无法恢复。',
          ja: '削除された動画はアーカイブから完全に削除され、復元できません。',
          es: 'Los videos eliminados se borrarán permanentemente del archivo y no se podrán recuperar.',
          de: 'Gelöschte Videos werden dauerhaft aus dem Archiv entfernt und können nicht wiederhergestellt werden.',
          fr: 'Les vidéos supprimées sont définitivement effacées et ne peuvent pas être récupérées.',
        )
      : _pick(
          ko: '삭제된 사진은 보관함에서 완전히 삭제되며 복구할 수 없어요',
          en: 'Deleted photos are permanently removed from the app archive and cannot be recovered.',
          zh: '删除的照片将从应用存档中彻底移除，且无法恢复。',
          ja: '削除された写真はアーカイブから完全に削除され、復元できません。',
          es: 'Las fotos eliminadas se borrarán permanentemente del archivo y no se podrán recuperar.',
          de: 'Gelöschte Fotos werden dauerhaft aus dem Archiv entfernt und können nicht wiederhergestellt werden.',
          fr: 'Les photos supprimées sont définitivement effacées et ne peuvent pas être récupérées.',
        );

  static String get videoNotFoundError => _pick(
        ko: '영상을 찾을 수 없거나 재생할 수 없습니다',
        en: 'Video not found or cannot be played',
        zh: '找不到视频或无法播放',
        ja: '動画が見つからないか再生できません',
        es: 'No se encuentra el video o no se puede reproducir',
        de: 'Video wurde nicht gefunden oder kann nicht abgespielt werden',
        fr: 'Vidéo introuvable ou lecture impossible',
      );

  static String get fullscreenLabel => _pick(
        ko: '전체화면',
        en: 'Fullscreen',
        zh: '全屏',
        ja: '全画面',
        es: 'Pantalla completa',
        de: 'Vollbild',
        fr: 'Plein écran',
      );

  // ─── 스탬프 관리 & 해금/문구 편집 ───
  static String get stampManagementTitle => _pick(
        ko: '스탬프 관리',
        en: 'Manage Stamps',
        zh: '印章管理',
        ja: 'スタンプ管理',
        es: 'Gestionar sellos',
        de: 'Stempel verwalten',
        fr: 'Gérer les tampons',
      );

  static String get favoritesResetSnackbar => _pick(
        ko: '즐겨찾기가 기본 순서로 초기화되었습니다.',
        en: 'Favorites have been reset to default.',
        zh: '收藏夹已重置为默认顺序。',
        ja: 'お気に入りが初期順序にリセットされました。',
        es: 'Los favoritos se han restablecido al orden predeterminado.',
        de: 'Favoriten wurden auf die Standardreihenfolge zurückgesetzt.',
        fr: 'Les favoris ont été réinitialisés par défaut.',
      );

  static String get favoritesTitle => _pick(
        ko: '즐겨찾기',
        en: 'Favorites',
        zh: '收藏夹',
        ja: 'お気に入り',
        es: 'Favoritos',
        de: 'Favoriten',
        fr: 'Favoris',
      );

  static String get favoritesDescription => _pick(
        ko: '메인에 우선 노출될 8개의 즐겨찾기 스탬프입니다. 슬롯을 탭하면 제거됩니다.',
        en: 'Up to 8 favorite stamps shown first on the main screen. Tap a slot to remove.',
        zh: '主界面优先显示的8个收藏印章。点击槽位即可移除。',
        ja: 'メイン画面に優先表示される8つのお気に入りスタンプです。タップすると解除されます。',
        es: 'Hasta 8 sellos favoritos mostrados en la pantalla principal. Toca una ranura para quitarlo.',
        de: 'Bis zu 8 Favoriten-Stempel für den Hauptbildschirm. Tippe auf einen Platz zum Entfernen.',
        fr: 'Jusqu\'à 8 tampons favoris affichés sur l\'écran principal. Appuyez pour retirer.',
      );

  static String get allStampsHeader => _pick(
        ko: '전체 스탬프 목록',
        en: 'All Stamps',
        zh: '全部印章列表',
        ja: 'すべてのスタンプ',
        es: 'Todos los sellos',
        de: 'Alle Stempel',
        fr: 'Tous les tampons',
      );

  static String totalStampsCount(int count) => _pick(
        ko: '총 $count개',
        en: 'Total $count',
        zh: '共 $count 个',
        ja: '全$count個',
        es: 'Total: $count',
        de: 'Gesamt: $count',
        fr: 'Total : $count',
      );

  static String get favoritesFullSnackbar => _pick(
        ko: '즐겨찾기가 가득 찼습니다 (최대 8개)\n상단에서 스탬프를 눌러 비운 후 추가해주세요.',
        en: 'Favorites are full (max 8).\nTap a slot above to free up space first.',
        zh: '收藏夹已满（最多8个）\n请先点击上方印章腾出空位后再添加。',
        ja: 'お気に入りがいっぱいです（最大8個）\n上部のスロットをタップして空きを作ってから追加してください。',
        es: 'Favoritos llenos (máx. 8).\nToca un sello arriba para liberar espacio primero.',
        de: 'Favoriten sind voll (max. 8).\nTippe oben auf einen Stempel, um Platz zu schaffen.',
        fr: 'Les favoris sont pleins (max. 8).\nLibérez un emplacement en haut avant d\'ajouter.',
      );

  static String get stampFreeUse => _pick(
        ko: '무료 사용',
        en: 'Free',
        zh: '免费使用',
        ja: '無料',
        es: 'Gratis',
        de: 'Kostenlos',
        fr: 'Gratuit',
      );

  static String get stampLocked => _pick(
        ko: '잠김',
        en: 'Locked',
        zh: '已锁定',
        ja: 'ロック中',
        es: 'Bloqueado',
        de: 'Gesperrt',
        fr: 'Verrouillé',
      );

  static String stampRemainingDaysHours(int days, int hours) => _pick(
        ko: '$days일 $hours시간 남음',
        en: '${days}d ${hours}h left',
        zh: '剩余 $days天 $hours小时',
        ja: '残り$days日$hours時間',
        es: 'Quedan ${days}d ${hours}h',
        de: 'Noch ${days}T ${hours}Std.',
        fr: '${days}j ${hours}h restants',
      );

  static String stampRemainingHoursMinutes(int hours, int minutes) => _pick(
        ko: '$hours시간 $minutes분 남음',
        en: '${hours}h ${minutes}m left',
        zh: '剩余 $hours小时 $minutes分钟',
        ja: '残り$hours時間$minutes分',
        es: 'Quedan ${hours}h ${minutes}m',
        de: 'Noch ${hours}Std. ${minutes}Min.',
        fr: '${hours}h ${minutes}m restants',
      );

  static String stampRemainingMinutes(int minutes) => _pick(
        ko: '$minutes분 남음',
        en: '${minutes}m left',
        zh: '剩余 $minutes分钟',
        ja: '残り$minutes分',
        es: 'Quedan ${minutes}m',
        de: 'Noch ${minutes}Min.',
        fr: '${minutes}m restantes',
      );

  static String stampUnlockedBadge(String remaining) => _pick(
        ko: '해금됨 ($remaining)',
        en: 'Unlocked ($remaining)',
        zh: '已解锁 ($remaining)',
        ja: '解放済み ($remaining)',
        es: 'Desbloqueado ($remaining)',
        de: 'Freigeschaltet ($remaining)',
        fr: 'Débloqué ($remaining)',
      );

  static String get unlockDialogTitle => _pick(
        ko: '스탬프 3일 무료 해금',
        en: 'Unlock Stamp for 3 Days',
        zh: '免费解锁印章 3 天',
        ja: 'スタンプを3日間無料解放',
        es: 'Desbloquear sello por 3 días',
        de: 'Stempel für 3 Tage freischalten',
        fr: 'Débloquer le tampon pour 3 jours',
      );

  static String get unlockDialogDesc => _pick(
        ko: '짧은 영상 광고 1편을 시청하시면\n3일(72시간) 동안 자유롭게 사용할 수 있어요!',
        en: 'Watch a short video ad to use this stamp\nfreely for 3 days (72 hours)!',
        zh: '观看一段简短的视频广告，\n即可在 3 天（72 小时）内自由使用该印章！',
        ja: '短い動画広告を1本視聴すると、\n3日間（72時間）自由にご利用いただけます！',
        es: '¡Mira un breve anuncio de video para usar\neste sello gratis durante 3 días (72 horas)!',
        de: 'Sieh dir ein kurzes Werbevideo an, um diesen Stempel\n3 Tage (72 Stunden) lang kostenlos zu nutzen!',
        fr: 'Regardez une courte publicité vidéo pour utiliser\nce tampon gratuitement pendant 3 jours (72 h) !',
      );

  static String get preparingAd => _pick(
        ko: '광고를 준비하고 있습니다...',
        en: 'Preparing ad...',
        zh: '正在准备广告...',
        ja: '広告を準備しています...',
        es: 'Preparando anuncio...',
        de: 'Werbung wird geladen...',
        fr: 'Préparation de la publicité...',
      );

  static String get unlockWatchAdButton => _pick(
        ko: '광고 보고 3일 해금하기',
        en: 'Watch Ad & Unlock for 3 Days',
        zh: '观看广告并解锁 3 天',
        ja: '広告を見て3日間解放する',
        es: 'Ver anuncio y desbloquear 3 días',
        de: 'Video ansehen & 3 Tage freischalten',
        fr: 'Voir la pub et débloquer 3 jours',
      );

  static String get maybeLater => _pick(
        ko: '다음에 하기',
        en: 'Maybe Later',
        zh: '稍后再说',
        ja: 'あとで',
        es: 'Más tarde',
        de: 'Später',
        fr: 'Plus tard',
      );

  static String get stampUnlockedSnackbar => _pick(
        ko: '🎉 스탬프가 해금되었습니다! 3일 동안 자유롭게 사용하세요.',
        en: '🎉 Stamp unlocked! Enjoy using it for 3 days.',
        zh: '🎉 印章已解锁！未来 3 天内可自由使用。',
        ja: '🎉 スタンプが解放されました！3日間自由にお使いください。',
        es: '🎉 ¡Sello desbloqueado! Úsalo libremente durante 3 días.',
        de: '🎉 Stempel freigeschaltet! 3 Tage lang frei nutzbar.',
        fr: '🎉 Tampon débloqué ! Profitez-en pendant 3 jours.',
      );

  // ─── 스탬프 문구 수정 다이얼로그 ───
  static String get editStampTextTitle => _pick(
        ko: '스탬프 문구 수정',
        en: 'Edit Stamp Text',
        zh: '修改印章文字',
        ja: 'スタンプ文言の編集',
        es: 'Editar texto del sello',
        de: 'Stempeltext bearbeiten',
        fr: 'Modifier le texte du tampon',
      );

  static String get restoreDefault => _pick(
        ko: '기본값 복원',
        en: 'Restore Default',
        zh: '恢复默认',
        ja: '初期値に戻す',
        es: 'Restaurar valores',
        de: 'Standard wiederherstellen',
        fr: 'Par défaut',
      );

  static String get editStampTextSubtitle => _pick(
        ko: '원하는 문구로 수정하면 사진과 영상에 바로 반영됩니다.',
        en: 'Customize the text shown on your photo and video stamps.',
        zh: '修改为您喜欢的文字后，将立即应用到照片和视频印章中。',
        ja: 'お好みの文言に変更すると、写真や動画にすぐ反映されます。',
        es: 'Personaliza el texto y se reflejará al instante en tus fotos y videos.',
        de: 'Passe den Text an – er wird sofort auf Fotos und Videos übernommen.',
        fr: 'Personnalisez le texte pour l\'appliquer immédiatement à vos photos et vidéos.',
      );

  static String defaultTextHint(String def) => _pick(
        ko: '기본값: $def',
        en: 'Default: $def',
        zh: '默认值: $def',
        ja: '初期値: $def',
        es: 'Predeterminado: $def',
        de: 'Standard: $def',
        fr: 'Par défaut : $def',
      );

  static String stampFieldLabel(String fieldId) {
    switch (fieldId) {
      case 'f4_txt1':
      case 'style2_txt1':
      case 'style5_txt1':
        return _pick(
          ko: '문구',
          en: 'Text',
          zh: '文字',
          ja: 'テキスト',
          es: 'Texto',
          de: 'Text',
          fr: 'Texte',
        );
      case 'style1_rtxt1':
      case 'style5_rtxt1':
      case 'style8_rtxt1':
        return _pick(
          ko: '곡선 문구',
          en: 'Curved Text',
          zh: '弧形文字',
          ja: 'アーチ文字',
          es: 'Texto curvo',
          de: 'Gebogener Text',
          fr: 'Texte courbé',
        );
      case 'style3_txt1':
      case 'style8_txt1':
        return _pick(
          ko: '상단 문구',
          en: 'Top Text',
          zh: '上方文字',
          ja: '上部テキスト',
          es: 'Texto superior',
          de: 'Oberer Text',
          fr: 'Texte du haut',
        );
      case 'style3_txt2':
      case 'style8_txt2':
        return _pick(
          ko: '하단 문구',
          en: 'Bottom Text',
          zh: '下方文字',
          ja: '下部テキスト',
          es: 'Texto inferior',
          de: 'Unterer Text',
          fr: 'Texte du bas',
        );
      case 'style4_txt1':
      case 'style7_txt1':
        return _pick(
          ko: '첫째 줄',
          en: 'Line 1',
          zh: '第一行',
          ja: '1行目',
          es: 'Línea 1',
          de: 'Zeile 1',
          fr: 'Ligne 1',
        );
      case 'style4_txt2':
      case 'style7_txt2':
        return _pick(
          ko: '둘째 줄',
          en: 'Line 2',
          zh: '第二行',
          ja: '2行目',
          es: 'Línea 2',
          de: 'Zeile 2',
          fr: 'Ligne 2',
        );
      case 'style4_txt3':
      case 'style7_txt3':
        return _pick(
          ko: '셋째 줄',
          en: 'Line 3',
          zh: '第三行',
          ja: '3行目',
          es: 'Línea 3',
          de: 'Zeile 3',
          fr: 'Ligne 3',
        );
      case 'style11_txt1':
        return _pick(
          ko: '제목',
          en: 'Title',
          zh: '标题',
          ja: 'タイトル',
          es: 'Título',
          de: 'Titel',
          fr: 'Titre',
        );
      case 'style11_txt2':
        return _pick(
          ko: '태그 1 (좌상)',
          en: 'Tag 1 (Top-Left)',
          zh: '标签 1（左上）',
          ja: 'タグ1（左上）',
          es: 'Etiqueta 1 (Sup. izq.)',
          de: 'Tag 1 (Oben links)',
          fr: 'Tag 1 (Haut gauche)',
        );
      case 'style11_txt3':
        return _pick(
          ko: '태그 2 (우하)',
          en: 'Tag 2 (Bottom-Right)',
          zh: '标签 2（右下）',
          ja: 'タグ2（右下）',
          es: 'Etiqueta 2 (Inf. der.)',
          de: 'Tag 2 (Unten rechts)',
          fr: 'Tag 2 (Bas droite)',
        );
      case 'style11_txt4':
        return _pick(
          ko: '태그 3 (좌하)',
          en: 'Tag 3 (Bottom-Left)',
          zh: '标签 3（左下）',
          ja: 'タグ3（左下）',
          es: 'Etiqueta 3 (Inf. izq.)',
          de: 'Tag 3 (Unten links)',
          fr: 'Tag 3 (Bas gauche)',
        );
      case 'style11_txt5':
        return _pick(
          ko: '태그 4 (우상)',
          en: 'Tag 4 (Top-Right)',
          zh: '标签 4（右上）',
          ja: 'タグ4（右上）',
          es: 'Etiqueta 4 (Sup. der.)',
          de: 'Tag 4 (Oben rechts)',
          fr: 'Tag 4 (Haut droite)',
        );
      default:
        return _pick(
          ko: '문구',
          en: 'Text',
          zh: '文字',
          ja: 'テキスト',
          es: 'Texto',
          de: 'Text',
          fr: 'Texte',
        );
    }
  }

  static String get style3Txt1AutoHint => _pick(
        ko: '비워두면 시간대에 따라 BREAKFAST / LUNCH / DINNER 로 자동 표시돼요',
        en: 'Leave blank to automatically show BREAKFAST / LUNCH / DINNER by time of day',
        zh: '留空将根据时间段自动显示 BREAKFAST / LUNCH / DINNER',
        ja: '空欄にすると時間帯に応じて BREAKFAST / LUNCH / DINNER が自動表示されます',
        es: 'Déjalo en blanco para mostrar BREAKFAST / LUNCH / DINNER automáticamente según la hora',
        de: 'Leer lassen, um je nach Tageszeit automatisch BREAKFAST / LUNCH / DINNER anzuzeigen',
        fr: 'Laissez vide pour afficher automatiquement BREAKFAST / LUNCH / DINNER selon l\'heure',
      );

  /// 스탬프 내 기본 다국어 문구 (I18n 키 및 필드 기본값)
  static String stampI18nDefault(String key) {
    switch (key) {
      case 'input_text':
      case 'f4_txt1':
        return _pick(
          ko: '누르면 글을 작성할 수 있어요!',
          en: 'Tap to write your text!',
          zh: '点击即可输入文字！',
          ja: 'タップして文字を入力できます！',
          es: '¡Toca para escribir tu texto!',
          de: 'Tippen, um Text einzugeben!',
          fr: 'Appuyez pour écrire votre texte !',
        );
      case 'today_dish_record':
      case 'style3_txt2':
        return _pick(
          ko: '#오늘의 식단기록',
          en: '#Today\'s Meal Log',
          zh: '#今日饮食记录',
          ja: '#今日の食事記録',
          es: '#RegistroDeComida',
          de: '#Ernährungstagebuch',
          fr: '#JournalRepas',
        );
      case 'style7_default_text1':
      case 'style7_txt1':
        return _pick(
          ko: '“별이 아름다운 이유는',
          en: '“The stars are beautiful',
          zh: '“星星之所以美丽，',
          ja: '「星が美しいのは',
          es: '“Las estrellas son hermosas',
          de: '„Die Sterne sind schön,',
          fr: '« Les étoiles sont belles',
        );
      case 'style7_default_text2':
      case 'style7_txt2':
        return _pick(
          ko: '보이지 않는 꽃이 있기 때문이다”',
          en: 'because of a flower unseen”',
          zh: '是因为有一朵看不见的花”',
          ja: '見えない花があるから」',
          es: 'por una flor que no se ve”',
          de: 'weil es eine unsichtbare Blume gibt“',
          fr: 'à cause d\'une fleur qu\'on ne voit pas »',
        );
      case 'today_brunch':
      case 'style11_txt1':
        return _pick(
          ko: '오늘의 브런치',
          en: 'Today\'s Brunch',
          zh: '今日早午餐',
          ja: '今日のブランチ',
          es: 'Brunch de hoy',
          de: 'Heutiger Brunch',
          fr: 'Brunch du jour',
        );
      case 'shrimp':
      case 'style11_txt2':
        return _pick(
          ko: '새우',
          en: 'Shrimp',
          zh: '鲜虾',
          ja: 'エビ',
          es: 'Camarón',
          de: 'Garnele',
          fr: 'Crevettes',
        );
      case 'rucola':
      case 'style11_txt3':
        return _pick(
          ko: '루꼴라',
          en: 'Arugula',
          zh: '芝麻菜',
          ja: 'ルッコラ',
          es: 'Rúcula',
          de: 'Rucola',
          fr: 'Roquette',
        );
      case 'egg':
      case 'style11_txt4':
        return _pick(
          ko: '계란',
          en: 'Egg',
          zh: '鸡蛋',
          ja: 'たまご',
          es: 'Huevo',
          de: 'Ei',
          fr: 'Œuf',
        );
      case 'cherry_tomato':
      case 'style11_txt5':
        return _pick(
          ko: '방울토마토',
          en: 'Cherry Tomato',
          zh: '圣女果',
          ja: 'ミニトマト',
          es: 'Tomate cherry',
          de: 'Cherrytomate',
          fr: 'Tomate cerise',
        );
      default:
        return key;
    }
  }

  static String get unlockFeatShortAd => _pick(
        ko: '짧은 광고 1회',
        en: '1 Short Ad',
        zh: '1 次简短广告',
        ja: '短い広告1回',
        es: '1 anuncio corto',
        de: '1 kurzer Spot',
        fr: '1 courte pub',
      );

  static String get unlockFeat3DaysUnlimited => _pick(
        ko: '3일간 무제한',
        en: '3 Days Unlimited',
        zh: '3 天无限使用',
        ja: '3日間無制限',
        es: '3 días ilimitados',
        de: '3 Tage unbegrenzt',
        fr: '3 jours illimités',
      );

  static String get unlockFeatNoWatermark => _pick(
        ko: '워터마크 없음',
        en: 'No Watermark',
        zh: '无水印',
        ja: '透かしなし',
        es: 'Sin marca de agua',
        de: 'Kein Wasserzeichen',
        fr: 'Sans filigrane',
      );

  static String get autoTextHint => _pick(
        ko: '자동',
        en: 'Auto',
        zh: '自动',
        ja: '自動',
        es: 'Automático',
        de: 'Automatisch',
        fr: 'Auto',
      );

  static String get locLabelAddressDefault => _pick(
        ko: '주소',
        en: 'Address',
        zh: '地址',
        ja: '住所',
        es: 'Dirección',
        de: 'Adresse',
        fr: 'Adresse',
      );

  static String get locLabelDetailAddress => _pick(
        ko: '상세주소',
        en: 'District / Neighborhood',
        zh: '详细地址',
        ja: '詳細住所',
        es: 'Distrito / Barrio',
        de: 'Bezirk / Stadtteil',
        fr: 'Quartier / Arrondissement',
      );

  static String get locLabelCountryCityDetail => _pick(
        ko: '국가 및 도시 + 상세주소',
        en: 'Country, City & District',
        zh: '国家及城市 + 详细地址',
        ja: '国・都市 + 詳細住所',
        es: 'País, ciudad y distrito',
        de: 'Land, Stadt & Bezirk',
        fr: 'Pays, ville et quartier',
      );

  static String get locLabelMoreDetailedAddress => _pick(
        ko: '더 상세한 주소',
        en: 'Street Address',
        zh: '更详细的地址',
        ja: 'より詳細な住所',
        es: 'Dirección detallada',
        de: 'Straßenadresse',
        fr: 'Adresse précise',
      );

  static String get locLabelCountryCityDetailed => _pick(
        ko: '국가 및 도시 + 더 상세한 주소',
        en: 'Full Street Address',
        zh: '国家及城市 + 更详细的地址',
        ja: '国・都市 + より詳細な住所',
        es: 'País, ciudad y dirección detallada',
        de: 'Vollständige Straßenadresse',
        fr: 'Adresse complète',
      );

  static String get locLabelLatLng => _pick(
        ko: '위도/경도',
        en: 'Coordinates (Lat/Lng)',
        zh: '经纬度',
        ja: '緯度・経度',
        es: 'Latitud / Longitud',
        de: 'Breiten-/Längengrad',
        fr: 'Latitude / Longitude',
      );

  static String localizeLocationOptionLabel(String rawLabel) {
    switch (rawLabel) {
      case '상세주소':
      case 'District / Neighborhood':
      case '详细地址':
      case '詳細住所':
      case 'Distrito / Barrio':
      case 'Bezirk / Stadtteil':
      case 'Quartier / Arrondissement':
        return locLabelDetailAddress;
      case '국가 및 도시 + 상세주소':
      case 'Country, City & District':
      case '国家及城市 + 详细地址':
      case '国・都市 + 詳細住所':
      case 'País, ciudad y distrito':
      case 'Land, Stadt & Bezirk':
      case 'Pays, ville et quartier':
        return locLabelCountryCityDetail;
      case '더 상세한 주소':
      case 'Street Address':
      case '更详细的地址':
      case 'より詳細な住所':
      case 'Dirección detallada':
      case 'Straßenadresse':
      case 'Adresse précise':
        return locLabelMoreDetailedAddress;
      case '국가 및 도시 + 더 상세한 주소':
      case 'Full Street Address':
      case '国家及城市 + 更详细的地址':
      case '国・都市 + より詳細な住所':
      case 'País, ciudad y dirección detallada':
      case 'Vollständige Straßenadresse':
      case 'Adresse complète':
        return locLabelCountryCityDetailed;
      case '위도/경도':
      case 'Coordinates (Lat/Lng)':
      case '经纬度':
      case '緯度・経度':
      case 'Latitud / Longitud':
      case 'Breiten-/Längengrad':
      case 'Latitude / Longitude':
        return locLabelLatLng;
      case '주소':
        return locLabelAddressDefault;
      default:
        return rawLabel;
    }
  }

  static String locErrUnexpected(String e) => _pick(
        ko: '위치 정보를 가져오는 중 오류가 발생했습니다: $e',
        en: 'Error fetching location: $e',
        zh: '获取位置信息时出错: $e',
        ja: '位置情報の取得中にエラーが発生しました: $e',
        es: 'Error al obtener la ubicación: $e',
        de: 'Fehler beim Abrufen des Standorts: $e',
        fr: 'Erreur lors de la récupération de la position : $e',
      );

  // ─── GPS 위치 서비스 & 오버레이 ───
  static String get gpsCheckingOverlay => _pick(
        ko: 'GPS 위치 확인 중',
        en: 'Checking GPS location',
        zh: '正在获取 GPS 位置',
        ja: 'GPS位置を確認中',
        es: 'Comprobando ubicación GPS',
        de: 'GPS-Standort wird ermittelt',
        fr: 'Recherche de la position GPS',
      );

  static String get locLabelFull => _pick(
        ko: '전체 주소',
        en: 'Full Address',
        zh: '完整地址',
        ja: '住所全体',
        es: 'Dirección completa',
        de: 'Vollständige Adresse',
        fr: 'Adresse complète',
      );

  static String get locLabelCityDistrict => _pick(
        ko: '시/구/동 요약',
        en: 'City & District',
        zh: '省/市/区概要',
        ja: '市区町村',
        es: 'Ciudad y distrito',
        de: 'Stadt & Bezirk',
        fr: 'Ville et quartier',
      );

  static String get locLabelDistrictNeighborhood => _pick(
        ko: '구/동 간편',
        en: 'Neighborhood',
        zh: '区/街道简写',
        ja: 'エリア・町名',
        es: 'Barrio / Zona',
        de: 'Stadtteil',
        fr: 'Quartier',
      );

  static String get locLabelStreetPlace => _pick(
        ko: '도로명/장소',
        en: 'Street / Place',
        zh: '道路/地点',
        ja: '通り・場所名',
        es: 'Calle / Lugar',
        de: 'Straße / Ort',
        fr: 'Rue / Lieu',
      );

  static String get locLabelCurrent => _pick(
        ko: '현재 위치',
        en: 'Current Location',
        zh: '当前位置',
        ja: '現在地',
        es: 'Ubicación actual',
        de: 'Aktueller Standort',
        fr: 'Position actuelle',
      );

  static String get locErrServiceDisabled => _pick(
        ko: '위치 서비스(GPS)가 꺼져 있습니다. 기기 설정에서 위치 서비스를 켜주세요.',
        en: 'Location services (GPS) are disabled. Please enable them in device settings.',
        zh: '位置服务 (GPS) 已关闭。请在设备设置中开启位置服务。',
        ja: '位置情報サービス(GPS)がオフになっています。端末の設定でオンにしてください。',
        es: 'Los servicios de ubicación (GPS) están desactivados. Actívalos en los ajustes del dispositivo.',
        de: 'Standortdienste (GPS) sind deaktiviert. Bitte in den Geräteeinstellungen aktivieren.',
        fr: 'Les services de localisation (GPS) sont désactivés. Veuillez les activer dans les réglages.',
      );

  static String get locErrDenied => _pick(
        ko: '위치 권한이 거부되었습니다. 위치를 표시하려면 권한을 허용해주세요.',
        en: 'Location permission denied. Please allow permission to display your location.',
        zh: '位置权限已被拒绝。若要显示位置，请允许访问位置权限。',
        ja: '位置情報の権限が拒否されました。位置を表示するには権限を許可してください。',
        es: 'Permiso de ubicación denegado. Permite el acceso para mostrar tu ubicación.',
        de: 'Standortberechtigung verweigert. Bitte erlauben Sie den Zugriff.',
        fr: 'Autorisation de localisation refusée. Veuillez l\'autoriser pour afficher votre position.',
      );

  static String get locErrDeniedForever => _pick(
        ko: '위치 권한이 영구 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.',
        en: 'Location permission permanently denied. Please enable it in App Settings.',
        zh: '位置权限已被永久拒绝。请在应用设置中开启位置权限。',
        ja: '位置情報の権限が拒否されています。アプリの設定から位置情報を許可してください。',
        es: 'Permiso de ubicación denegado permanentemente. Actívalo en los ajustes de la app.',
        de: 'Standortberechtigung dauerhaft verweigert. Bitte in den App-Einstellungen aktivieren.',
        fr: 'Autorisation de localisation refusée définitivement. Veuillez l\'activer dans les réglages.',
      );

  static String get locErrAddressNotFound => _pick(
        ko: '현재 위치의 주소를 확인할 수 없습니다.',
        en: 'Unable to determine the address for your current location.',
        zh: '无法确认当前位置的地址。',
        ja: '現在地の住所を確認できませんでした。',
        es: 'No se pudo determinar la dirección de tu ubicación actual.',
        de: 'Adresse für den aktuellen Standort konnte nicht ermittelt werden.',
        fr: 'Impossible de déterminer l\'adresse de votre position actuelle.',
      );

  static String get locErrFailed => _pick(
        ko: '위치 정보를 가져오지 못했습니다. 잠시 후 다시 시도해주세요.',
        en: 'Failed to get location. Please try again in a moment.',
        zh: '无法获取位置信息，请稍后重试。',
        ja: '位置情報を取得できませんでした。しばらくしてからもう一度お試しください。',
        es: 'No se pudo obtener la ubicación. Inténtalo de nuevo más tarde.',
        de: 'Standort konnte nicht abgerufen werden. Bitte später erneut versuchen.',
        fr: 'Impossible d\'obtenir la position. Veuillez réessayer plus tard.',
      );

  // ─── 광고 서비스 ───
  static String get adLoadFailed => _pick(
        ko: '광고를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
        en: 'Failed to load ad. Please try again in a moment.',
        zh: '广告加载失败，请稍后重试。',
        ja: '広告を読み込めませんでした。しばらくしてからもう一度お試しください。',
        es: 'No se pudo cargar el anuncio. Inténtalo de nuevo en un momento.',
        de: 'Werbung konnte nicht geladen werden. Bitte später erneut versuchen.',
        fr: 'Impossible de charger la publicité. Veuillez réessayer plus tard.',
      );

  static String adShowFailed(String message) => _pick(
        ko: '광고 표시에 실패했습니다: $message',
        en: 'Failed to show ad: $message',
        zh: '显示广告失败: $message',
        ja: '広告の表示に失敗しました: $message',
        es: 'Error al mostrar el anuncio: $message',
        de: 'Fehler beim Anzeigen der Werbung: $message',
        fr: 'Échec de l\'affichage de la publicité : $message',
      );

  // ─── 설정 화면 (SettingsScreen) ───
  static String get settingsTitle => _pick(
        ko: '설정',
        en: 'Settings',
        zh: '设置',
        ja: '設定',
        es: 'Ajustes',
        de: 'Einstellungen',
        fr: 'Réglages',
      );

  static String get sectionLanguage => _pick(
        ko: '언어 설정',
        en: 'Language',
        zh: '语言设置',
        ja: '言語設定',
        es: 'Idioma',
        de: 'Sprache',
        fr: 'Langue',
      );

  static String get appLanguageTitle => _pick(
        ko: '앱 및 타임스탬프 언어',
        en: 'App & Timestamp Language',
        zh: '应用与时间戳语言',
        ja: 'アプリ・タイムスタンプの言語',
        es: 'Idioma de la app y marca de tiempo',
        de: 'App- & Zeitstempel-Sprache',
        fr: 'Langue de l\'app et de l\'horodatage',
      );

  static String get languageSystemDefault => _pick(
        ko: '시스템 기본값',
        en: 'System Default',
        zh: '跟随系统',
        ja: 'システム標準',
        es: 'Predeterminado del sistema',
        de: 'Systemstandard',
        fr: 'Langue du système',
      );

  static String get languageSubtitle => _pick(
        ko: '선택한 국가/언어에 맞춰 앱 화면과 타임스탬프 날짜·시간 형식이 자동 변환됩니다.',
        en: 'App UI and timestamp date/time order automatically adapt to the selected language.',
        zh: '应用界面和时间戳的日期、时间格式将根据所选语言自动转换。',
        ja: '選択した言語に合わせて、アプリ画面とタイムスタンプの日時形式が自動的に切り替わります。',
        es: 'La interfaz y el formato de fecha/hora del sello se adaptan automáticamente al idioma seleccionado.',
        de: 'App-Oberfläche sowie Datums- und Uhrzeitformat passen sich automatisch der gewählten Sprache an.',
        fr: 'L\'interface et le format de date/heure s\'adaptent automatiquement à la langue choisie.',
      );

  static String get sectionTimestampSettings => _pick(
        ko: '타임스탬프 설정',
        en: 'Timestamp Settings',
        zh: '时间戳设置',
        ja: 'タイムスタンプ設定',
        es: 'Ajustes de marca de tiempo',
        de: 'Zeitstempel-Einstellungen',
        fr: 'Paramètres d\'horodatage',
      );

  static String get showLocationTitle => _pick(
        ko: '위치 정보 표시',
        en: 'Show Location Tag',
        zh: '显示位置信息',
        ja: '位置情報を表示',
        es: 'Mostrar etiqueta de ubicación',
        de: 'Standort-Tag anzeigen',
        fr: 'Afficher le lieu',
      );

  static String get locationToDisplay => _pick(
        ko: '표시할 위치',
        en: 'Location Text',
        zh: '显示位置',
        ja: '表示する場所',
        es: 'Ubicación a mostrar',
        de: 'Angezeigter Standort',
        fr: 'Lieu affiché',
      );

  static String get fetchingGpsLocation => _pick(
        ko: 'GPS 위치를 가져오는 중...',
        en: 'Fetching GPS location...',
        zh: '正在获取 GPS 位置...',
        ja: 'GPS位置を取得中...',
        es: 'Obteniendo ubicación GPS...',
        de: 'GPS-Standort wird abgerufen...',
        fr: 'Récupération de la position GPS...',
      );

  static String get locationNotSetTapToSelect => _pick(
        ko: '위치 미설정 (탭하여 선택)',
        en: 'Not set (Tap to select)',
        zh: '未设置位置（点击选择）',
        ja: '未設定（タップして選択）',
        es: 'Sin configurar (Toca para elegir)',
        de: 'Nicht festgelegt (Zum Wählen tippen)',
        fr: 'Non défini (Appuyez pour choisir)',
      );

  static String get tooltipRefreshGps => _pick(
        ko: 'GPS 현재 위치 새로고침',
        en: 'Refresh GPS Location',
        zh: '刷新当前 GPS 位置',
        ja: '現在地をGPSで更新',
        es: 'Actualizar ubicación GPS',
        de: 'GPS-Standort aktualisieren',
        fr: 'Actualiser la position GPS',
      );

  static String get measuringGpsSnackbar => _pick(
        ko: '현재 GPS 위치를 측정하고 있습니다...',
        en: 'Measuring current GPS location...',
        zh: '正在测量当前 GPS 位置...',
        ja: '現在のGPS位置を測定しています...',
        es: 'Obteniendo la ubicación GPS actual...',
        de: 'Aktueller GPS-Standort wird ermittelt...',
        fr: 'Mesure de la position GPS actuelle...',
      );

  static String gpsUpdatedSnackbar(String address) => _pick(
        ko: '📍 현재 위치가 갱신되었습니다: $address',
        en: '📍 Location updated: $address',
        zh: '📍 当前位置已更新: $address',
        ja: '📍 現在地が更新されました: $address',
        es: '📍 Ubicación actualizada: $address',
        de: '📍 Standort aktualisiert: $address',
        fr: '📍 Position mise à jour : $address',
      );

  static String get locationPositionTitle => _pick(
        ko: '위치 태그 표시 위치',
        en: 'Location Tag Position',
        zh: '位置标签显示位置',
        ja: '位置タグの表示位置',
        es: 'Posición de la etiqueta de ubicación',
        de: 'Position des Standort-Tags',
        fr: 'Position du badge de lieu',
      );

  static String get locationPositionSubtitle => _pick(
        ko: '화면/타임스탬프 내에서 위치 태그가 나타날 위치를 선택합니다.',
        en: 'Choose where the location tag appears on the screen.',
        zh: '选择位置标签在画面中的显示位置。',
        ja: '画面内で位置タグを表示する場所を選択します。',
        es: 'Elige dónde aparecerá la etiqueta de ubicación en la pantalla.',
        de: 'Wähle aus, wo das Standort-Tag auf dem Bildschirm erscheint.',
        fr: 'Choisissez où afficher le badge de lieu sur l\'écran.',
      );

  static String get posTopLeft => _pick(
        ko: '좌상단',
        en: 'Top Left',
        zh: '左上角',
        ja: '左上',
        es: 'Sup. izq.',
        de: 'Oben links',
        fr: 'Haut gauche',
      );

  static String get posTopCenter => _pick(
        ko: '상단 중앙',
        en: 'Top Center',
        zh: '顶部居中',
        ja: '上部中央',
        es: 'Sup. centro',
        de: 'Oben Mitte',
        fr: 'Haut centre',
      );

  static String get posTopRight => _pick(
        ko: '우상단',
        en: 'Top Right',
        zh: '右上角',
        ja: '右上',
        es: 'Sup. der.',
        de: 'Oben rechts',
        fr: 'Haut droite',
      );

  static String get posBottomLeft => _pick(
        ko: '좌하단',
        en: 'Bottom Left',
        zh: '左下角',
        ja: '左下',
        es: 'Inf. izq.',
        de: 'Unten links',
        fr: 'Bas gauche',
      );

  static String get posBottomCenter => _pick(
        ko: '하단 중앙',
        en: 'Bottom Center',
        zh: '底部居中',
        ja: '下部中央',
        es: 'Inf. centro',
        de: 'Unten Mitte',
        fr: 'Bas centre',
      );

  static String get posBottomRight => _pick(
        ko: '우하단',
        en: 'Bottom Right',
        zh: '右下角',
        ja: '右下',
        es: 'Inf. der.',
        de: 'Unten rechts',
        fr: 'Bas droite',
      );

  static String get selectLocationSheetTitle => _pick(
        ko: '표시할 위치 선택',
        en: 'Select Location Format',
        zh: '选择要显示的位置',
        ja: '表示する場所を選択',
        es: 'Seleccionar ubicación',
        de: 'Standort auswählen',
        fr: 'Choisir le lieu à afficher',
      );

  static String get refreshGpsButton => _pick(
        ko: 'GPS 갱신',
        en: 'Refresh GPS',
        zh: '刷新 GPS',
        ja: 'GPS更新',
        es: 'Actualizar GPS',
        de: 'GPS neu laden',
        fr: 'Actualiser GPS',
      );

  static String get selectLocationSheetSubtitle => _pick(
        ko: 'GPS 기반 4가지 주소 형식 또는 원하는 문구 직접 입력 중 선택하세요.',
        en: 'Choose from 4 GPS address formats or enter your own custom location text.',
        zh: '从 4 种 GPS 地址格式中选择，或直接输入自定义文字。',
        ja: 'GPSに基づく4つの住所形式、または自由入力から選択してください。',
        es: 'Elige entre los formatos de dirección GPS o escribe un texto personalizado.',
        de: 'Wähle aus 4 GPS-Adressformaten oder gib einen eigenen Text ein.',
        fr: 'Choisissez parmi 4 formats d\'adresse GPS ou saisissez un texte personnalisé.',
      );

  static String get noGpsOptionsInfo => _pick(
        ko: '측정된 GPS 옵션이 없습니다. 상단의 GPS 갱신을 누르시거나 직접 입력해주세요.',
        en: 'No GPS options available yet. Tap Refresh GPS above or enter custom text.',
        zh: '暂无测量到的 GPS 选项。请点击上方的“刷新 GPS”或直接输入。',
        ja: '取得されたGPS候補がありません。上の「GPS更新」を押すか直接入力してください。',
        es: 'No hay opciones GPS disponibles. Toca Actualizar GPS arriba o ingresa un texto.',
        de: 'Keine GPS-Optionen verfügbar. Oben auf „GPS neu laden“ tippen oder Text eingeben.',
        fr: 'Aucune option GPS disponible. Appuyez sur Actualiser GPS ou saisissez un texte.',
      );

  static String get enterCustomLocationTitle => _pick(
        ko: '원하는 문구 입력',
        en: 'Custom Location Text',
        zh: '输入自定义位置文字',
        ja: '好きな文言を入力',
        es: 'Texto de ubicación personalizado',
        de: 'Eigener Standorttext',
        fr: 'Lieu personnalisé',
      );

  static String get customLocationSelectedSubtitle => _pick(
        ko: '직접 입력한 문구 (탭하여 변경)',
        en: 'Custom text (Tap to edit)',
        zh: '自定义输入的文字（点击修改）',
        ja: '直接入力した文言（タップして変更）',
        es: 'Texto personalizado (Toca para cambiar)',
        de: 'Eigener Text (Zum Ändern tippen)',
        fr: 'Texte personnalisé (Appuyez pour modifier)',
      );

  static String get customLocationUnselectedSubtitle => _pick(
        ko: '자유로운 문구 직접 입력',
        en: 'Enter any place name freely',
        zh: '自由输入任意地点文字',
        ja: '自由な場所・テキストを入力',
        es: 'Introduce cualquier lugar libremente',
        de: 'Beliebigen Ortsnamen frei eingeben',
        fr: 'Saisissez librement le lieu de votre choix',
      );

  static String get customLocationDialogDesc => _pick(
        ko: '타임스탬프에 표시할 원하는 위치 문구를 자유롭게 입력하세요.',
        en: 'Enter any location text you want to display on your timestamp.',
        zh: '请自由输入要在时间戳中显示的位置文字。',
        ja: 'タイムスタンプに表示したい場所やテキストを自由に入力してください。',
        es: 'Introduce el texto de ubicación que quieras mostrar en tu sello.',
        de: 'Gib den Standorttext ein, der auf dem Zeitstempel angezeigt werden soll.',
        fr: 'Saisissez le texte de lieu que vous souhaitez afficher sur votre horodatage.',
      );

  static String get customLocationHint => _pick(
        ko: '예: 우리집 / 서울 한강공원 / 제주 협재',
        en: 'e.g. Home / Central Park, NY / Paris',
        zh: '例：我家 / 北京朝阳公园 / 上海外滩',
        ja: '例：自宅 / 東京・渋谷 / 京都・嵐山',
        es: 'Ej.: Mi casa / Parque del Retiro / Madrid',
        de: 'z. B. Zuhause / Berliner Tiergarten / München',
        fr: 'Ex. : Chez moi / Tour Eiffel, Paris / Nice',
      );

  // ─── 테마 및 스타일 ───
  static String get sectionThemeAndStyle => _pick(
        ko: '테마 및 스타일',
        en: 'Theme & Style',
        zh: '主题与样式',
        ja: 'テーマとスタイル',
        es: 'Tema y estilo',
        de: 'Design & Stil',
        fr: 'Thème et style',
      );

  static String get appThemeModeTitle => _pick(
        ko: '앱 테마 모드',
        en: 'App Theme Mode',
        zh: '应用主题模式',
        ja: 'アプリテーマモード',
        es: 'Modo de tema',
        de: 'App-Designmodus',
        fr: 'Mode de thème',
      );

  static String get themeDescLight => _pick(
        ko: '클린 화이트 (라이트 모드)',
        en: 'Clean White (Light Mode)',
        zh: '纯净白（浅色模式）',
        ja: 'クリーンホワイト（ライトモード）',
        es: 'Blanco limpio (Modo claro)',
        de: 'Clean White (Heller Modus)',
        fr: 'Blanc épuré (Mode clair)',
      );

  static String get themeDescPureBlack => _pick(
        ko: '트루 블랙 (OLED 완전 검정)',
        en: 'True Black (OLED Pure Black)',
        zh: '纯黑模式（OLED 极致省电黑）',
        ja: 'トゥルーブラック（OLED完全黒）',
        es: 'Negro puro (OLED True Black)',
        de: 'True Black (OLED Tiefschwarz)',
        fr: 'Noir absolu (OLED True Black)',
      );

  static String get themeDescDark => _pick(
        ko: '딥 차콜 다크 (기본)',
        en: 'Deep Charcoal Dark (Default)',
        zh: '深炭灰暗黑（默认）',
        ja: 'ディープチャコールダーク（標準）',
        es: ' Carbón oscuro (Predeterminado)',
        de: 'Anthrazit Dunkel (Standard)',
        fr: 'Anthracite sombre (Par défaut)',
      );

  static String get themeSegmentDark => _pick(
        ko: '다크',
        en: 'Dark',
        zh: '深色',
        ja: 'ダーク',
        es: 'Oscuro',
        de: 'Dunkel',
        fr: 'Sombre',
      );

  static String get themeSegmentBlack => _pick(
        ko: '블랙',
        en: 'Black',
        zh: '纯黑',
        ja: 'ブラック',
        es: 'Negro',
        de: 'Schwarz',
        fr: 'Noir',
      );

  static String get themeSegmentLight => _pick(
        ko: '화이트',
        en: 'Light',
        zh: '浅色',
        ja: 'ホワイト',
        es: 'Claro',
        de: 'Hell',
        fr: 'Clair',
      );

  static String get accentColorTitle => _pick(
        ko: '포인트 컬러',
        en: 'Accent Color',
        zh: '强调色',
        ja: 'アクセントカラー',
        es: 'Color de acento',
        de: 'Akzentfarbe',
        fr: 'Couleur d\'accentuation',
      );

  static String get accentColorSubtitle => _pick(
        ko: '버튼 및 주요 하이라이트에 적용될 포인트 색상입니다.',
        en: 'Highlight color applied to buttons and key UI elements.',
        zh: '应用于按钮和主要高亮元素的主题强调色。',
        ja: 'ボタンや主要なハイライトに適用されるポイントカラーです。',
        es: 'Color principal aplicado a los botones y elementos destacados.',
        de: 'Hervorhebungsfarbe für Schaltflächen und wichtige UI-Elemente.',
        fr: 'Couleur principale appliquée aux boutons et éléments clés.',
      );

  // ─── 개발자 응원하기 ───
  static String get sectionSupportDeveloper => _pick(
        ko: '개발자 응원하기',
        en: 'Support the Developer',
        zh: '支持开发者',
        ja: '開発者を応援する',
        es: 'Apoyar al desarrollador',
        de: 'Entwickler unterstützen',
        fr: 'Soutenir le développeur',
      );

  static String get supportCoffeeTitle => _pick(
        ko: '개발자에게 커피 한 잔 선물하기 ☕',
        en: 'Treat the Developer to a Coffee ☕',
        zh: '请开发者喝杯咖啡 ☕',
        ja: '開発者にコーヒーを1杯プレゼント ☕',
        es: 'Invítale un café al desarrollador ☕',
        de: 'Dem Entwickler einen Kaffee spendieren ☕',
        fr: 'Offrir un café au développeur ☕',
      );

  static String get supportCoffeeSubtitle => _pick(
        ko: '짧은 영상 광고 1편으로 앱 개발을 응원해주세요!',
        en: 'Support ongoing app development by watching a short video ad!',
        zh: '观看一段简短的视频广告，支持应用的持续开发！',
        ja: '短い動画広告を1本見て、アプリの開発を応援してください！',
        es: '¡Apoya el desarrollo de la app viendo un breve anuncio de video!',
        de: 'Unterstütze die Weiterentwicklung mit einem kurzen Werbevideo!',
        fr: 'Soutenez le développement de l\'application en regardant une courte pub !',
      );

  static String get supportWatchAdButton => _pick(
        ko: '광고 보고 응원하기',
        en: 'Watch Ad to Support',
        zh: '观看广告支持我们',
        ja: '広告を見て応援する',
        es: 'Ver anuncio para apoyar',
        de: 'Video ansehen & unterstützen',
        fr: 'Regarder une pub pour soutenir',
      );

  static String get preparingAdWaitSnackbar => _pick(
        ko: '광고를 준비하고 있습니다... 잠시만 기다려주세요.',
        en: 'Preparing ad... Please wait a moment.',
        zh: '正在准备广告... 请稍候。',
        ja: '広告を準備しています... 少々お待ちください。',
        es: 'Preparando anuncio... Espera un momento.',
        de: 'Werbung wird vorbereitet... Bitte kurz warten.',
        fr: 'Préparation de la publicité... Veuillez patienter.',
      );

  static String get supportThankYouTitle => _pick(
        ko: '따뜻한 응원 감사합니다! ❤️',
        en: 'Thank you for your support! ❤️',
        zh: '感谢您的温暖支持！❤️',
        ja: '温かい応援ありがとうございます！❤️',
        es: '¡Muchas gracias por tu apoyo! ❤️',
        de: 'Vielen Dank für deine Unterstützung! ❤️',
        fr: 'Merci beaucoup pour votre soutien ! ❤️',
      );

  static String get supportThankYouDesc => _pick(
        ko: '보내주신 소중한 응원, 더 좋은 앱으로 보답할게요.',
        en: 'Your support means the world to us. We\'ll keep making LOG even better!',
        zh: '您的每一份支持都是我们把应用做得更好的动力。',
        ja: 'いただいた大切な応援に、より良いアプリでお応えします。',
        es: 'Tu apoyo nos impulsa a seguir mejorando la aplicación cada día.',
        de: 'Deine Unterstützung motiviert uns, die App noch besser zu machen.',
        fr: 'Votre soutien est précieux, nous continuerons d\'améliorer l\'application.',
      );

  // ─── 앱 정보 및 약관 ───
  static String get sectionAppInfoAndLegal => _pick(
        ko: '앱 정보 및 약관',
        en: 'App Info & Legal',
        zh: '应用信息与条款',
        ja: 'アプリ情報と規約',
        es: 'Información y términos',
        de: 'App-Infos & Rechtliches',
        fr: 'Infos et mentions légales',
      );

  static String get appVersionTitle => _pick(
        ko: '앱 버전',
        en: 'App Version',
        zh: '应用版本',
        ja: 'アプリバージョン',
        es: 'Versión de la app',
        de: 'App-Version',
        fr: 'Version de l\'application',
      );

  static String get appVersionSubtitle => _pick(
        ko: '1.0.2 (최신 버전)',
        en: '1.0.2 (Latest)',
        zh: '1.0.2（最新版本）',
        ja: '1.0.2（最新バージョン）',
        es: '1.0.2 (Última versión)',
        de: '1.0.2 (Aktuell)',
        fr: '1.0.2 (Dernière version)',
      );

  static String get termsOfServiceTitle => _pick(
        ko: '서비스 이용약관',
        en: 'Terms of Service',
        zh: '服务使用条款',
        ja: 'サービス利用規約',
        es: 'Términos de servicio',
        de: 'Nutzungsbedingungen',
        fr: 'Conditions d\'utilisation',
      );

  static String get termsOfServiceSubtitle => _pick(
        ko: 'Log 서비스 이용 관련 기본 약관',
        en: 'General terms and conditions for using LOG',
        zh: 'Log 服务使用相关基本条款',
        ja: 'Logサービスの利用に関する基本規約',
        es: 'Condiciones generales para el uso de LOG',
        de: 'Allgemeine Bedingungen für die Nutzung von LOG',
        fr: 'Conditions générales d\'utilisation du service LOG',
      );

  static String get privacyPolicyTitle => _pick(
        ko: '개인정보 처리방침',
        en: 'Privacy Policy',
        zh: '隐私政策',
        ja: 'プライバシーポリシー',
        es: 'Política de privacidad',
        de: 'Datenschutzerklärung',
        fr: 'Politique de confidentialité',
      );

  static String get privacyPolicySubtitle => _pick(
        ko: '카메라, 저장공간 및 위치정보 보호 방침',
        en: 'How we protect your camera, storage, and location data',
        zh: '相机、存储空间及位置信息保护政策',
        ja: 'カメラ、ストレージおよび位置情報の保護方針',
        es: 'Política de protección de cámara, almacenamiento y ubicación',
        de: 'Schutz Ihrer Kamera-, Speicher- und Standortdaten',
        fr: 'Protection des données caméra, stockage et localisation',
      );

  static String get openSourceLicensesTitle => _pick(
        ko: '오픈소스 라이선스',
        en: 'Open Source Licenses',
        zh: '开源软件许可',
        ja: 'オープンソースライセンス',
        es: 'Licencias de código abierto',
        de: 'Open-Source-Lizenzen',
        fr: 'Licences open source',
      );

  static String get openSourceLicensesSubtitle => _pick(
        ko: '사용된 오픈소스 소프트웨어 라이선스 목록',
        en: 'List of open-source software licenses used',
        zh: '所使用的开源软件许可证列表',
        ja: '使用されているオープンソースソフトウェアのライセンス一覧',
        es: 'Lista de licencias de software de código abierto utilizadas',
        de: 'Liste der verwendeten Open-Source-Softwarelizenzen',
        fr: 'Liste des licences des logiciels open source utilisés',
      );

  static String get contactAndFeedbackTitle => _pick(
        ko: '문의 및 피드백',
        en: 'Contact & Feedback',
        zh: '联系与反馈',
        ja: 'お問い合わせ・フィードバック',
        es: 'Contacto y comentarios',
        de: 'Kontakt & Feedback',
        fr: 'Contact et commentaires',
      );

  static String get emailCopiedSnackbar => _pick(
        ko: '이메일 주소가 클립보드에 복사되었습니다.',
        en: 'Email address copied to clipboard.',
        zh: '邮箱地址已复制到剪贴板。',
        ja: 'メールアドレスがクリップボードにコピーされました。',
        es: 'Dirección de correo copiada al portapapeles.',
        de: 'E-Mail-Adresse in die Zwischenablage kopiert.',
        fr: 'Adresse e-mail copiée dans le presse-papiers.',
      );

  static String get termsOfServiceContent => _pick(
        ko: '''제 1 조 (목적)
본 약관은 Log(이하 "앱")가 제공하는 타임스탬프 카메라 및 앨범 관리 서비스의 이용조건 및 절차, 이용자와 앱의 권리, 의무, 책임사항을 규정함을 목적으로 합니다.

제 2 조 (서비스의 제공)
1. 앱은 사진 및 동영상 촬영 시 현재 시간, 스탬프 디자인 오버레이, 앨범 분류 기능을 무료로 제공합니다.
2. 앱은 단말기 내 로컬 환경에서 구동되며, 사용자가 촬영한 사진과 동영상은 외부 서버로 전송되지 않고 사용자의 기기에 안전하게 저장됩니다.

제 3 조 (이용자의 의무)
1. 이용자는 관계 법령, 본 약관의 규정 및 공서양속을 준수하여야 합니다.
2. 타인의 권리나 명예를 침해하는 촬영 행위의 책임은 이용자 본인에게 있습니다.

제 4 조 (면책조항)
1. 앱은 천재지변, 단말기 고장 또는 OS 업데이트로 인한 데이터 손실에 대해 책임을 지지 않으며, 중요한 미디어는 이용자가 사전에 백업해야 합니다.
2. 광고 시청 및 보상형 기능은 네트워크 상태에 따라 제공이 원활하지 않을 수 있습니다.

부칙: 본 약관은 2026년 11월 1일부터 효력을 발생합니다.''',
        en: '''Article 1 (Purpose)
These Terms of Service govern your use of the LOG timestamp camera and album management application ("the App") operated by bebong.

Article 2 (Provision of Service)
1. The App provides real-time timestamp overlays, location badges, photo/video capture, and calendar album organization.
2. The App operates locally on your device. Photos and videos you capture are saved safely on your device and are never uploaded to external servers.

Article 3 (User Obligations)
1. Users must comply with applicable laws and these Terms.
2. Users are solely responsible for ensuring that their recordings respect the privacy and rights of others.

Article 4 (Disclaimer)
1. The App is not liable for data loss caused by device failure, OS updates, or uninstallation. Please back up important media regularly.
2. Ad-supported and rewarded features require an active network connection.

Effective Date: November 1, 2026.''',
        zh: '''第一条（目的）
本条款旨在规定 Log（以下简称“本应用”）提供的时间戳相机及相册管理服务的使用条件、程序以及用户与本应用之间的权利、义务和责任事项。

第二条（服务的提供）
1. 本应用免费提供拍照与录像时的实时时间戳叠加、位置标签及相册分类功能。
2. 本应用在设备本地环境中运行，用户拍摄的照片和视频不会上传至外部服务器，而是安全保存在用户的设备中。

第三条（用户的义务）
1. 用户应遵守相关法律法规、本条款规定及社会公序良俗。
2. 因侵犯他人权利或名誉的拍摄行为所产生的责任由用户本人承担。

第四条（免责声明）
1. 对于因不可抗力、设备故障或系统更新导致的数据丢失，本应用不承担责任，重要媒体文件请用户提前备份。
2. 广告观看及激励解锁功能可能受网络状况影响。

附则：本条款自 2026 年 11 月 1 日起生效。''',
        ja: '''第1条（目的）
本規約は、Log（以下「本アプリ」）が提供するタイムスタンプカメラおよびアルバム管理サービスの利用条件・手続、ならびに利用者と本アプリの権利・義務・責任事項を定めることを目的とします。

第2条（サービスの提供）
1. 本アプリは、写真および動画撮影時の現在時刻・スタンプデザイン合成、アルバム分類機能を無料で提供します。
2. 本アプリは端末内のローカル環境で動作し、撮影された写真や動画は外部サーバーへ送信されることなく端末内に安全に保存されます。

第3条（利用者の義務）
1. 利用者は関係法令、本規約および公序良俗を遵守しなければなりません。
2. 他者の権利や名誉を侵害する撮影行為の責任は利用者本人にあります。

第4条（免責事項）
1. 端末の故障やOSアップデート等によるデータ損失について本アプリは責任を負いません。重要なメディアは事前にバックアップしてください。
2. 広告視聴およびリワード機能は通信環境により利用できない場合があります。

附則：本規約は2026年11月1日より施行します。''',
        es: '''Artículo 1 (Propósito)
Estos Términos de Servicio regulan el uso de la aplicación de cámara con marca de tiempo y gestión de álbumes LOG ("la Aplicación").

Artículo 2 (Prestación del Servicio)
1. La Aplicación ofrece superposición de fecha y hora en tiempo real, etiquetas de ubicación y organización de álbumes en calendario para fotos y videos.
2. La Aplicación funciona localmente en tu dispositivo. Tus fotos y videos se guardan de forma segura en tu dispositivo y no se envían a servidores externos.

Artículo 3 (Obligaciones del Usuario)
1. El usuario debe cumplir con las leyes aplicables y estos Términos.
2. El usuario es responsable del uso adecuado de la cámara respetando los derechos de terceros.

Artículo 4 (Exención de Responsabilidad)
1. La Aplicación no se hace responsable de la pérdida de datos causada por fallos del dispositivo o actualizaciones del sistema. Se recomienda realizar copias de seguridad periódicas.
2. Las funciones de anuncios con recompensa dependen de la conexión de red.

Fecha de entrada en vigor: 1 de noviembre de 2026.''',
        de: '''§ 1 (Zweck)
Diese Nutzungsbedingungen regeln die Verwendung der Zeitstempel-Kamera- und Albumverwaltungs-App LOG („die App“).

§ 2 (Bereitstellung des Dienstes)
1. Die App bietet Echtzeit-Zeitstempel, Standort-Tags sowie Foto-/Videoaufnahmen und Kalender-Alben.
2. Die App arbeitet lokal auf Ihrem Gerät. Aufgenommene Fotos und Videos werden sicher auf Ihrem Gerät gespeichert und nicht an externe Server übertragen.

§ 3 (Pflichten des Nutzers)
1. Nutzer müssen geltende Gesetze und diese Bedingungen einhalten.
2. Nutzer sind selbst dafür verantwortlich, bei Aufnahmen die Rechte Dritter zu achten.

§ 4 (Haftungsausschluss)
1. Die App haftet nicht für Datenverlust durch Gerätedefekte oder Systemupdates. Bitte sichern Sie wichtige Medien regelmäßig.
2. Werbefinanzierte Freischaltfunktionen erfordern eine aktive Internetverbindung.

Gültig ab: 1. November 2026.''',
        fr: '''Article 1 (Objet)
Les présentes Conditions d'utilisation régissent l'utilisation de l'application d'appareil photo horodaté et de gestion d'albums LOG (« l'Application »).

Article 2 (Fourniture du service)
1. L'Application propose gratuitement l'ajout d'horodatages, de badges de lieu et le classement par calendrier pour vos photos et vidéos.
2. L'Application fonctionne localement sur votre appareil. Vos photos et vidéos restent stockées en toute sécurité sur votre appareil et ne sont pas envoyées sur des serveurs externes.

Article 3 (Obligations de l'utilisateur)
1. L'utilisateur s'engage à respecter les lois en vigueur et les présentes conditions.
2. L'utilisateur est seul responsable du respect du droit à l'image et de la vie privée d'autrui.

Article 4 (Limitation de responsabilité)
1. L'Application ne saurait être tenue responsable des pertes de données liées à une panne de l'appareil ou une mise à jour système. Veuillez sauvegarder régulièrement vos médias importants.
2. Les fonctionnalités liées aux publicités nécessitent une connexion réseau.

Date d'entrée en vigueur : 1er novembre 2026.''',
      );

  static String get privacyPolicyContent => _pick(
        ko: '''Log(이하 "앱")는 사용자의 개인정보를 매우 소중하게 생각하며, 관련 법령을 준수합니다.

1. 수집하는 개인정보 항목 및 목적
앱은 회원의 개인정보를 별도로 수집하거나 서버에 저장하지 않습니다.
- 카메라 권한: 사진 및 동영상 촬영 목적으로만 사용됩니다.
- 오디오/마이크 권한: 동영상 녹화 시 소리 녹음 목적으로만 사용됩니다.
- 저장공간/사진 라이브러리 권한: 촬영한 사진 및 동영상을 기기에 저장하고 불러오기 위한 목적으로만 사용됩니다.
- 위치 권한(선택): 사용자가 스탬프에 위치 표시 기능을 활성화한 경우에 한해 현재 위치명을 표기하는 데 로컬에서만 사용됩니다.

2. 제3자 제공 및 외부 전송
앱에서 생성된 모든 사진, 동영상, 캘린더 기록 데이터는 사용자 단말기 내부에만 저장되며, 외부 서버로 전송되거나 제3자에게 제공되지 않습니다.

3. 구글 애드몹(Google AdMob) 광고
앱은 개발 및 서비스 유지를 위해 Google AdMob 광고 SDK를 포함하고 있습니다. AdMob은 맞춤형 광고 제공을 위해 비식별 광고 ID 및 기기 정보를 처리할 수 있으며, 이에 대한 자세한 내용은 Google 개인정보처리방침을 따릅니다.

4. 문의처
개인정보 보호와 관련된 문의사항은 kmh96503981@gmail.com 으로 연락주시기 바랍니다.

공고일자: 2026년 11월 1일''',
        en: '''LOG ("the App") values your privacy and complies with applicable data protection laws.

1. Permissions & Purpose of Use
The App does not collect or store your personal photos, videos, or notes on external servers.
- Camera Permission: Used solely for taking photos and recording videos.
- Microphone Permission: Used solely for recording audio during video capture.
- Photo Library / Storage Permission: Used solely to save and load photos and videos on your device.
- Location Permission (Optional): Used locally on your device only when you enable the location tag feature.

2. Local Storage & No External Upload
All photos, videos, and calendar logs created in the App are stored exclusively on your device and are never transmitted to external servers.

3. Google AdMob Advertising
The App uses the Google AdMob SDK to display ads. AdMob may process anonymized advertising IDs and device information in accordance with Google's Privacy Policy.

4. Contact Us
If you have any questions about privacy, please contact us at kmh96503981@gmail.com.

Effective Date: November 1, 2026''',
        zh: '''Log（以下简称“本应用”）非常重视用户的个人隐私，并严格遵守相关法律法规。

1. 权限使用说明与目的
本应用不会在外部服务器上收集或存储您的个人照片、视频或笔记。
- 相机权限：仅用于拍摄照片和录制视频。
- 麦克风权限：仅用于在录制视频时录制声音。
- 存储/相册权限：仅用于在设备上保存和读取照片及视频。
- 位置权限（可选）：仅在用户开启时间戳位置显示功能时，在本地用于转换当前位置名称。

2. 本地存储与第三方共享
在本应用中生成的所有照片、视频和日历记录数据均仅保存在用户设备内部，绝不会传输至外部服务器或提供给第三方。

3. Google AdMob 广告服务
为维持服务与开发，本应用集成了 Google AdMob 广告 SDK。AdMob 可能会根据 Google 隐私政策处理非个人识别的广告 ID 和设备信息。

4. 联系方式
如有隐私保护相关疑问，请联系：kmh96503981@gmail.com

公布日期：2026 年 11 月 1 日''',
        ja: '''Log（以下「本アプリ」）はユーザーのプライバシーを尊重し、関連法令を遵守します。

1. 使用する権限と目的
本アプリは、ユーザーの個人情報や写真・動画を外部サーバーに収集・保存しません。
- カメラ権限：写真および動画の撮影目的にのみ使用されます。
- マイク権限：動画撮影時の音声録音目的にのみ使用されます。
- 写真ライブラリ・ストレージ権限：撮影した写真や動画を端末に保存・読み込みするためにのみ使用されます。
- 位置情報権限（任意）：位置表示機能を有効にした場合に限り、現在地名を表示するために端末内でのみ使用されます。

2. 第三者提供および外部送信
本アプリで作成されたすべての写真、動画、カレンダー記録データは端末内にのみ保存され、外部サーバーへの送信や第三者への提供は行われません。

3. Google AdMob 広告について
本アプリはサービス維持のため Google AdMob SDK を利用しています。AdMob は Google のプライバシーポリシーに基づき広告IDや端末情報を処理する場合があります。

4. お問い合わせ
プライバシーに関するお問い合わせは kmh96503981@gmail.com までご連絡ください。

制定日：2026年11月1日''',
        es: '''LOG ("la Aplicación") valora tu privacidad y cumple con las leyes de protección de datos aplicables.

1. Permisos y finalidad de uso
La Aplicación no recopila ni almacena tus fotos, videos o notas en servidores externos.
- Permiso de Cámara: Se utiliza únicamente para tomar fotos y grabar videos.
- Permiso de Micrófono: Se utiliza únicamente para grabar audio en los videos.
- Permiso de Galería / Almacenamiento: Se utiliza únicamente para guardar y cargar fotos y videos en tu dispositivo.
- Permiso de Ubicación (Opcional): Se utiliza localmente solo cuando activas la etiqueta de ubicación en el sello.

2. Almacenamiento local
Todas las fotos, videos y registros del calendario se guardan exclusivamente en tu dispositivo y no se comparten con terceros.

3. Publicidad de Google AdMob
La Aplicación incluye el SDK de Google AdMob para mostrar anuncios, el cual puede procesar identificadores publicitarios conforme a la Política de Privacidad de Google.

4. Contacto
Para cualquier consulta sobre privacidad, escríbenos a kmh96503981@gmail.com.

Fecha de publicación: 1 de noviembre de 2026''',
        de: '''LOG („die App“) legt größten Wert auf den Schutz Ihrer Daten und hält sich an die geltenden Datenschutzgesetze.

1. Berechtigungen & Verwendungszweck
Die App speichert Ihre persönlichen Fotos, Videos oder Notizen nicht auf externen Servern.
- Kameraberechtigung: Wird ausschließlich zum Aufnehmen von Fotos und Videos verwendet.
- Mikrofonberechtigung: Wird ausschließlich für die Tonaufnahme bei Videos verwendet.
- Foto-/Speicherberechtigung: Wird ausschließlich zum Speichern und Laden von Medien auf Ihrem Gerät verwendet.
- Standortberechtigung (Optional): Wird nur lokal verwendet, wenn Sie die Standortanzeige im Zeitstempel aktivieren.

2. Lokale Speicherung
Alle in der App erstellten Fotos, Videos und Kalendereinträge verbleiben ausschließlich auf Ihrem Gerät.

3. Google AdMob-Werbung
Die App nutzt das Google AdMob SDK zur Anzeige von Werbung gemäß der Datenschutzerklärung von Google.

4. Kontakt
Bei Fragen zum Datenschutz erreichen Sie uns unter kmh96503981@gmail.com.

Stand: 1. November 2026''',
        fr: '''LOG (« l'Application ») accorde une grande importance à la protection de votre vie privée et respecte la réglementation en vigueur.

1. Autorisations et finalités
L'Application ne collecte ni ne stocke vos photos, vidéos ou notes sur des serveurs externes.
- Appareil photo : Utilisé uniquement pour prendre des photos et enregistrer des vidéos.
- Microphone : Utilisé uniquement pour enregistrer le son lors des vidéos.
- Photothèque / Stockage : Utilisé uniquement pour enregistrer et charger vos médias sur votre appareil.
- Localisation (Optionnel) : Utilisée localement uniquement lorsque vous activez l'affichage du lieu sur l'horodatage.

2. Stockage local
Toutes les photos, vidéos et entrées du calendrier sont conservées exclusivement sur votre appareil.

3. Publicités Google AdMob
L'Application intègre le SDK Google AdMob pour diffuser des publicités conformément aux règles de confidentialité de Google.

4. Contact
Pour toute question relative à la confidentialité, contactez-nous à : kmh96503981@gmail.com.

Date d'effet : 1er novembre 2026''',
      );

  // ─── 하단 내비게이션 바 & 화면별 별칭(Aliases) ───
  static String get navPickPhoto => galleryPickerTitle;
  static String get navAlbum => _pick(
        ko: '앨범',
        en: 'Album',
        zh: '相册',
        ja: 'アルバム',
        es: 'Álbum',
        de: 'Album',
        fr: 'Album',
      );
  static String get navStampManage => stampManagementTitle;
  static String get navSettings => settingsTitle;

  // 캘린더 & 폴더 별칭
  static String get calendarViewTooltip => tooltipCalendarView;
  static String get gridViewTooltip => tooltipGridView;
  static String get recordButton => btnRecord;
  static String get emptyRecordToday => emptyTodayTitle;
  static String get emptyRecordFuture => emptyFutureTitle;
  static String get emptyRecordPast => emptyPastTitle;
  static String get emptyRecordTodaySub => emptyTodaySubtitle;
  static String get emptyGridSub => emptyGridSubtitle;
  static String get folderSelectTitle => selectFolderTitle;
  static String get folderNewCreate => createNewFolder;
  static String get folderEditTooltip => editFolderTitle;
  static String get folderDeleteTooltip => deleteFolderTitle;
  static String get folderDeleteTitle => deleteFolderTitle;
  static String folderDeleteConfirm(String name) => deleteFolderConfirmMessage(name);
  static String get colorSelectTitle => selectColorTitle;
  static String get apply => applyAction;
  static String get folderCreateSubtitle => createFolderSubtitle;
  static String get folderCustomColor => customColorPick;
  static String get folderExistsSnackbar => folderAlreadyExistsSnackbar;
  static String get folderCreateButton => _pick(
        ko: '폴더 생성하기',
        en: 'Create Folder',
        zh: '创建文件夹',
        ja: 'フォルダを作成',
        es: 'Crear carpeta',
        de: 'Ordner erstellen',
        fr: 'Créer le dossier',
      );
  static String get folderEditTitle => editFolderTitle;
  static String get folderEditDefaultSubtitle => editDefaultFolderSubtitle;
  static String get folderEditCustomSubtitle => editCustomFolderSubtitle;
  static String get folderDefaultNameHelper => defaultFolderRenameDisabled;

  // 사진 고르기(갤러리 피커) 별칭
  static String get galleryRecentItems => recentAlbumName;
  static String get galleryPermissionAllNeededTitle => permTitleLimited;
  static String get galleryPermissionNeededTitle => permTitleDenied;
  static String get galleryPermissionLimitedDesc => permDescLimited;
  static String get galleryPermissionDeniedDesc => permDescDenied;
  static String get galleryPermissionAllowAllBtn => permBtnLimited;
  static String get galleryPermissionGoSettingsBtn => permBtnDenied;
  static String get galleryPermissionGuideBottom => permGuideFooter;
  static String get galleryPickPhotoTitle => galleryPickerTitle;
  static String get galleryBannerDenied => bannerPermissionDenied;
  static String get galleryBannerLimited => bannerPermissionLimited;
  static String get galleryEmptyPhotos => noPhotosInGallery;

  // 사진 상세 & 리뷰 별칭
  static String get shareDefaultText => defaultShareText;
  static String get memoDeleteTitle => deleteMemoTitle;
  static String get memoDeleteWarning => deleteMemoWarning;
  static String get videoDeleteTitle => deleteMediaConfirmTitle(true);
  static String get photoDeleteTitle => deleteMediaConfirmTitle(false);
  static String get videoDeleteWarning => deleteMediaWarning(true);
  static String get photoDeleteWarning => deleteMediaWarning(false);
  static String get memoAddPlaceholder => addMemoPlaceholder;
  static String get memoDeleteTooltip => _pick(
        ko: '메모 삭제',
        en: 'Delete Note',
        zh: '删除备注',
        ja: 'メモを削除',
        es: 'Eliminar nota',
        de: 'Notiz löschen',
        fr: 'Supprimer la note',
      );
  static String get videoPlayError => videoNotFoundError;
  static String get fullscreen => fullscreenLabel;
  static String saveError(Object e) => photoSaveError(e);

  // 스탬프 관리 별칭
  static String get favoritesDesc => favoritesDescription;
  static String get deckSlotPrefix => _pick(
        ko: '즐겨찾기',
        en: 'Slot',
        zh: '槽位',
        ja: 'スロット',
        es: 'Ranura',
        de: 'Platz',
        fr: 'Emplacement',
      );

  // 설정 화면 별칭
  static String get sectionTimestamp => sectionTimestampSettings;
  static String get locationToDisplayTitle => locationToDisplay;
  static String get refreshGpsTooltip => tooltipRefreshGps;
  static String get sectionTheme => sectionThemeAndStyle;
  static String get themeLightDesc => themeDescLight;
  static String get themePureBlackDesc => themeDescPureBlack;
  static String get themeDarkDesc => themeDescDark;
  static String get accentColorSub => accentColorSubtitle;
  static String get sectionSupport => sectionSupportDeveloper;
  static String get supportTitle => supportCoffeeTitle;
  static String get supportSub => supportCoffeeSubtitle;
  static String get supportButton => supportWatchAdButton;
  static String get sectionAppInfo => sectionAppInfoAndLegal;
  static String get appVersionSub => appVersionSubtitle;
  static String get termsOfServiceSub => termsOfServiceSubtitle;
  static String get privacyPolicySub => privacyPolicySubtitle;
  static String get openSourceLicenseTitle => openSourceLicensesTitle;
  static String get openSourceLicenseSub => openSourceLicensesSubtitle;
  static String get contactFeedbackTitle => contactAndFeedbackTitle;
  static String locationUpdatedSnackbar(String addr) => gpsUpdatedSnackbar(addr);
  static String get locationFetchErrorDefault => locErrFailed;
  static String get locationTagPosTitle => locationPositionTitle;
  static String get locationTagPosSub => locationPositionSubtitle;
  static String get gpsRefreshButton => refreshGpsButton;
  static String get selectLocationSheetSub => selectLocationSheetSubtitle;
  static String get noGpsOptionsMeasured => noGpsOptionsInfo;
  static String get customLocationTextTitle => enterCustomLocationTitle;
  static String get customLocationTextSubSelected => customLocationSelectedSubtitle;
  static String get customLocationTextSubEmpty => customLocationUnselectedSubtitle;
  static String get customLocationDialogTitle => enterCustomLocationTitle;
  static String get customLocationDialogSub => customLocationDialogDesc;
  static String get customLocationDialogHint => customLocationHint;
  static String get preparingAdSnackbar => preparingAdWaitSnackbar;
  static String get supportThankYouSub => supportThankYouDesc;
  static String get termsOfServiceBody => termsOfServiceContent;
  static String get privacyPolicyBody => privacyPolicyContent;
  static String get accentColorPickerTitle => selectAccentColorTitle;
}

/// 각 국가/언어별 날짜·시간·요일·AM/PM 표시 순서 및 포맷 변환기
class TimestampLocaleFormatter {
  static String get lang => AppLocalizations.languageCode;
  static DateOrderType get dateOrder => AppLocalizations.currentInfo.dateOrder;

  /// 달력 상단 요일 헤더 (일요일 ~ 토요일, 7개)
  static List<String> get calendarSunToSatWeekdays {
    switch (lang) {
      case 'en':
        return const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
      case 'zh':
        return const ['日', '一', '二', '三', '四', '五', '六'];
      case 'ja':
        return const ['日', '月', '火', '水', '木', '金', '土'];
      case 'es':
        return const ['DOM', 'LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB'];
      case 'de':
        return const ['SO', 'MO', 'DI', 'MI', 'DO', 'FR', 'SA'];
      case 'fr':
        return const ['DIM', 'LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM'];
      case 'ko':
      default:
        return const ['일', '월', '화', '수', '목', '금', '토'];
    }
  }

  /// 스탬프 위클리 바 (월요일 ~ 일요일, 7개 1글자 약어)
  static List<String> get stampMonToSunSingleChars {
    switch (lang) {
      case 'ko':
        return const ['월', '화', '수', '목', '금', '토', '일'];
      case 'zh':
        return const ['一', '二', '三', '四', '五', '六', '日'];
      case 'ja':
        return const ['月', '火', '水', '木', '金', '土', '日'];
      case 'es':
        return const ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
      case 'de':
        return const ['M', 'D', 'M', 'D', 'F', 'S', 'S'];
      case 'fr':
        return const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
      case 'en':
      default:
        return const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    }
  }

  /// 짧은 요일명 (월=1 .. 일=7)
  static String shortWeekday(DateTime dt, {String? overrideLang}) {
    final code = overrideLang ?? lang;
    final idx = (dt.weekday - 1).clamp(0, 6);
    switch (code) {
      case 'en':
        return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][idx];
      case 'zh':
        return const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][idx];
      case 'ja':
        return const ['月', '火', '水', '木', '金', '土', '日'][idx];
      case 'es':
        return const ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'][idx];
      case 'de':
        return const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][idx];
      case 'fr':
        return const ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'][idx];
      case 'ko':
      default:
        return const ['월', '화', '수', '목', '금', '토', '일'][idx];
    }
  }

  /// 전체 요일명 (월=1 .. 일=7)
  static String fullWeekday(DateTime dt, {String? overrideLang}) {
    final code = overrideLang ?? lang;
    final idx = (dt.weekday - 1).clamp(0, 6);
    switch (code) {
      case 'en':
        return const [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ][idx];
      case 'zh':
        return const [
          '星期一',
          '星期二',
          '星期三',
          '星期四',
          '星期五',
          '星期六',
          '星期日',
        ][idx];
      case 'ja':
        return const [
          '月曜日',
          '火曜日',
          '水曜日',
          '木曜日',
          '金曜日',
          '土曜日',
          '日曜日',
        ][idx];
      case 'es':
        return const [
          'Lunes',
          'Martes',
          'Miércoles',
          'Jueves',
          'Viernes',
          'Sábado',
          'Domingo',
        ][idx];
      case 'de':
        return const [
          'Montag',
          'Dienstag',
          'Mittwoch',
          'Donnerstag',
          'Freitag',
          'Samstag',
          'Sonntag',
        ][idx];
      case 'fr':
        return const [
          'Lundi',
          'Mardi',
          'Mercredi',
          'Jeudi',
          'Vendredi',
          'Samedi',
          'Dimanche',
        ][idx];
      case 'ko':
      default:
        return const [
          '월요일',
          '화요일',
          '수요일',
          '목요일',
          '금요일',
          '토요일',
          '일요일',
        ][idx];
    }
  }

  /// 오전/오후 (AM/PM) 현지화 문자열
  static String localizedPeriod(DateTime dt, {bool asciiOnly = false}) {
    final isAm = dt.hour < 12;
    if (asciiOnly) return isAm ? 'AM' : 'PM';
    switch (lang) {
      case 'ko':
        return isAm ? '오전' : '오후';
      case 'zh':
        return isAm ? '上午' : '下午';
      case 'ja':
        return isAm ? '午前' : '午後';
      case 'es':
      case 'de':
      case 'fr':
      case 'en':
      default:
        return isAm ? 'AM' : 'PM';
    }
  }

  /// 짧은 월 이름 (Jan..Dec / 1월..12월 등)
  static String shortMonthName(DateTime dt, {String? overrideLang}) {
    final code = overrideLang ?? lang;
    final m = (dt.month - 1).clamp(0, 11);
    switch (code) {
      case 'ko':
        return '${dt.month}월';
      case 'zh':
        return '${dt.month}月';
      case 'ja':
        return '${dt.month}月';
      case 'es':
        return const [
          'ene',
          'feb',
          'mar',
          'abr',
          'may',
          'jun',
          'jul',
          'ago',
          'sep',
          'oct',
          'nov',
          'dic',
        ][m];
      case 'de':
        return const [
          'Jan.',
          'Feb.',
          'März',
          'Apr.',
          'Mai',
          'Juni',
          'Juli',
          'Aug.',
          'Sept.',
          'Okt.',
          'Nov.',
          'Dez.',
        ][m];
      case 'fr':
        return const [
          'janv.',
          'févr.',
          'mars',
          'avr.',
          'mai',
          'juin',
          'juil.',
          'août',
          'sept.',
          'oct.',
          'nov.',
          'déc.',
        ][m];
      case 'en':
      default:
        return const [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ][m];
    }
  }

  /// 전체 월 이름 (January..December / 1월..12월 등)
  static String fullMonthName(DateTime dt, {String? overrideLang}) {
    final code = overrideLang ?? lang;
    final m = (dt.month - 1).clamp(0, 11);
    switch (code) {
      case 'ko':
        return '${dt.month}월';
      case 'zh':
        return '${dt.month}月';
      case 'ja':
        return '${dt.month}月';
      case 'es':
        return const [
          'enero',
          'febrero',
          'marzo',
          'abril',
          'mayo',
          'junio',
          'julio',
          'agosto',
          'septiembre',
          'octubre',
          'noviembre',
          'diciembre',
        ][m];
      case 'de':
        return const [
          'Januar',
          'Februar',
          'März',
          'April',
          'Mai',
          'Juni',
          'Juli',
          'August',
          'September',
          'Oktober',
          'November',
          'Dezember',
        ][m];
      case 'fr':
        return const [
          'janvier',
          'février',
          'mars',
          'avril',
          'mai',
          'juin',
          'juillet',
          'août',
          'septembre',
          'octobre',
          'novembre',
          'décembre',
        ][m];
      case 'en':
      default:
        return const [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ][m];
    }
  }

  /// 숫자형 년/월/일 포맷 (국가별 YMD / MDY / DMY 자동 재배열)
  static String formatNumericDate(
    DateTime dt, {
    String sep = '.',
    bool shortYear = false,
    bool padMonthDay = true,
  }) {
    final y = shortYear
        ? (dt.year % 100).toString().padLeft(2, '0')
        : dt.year.toString().padLeft(4, '0');
    final m = padMonthDay ? dt.month.toString().padLeft(2, '0') : '${dt.month}';
    final d = padMonthDay ? dt.day.toString().padLeft(2, '0') : '${dt.day}';

    switch (dateOrder) {
      case DateOrderType.mdy:
        return '$m$sep$d$sep$y';
      case DateOrderType.dmy:
        return '$d$sep$m$sep$y';
      case DateOrderType.ymd:
        return '$y$sep$m$sep$d';
    }
  }

  /// 숫자형 월/일 포맷 (국가별 MD / DM 자동 재배열)
  static String formatNumericMonthDay(
    DateTime dt, {
    String sep = '.',
    bool pad = true,
  }) {
    final m = pad ? dt.month.toString().padLeft(2, '0') : '${dt.month}';
    final d = pad ? dt.day.toString().padLeft(2, '0') : '${dt.day}';
    if (dateOrder == DateOrderType.dmy) {
      return '$d$sep$m';
    }
    return '$m$sep$d';
  }

  /// 언어별 자연스러운 년+월+일 텍스트 (예: 2026년 11월 14일 / Nov 14, 2026 / 2026年11月14日 / 14 nov 2026)
  static String formatWordDate(
    DateTime dt, {
    bool shortYear = false,
    bool fullMonth = false,
    bool padMonthDay = false,
  }) {
    final y = shortYear
        ? (dt.year % 100).toString().padLeft(2, '0')
        : dt.year.toString();
    final mNum = padMonthDay ? dt.month.toString().padLeft(2, '0') : '${dt.month}';
    final dNum = padMonthDay ? dt.day.toString().padLeft(2, '0') : '${dt.day}';
    final mName = fullMonth ? fullMonthName(dt) : shortMonthName(dt);

    switch (lang) {
      case 'ko':
        return '$y년 $mNum월 $dNum일';
      case 'zh':
      case 'ja':
        return '$y年$mNum月$dNum日';
      case 'en':
        return '$mName $dNum, $y';
      case 'es':
        return fullMonth ? '$dNum de $mName de $y' : '$dNum $mName $y';
      case 'de':
        return '$dNum. $mName $y';
      case 'fr':
        return '$dNum $mName $y';
      default:
        return '$mName $dNum, $y';
    }
  }

  /// 언어별 자연스러운 월+일 텍스트 (예: 11월 14일 / Nov 14 / 11月14日 / 14 nov / 14. Nov.)
  static String formatWordMonthDay(
    DateTime dt, {
    bool fullMonth = false,
    bool padDay = false,
  }) {
    final mNum = '${dt.month}';
    final dNum = padDay ? dt.day.toString().padLeft(2, '0') : '${dt.day}';
    final mName = fullMonth ? fullMonthName(dt) : shortMonthName(dt);

    switch (lang) {
      case 'ko':
        return '$mNum월 $dNum일';
      case 'zh':
      case 'ja':
        return '$mNum月$dNum日';
      case 'en':
        return '$mName $dNum';
      case 'es':
        return fullMonth ? '$dNum de $mName' : '$dNum $mName';
      case 'de':
        return '$dNum. $mName';
      case 'fr':
        return '$dNum $mName';
      default:
        return '$mName $dNum';
    }
  }

  /// 언어별 12시간제 시각 포맷 (AM/PM 위치 및 오전/오후/上午/午前 자동 반영)
  static String format12hTime(
    DateTime dt, {
    bool padHour = true,
    bool localizePeriod = true,
    bool useUnitWords = false,
  }) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final hStr = padHour ? h12.toString().padLeft(2, '0') : '$h12';
    final mStr = dt.minute.toString().padLeft(2, '0');
    final minUnpadded = '${dt.minute}';
    final p = localizedPeriod(dt, asciiOnly: !localizePeriod);

    if (useUnitWords) {
      final mPart = padHour ? mStr : minUnpadded;
      switch (lang) {
        case 'ko':
          return '$p $hStr시 $mPart분';
        case 'zh':
          return '$p $hStr时$mPart分';
        case 'ja':
          return '$p $hStr時$mPart分';
        case 'de':
          final h24 = padHour ? dt.hour.toString().padLeft(2, '0') : '${dt.hour}';
          return '$h24:$mStr Uhr';
        case 'fr':
          final h24 = padHour ? dt.hour.toString().padLeft(2, '0') : '${dt.hour}';
          return '${h24}h$mStr';
        case 'es':
        case 'en':
        default:
          return '$hStr:$mStr $p';
      }
    }

    if (AppLocalizations.currentInfo.amPmBeforeTime) {
      return '$p $hStr:$mStr';
    } else {
      return '$hStr:$mStr $p';
    }
  }

  /// 달력 상단 월 헤더 (예: 2026년 11월 / November 2026 / 2026年11月 / Noviembre 2026)
  static String formatCalendarMonthHeader(DateTime dt) {
    switch (lang) {
      case 'ko':
        return '${dt.year}년 ${dt.month}월';
      case 'zh':
      case 'ja':
        return '${dt.year}年${dt.month}月';
      case 'es':
        final m = fullMonthName(dt);
        final cap = m.isNotEmpty ? '${m[0].toUpperCase()}${m.substring(1)}' : m;
        return '$cap ${dt.year}';
      case 'fr':
        final m = fullMonthName(dt);
        final cap = m.isNotEmpty ? '${m[0].toUpperCase()}${m.substring(1)}' : m;
        return '$cap ${dt.year}';
      case 'de':
      case 'en':
      default:
        return '${fullMonthName(dt)} ${dt.year}';
    }
  }

  /// 그리드 뷰 월 헤더 ("2026.11" -> 국가별 월/년 또는 년.월)
  static String formatGridMonthKey(String monthKey) {
    final parts = monthKey.split('.');
    if (parts.length == 2) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (y != null && m != null) {
        return formatCalendarMonthHeader(DateTime(y, m, 1));
      }
    }
    return monthKey;
  }

  /// 캘린더 시트 및 상세 화면의 선택된 날짜 표시 (예: 2026.11.14 (토) / 11.14.2026 (Sat) / 14.11.2026 (sáb))
  static String formatSelectedDayHeader(DateTime dt) {
    return '${formatNumericDate(dt, sep: '.')} (${shortWeekday(dt)})';
  }

  /// 사진 상세 화면 상단 날짜 표시 (예: 2026년 11월 14일 (토) / Nov 14, 2026 (Sat))
  static String formatPhotoDetailHeaderDate(DateTime dt) {
    return '${formatWordDate(dt)} (${shortWeekday(dt)})';
  }

  static String formatDetailDateHeader(DateTime dt) =>
      formatPhotoDetailHeaderDate(dt);

  static String localizedAmPm(bool isAm) =>
      localizedPeriod(DateTime(2026, 1, 1, isAm ? 9 : 15));

  static String shortWeekdayByIndex(int weekday) =>
      shortWeekday(DateTime(2026, 1, 4 + weekday.clamp(1, 7)));

  static String fullWeekdayByIndex(int weekday) =>
      fullWeekday(DateTime(2026, 1, 4 + weekday.clamp(1, 7)));

  /// 사진 상세 및 기록 리스트의 시간 표시 (예: 오후 2:11 / 2:11 PM / 下午 2:11 / 午後 2:11)
  static String formatRecordTime(DateTime dt) {
    return format12hTime(dt, padHour: false, localizePeriod: true);
  }

  // ─── 13개 기본(Legacy) 스탬프 전용 포맷터 ───

  /// n2_1 상단 날짜+요일: "2026년 11월 14일 (토)" / "Nov 14, 2026 (Sat)" / "2026年11月14日 (周六)"
  static String formatLegacyN2_1Date(DateTime dt) {
    return '${formatWordDate(dt, padMonthDay: true)} (${shortWeekday(dt)})';
  }

  /// s1_1 / s1_2 프레임 스탬프: "2026.11.14.토 오후 02:11" / "11.14.2026 Sat 02:11 PM" / "14.11.2026 Sa 02:11 PM"
  static String formatLegacyS1_2(
    DateTime dt, {
    bool shortYear = false,
    bool padHour = true,
  }) {
    final d = formatNumericDate(dt, sep: '.', shortYear: shortYear);
    final w = shortWeekday(dt);
    final t = format12hTime(dt, padHour: padHour, localizePeriod: true);
    if (lang == 'ko') {
      return '$d.$w $t';
    } else if (lang == 'ja') {
      return '$d($w) $t';
    }
    return '$d $w $t';
  }

  /// s2_2 하단 날짜: "2026 Nov 14" / "Nov 14, 2026" / "14 Nov 2026"
  static String formatLegacyS2_2Date(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = shortMonthName(dt);
    final y = '${dt.year}';
    switch (dateOrder) {
      case DateOrderType.mdy:
        return '$m $d, $y';
      case DateOrderType.dmy:
        return '$d $m $y';
      case DateOrderType.ymd:
        if (lang == 'ko' || lang == 'zh' || lang == 'ja') {
          return formatWordDate(dt, padMonthDay: true);
        }
        return '$y $m $d';
    }
  }

  /// s3_1 중앙 월/일: "November 14" / "11월 14일" / "11月14日" / "14 de noviembre"
  static String formatLegacyS3_1MonthDay(DateTime dt) {
    return formatWordMonthDay(dt, fullMonth: true, padDay: true);
  }

  /// style1 좌측/우측 숫자 (YMD/MDY는 좌=월, 우=일 / DMY는 좌=일, 우=월)
  static String formatStyle1LeftNumber(DateTime dt) {
    if (dateOrder == DateOrderType.dmy) {
      return dt.day.toString().padLeft(2, '0');
    }
    return dt.month.toString().padLeft(2, '0');
  }

  static String formatStyle1RightNumber(DateTime dt) {
    if (dateOrder == DateOrderType.dmy) {
      return dt.month.toString().padLeft(2, '0');
    }
    return dt.day.toString().padLeft(2, '0');
  }

  // ─── 80+ 샘플 스탬프(SampleStampLibrary) 통합 다국어 포맷터 ───

  /// 샘플 스탬프의 각 `TimestampEntity` / `StyleTimestampEntity`의 `regex`와 `i18nTypes`,
  /// 그리고 분할된 멀티 엔티티(`n1_7`, `d5`, `style1`)의 ID를 받아 현재 언어의 날짜/시간 순서로 변환합니다.
  static String formatSampleStampEntity({
    required String regex,
    required String? i18nTypes,
    required DateTime dt,
    String? entityId,
    String? groupId,
  }) {
    // 1. 멀티 엔티티에서 년/월/일 또는 월/일이 상하/좌우로 분리된 스탬프 처리
    if (entityId != null) {
      // style1: 좌측(style1_t2) / 우측(style1_t3)
      if (entityId == 'style1_t2') {
        return formatStyle1LeftNumber(dt);
      }
      if (entityId == 'style1_t3') {
        return formatStyle1RightNumber(dt);
      }
      // n1_7: 상단(t2='yyyy') / 하단(t3='MM/dd')
      // YMD는 상단=yyyy, 하단=MM/dd | MDY는 상단=MM/dd, 하단=yyyy | DMY는 상단=dd/MM, 하단=yyyy
      if (entityId.startsWith('n1_7_t2')) {
        if (dateOrder == DateOrderType.ymd) return '${dt.year}';
        return formatNumericMonthDay(dt, sep: '/');
      }
      if (entityId.startsWith('n1_7_t3')) {
        if (dateOrder == DateOrderType.ymd) {
          return formatNumericMonthDay(dt, sep: '/');
        }
        return '${dt.year}';
      }
      // d5: 상단(d5_t2='MM/dd') / 하단(d5_t3='yyyy')
      if (entityId == 'd5_t2') {
        if (dateOrder == DateOrderType.ymd) return '${dt.year}';
        return formatNumericMonthDay(dt, sep: '/');
      }
      if (entityId == 'd5_t3') {
        if (dateOrder == DateOrderType.ymd) {
          return formatNumericMonthDay(dt, sep: '/');
        }
        return '${dt.year}';
      }
    }

    final upperTypes = (i18nTypes ?? '').toUpperCase();
    final hasDayToKr = upperTypes.contains('DAY_TO_KR') || upperTypes.contains('DAYTOKR');
    final hasFullDayToKr = upperTypes.contains('FULL_DAY_TO_KR') || upperTypes.contains('FULLDAYTOKR');
    final hasAmPmToKr = upperTypes.contains('AMPM_TO_KR') || upperTypes.contains('AMPMTOKR');
    final hasToCapital = upperTypes.contains('ALL_TO_CAPITAL') || upperTypes.contains('ALLTOCAPITAL');
    final hasToLower = upperTypes.contains('ALL_TO_LOWERCASE') || upperTypes.contains('ALLTOLOWERCASE');

    String result = _formatPatternByLocale(
      regex: regex,
      dt: dt,
      localizeWeekday: true,
      localizeAmPm: hasAmPmToKr || lang == 'ko' || lang == 'zh' || lang == 'ja',
      hasDayToKr: hasDayToKr,
      hasFullDayToKr: hasFullDayToKr,
    );

    if (hasToCapital) {
      result = result.toUpperCase();
    } else if (hasToLower) {
      result = result.toLowerCase();
    }
    return result;
  }

  static String _formatPatternByLocale({
    required String regex,
    required DateTime dt,
    required bool localizeWeekday,
    required bool localizeAmPm,
    required bool hasDayToKr,
    required bool hasFullDayToKr,
  }) {
    final wShort = shortWeekday(dt);
    final wFull = fullWeekday(dt);

    switch (regex) {
      // ── 순수 시간/단일 컴포넌트 ──
      case 'HH:mm':
        return DateFormat('HH:mm').format(dt);
      case 'HH':
        return DateFormat('HH').format(dt);
      case 'hh:mm':
        return DateFormat('hh:mm').format(dt);
      case 'hh':
        return DateFormat('hh').format(dt);
      case 'mm':
        return DateFormat('mm').format(dt);
      case 'dd':
        return DateFormat('dd').format(dt);
      case 'MM':
        return DateFormat('MM').format(dt);
      case 'yyyy':
        return DateFormat('yyyy').format(dt);
      case 'a':
        return localizedPeriod(dt, asciiOnly: !localizeAmPm);
      case 'ahhmm':
        return '${localizedPeriod(dt, asciiOnly: true)}${DateFormat('hhmm').format(dt)}';
      case 'a hh:mm':
        return format12hTime(dt, padHour: true, localizePeriod: localizeAmPm);
      case 'a h:mm':
        return format12hTime(dt, padHour: false, localizePeriod: localizeAmPm);
      case 'hh:mm a':
        return format12hTime(dt, padHour: true, localizePeriod: localizeAmPm);
      case 'a hh시 mm분':
        return format12hTime(
          dt,
          padHour: true,
          localizePeriod: true,
          useUnitWords: true,
        );
      case 'a h시 m분':
        return format12hTime(
          dt,
          padHour: false,
          localizePeriod: true,
          useUnitWords: true,
        );

      // ── 요일 및 요일+AM/PM ──
      case 'E':
      case 'EEE':
        return wShort;
      case 'EEEE':
        return wFull;
      case 'EEEE a':
        final p = localizedPeriod(dt, asciiOnly: !localizeAmPm);
        return '$wFull $p';
      case 'EEE a':
        final p = localizedPeriod(dt, asciiOnly: !localizeAmPm);
        return '$wShort $p';
      case 'a EEE':
        final p = localizedPeriod(dt, asciiOnly: !localizeAmPm);
        return AppLocalizations.currentInfo.amPmBeforeTime
            ? '$p $wShort'
            : '$wShort $p';
      case 'EEEE a hh:mm':
        return '$wFull ${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)}';

      // ── 월/일 또는 월 이름 ──
      case 'MMMM':
        return fullMonthName(dt);
      case 'MM.dd':
        return formatNumericMonthDay(dt, sep: '.');
      case 'MM/dd':
        return formatNumericMonthDay(dt, sep: '/');
      case 'MM.dd E':
        return '${formatNumericMonthDay(dt, sep: '.')} $wShort';
      case 'MMM dd':
        return formatWordMonthDay(dt, fullMonth: false, padDay: true);
      case 'MMMM dd':
        return formatWordMonthDay(dt, fullMonth: true, padDay: true);
      case 'dd MMM':
        return formatWordMonthDay(dt, fullMonth: false, padDay: true);
      case 'M월 dd일 (E)':
        return '${formatWordMonthDay(dt, fullMonth: false, padDay: true)} ($wShort)';

      // ── 숫자형 년/월/일 ──
      case 'yyyy.MM.dd':
        return formatNumericDate(dt, sep: '.');
      case 'yyyy/MM/dd':
        if (hasFullDayToKr) {
          return '${formatNumericDate(dt, sep: '/')} $wFull';
        }
        return formatNumericDate(dt, sep: '/');
      case 'yyyy / MM / dd':
        return formatNumericDate(dt, sep: ' / ');
      case 'yyyy.M.d':
        return formatNumericDate(dt, sep: '.', padMonthDay: false);
      case 'yy.MM.dd':
        return formatNumericDate(dt, sep: '.', shortYear: true);
      case 'yy/MM/dd':
        return formatNumericDate(dt, sep: '/', shortYear: true);
      case 'yy.M.d':
        return formatNumericDate(dt, sep: '.', shortYear: true, padMonthDay: false);
      case 'MM/dd yy':
        final y2 = (dt.year % 100).toString().padLeft(2, '0');
        if (dateOrder == DateOrderType.ymd) {
          return '$y2 ${formatNumericMonthDay(dt, sep: '/')}';
        }
        return '${formatNumericMonthDay(dt, sep: '/')} $y2';
      case 'yyyyMMdd':
        return formatNumericDate(dt, sep: '');

      // ── 문자/단위형 년/월/일 ──
      case 'yyyy년 MM월 dd일':
      case 'yyyy MMM dd':
      case 'MMM dd, yyyy':
      case 'dd MMM, yyyy':
      case 'dd. MMM yyyy':
        return formatWordDate(dt, fullMonth: false, padMonthDay: true);
      case 'MMMM dd, yyyy':
        return formatWordDate(dt, fullMonth: true, padMonthDay: true);
      case 'yyyy.MMM.dd':
        return formatWordDate(dt, fullMonth: false, padMonthDay: true);
      case 'yy.MMM.dd':
        return formatWordDate(dt, shortYear: true, fullMonth: false, padMonthDay: true);
      case 'yyyy년 M월 d일':
        return formatWordDate(dt, fullMonth: false, padMonthDay: false);
      case 'yy년 M월 d일':
        return formatWordDate(dt, shortYear: true, fullMonth: false, padMonthDay: false);

      // ── 날짜 + 요일 조합 ──
      case 'yyyy.MM.dd (E)':
        return '${formatNumericDate(dt, sep: '.')} ($wShort)';
      case 'yyyy/MM/dd (E)':
        return '${formatNumericDate(dt, sep: '/')} ($wShort)';
      case 'yyyy.MM.dd.E':
      case 'yyyy.MM.dd.EEE':
        if (lang == 'ko') {
          return '${formatNumericDate(dt, sep: '.')}.$wShort';
        }
        return '${formatNumericDate(dt, sep: '.')} $wShort';
      case 'yyyy.MM.dd EEEE':
        return '${formatNumericDate(dt, sep: '.')} $wFull';
      case 'yyyy년 MM월 dd일(E)':
        return '${formatWordDate(dt, padMonthDay: true)}($wShort)';
      case 'yy년 M월 d일 EEEE':
        if (dateOrder == DateOrderType.ymd) {
          return '${formatWordDate(dt, shortYear: true)} $wFull';
        }
        return '$wFull, ${formatWordDate(dt, shortYear: true)}';
      case '- yyyy년 M월 d일 EEEE -':
        if (dateOrder == DateOrderType.ymd) {
          return '- ${formatWordDate(dt)} $wFull -';
        }
        return '- $wFull, ${formatWordDate(dt)} -';

      // ── 날짜 + 시간 복합 패턴 ──
      case 'yyyy.MM.dd HH:mm':
        return '${formatNumericDate(dt, sep: '.')} ${DateFormat('HH:mm').format(dt)}';
      case 'yyyy/MM/dd HH:mm':
        return '${formatNumericDate(dt, sep: '/')} ${DateFormat('HH:mm').format(dt)}';
      case 'yyyy-MM-d HH:mm':
        return '${formatNumericDate(dt, sep: '-', padMonthDay: false)} ${DateFormat('HH:mm').format(dt)}';
      case 'yyyy.MM.dd a hh:mm':
        return '${formatNumericDate(dt, sep: '.')} ${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)}';
      case 'yy.MM.dd a hh:mm':
        return '${formatNumericDate(dt, sep: '.', shortYear: true)} ${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)}';
      case 'yyyy/MM/dd a hh:mm':
        return '${formatNumericDate(dt, sep: '/')} ${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)}';
      case 'yyyy/MM/dd a h:m':
        return '${formatNumericDate(dt, sep: '/')} ${format12hTime(dt, padHour: false, localizePeriod: localizeAmPm)}';
      case 'yyyy/MM/dd (E) a hh:mm':
        return '${formatNumericDate(dt, sep: '/')} ($wShort) ${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)}';
      case 'yyyy.MM.dd.E a hh:mm':
        if (lang == 'ko') {
          return '${formatNumericDate(dt, sep: '.')}.$wShort ${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)}';
        }
        return '${formatNumericDate(dt, sep: '.')} $wShort ${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)}';
      case 'a hh:mm yyyy.MM.dd':
        return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatNumericDate(dt, sep: '.')}';
      case 'a hh:mm yyyy/MM/dd':
        return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatNumericDate(dt, sep: '/')}';
      case 'a hh:mm yyyy.MM.dd EEEE':
        return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatNumericDate(dt, sep: '.')} $wFull';
      case 'a hh:mm yyyy.MM.dd.EEE':
        if (lang == 'ko') {
          return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatNumericDate(dt, sep: '.')}.$wShort';
        }
        return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatNumericDate(dt, sep: '.')} $wShort';
      case 'a hh:mm yyyy/MM/dd E':
        return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatNumericDate(dt, sep: '/')} $wShort';
      case 'E hh:mma yy.MM.dd':
        return '$wShort ${format12hTime(dt, padHour: true, localizePeriod: false)} ${formatNumericDate(dt, sep: '.', shortYear: true)}';
      case 'a hh:mm dd/MMM':
        return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatWordMonthDay(dt, fullMonth: false, padDay: true)}';
      case 'a hh:mm MMMM dd, yyyy':
      case 'hh:mm a, MMMM dd, yyyy':
      case 'hh:mm a. MMMM dd. yyyy':
        return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatWordDate(dt, fullMonth: true, padMonthDay: true)}';
      case 'hh:mm a, MMM dd, yyyy':
        return '${format12hTime(dt, padHour: true, localizePeriod: localizeAmPm)} ${formatWordDate(dt, fullMonth: false, padMonthDay: true)}';
      case 'yyyy년 MM월 dd일 a hh시 mm분':
        return '${formatWordDate(dt, padMonthDay: true)} ${format12hTime(dt, padHour: true, localizePeriod: true, useUnitWords: true)}';
      case 'yyyy년 M월 d일 a h시 m분':
        return '${formatWordDate(dt, padMonthDay: false)} ${format12hTime(dt, padHour: false, localizePeriod: true, useUnitWords: true)}';
      case 'yy년 M월 dd일 a h시 m분':
        return '${formatWordDate(dt, shortYear: true, padMonthDay: false)} ${format12hTime(dt, padHour: false, localizePeriod: true, useUnitWords: true)}';
      case 'yy년 M월 d일 (E) H시 m분':
        final h24 = '${dt.hour}';
        final m2 = dt.minute.toString().padLeft(2, '0');
        final timePart = (lang == 'ko')
            ? '${dt.hour}시 ${dt.minute}분'
            : (lang == 'zh'
                ? '${dt.hour}时${dt.minute}分'
                : (lang == 'ja' ? '${dt.hour}時${dt.minute}分' : '$h24:$m2'));
        return '${formatWordDate(dt, shortYear: true, padMonthDay: false)} ($wShort) $timePart';

      default:
        try {
          return DateFormat(regex, AppLocalizations.currentInfo.localeString).format(dt);
        } catch (_) {
          return DateFormat(regex).format(dt);
        }
    }
  }
}
