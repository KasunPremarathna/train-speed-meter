import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService.isEnabled) {
      _loadAd();
    }
  }

  void _loadAd() {
    print('Loading Banner Ad for Unit ID: ${AdService.bannerAdUnitId}');
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('BannerAd successfully loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print(
            'BannerAd failed to load: ${error.message} (code: ${error.code})',
          );
          ad.dispose();
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
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Optional: Show a small informative text in debug mode
    return Container(
      width: 320,
      height: 50,
      color: Colors.black12,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              _isLoaded = false;
              _loadAd();
            });
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ad Placement',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              Icon(Icons.refresh, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
