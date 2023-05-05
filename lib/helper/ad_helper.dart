import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5496362289491904/7979953754';
    } else if (Platform.isIOS) {
      return 'not ready';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    try {
      if (Platform.isAndroid) {
        return "ca-app-pub-5496362289491904/7979953754";
      } else if (Platform.isIOS) {
        return "not ready";
      } else {
        return "ca-app-pub-5496362289491904/7979953754";
      }
    } catch (Exception) {
      return "ca-app-pub-5496362289491904/7979953754";
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5496362289491904/7979953754";
    } else if (Platform.isIOS) {
      return "not ready";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
