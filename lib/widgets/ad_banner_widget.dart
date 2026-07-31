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
  bool _isUsingFallback = false;

  // Google Mobile Ads Live & Test Unit IDs
  static const String _liveAndroidAdUnitId = 'ca-app-pub-7338989922918066/2618394205';
  static const String _testAndroidAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

  String get _primaryAdUnitId {
    if (widget.customAdUnitId != null && widget.customAdUnitId!.isNotEmpty) {
      return widget.customAdUnitId!;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ? _testIosAdUnitId : _liveAndroidAdUnitId;
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      _loadBannerAd(_primaryAdUnitId);
    }
  }

  void _loadBannerAd(String adUnitId) {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
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
          debugPrint('AdBannerWidget failed to load unit ($adUnitId): ${error.message} (code ${error.code})');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
            if (!_isUsingFallback && adUnitId == _liveAndroidAdUnitId) {
              _isUsingFallback = true;
              _loadBannerAd(_testAndroidAdUnitId);
            }
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
      return SafeArea(
        top: false,
        child: Container(
          height: 50,
          width: double.infinity,
          color: theme.colorScheme.secondaryContainer,
          alignment: Alignment.center,
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // Default Sponsored Content UI matching Lumia design specs
    return SafeArea(
      top: false,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ads_click, size: 16, color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(
              'SPONSORED ADVERTISEMENT',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
