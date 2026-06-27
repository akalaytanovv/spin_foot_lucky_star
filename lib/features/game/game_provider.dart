import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

import '../../core/constants.dart';
import '../../services/audio_service.dart';
import '../../services/prefs_service.dart';

enum RoundState { idle, running, cashedOut, crashed }

class GameProvider extends ChangeNotifier {
  int _balance;
  int _bet;
  bool _x2Mode = false;
  RoundState _state = RoundState.idle;
  double _multiplier = 1.00;
  double _crashPoint = 1.00;
  double _elapsed = 0.0;
  int _effectiveBet = 0;
  // null = no result yet, 0 = lost, > 0 = amount won
  int? _lastWin;
  Timer? _timer;

  GameProvider() : _balance = PrefsService.instance.balance, _bet = Constants.minBet {
    final savedBet = PrefsService.instance.bet;
    _bet = savedBet.clamp(Constants.minBet, _safeMaxBet(_balance));
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  int get balance => _balance;
  int get bet => _bet;
  bool get x2Mode => _x2Mode;
  RoundState get state => _state;
  double get multiplier => _multiplier;
  int? get lastWin => _lastWin;

  int get maxBet => _safeMaxBet(_balance);

  int get potentialWin {
    final activeBet = _state == RoundState.running ? _effectiveBet : (_x2Mode ? (_bet * 2).clamp(Constants.minBet, maxBet) : _bet);
    double win = activeBet * _multiplier;
    final bonusPercent = PrefsService.instance.bonusPercent;
    final bonusExpiry = PrefsService.instance.bonusExpiry;
    if (bonusPercent > 0 && bonusExpiry != null && bonusExpiry.isAfter(DateTime.now())) {
      win *= (1 + bonusPercent / 100);
    }
    return win.round();
  }

  static int _safeMaxBet(int balance) {
    final max = (balance * 0.9).floor();
    return max < Constants.minBet ? Constants.minBet : max;
  }

  // ── Bet ──────────────────────────────────────────────────────────────────

  void setBet(int value) {
    _bet = value.clamp(Constants.minBet, maxBet);
    PrefsService.instance.setBet(_bet);
    notifyListeners();
  }

  void toggleX2() {
    if (_state == RoundState.running) return;
    _x2Mode = !_x2Mode;
    notifyListeners();
  }

  void addToBalance(int amount) {
    _balance += amount;
    PrefsService.instance.setBalance(_balance);
    notifyListeners();
  }

  // ── Round ─────────────────────────────────────────────────────────────────

  void startRound() {
    if (_state != RoundState.idle) return;
    _effectiveBet = _x2Mode ? (_bet * 2).clamp(Constants.minBet, maxBet) : _bet;
    if (_balance < _effectiveBet) return;

    _balance -= _effectiveBet;
    _state = RoundState.running;
    _elapsed = 0.0;
    _multiplier = 1.00;
    _crashPoint = _generateCrashPoint();
    _lastWin = null;

    AudioService.instance.playSpin();
    notifyListeners();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void _tick() {
    _elapsed += 0.1;
    _multiplier = 1.0 + (_elapsed * 0.15);
    if (_multiplier >= _crashPoint) {
      _multiplier = _crashPoint;
      _crash();
    } else {
      notifyListeners();
    }
  }

  void cashOut() {
    if (_state != RoundState.running) return;
    _timer?.cancel();
    _timer = null;

    double winAmount = _effectiveBet * _multiplier;
    final bonusPercent = PrefsService.instance.bonusPercent;
    final bonusExpiry = PrefsService.instance.bonusExpiry;
    if (bonusPercent > 0 && bonusExpiry != null && bonusExpiry.isAfter(DateTime.now())) {
      winAmount *= (1 + bonusPercent / 100);
    }
    final win = winAmount.roundToDouble().toInt();
    _lastWin = win;
    _balance += win;
    _state = RoundState.cashedOut;

    _afterRound(win);
    notifyListeners();

    AudioService.instance.stopSpin();
    AudioService.instance.playWin();
    _vibrate();
  }

  void _crash() {
    _timer?.cancel();
    _timer = null;
    _state = RoundState.crashed;
    _lastWin = 0;

    _afterRound(0);
    notifyListeners();

    AudioService.instance.stopSpin();
    AudioService.instance.playLose();
    _vibrate();
  }

  Future<void> _afterRound(int win) async {
    try {
      await PrefsService.instance.setBalance(_balance);
      if (win > 0) {
        await PrefsService.instance.addLeaderboardEntry(win);
      }
      if (_balance < Constants.lowBalanceThreshold) {
        _balance += Constants.lowBalanceBonus;
        await PrefsService.instance.setBalance(_balance);
        notifyListeners();
      }
    } catch (e, stack) {
      debugPrint('[GameProvider] _afterRound error: $e\n$stack');
    }
  }

  void resetRound() {
    if (_state == RoundState.running) return;
    _state = RoundState.idle;
    _multiplier = 1.00;
    _elapsed = 0.0;
    _lastWin = null;
    final clamped = _bet.clamp(Constants.minBet, maxBet);
    if (clamped != _bet) {
      _bet = clamped;
      PrefsService.instance.setBet(_bet);
    }
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  double _generateCrashPoint() {
    final r = Random().nextDouble();
    final crash = 0.95 / (1.0 - r);
    return double.parse(crash.toStringAsFixed(2)).clamp(1.05, 100.00);
  }

  void _vibrate() {
    if (PrefsService.instance.vibrationEnabled) {
      Vibration.vibrate(duration: 200);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
