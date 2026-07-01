import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../core/constants.dart';
import '../../services/prefs_service.dart';
import '../game/game_provider.dart';

class WheelPrize {
  final String label;
  final int coins;
  final int freeSpins;

  const WheelPrize({required this.label, required this.coins, required this.freeSpins});
}

class WheelProvider extends ChangeNotifier {
  // 12 equal segments (30° each), clockwise from top, matching wheel_example.png
  static const List<WheelPrize> prizes = [
    WheelPrize(label: 'MEGA WIN!\n10 000', coins: 10000, freeSpins: 0),
    WheelPrize(label: '100', coins: 100, freeSpins: 0),
    WheelPrize(label: 'FAIL', coins: 0, freeSpins: 0),
    WheelPrize(label: '500', coins: 500, freeSpins: 0),
    WheelPrize(label: '1 000', coins: 1000, freeSpins: 0),
    WheelPrize(label: '200', coins: 200, freeSpins: 0),
    WheelPrize(label: '3 FREE\nSPINS', coins: 0, freeSpins: 3),
    WheelPrize(label: '300', coins: 300, freeSpins: 0),
    WheelPrize(label: 'FAIL', coins: 0, freeSpins: 0),
    WheelPrize(label: '5 000', coins: 5000, freeSpins: 0),
    WheelPrize(label: '150', coins: 150, freeSpins: 0),
    WheelPrize(label: '800', coins: 800, freeSpins: 0),
  ];

  static final _random = Random();

  int _spinToIndex = 0;
  WheelPrize? _lastPrize;
  Timer? _countdownTimer;

  WheelProvider() {
    if (!canSpin) {
      _startCountdownTimer();
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  int get spinToIndex => _spinToIndex;
  WheelPrize? get lastPrize => _lastPrize;
  int get freeSpins => PrefsService.instance.freeSpins;

  bool get canSpin {
    if (PrefsService.instance.freeSpins > 0) return true;
    final last = PrefsService.instance.lastWheelSpin;
    if (last == null) return true;
    return DateTime.now().difference(last) >= Constants.wheelCooldown;
  }

  Duration get timeUntilNextSpin {
    final last = PrefsService.instance.lastWheelSpin;
    if (last == null) return Duration.zero;
    if (PrefsService.instance.freeSpins > 0) return Duration.zero;
    final remaining = last.add(Constants.wheelCooldown).difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // ── Spin ─────────────────────────────────────────────────────────────────

  void spin() {
    final currentFreeSpins = PrefsService.instance.freeSpins;
    if (!canSpin) return;

    _spinToIndex = _pickPrize();
    _lastPrize = prizes[_spinToIndex];

    if (currentFreeSpins > 0) {
      PrefsService.instance.setFreeSpins(currentFreeSpins - 1);
    } else {
      PrefsService.instance.setLastWheelSpin(DateTime.now());
      _startCountdownTimer();
    }

    notifyListeners();
  }

  void onSpinComplete(GameProvider game) {
    final prize = _lastPrize;
    if (prize != null) {
      if (prize.coins > 0) {
        game.addToBalance(prize.coins);
      }
      if (prize.freeSpins > 0) {
        final current = PrefsService.instance.freeSpins;
        PrefsService.instance.setFreeSpins(current + prize.freeSpins);
      }
    }

    if (PrefsService.instance.vibrationEnabled) {
      Vibration.vibrate(duration: 200);
    }

    // If no free spins remain and the cooldown is still active, start the
    // countdown timer so the UI updates correctly.
    if (PrefsService.instance.freeSpins == 0) {
      final last = PrefsService.instance.lastWheelSpin;
      if (last != null && DateTime.now().difference(last) < Constants.wheelCooldown) {
        _startCountdownTimer();
      }
    }

    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _pickPrize() => _random.nextInt(prizes.length);

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (canSpin) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
