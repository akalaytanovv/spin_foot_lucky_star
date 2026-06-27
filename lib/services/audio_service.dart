import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

import 'prefs_service.dart';

class AudioService with WidgetsBindingObserver {
  AudioService._();
  static final AudioService instance = AudioService._();

  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _fxPlayer;
  late final AudioPlayer _spinPlayer;

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

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
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
    _fxPlayer = AudioPlayer();
    _spinPlayer = AudioPlayer();

    // Apply saved volume preferences immediately so the first playback
    // matches the user's settings without needing a slider interaction.
    final sv = PrefsService.instance.soundVolume;
    final mv = PrefsService.instance.musicVolume;
    await _bgPlayer.setVolume(mv);
    await _fxPlayer.setVolume(sv);
    await _spinPlayer.setVolume(sv);
    _spinVolume = sv;

    WidgetsBinding.instance.addObserver(this);
  }

  // ── App lifecycle ─────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // Pause only on `paused`. `inactive` fires during in-app navigation and
      // must not interrupt playback.
      case AppLifecycleState.paused:
        if (_bgPlayer.state == PlayerState.playing) {
          _wasPlayingBeforePause = true;
          _bgPlayer.pause();
        }
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
      default:
        break;
    }
  }

  // ── Background music ──────────────────────────────────────────────────────

  /// Starts looping background music from [asset]. Call again to switch tracks.
  Future<void> playBackground(String asset) async {
    _lastBgAsset = asset;
    _wasPlayingBeforePause = false;
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource(asset));
  }

  Future<void> stopBackground() async {
    _wasPlayingBeforePause = false;
    await _bgPlayer.stop();
  }

  Future<void> pauseBackground() async {
    if (_bgPlayer.state == PlayerState.playing) {
      await _bgPlayer.pause();
    }
  }

  Future<void> resumeBackground() async {
    _wasPlayingBeforePause = false;
    if (_bgPlayer.state == PlayerState.paused) {
      await _bgPlayer.resume();
    } else if (_lastBgAsset != null) {
      await playBackground(_lastBgAsset!);
    }
  }

  // ── FX ───────────────────────────────────────────────────────────────────

  Future<void> playWin() async {
    await _fxPlayer.play(AssetSource('audio/win.mp3'));
  }

  Future<void> playLose() async {
    await _fxPlayer.play(AssetSource('audio/lose.mp3'));
  }

  Future<void> playSpin() async {
    _fadeTimer?.cancel();
    // Read the current user preference so each spin starts at the correct level.
    _spinVolume = PrefsService.instance.soundVolume;
    await _spinPlayer.setReleaseMode(ReleaseMode.loop);
    await _spinPlayer.setVolume(_spinVolume);
    await _spinPlayer.play(AssetSource('audio/spin.mp3'));
  }

  /// Fades the spin sound out from its current volume over ~500 ms, then stops.
  Future<void> stopSpin() async {
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
    // Cancel any in-progress fade so its timer doesn't overwrite this value.
    _fadeTimer?.cancel();
    _spinVolume = volume;
    await _fxPlayer.setVolume(volume);
    await _spinPlayer.setVolume(volume);
  }

  Future<void> setMusicVolume(double volume) async {
    await _bgPlayer.setVolume(volume);
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _fadeTimer?.cancel();
    await _bgPlayer.dispose();
    await _fxPlayer.dispose();
    await _spinPlayer.dispose();
  }
}
