import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:startapp_sdk/startapp.dart';

import 'audio_service.dart';

class AdService with WidgetsBindingObserver {
  AdService._();
  static final AdService instance = AdService._();

  final StartAppSdk _sdk = StartAppSdk();
  StartAppRewardedVideoAd? _rewardedAd;
  bool _loading = false;
  bool _sessionActive = false;
  bool _backgroundedDuringSession = false;
  bool _observerRegistered = false;

  VoidCallback? _pendingOnRewarded;
  VoidCallback? _pendingOnAdFinished;

  bool get isReady => _rewardedAd != null;

  Future<void> init() async {
    if (kDebugMode) {
      _sdk.setTestAdsEnabled(true);
    }
    if (!_observerRegistered) {
      WidgetsBinding.instance.addObserver(this);
      _observerRegistered = true;
    }
    loadRewarded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (_sessionActive) {
          _backgroundedDuringSession = true;
        }
      case AppLifecycleState.resumed:
        if (_backgroundedDuringSession) {
          _backgroundedDuringSession = false;
          if (_sessionActive) {
            debugPrint('[AdService] resumed after background during ad — closing session');
            _closeAdSession(reload: true);
          }
        }
      default:
        break;
    }
  }

  void loadRewarded() {
    if (_loading) return;
    _loading = true;

    _sdk
        .loadRewardedVideoAd(
          onAdNotDisplayed: () {
            debugPrint('[AdService] onAdNotDisplayed');
            _closeAdSession(reload: true);
          },
          onAdHidden: () {
            debugPrint('[AdService] onAdHidden');
            _closeAdSession(reload: true);
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

  void _finishAdSession() {
    if (!_sessionActive) return;
    _sessionActive = false;
    _backgroundedDuringSession = false;
    AudioService.instance.resumeBackgroundAfterOverlay();
    _pendingOnAdFinished?.call();
    _pendingOnAdFinished = null;
    _pendingOnRewarded = null;
  }

  void _closeAdSession({required bool reload}) {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _loading = false;
    _finishAdSession();
    if (reload) loadRewarded();
  }

  /// Cancels an in-flight ad session without granting reward.
  void cancelAdSession() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _loading = false;
    _backgroundedDuringSession = false;
    if (_sessionActive) {
      _sessionActive = false;
      AudioService.instance.resumeBackgroundAfterOverlay();
    }
    _pendingOnRewarded = null;
    _pendingOnAdFinished = null;
    loadRewarded();
  }

  /// Show rewarded video.
  /// [onRewarded] is called only when the user watches the ad to completion.
  /// [onAdFinished] is called when the ad closes (with or without reward).
  void showRewarded({required VoidCallback onRewarded, VoidCallback? onAdFinished}) {
    final ad = _rewardedAd;
    if (ad == null) {
      debugPrint('[AdService] showRewarded: no ad ready');
      onAdFinished?.call();
      return;
    }
    _pendingOnRewarded = onRewarded;
    _pendingOnAdFinished = onAdFinished;
    _sessionActive = true;
    AudioService.instance.pauseBackgroundForOverlay();
    ad
        .show()
        .then((shown) {
          if (!shown) {
            debugPrint('[AdService] showRewarded: show returned false');
            _closeAdSession(reload: true);
          }
        })
        .catchError((Object e, _) {
          debugPrint('[AdService] show error: $e');
          _closeAdSession(reload: true);
        });
  }
}
