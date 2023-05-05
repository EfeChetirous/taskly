import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  late BannerAd _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: "ca-app-pub-5496362289491904/7979953754",
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

    _bannerAd?.load();
  }

  void loadRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isIOS
            ? "ca-app-pub-3940256099942544/1712485313"
            : "ca-app-pub-5496362289491904/7979953754",
        request: const AdRequest(),
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
        }));
  }

  void loadInterstitialAd() {
    String interstitialAdId = Platform.isIOS
        ? "ca-app-pub-3940256099942544/4411468910"
        : "ca-app-pub-5496362289491904/7979953754";

    InterstitialAd.load(
        adUnitId: interstitialAdId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                ad.dispose();
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent:
                  (InterstitialAd ad, AdError error) {
                ad.dispose();
                loadInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void addAds(bool interstitial, bool bannerAd, bool rewardedAd) {
    if (interstitial) {
      loadInterstitialAd();
    }

    if (bannerAd) {
      loadBannerAd();
    }

    if (rewardedAd) {
      loadRewardedAd();
    }
  }

  void showInterstitial() {
    _interstitialAd?.show();
  }

  BannerAd getBannerAd() {
    return _bannerAd;
  }

  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad) {
        print("Ad onAdShowedFullScreenContent");
      }, onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        loadRewardedAd();
      }, onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        loadRewardedAd();
      });

      _rewardedAd!.setImmersiveMode(true);
      _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print("${reward.amount} ${reward.type}");
      });
    }
  }

  void disposeAds() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
