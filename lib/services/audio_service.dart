import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

import 'prefs_service.dart';

class AudioService with WidgetsBindingObserver {
  AudioService._();
  static final AudioService instance = AudioService._();

  static const backgroundAsset = 'audio/bg.mp3';
  static const winAsset = 'audio/win.mp3';
  static const loseAsset = 'audio/lose.mp3';

  static const assetsToPreload = [backgroundAsset, winAsset, loseAsset];

  late AudioPlayer _bgPlayer;
  late AudioPlayer _spinPlayer;
  bool _initialized = false;

  /// One-shot FX players; each play gets its own instance so sounds can overlap.
  final Set<AudioPlayer> _activeFxPlayers = {};

  /// True when music was playing at the moment the app went to background.
  /// Reset on resume or on any intentional stop/play.
  bool _wasPlayingBeforePause = false;

  /// Last asset passed to [playBackground]. Used to restart the player after
  /// Android kills the audio stream entirely instead of just pausing it.
  String? _lastBgAsset;

  /// Tracks the spin player's current volume during fade-out so [stopSpin]
  /// always fades from the actual in-flight level, not from a stale value.
  double _spinVolume = 1.0;

  Timer? _fadeTimer;
  bool _assetsPreloaded = false;

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) await dispose();

    await AudioPlayer.global.setAudioContext(
      const AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );

    _bgPlayer = AudioPlayer();
    _spinPlayer = AudioPlayer();

    // Apply saved volume preferences immediately so the first playback
    // matches the user's settings without needing a slider interaction.
    final sv = PrefsService.instance.soundVolume;
    final mv = PrefsService.instance.musicVolume;
    await _bgPlayer.setVolume(mv);
    await _spinPlayer.setVolume(sv);
    _spinVolume = sv;

    WidgetsBinding.instance.addObserver(this);
    _initialized = true;
  }

  /// Loads game audio assets into memory. Safe to call multiple times.
  Future<void> preloadAssets() async {
    if (!_initialized || _assetsPreloaded) return;
    final cache = AudioCache(prefix: 'assets/');
    await cache.loadAll(assetsToPreload);
    _assetsPreloaded = true;
  }

  // ── App lifecycle ─────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialized) return;

    switch (state) {
      // Pause only on `paused`. `inactive` fires during in-app navigation and
      // must not interrupt playback.
      case AppLifecycleState.paused:
        if (_bgPlayer.state == PlayerState.playing) {
          _wasPlayingBeforePause = true;
          _bgPlayer.pause();
        }
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _wasPlayingBeforePause = false;
          // Android may have killed the stream (stopped instead of paused).
          if (_bgPlayer.state == PlayerState.paused) {
            _bgPlayer.resume();
          } else if (_lastBgAsset != null) {
            playBackground(_lastBgAsset!);
          }
        }
        break;
      default:
        break;
    }
  }

  // ── Background music ──────────────────────────────────────────────────────

  /// Starts looping background music from [asset]. Call again to switch tracks.
  Future<void> playBackground(String asset) async {
    if (!_initialized) return;

    if (_lastBgAsset == asset && _bgPlayer.state == PlayerState.playing) return;

    _lastBgAsset = asset;
    _wasPlayingBeforePause = false;
    await _bgPlayer.stop();
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource(asset));
  }

  Future<void> stopBackground() async {
    if (!_initialized) return;
    _wasPlayingBeforePause = false;
    _lastBgAsset = null;
    await _bgPlayer.stop();
  }

  Future<void> pauseBackground() async {
    if (!_initialized) return;
    if (_bgPlayer.state == PlayerState.playing) {
      await _bgPlayer.pause();
    }
  }

  Future<void> resumeBackground() async {
    if (!_initialized) return;
    _wasPlayingBeforePause = false;
    if (_bgPlayer.state == PlayerState.paused) {
      await _bgPlayer.resume();
    } else if (_lastBgAsset != null) {
      await playBackground(_lastBgAsset!);
    }
  }

  // ── FX ───────────────────────────────────────────────────────────────────

  Future<void> playWin() => _playFx(winAsset);

  Future<void> playLose() => _playFx(loseAsset);

  Future<void> _playFx(String asset) async {
    if (!_initialized) return;

    final player = AudioPlayer();
    _activeFxPlayers.add(player);

    StreamSubscription<void>? subscription;
    subscription = player.onPlayerComplete.listen((_) async {
      await subscription?.cancel();
      _activeFxPlayers.remove(player);
      await player.dispose();
    });

    try {
      await player.setVolume(PrefsService.instance.soundVolume);
      await player.play(AssetSource(asset));
    } catch (_) {
      await subscription.cancel();
      _activeFxPlayers.remove(player);
      await player.dispose();
    }
  }

  Future<void> playSpin() async {
    if (!_initialized) return;
    _fadeTimer?.cancel();
    // Read the current user preference so each spin starts at the correct level.
    _spinVolume = PrefsService.instance.soundVolume;
    await _spinPlayer.setReleaseMode(ReleaseMode.loop);
    await _spinPlayer.setVolume(_spinVolume);
  }

  /// Fades the spin sound out from its current volume over ~500 ms, then stops.
  Future<void> stopSpin() async {
    if (!_initialized) return;
    _fadeTimer?.cancel();
    final startVolume = _spinVolume;
    const steps = 10;
    const stepDuration = Duration(milliseconds: 50);
    int step = 0;

    _fadeTimer = Timer.periodic(stepDuration, (timer) async {
      step++;
      _spinVolume = startVolume * (1 - step / steps);
      if (step >= steps) {
        timer.cancel();
        _spinVolume = 0;
        await _spinPlayer.stop();
        // Restore to the user's saved preference so the next playSpin
        // picks up the right starting volume.
        final restored = PrefsService.instance.soundVolume;
        _spinVolume = restored;
        await _spinPlayer.setVolume(restored);
      } else {
        await _spinPlayer.setVolume(_spinVolume);
      }
    });
  }

  // ── Settings ─────────────────────────────────────────────────────────────

  Future<void> setSoundVolume(double volume) async {
    if (!_initialized) return;
    // Cancel any in-progress fade so its timer doesn't overwrite this value.
    _fadeTimer?.cancel();
    _spinVolume = volume;
    await _spinPlayer.setVolume(volume);
    for (final player in _activeFxPlayers) {
      await player.setVolume(volume);
    }
  }

  Future<void> setMusicVolume(double volume) async {
    if (!_initialized) return;
    await _bgPlayer.setVolume(volume);
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    if (!_initialized) return;
    _initialized = false;

    WidgetsBinding.instance.removeObserver(this);
    _fadeTimer?.cancel();
    _fadeTimer = null;
    _wasPlayingBeforePause = false;
    _lastBgAsset = null;
    _assetsPreloaded = false;

    await _bgPlayer.stop();
    await _bgPlayer.dispose();
    for (final player in _activeFxPlayers.toList()) {
      await player.stop();
      await player.dispose();
    }
    _activeFxPlayers.clear();
    await _spinPlayer.stop();
    await _spinPlayer.dispose();
  }
}
