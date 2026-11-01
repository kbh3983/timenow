import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  /// AdMob 공식 테스트용 보상형 광고 ID
  /// (실제 서비스 출시 시 구글 애드몹 콘솔에서 발급받은 광고 단위 ID로 교체하면 됩니다.)
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917'; // Android Test Rewarded ID
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313'; // iOS Test Rewarded ID
      }
    }

    // 실제 프로덕션 광고 ID 설정 (미설정 시 테스트 ID 폴백)
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  /// 앱 시작 시 호출하여 MobileAds 초기화 및 광고 사전 로드
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      // 첫 광고 사전 로드
      AdService().loadRewardedAd();
    } catch (e) {
      debugPrint('AdService: MobileAds initialize error: $e');
    }
  }

  /// 보상형 광고 사전 로드
  void loadRewardedAd({VoidCallback? onLoaded, Function(LoadAdError)? onFailed}) {
    if (_rewardedAd != null || _isAdLoading) return;

    _isAdLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoading = false;
          debugPrint('AdService: RewardedAd loaded successfully.');
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isAdLoading = false;
          debugPrint('AdService: Failed to load RewardedAd: $error');
          onFailed?.call(error);
        },
      ),
    );
  }

  /// 보상형 광고 표시
  /// [onUserEarnedReward]: 사용자가 광고 시청을 완료하여 보상을 받을 때 호출
  /// [onAdClosed]: 광고가 닫혔을 때 (성공/취소 무관)
  /// [onFailed]: 광고 로드 실패 또는 표시 실패 시
  void showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdClosed,
    Function(String error)? onFailed,
  }) {
    if (_rewardedAd == null) {
      // 아직 로드되지 않은 경우 로드 시도 후 표시
      _isAdLoading = true;
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isAdLoading = false;
            _presentAd(
              ad,
              onUserEarnedReward: onUserEarnedReward,
              onAdClosed: onAdClosed,
              onFailed: onFailed,
            );
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isAdLoading = false;
            onFailed?.call('광고를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.');
          },
        ),
      );
      return;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null; // 표시 시작 시 캐시 해제
    _presentAd(
      ad,
      onUserEarnedReward: onUserEarnedReward,
      onAdClosed: onAdClosed,
      onFailed: onFailed,
    );
  }

  void _presentAd(
    RewardedAd ad, {
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdClosed,
    Function(String error)? onFailed,
  }) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdService: onAdShowedFullScreenContent');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: onAdDismissedFullScreenContent');
        ad.dispose();
        // 다음 광고를 위해 미리 로드
        loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        loadRewardedAd();
        onFailed?.call('광고 표시에 실패했습니다: ${error.message}');
      },
    );

    ad.setImmersiveMode(true);
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('AdService: User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward();
      },
    );
  }
}
