import 'package:flutter/foundation.dart';

import '../../services/audio_service.dart';
import '../../services/prefs_service.dart';

class SettingsProvider extends ChangeNotifier {
  late bool _vibrationEnabled;
  late double _soundVolume;
  late double _musicVolume;

  bool get vibrationEnabled => _vibrationEnabled;
  double get soundVolume => _soundVolume;
  double get musicVolume => _musicVolume;

  SettingsProvider() {
    _vibrationEnabled = PrefsService.instance.vibrationEnabled;
    _soundVolume = PrefsService.instance.soundVolume;
    _musicVolume = PrefsService.instance.musicVolume;
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await PrefsService.instance.setVibrationEnabled(value);
    notifyListeners();
  }

  Future<void> setSoundVolume(double value) async {
    _soundVolume = value;
    await PrefsService.instance.setSoundVolume(value);
    await AudioService.instance.setSoundVolume(value);
    notifyListeners();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value;
    await PrefsService.instance.setMusicVolume(value);
    await AudioService.instance.setMusicVolume(value);
    notifyListeners();
  }
}
