import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'services/ad_service.dart';
import 'services/app_settings_service.dart';
import 'services/app_localizations.dart';
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
              AppStrings.settingsTitle,
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
              _sectionHeader(AppStrings.sectionTimestamp),
              _cardContainer(
                cardColor: cardColor,
                children: [
                  SwitchListTile(
                    activeThumbColor: accent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    title: Text(
                      AppStrings.showLocationTitle,
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
                        AppStrings.locationToDisplayTitle,
                        style: TextStyle(color: textColor, fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _settings.isFetchingLocation
                            ? AppStrings.fetchingGpsLocation
                            : (_settings.locationText.isEmpty ? AppStrings.locationNotSetTapToSelect : _settings.locationText),
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
                              tooltip: AppStrings.refreshGpsTooltip,
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
              _sectionHeader(AppStrings.sectionTheme),
              _cardContainer(
                cardColor: cardColor,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appThemeModeTitle,
                          style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _settings.isLight
                              ? AppStrings.themeLightDesc
                              : (_settings.isPureBlack ? AppStrings.themePureBlackDesc : AppStrings.themeDarkDesc),
                          style: TextStyle(color: subTextColor, fontSize: 12.5),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            segments: [
                              ButtonSegment(
                                value: 'dark',
                                label: Text(AppStrings.themeSegmentDark, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                icon: const Icon(Icons.dark_mode_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'pureBlack',
                                label: Text(AppStrings.themeSegmentBlack, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                icon: const Icon(Icons.brightness_2_outlined, size: 16),
                              ),
                              ButtonSegment(
                                value: 'light',
                                label: Text(AppStrings.themeSegmentLight, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                icon: const Icon(Icons.light_mode_outlined, size: 16),
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
                              AppStrings.accentColorTitle,
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
                                    AppStrings.folderCustomColor,
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
                          AppStrings.accentColorSub,
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
              _sectionHeader(AppStrings.sectionSupport),
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
                                AppStrings.supportTitle,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                AppStrings.supportSub,
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
                          AppStrings.supportButton,
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
              _sectionHeader(AppStrings.sectionAppInfo),
              _cardContainer(
                cardColor: cardColor,
                children: [
                  _infoTile(
                    title: AppStrings.appVersionTitle,
                    subtitle: AppStrings.appVersionSub,
                    trailing: Icon(Icons.verified_rounded, color: subTextColor, size: 18),
                  ),
                  Divider(color: dividerColor, height: 1),
                  _infoTile(
                    title: AppStrings.termsOfServiceTitle,
                    subtitle: AppStrings.termsOfServiceSub,
                    onTap: _showTermsOfService,
                  ),
                  Divider(color: dividerColor, height: 1),
                  _infoTile(
                    title: AppStrings.privacyPolicyTitle,
                    subtitle: AppStrings.privacyPolicySub,
                    onTap: _showPrivacyPolicy,
                  ),
                  Divider(color: dividerColor, height: 1),
                  _infoTile(
                    title: AppStrings.openSourceLicenseTitle,
                    subtitle: AppStrings.openSourceLicenseSub,
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: 'Log',
                      applicationVersion: '1.0.0',
                      applicationIcon: Icon(Icons.camera_alt_rounded, size: 48, color: accent),
                    ),
                  ),
                  Divider(color: dividerColor, height: 1),
                  _infoTile(
                    title: AppStrings.contactFeedbackTitle,
                    subtitle: 'kmh96503981@gmail.com',
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'kmh96503981@gmail.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.emailCopiedSnackbar),
                          duration: const Duration(seconds: 2),
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
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(AppStrings.measuringGpsSnackbar),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    final result = await _settings.fetchAndApplyGpsLocation(overwrite: true);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (result.success) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.locationUpdatedSnackbar(result.primaryAddress)),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? AppStrings.locationFetchErrorDefault),
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

    final positions = [
      {'id': 'topLeft', 'label': AppStrings.posTopLeft, 'align': Alignment.topLeft},
      {'id': 'topCenter', 'label': AppStrings.posTopCenter, 'align': Alignment.topCenter},
      {'id': 'topRight', 'label': AppStrings.posTopRight, 'align': Alignment.topRight},
      {'id': 'bottomLeft', 'label': AppStrings.posBottomLeft, 'align': Alignment.bottomLeft},
      {'id': 'bottomCenter', 'label': AppStrings.posBottomCenter, 'align': Alignment.bottomCenter},
      {'id': 'bottomRight', 'label': AppStrings.posBottomRight, 'align': Alignment.bottomRight},
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
                AppStrings.locationTagPosTitle,
                style: TextStyle(color: textColor, fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.locationTagPosSub,
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
                          AppStrings.selectLocationSheetTitle,
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
                            AppStrings.gpsRefreshButton,
                            style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.selectLocationSheetSub,
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
                              AppStrings.localizeLocationOptionLabel(opt.label),
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
                                AppStrings.noGpsOptionsMeasured,
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
                          isCustomSelected ? current : AppStrings.customLocationTextTitle,
                          style: TextStyle(
                            color: isCustomSelected ? accent : textColor,
                            fontSize: 14,
                            fontWeight: isCustomSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          isCustomSelected ? AppStrings.customLocationTextSubSelected : AppStrings.customLocationTextSubEmpty,
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
                    AppStrings.customLocationDialogTitle,
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
                AppStrings.customLocationDialogSub,
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
                    hintText: AppStrings.customLocationDialogHint,
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
                        AppStrings.cancel,
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
                      child: Text(
                        AppStrings.save,
                        style: const TextStyle(
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
      SnackBar(
        content: Text(AppStrings.preparingAdSnackbar),
        duration: const Duration(seconds: 1),
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
                    AppStrings.supportThankYouTitle,
                    style: TextStyle(color: _settings.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.supportThankYouSub,
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
                      child: Text(AppStrings.confirm, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      title: AppStrings.termsOfServiceTitle,
      content: AppStrings.termsOfServiceBody,
    );
  }

  void _showPrivacyPolicy() {
    _showLegalSheet(
      title: AppStrings.privacyPolicyTitle,
      content: AppStrings.privacyPolicyBody,
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
                              AppStrings.accentColorPickerTitle,
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
                                  AppStrings.cancel,
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
                                child: Text(
                                  AppStrings.apply,
                                  style: const TextStyle(
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
