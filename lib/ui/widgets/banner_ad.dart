import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/native_bridge.dart';

/// Gathers ad consent (UMP, required for EEA/UK users) and starts the Ads SDK.
class Ads {
  static final ready = ValueNotifier<bool>(false);

  /// True while a banner is on screen, so the layout can make room for it.
  static final bannerVisible = ValueNotifier<bool>(false);
  static String _unitId = '';

  static Future<void> init() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _unitId = await adUnitId();
    if (_unitId.isEmpty) return;

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) => _start()),
      (_) => _start(),
    );
  }

  static Future<void> _start() async {
    if (ready.value || !await ConsentInformation.instance.canRequestAds()) {
      return;
    }
    await MobileAds.instance.initialize();
    ready.value = true;
  }

  static Future<bool> privacyOptionsRequired() async {
    if (_unitId.isEmpty) return false;
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  static Future<void> showPrivacyOptions() =>
      ConsentForm.showPrivacyOptionsForm((_) => _start());
}

/// Compact 320x50 banner, shown only once the SDK is ready and an ad has
/// loaded. It slides in so the layout doesn't jump.
class BannerAdView extends StatefulWidget {
  const BannerAdView({super.key});

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Ads.ready.addListener(_load);
    _load();
  }

  void _load() {
    if (!Ads.ready.value || _ad != null) return;
    _ad = BannerAd(
      adUnitId: Ads._unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
          Ads.bannerVisible.value = true;
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          Ads.bannerVisible.value = false;
          if (mounted) setState(() => _ad = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    Ads.ready.removeListener(_load);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    final show = ad != null && _loaded;
    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: show
          ? Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: SizedBox(
                width: ad.size.width.toDouble(),
                height: ad.size.height.toDouble(),
                child: AdWidget(ad: ad),
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}
