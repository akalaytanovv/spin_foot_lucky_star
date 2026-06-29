import 'package:flutter/foundation.dart';
import 'package:startapp_sdk/startapp.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  final StartAppSdk _sdk = StartAppSdk();
  StartAppRewardedVideoAd? _rewardedAd;
  bool _loading = false;

  VoidCallback? _pendingOnRewarded;

  bool get isReady => _rewardedAd != null;

  Future<void> init() async {
    if (kDebugMode) {
      _sdk.setTestAdsEnabled(true);
    }
    loadRewarded();
  }

  void loadRewarded() {
    if (_loading) return;
    _loading = true;

    _sdk
        .loadRewardedVideoAd(
          onAdNotDisplayed: () {
            debugPrint('[AdService] onAdNotDisplayed');
            _rewardedAd?.dispose();
            _rewardedAd = null;
            _loading = false;
            loadRewarded();
          },
          onAdHidden: () {
            debugPrint('[AdService] onAdHidden');
            _rewardedAd?.dispose();
            _rewardedAd = null;
            _loading = false;
            loadRewarded();
          },
          onVideoCompleted: () {
            debugPrint('[AdService] onVideoCompleted — reward granted');
            _pendingOnRewarded?.call();
            _pendingOnRewarded = null;
          },
        )
        .then((ad) {
          debugPrint('[AdService] ad loaded');
          _rewardedAd = ad;
          _loading = false;
        })
        .onError<StartAppException>((ex, _) {
          debugPrint('[AdService] load error: ${ex.message}');
          _loading = false;
        })
        .onError((e, _) {
          debugPrint('[AdService] load error: $e');
          _loading = false;
        });
  }

  /// Show rewarded video.
  /// [onRewarded] is called only when the user watches the ad to completion.
  void showRewarded({required VoidCallback onRewarded}) {
    final ad = _rewardedAd;
    if (ad == null) {
      debugPrint('[AdService] showRewarded: no ad ready');
      return;
    }
    _pendingOnRewarded = onRewarded;
    ad.show().onError((e, _) {
      debugPrint('[AdService] show error: $e');
      _pendingOnRewarded = null;
      return false;
    });
  }
}
