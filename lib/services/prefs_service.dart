import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

class PrefsService {
  PrefsService._();
  static final PrefsService instance = PrefsService._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Balance ──────────────────────────────────────────────────────────────

  int get balance => _prefs.getInt('balance') ?? Constants.initialBalance;

  Future<void> setBalance(int value) => _prefs.setInt('balance', value);

  // ── Bet ──────────────────────────────────────────────────────────────────

  int get bet => _prefs.getInt('bet') ?? Constants.minBet;

  Future<void> setBet(int value) => _prefs.setInt('bet', value);

  // ── Sound / FX / Vibration ───────────────────────────────────────────────

  bool get soundEnabled => _prefs.getBool('soundEnabled') ?? true;

  Future<void> setSoundEnabled(bool value) =>
      _prefs.setBool('soundEnabled', value);

  bool get fxEnabled => _prefs.getBool('fxEnabled') ?? true;

  Future<void> setFxEnabled(bool value) => _prefs.setBool('fxEnabled', value);

  bool get vibrationEnabled => _prefs.getBool('vibrationEnabled') ?? true;

  Future<void> setVibrationEnabled(bool value) =>
      _prefs.setBool('vibrationEnabled', value);

  double get soundVolume => _prefs.getDouble('soundVolume') ?? 1.0;

  Future<void> setSoundVolume(double value) =>
      _prefs.setDouble('soundVolume', value);

  double get musicVolume => _prefs.getDouble('musicVolume') ?? 1.0;

  Future<void> setMusicVolume(double value) =>
      _prefs.setDouble('musicVolume', value);

  // ── Wheel ────────────────────────────────────────────────────────────────

  /// Returns null if the wheel has never been spun.
  DateTime? get lastWheelSpin {
    final raw = _prefs.getString('lastWheelSpin');
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setLastWheelSpin(DateTime value) =>
      _prefs.setString('lastWheelSpin', value.toIso8601String());

  Future<void> clearLastWheelSpin() => _prefs.remove('lastWheelSpin');

  // ── Bonus ────────────────────────────────────────────────────────────────

  int get bonusPercent => _prefs.getInt('bonusPercent') ?? 0;

  Future<void> setBonusPercent(int value) =>
      _prefs.setInt('bonusPercent', value);

  /// Returns null if no bonus expiry is set.
  DateTime? get bonusExpiry {
    final raw = _prefs.getString('bonusExpiry');
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setBonusExpiry(DateTime value) =>
      _prefs.setString('bonusExpiry', value.toIso8601String());

  // ── Free spins ───────────────────────────────────────────────────────────

  int get freeSpins => _prefs.getInt('freeSpins') ?? 0;

  Future<void> setFreeSpins(int value) => _prefs.setInt('freeSpins', value);

  // ── Leaderboard ──────────────────────────────────────────────────────────

  /// Top-10 scores, sorted descending.
  List<int> get leaderboard {
    final raw = _prefs.getString('leaderboard');
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<int>();
  }

  Future<void> _saveLeaderboard(List<int> scores) =>
      _prefs.setString('leaderboard', jsonEncode(scores));

  /// Inserts [score], keeps top-10 sorted descending.
  Future<void> addLeaderboardEntry(int score) async {
    final scores = leaderboard;
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a));
    if (scores.length > 10) scores.removeRange(10, scores.length);
    await _saveLeaderboard(scores);
  }
}
