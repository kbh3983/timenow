import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'services/ad_service.dart';
import 'services/app_settings_service.dart';
import 'widgets/ad_banner_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettingsService _settings = AppSettingsService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final accent = _settings.accentColor;
        final bgColor = _settings.scaffoldBackgroundColor;
        final cardColor = _settings.cardBackgroundColor;
        final textColor = _settings.textColor;
        final subTextColor = _settings.subTextColor;
        final dividerColor = _settings.dividerColor;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              '설정',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // 1. 타임스탬프 & 위치 설정
              _sectionHeader('타임스탬프 설정'),
              _cardContainer(
                cardColor: cardColor,
                children: [
                  SwitchListTile(
                    activeThumbColor: accent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: Text(
                      '위치 정보 표시',
                      style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    value: _settings.showLocation,
                    onChanged: (val) async {
                      HapticFeedback.selectionClick();
                      await _settings.setShowLocation(val);
                      if (val && _settings.locationText.isEmpty) {
                        _refreshGpsLocation();
                      }
                    },
                  ),
                  if (_settings.showLocation) ...[
                    Divider(color: dividerColor, height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on_rounded, color: accent, size: 20),
                      ),
                      title: Text(
                        '표시할 위치',
                        style: TextStyle(color: textColor, fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _settings.isFetchingLocation
                            ? 'GPS 위치를 가져오는 중...'
                            : (_settings.locationText.isEmpty ? '위치 미설정 (탭하여 선택)' : _settings.locationText),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _settings.locationText.isEmpty ? subTextColor : accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_settings.isFetchingLocation)
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.refresh_rounded, color: subTextColor, size: 20),
                              tooltip: 'GPS 현재 위치 새로고침',
                              onPressed: _refreshGpsLocation,
                            ),
                          Icon(Icons.chevron_right_rounded, color: subTextColor, size: 20),
                        ],
                      ),
                      onTap: _showLocationPickerSheet,
                    ),
                    Divider(color: dividerColor, height: 1),
                    _buildLocationPositionGrid(_settings),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              const AdBannerWidget(margin: EdgeInsets.only(bottom: 16)),

              // 2. 테마 & 스타일 커스텀
              _sectionHeader('테마 및 스타일'),
              _cardContainer(
                cardColor: cardColor,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '앱 테마 모드',
                          style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _settings.isLight
                              ? '클린 화이트 (라이트 모드)'
                              : (_settings.isPureBlack ? '트루 블랙 (OLED 완전 검정)' : '딥 차콜 다크 (기본)'),
                          style: TextStyle(color: subTextColor, fontSize: 12.5),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'dark',
                                label: Text('다크', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                icon: Icon(Icons.dark_mode_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'pureBlack',
                                label: Text('블랙', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                icon: Icon(Icons.brightness_2_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'light',
                                label: Text('화이트', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                icon: Icon(Icons.light_mode_outlined, size: 16),
                              ),
                            ],
                            selected: {_settings.themeMode},
                            onSelectionChanged: (val) {
                              HapticFeedback.selectionClick();
                              _settings.setThemeMode(val.first);
                            },
                            style: ButtonStyle(
                              visualDensity: VisualDensity.standard,
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return accent.withValues(alpha: 0.22);
                                }
                                return _settings.isLight ? const Color(0xFFF1F3F5) : Colors.white.withValues(alpha: 0.04);
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return accent;
                                }
                                return subTextColor;
                              }),
                              side: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return BorderSide(color: accent.withValues(alpha: 0.6), width: 1.2);
                                }
                                return BorderSide(color: dividerColor, width: 0.8);
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: dividerColor, height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '포인트 컬러',
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _showCustomColorPickerBottomSheet(
                                  parentContext: context,
                                  currentColorValue: _settings.accentColor.toARGB32(),
                                  onColorSelected: (newColor) {
                                    _settings.setCustomAccentColor(newColor);
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.colorize, size: 14, color: subTextColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    '직접 선택',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '버튼 및 주요 하이라이트에 적용될 포인트 색상입니다.',
                          style: TextStyle(color: subTextColor, fontSize: 12.5),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...List.generate(AppSettingsService.accentColors.length, (index) {
                              final option = AppSettingsService.accentColors[index];
                              final isSelected = !_settings.isCustomAccent && _settings.accentIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  _settings.setAccentIndex(index);
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: option.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? (_settings.isLight ? Colors.black87 : Colors.white)
                                          : Colors.transparent,
                                      width: isSelected ? 2.5 : 0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: option.color.withValues(alpha: isSelected ? 0.6 : 0.25),
                                        blurRadius: isSelected ? 8 : 4,
                                        spreadRadius: isSelected ? 1 : 0,
                                      ),
                                    ],
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: option.color.computeLuminance() > 0.6
                                              ? Colors.black
                                              : Colors.white,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              );
                            }),
                            // 직접 선택 컬러 원형
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _showCustomColorPickerBottomSheet(
                                  parentContext: context,
                                  currentColorValue: _settings.accentColor.toARGB32(),
                                  onColorSelected: (newColor) {
                                    _settings.setCustomAccentColor(newColor);
                                  },
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _settings.isCustomAccent
                                      ? Color(_settings.customAccentColorValue!)
                                      : (_settings.isLight ? const Color(0xFFF1F3F5) : const Color(0xFF22252C)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _settings.isCustomAccent
                                        ? (_settings.isLight ? Colors.black87 : Colors.white)
                                        : (_settings.isLight ? const Color(0xFFCBD5E1) : const Color(0xFF3A3F4D)),
                                    width: _settings.isCustomAccent ? 2.5 : 1.2,
                                  ),
                                  boxShadow: [
                                    if (_settings.isCustomAccent)
                                      BoxShadow(
                                        color: Color(_settings.customAccentColorValue!).withValues(alpha: 0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                  ],
                                ),
                                child: _settings.isCustomAccent
                                    ? Icon(
                                        Icons.check,
                                        color: Color(_settings.customAccentColorValue!).computeLuminance() > 0.6
                                            ? Colors.black
                                            : Colors.white,
                                        size: 18,
                                      )
                                    : Icon(
                                        Icons.colorize,
                                        color: subTextColor,
                                        size: 18,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. 개발자 응원하기 (애드몹 광고)
              _sectionHeader('개발자 응원하기'),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.favorite_rounded, color: accent, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '개발자에게 커피 한 잔 선물하기 ☕',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '짧은 영상 광고 1편으로 앱 개발을 응원해주세요!',
                                style: TextStyle(color: subTextColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.play_circle_fill_rounded,
                          color: _settings.isLight ? Colors.white : Colors.black,
                          size: 20,
                        ),
                        label: Text(
                          '광고 보고 응원하기',
                          style: TextStyle(
                            color: _settings.isLight ? Colors.white : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _showSupportAd,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. 앱 정보 & 출시 필수 약관
              _sectionHeader('앱 정보 및 약관'),
              _cardContainer(
                cardColor: cardColor,
                children: [
                  _infoTile(
                    title: '앱 버전',
                    subtitle: '1.0.0 (최신 버전)',
                    trailing: Icon(Icons.verified_rounded, color: subTextColor, size: 18),
                  ),
                  Divider(color: dividerColor, height: 1),
                  _infoTile(
                    title: '서비스 이용약관',
                    subtitle: 'Log 서비스 이용 관련 기본 약관',
                    onTap: _showTermsOfService,
                  ),
                  Divider(color: dividerColor, height: 1),
                  _infoTile(
                    title: '개인정보 처리방침',
                    subtitle: '카메라, 저장공간 및 위치정보 보호 방침',
                    onTap: _showPrivacyPolicy,
                  ),
                  Divider(color: dividerColor, height: 1),
                  _infoTile(
                    title: '오픈소스 라이선스',
                    subtitle: '사용된 오픈소스 소프트웨어 라이선스 목록',
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Log',
                      applicationVersion: '1.0.0',
                      applicationIcon: Icon(Icons.camera_alt_rounded, size: 48, color: accent),
                    ),
                  ),
                  Divider(color: dividerColor, height: 1),
                  _infoTile(
                    title: '문의 및 피드백',
                    subtitle: 'kbh3983@gmail.com',
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'kbh3983@gmail.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('이메일 주소가 클립보드에 복사되었습니다.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: _settings.subTextColor,
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _cardContainer({required Color cardColor, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _settings.borderColor),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _infoTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(title, style: TextStyle(color: _settings.textColor, fontSize: 14.5, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: _settings.subTextColor, fontSize: 12)),
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: _settings.subTextColor, size: 20) : null),
      onTap: onTap,
    );
  }

  Future<void> _refreshGpsLocation() async {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('현재 GPS 위치를 측정하고 있습니다...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final result = await _settings.fetchAndApplyGpsLocation(overwrite: true);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (result.success) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📍 현재 위치가 갱신되었습니다: ${result.primaryAddress}'),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? '위치 정보를 가져올 수 없습니다.'),
          backgroundColor: Colors.redAccent.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildLocationPositionGrid(AppSettingsService settings) {
    final accent = settings.accentColor;
    final textColor = settings.textColor;
    final subTextColor = settings.subTextColor;
    final current = settings.locationPosition;

    final positions = const [
      {'id': 'topLeft', 'label': '좌상단', 'align': Alignment.topLeft},
      {'id': 'topCenter', 'label': '상단 중앙', 'align': Alignment.topCenter},
      {'id': 'topRight', 'label': '우상단', 'align': Alignment.topRight},
      {'id': 'bottomLeft', 'label': '좌하단', 'align': Alignment.bottomLeft},
      {'id': 'bottomCenter', 'label': '하단 중앙', 'align': Alignment.bottomCenter},
      {'id': 'bottomRight', 'label': '우하단', 'align': Alignment.bottomRight},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Row(
            children: [
              Icon(Icons.crop_free_rounded, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(
                '위치 태그 표시 위치',
                style: TextStyle(color: textColor, fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '화면/타임스탬프 내에서 위치 태그가 나타날 위치를 선택합니다.',
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemCount: positions.length,
            itemBuilder: (context, index) {
              final item = positions[index];
              final id = item['id'] as String;
              final label = item['label'] as String;
              final align = item['align'] as Alignment;
              final isSelected = current == id;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  settings.setLocationPosition(id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accent.withValues(alpha: 0.15)
                        : (settings.isLight ? const Color(0xFFF3F4F6) : Colors.white.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? accent : (settings.isLight ? const Color(0xFFE5E7EB) : Colors.white12),
                      width: isSelected ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 미니 뷰파인더 다이어그램
                      Container(
                        width: 44,
                        height: 28,
                        decoration: BoxDecoration(
                          color: settings.isLight ? Colors.white : Colors.black45,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isSelected ? accent.withValues(alpha: 0.6) : Colors.white24,
                            width: 0.8,
                          ),
                        ),
                        child: Align(
                          alignment: align,
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            width: 14,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected ? accent : (settings.isLight ? Colors.black45 : Colors.white60),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? accent : textColor,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showLocationPickerSheet() {
    final accent = _settings.accentColor;
    final isPureBlack = _settings.isPureBlack;
    final isLight = _settings.isLight;
    final bgColor = isLight
        ? Colors.white
        : (isPureBlack ? const Color(0xFF141416) : const Color(0xFF1E2026));
    final textColor = _settings.textColor;
    final subTextColor = _settings.subTextColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final options = _settings.locationOptions;
            final current = _settings.locationText;
            final bool isCustomSelected = current.isNotEmpty &&
                !options.any((opt) => opt.value == current);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 드래그 핸들
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isLight ? Colors.black12 : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '표시할 위치 선택',
                          style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            setSheetState(() {});
                            await _settings.fetchAndApplyGpsLocation(overwrite: false);
                            setSheetState(() {});
                          },
                          icon: _settings.isFetchingLocation
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 1.8, color: accent),
                                )
                              : Icon(Icons.my_location_rounded, color: accent, size: 16),
                          label: Text(
                            'GPS 갱신',
                            style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GPS 기반 4가지 주소 형식 또는 원하는 문구 직접 입력 중 선택하세요.',
                      style: TextStyle(color: subTextColor, fontSize: 12.5),
                    ),
                    const SizedBox(height: 14),

                    // 1, 2, 3, 4: GPS 기반 주소 형식
                    if (options.isNotEmpty) ...[
                      ...options.map((opt) {
                        final isSelected = current == opt.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accent.withValues(alpha: 0.12)
                                : (isLight ? const Color(0xFFF3F4F6) : Colors.white.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? accent : (isLight ? const Color(0xFFE5E7EB) : Colors.white12),
                              width: isSelected ? 1.4 : 0.8,
                            ),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            title: Text(
                              opt.value,
                              style: TextStyle(
                                color: isSelected ? accent : textColor,
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              opt.label,
                              style: TextStyle(
                                color: isSelected ? accent.withValues(alpha: 0.8) : subTextColor,
                                fontSize: 11.5,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle_rounded, color: accent, size: 20)
                                : Icon(Icons.circle_outlined, color: subTextColor.withValues(alpha: 0.4), size: 18),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _settings.setLocationText(opt.value);
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      }),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isLight ? const Color(0xFFF3F4F6) : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: subTextColor, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '측정된 GPS 옵션이 없습니다. 상단의 GPS 갱신을 누르시거나 직접 입력해주세요.',
                                style: TextStyle(color: subTextColor, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // 4: 원하는 문구 입력
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: isCustomSelected
                            ? accent.withValues(alpha: 0.12)
                            : (isLight ? const Color(0xFFF3F4F6) : Colors.white.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCustomSelected ? accent : (isLight ? const Color(0xFFE5E7EB) : Colors.white12),
                          width: isCustomSelected ? 1.4 : 0.8,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                        leading: Icon(
                          Icons.edit_note_rounded,
                          color: isCustomSelected ? accent : subTextColor,
                          size: 22,
                        ),
                        title: Text(
                          isCustomSelected ? current : '원하는 문구 입력',
                          style: TextStyle(
                            color: isCustomSelected ? accent : textColor,
                            fontSize: 14,
                            fontWeight: isCustomSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          isCustomSelected ? '직접 입력한 문구 (탭하여 변경)' : '자유로운 문구 직접 입력',
                          style: TextStyle(
                            color: isCustomSelected ? accent.withValues(alpha: 0.8) : subTextColor,
                            fontSize: 11.5,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCustomSelected)
                              Icon(Icons.check_circle_rounded, color: accent, size: 20)
                            else
                              Icon(Icons.chevron_right_rounded, color: subTextColor, size: 20),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _editCustomLocationDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editCustomLocationDialog() {
    final controller = TextEditingController(text: _settings.locationText);
    final isLight = _settings.isLight;
    final isPureBlack = _settings.isPureBlack;
    final bottomSheetBg = isLight
        ? Colors.white
        : (isPureBlack ? const Color(0xFF141416) : const Color(0xFF1E2026));
    final textColor = _settings.textColor;
    final subTextColor = _settings.subTextColor;
    final accent = _settings.accentColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: bottomSheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: subTextColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '원하는 문구 입력',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: subTextColor, size: 22),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '타임스탬프에 표시할 원하는 위치 문구를 자유롭게 입력하세요.',
                style: TextStyle(color: subTextColor, fontSize: 13),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFF3F4F6) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLight ? const Color(0xFFE5E7EB) : Colors.white12,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: textColor, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: '예: 우리집 / 서울 한강공원 / 제주 협재',
                    hintStyle: TextStyle(
                      color: subTextColor.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isLight ? const Color(0xFFCBD5E1) : Colors.white24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: isLight ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          _settings.setLocationText(text);
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSupportAd() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('광고를 준비하고 있습니다... 잠시만 기다려주세요.'),
        duration: Duration(seconds: 1),
      ),
    );

    AdService().showRewardedAd(
      onUserEarnedReward: () {
        if (!mounted) return;
        HapticFeedback.heavyImpact();
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _settings.isLight
                ? Colors.white
                : (_settings.isPureBlack ? const Color(0xFF141416) : const Color(0xFF1E2026)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _settings.accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_rounded, color: _settings.accentColor, size: 48),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '따뜻한 응원 감사합니다! ❤️',
                    style: TextStyle(color: _settings.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '보내주신 소중한 응원, 더 좋은 앱으로 보답할게요.',
                    style: TextStyle(color: _settings.subTextColor, fontSize: 13.5, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _settings.accentColor,
                        foregroundColor: _settings.isLight ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onFailed: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
        );
      },
    );
  }

  void _showTermsOfService() {
    _showLegalSheet(
      title: '서비스 이용약관',
      content: '''제 1 조 (목적)
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
    );
  }

  void _showPrivacyPolicy() {
    _showLegalSheet(
      title: '개인정보 처리방침',
      content: '''Log(이하 "앱")는 사용자의 개인정보를 매우 소중하게 생각하며, 관련 법령을 준수합니다.

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
개인정보 보호와 관련된 문의사항은 kbh3983@gmail.com 으로 연락주시기 바랍니다.

공고일자: 2026년 11월 1일''',
    );
  }

  void _showLegalSheet({required String title, required String content}) {
    final settings = AppSettingsService();
    final isLight = settings.isLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isLight ? Colors.white : const Color(0xFF17191E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFCBD5E1) : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isLight ? const Color(0xFF111418) : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isLight ? const Color(0xFF64748B) : Colors.white70,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Divider(
                color: isLight ? const Color(0xFFE2E4E8) : Colors.white12,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    content,
                    style: TextStyle(
                      color: isLight ? const Color(0xFF475569) : Colors.white70,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCustomColorPickerBottomSheet({
    required BuildContext parentContext,
    required int currentColorValue,
    required ValueChanged<int> onColorSelected,
  }) async {
    FocusScope.of(parentContext).unfocus();
    int tempColor = currentColorValue;
    HSVColor currentHsvColor = HSVColor.fromColor(Color(currentColorValue));

    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      showDragHandle: false,
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setPickerState) {
            final isLight = _settings.isLight;
            final bottomInset = MediaQuery.of(ctx).padding.bottom;
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : const Color(0xFF17191E),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(
                  color: isLight
                      ? const Color(0xFFE2E4E8)
                      : const Color(0xFF2E323A).withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag Indicator
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: isLight
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF2E323A),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Header
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Color(tempColor),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(tempColor).withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '포인트 색상 선택',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: isLight ? const Color(0xFF111418) : Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Pure Ring & Area Picker
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: ColorPickerHueRing(
                                    currentHsvColor,
                                    (hsv) {
                                      setPickerState(() {
                                        currentHsvColor = hsv;
                                        tempColor = hsv.toColor().toARGB32();
                                      });
                                    },
                                    displayThumbColor: true,
                                    strokeWidth: 18.0,
                                  ),
                                ),
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ColorPickerArea(
                                      currentHsvColor,
                                      (hsv) {
                                        setPickerState(() {
                                          currentHsvColor = hsv;
                                          tempColor = hsv.toColor().toARGB32();
                                        });
                                      },
                                      PaletteType.hsv,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons (Cancel / Apply)
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: isLight
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF2E323A).withValues(alpha: 0.5),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                    color: isLight ? const Color(0xFF475569) : const Color(0xFFF4F6F8),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Color(tempColor),
                                  foregroundColor: Color(tempColor).computeLuminance() > 0.6
                                      ? Colors.black
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  onColorSelected(tempColor);
                                  Navigator.pop(ctx);
                                },
                                child: const Text(
                                  '적용하기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
