import 'package:flutter/foundation.dart';

import '../../services/audio_service.dart';
import '../../services/prefs_service.dart';

class SettingsProvider extends ChangeNotifier {
  late bool _soundEnabled;
  late bool _fxEnabled;
  late bool _vibrationEnabled;

  bool get soundEnabled => _soundEnabled;
  bool get fxEnabled => _fxEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  SettingsProvider() {
    _soundEnabled = PrefsService.instance.soundEnabled;
    _fxEnabled = PrefsService.instance.fxEnabled;
    _vibrationEnabled = PrefsService.instance.vibrationEnabled;
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await PrefsService.instance.setSoundEnabled(value);
    await AudioService.instance.setMusicEnabled(value);
    if (value) {
      await AudioService.instance.resumeBackground();
    }
    notifyListeners();
  }

  Future<void> setFxEnabled(bool value) async {
    _fxEnabled = value;
    await PrefsService.instance.setFxEnabled(value);
    await AudioService.instance.setFxEnabled(value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await PrefsService.instance.setVibrationEnabled(value);
    notifyListeners();
  }
}
