import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  // Test Ad Unit IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError("Unsupported platform");
  }

  Future<void> initialize() async {
    print('AdService: Ads are temporarily disabled.');
    return; // Early return to stop initialization

    /* Original initialization code
    print('AdService: Initializing MobileAds...');
    try {
      await MobileAds.instance.initialize();
      print('AdService: MobileAds initialized successfully.');

      // Load first interstitial ad after a small delay
      Future.delayed(const Duration(seconds: 2), () {
        loadInterstitialAd();
      });
    } catch (e) {
      print('AdService: Initialization error: $e');
    }
    */
  }

  void loadInterstitialAd() {
    print('Loading Interstitial Ad for Unit ID: $interstitialAdUnitId');
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('InterstitialAd successfully loaded.');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _setInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          print(
            'InterstitialAd failed to load: ${error.message} (code: ${error.code})',
          );
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  void _setInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialAdLoaded = false;
        loadInterstitialAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialAdLoaded = false;
        loadInterstitialAd();
      },
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      print('Interstitial ad not loaded yet.');
      loadInterstitialAd();
    }
  }
}
