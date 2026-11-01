import 'package:flutter/material.dart';
import '../services/ad_service.dart';
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

    AdService().showRewardedAd(
      onUserEarnedReward: () async {
        // 3일 해금 처리
        await TimestampAccessManager().unlockForDays(widget.design, days: 3);
        if (!mounted) return;

        widget.onUnlocked();
        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Color(0xFFC6FF00)),
                SizedBox(width: 8),
                Text(
                  '3일 동안 무료로 해금되었습니다! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
          ),
        );
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
    return Dialog(
      backgroundColor: const Color(0xFF181A20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white12, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 뱃지
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFC6FF00).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC6FF00).withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.lock_open_rounded,
                color: Color(0xFFC6FF00),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),

            // 타이틀
            const Text(
              '감성 타임스탬프 해금',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // 서브타이틀
            Text(
              '짧은 광고를 시청하시면\n3일(72시간) 동안 마음껏 사용하실 수 있습니다!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // 혜택 포인트 박스
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _featureItem(Icons.play_circle_outline, '짧은 광고 1회'),
                  Container(width: 1, height: 26, color: Colors.white12),
                  _featureItem(Icons.timer_outlined, '3일간 무제한'),
                  Container(width: 1, height: 26, color: Colors.white12),
                  _featureItem(Icons.auto_awesome, '워터마크 없음'),
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

            const SizedBox(height: 24),

            // 액션 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoadingAd ? null : _watchAdAndUnlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC6FF00),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoadingAd
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_arrow_rounded, size: 22),
                          SizedBox(width: 6),
                          Text(
                            '광고 보고 3일 무료 사용',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
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
                  '다음에 하기',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFC6FF00), size: 18),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
