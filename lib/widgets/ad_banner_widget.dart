import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  final String? customAdUnitId;

  const AdBannerWidget({super.key, this.customAdUnitId});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  // Google Mobile Ads (AdMob / AdSense) Banner Ad Unit IDs
  static const String _liveAndroidAdUnitId = 'ca-app-pub-7338989922918066/2618394205';
  static const String _testIosAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

  String get _adUnitId {
    if (widget.customAdUnitId != null && widget.customAdUnitId!.isNotEmpty) {
      return widget.customAdUnitId!;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ? _testIosAdUnitId : _liveAndroidAdUnitId;
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        height: 50,
        width: double.infinity,
        color: theme.colorScheme.secondaryContainer,
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Default Sponsored Content UI matching Lumia design specs
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SPONSORED CONTENT',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 14,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
