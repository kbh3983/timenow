import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../services/app_localizations.dart';
import '../services/app_settings_service.dart';
import '../services/timestamp_access_manager.dart';
import '../timestamp_overlays.dart';

class UnlockTimestampDialog extends StatefulWidget {
  final TimestampDesign design;
  final VoidCallback onUnlocked;

  const UnlockTimestampDialog({
    super.key,
    required this.design,
    required this.onUnlocked,
  });

  static Future<bool?> show(
    BuildContext context, {
    required TimestampDesign design,
    required VoidCallback onUnlocked,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => UnlockTimestampDialog(
        design: design,
        onUnlocked: onUnlocked,
      ),
    );
  }

  @override
  State<UnlockTimestampDialog> createState() => _UnlockTimestampDialogState();
}

class _UnlockTimestampDialogState extends State<UnlockTimestampDialog> {
  bool _isLoadingAd = false;
  String? _errorMessage;

  void _watchAdAndUnlock() {
    setState(() {
      _isLoadingAd = true;
      _errorMessage = null;
    });

    final settings = AppSettingsService();
    final accent = settings.accentColor;

    AdService().showRewardedAd(
      onUserEarnedReward: () async {
        // 3일 해금 처리
        await TimestampAccessManager().unlockForDays(widget.design, days: 3);
        if (!mounted) return;

        // 다이얼로그가 닫히면 context가 비활성화되므로 messenger를 미리 확보
        final messenger = ScaffoldMessenger.of(context);

        widget.onUnlocked();
        Navigator.of(context).pop(true);

        messenger.clearSnackBars();
        final controller = messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.stampUnlockedSnackbar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E2129),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: AppStrings.confirm,
              textColor: accent,
              onPressed: () {
                messenger.hideCurrentSnackBar();
              },
            ),
          ),
        );

        // 액션 버튼이 있는 SnackBar는 자동으로 닫히지 않을 수 있으므로 3초 뒤 강제로 닫기
        var isClosed = false;
        controller.closed.then((_) => isClosed = true);
        Future.delayed(const Duration(seconds: 3), () {
          if (!isClosed && messenger.mounted) {
            controller.close();
          }
        });
      },
      onAdClosed: () {
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
          });
        }
      },
      onFailed: (error) {
        if (mounted) {
          setState(() {
            _isLoadingAd = false;
            _errorMessage = error;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService();
    final accent = settings.accentColor;

    return Dialog(
      backgroundColor: settings.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: settings.borderColor, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 뱃지
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  color: accent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),

              // 타이틀
              Text(
                AppStrings.unlockDialogTitle,
                style: TextStyle(
                  color: settings.textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // 서브타이틀
              Text(
                AppStrings.unlockDialogDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: settings.subTextColor,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),

              // 혜택 포인트 박스
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: settings.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: settings.borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _featureItem(
                        Icons.play_circle_outline,
                        AppStrings.unlockFeatShortAd,
                        accent,
                        settings.textColor,
                      ),
                    ),
                    Container(width: 1, height: 26, color: settings.dividerColor),
                    Expanded(
                      child: _featureItem(
                        Icons.timer_outlined,
                        AppStrings.unlockFeat3DaysUnlimited,
                        accent,
                        settings.textColor,
                      ),
                    ),
                    Container(width: 1, height: 26, color: settings.dividerColor),
                    Expanded(
                      child: _featureItem(
                        Icons.auto_awesome,
                        AppStrings.unlockFeatNoWatermark,
                        accent,
                        settings.textColor,
                      ),
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],

              const SizedBox(height: 22),

              // 액션 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoadingAd ? null : _watchAdAndUnlock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: settings.isLight ? Colors.white : Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoadingAd
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              settings.isLight ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 22),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                AppStrings.unlockWatchAdButton,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 8),

              // 취소 버튼
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppStrings.maybeLater,
                    style: TextStyle(
                      color: settings.subTextColor,
                      fontSize: 14,
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

  Widget _featureItem(IconData icon, String text, Color accent, Color textColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accent, size: 18),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
