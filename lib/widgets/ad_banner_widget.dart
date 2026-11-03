import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/app_settings_service.dart';

/// 앱 전체에서 재사용 가능한 통일된 디자인의 배너 광고 위젯
class AdBannerWidget extends StatefulWidget {
  final EdgeInsetsGeometry? margin;

  /// true면 카드 배경/테두리 없이 배너만 표시 (상단 바 등 좁은 영역용, margin 무시).
  /// 가로 공간이 배너 폭보다 좁으면 표시하지 않음.
  final bool compact;

  const AdBannerWidget({
    super.key,
    this.margin,
    this.compact = false,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final adUnitId = AdService.bannerAdUnitId;
    if (adUnitId.isEmpty) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdBannerWidget failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    if (widget.compact) {
      final adWidth = _bannerAd!.size.width.toDouble();
      final adHeight = _bannerAd!.size.height.toDouble();
      return LayoutBuilder(
        builder: (context, constraints) {
          // 광고 정책상 배너를 축소/잘라내면 안 되므로, 공간이 부족하면 숨김
          if (constraints.maxWidth < adWidth) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            width: adWidth,
            height: adHeight,
            child: AdWidget(ad: _bannerAd!),
          );
        },
      );
    }

    final settings = AppSettingsService();
    final isLight = settings.isLight;

    return Container(
      width: double.infinity,
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0xFFF1F3F5)
            : settings.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.borderColor,
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
