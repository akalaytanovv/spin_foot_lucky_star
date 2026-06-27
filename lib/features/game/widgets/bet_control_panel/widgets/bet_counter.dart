import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../game_provider.dart';

class BetCounter extends StatefulWidget {
  final bool disabled;

  const BetCounter({super.key, required this.disabled});

  @override
  State<BetCounter> createState() => _BetCounterState();
}

class _BetCounterState extends State<BetCounter> {
  Timer? _holdTimer;
  bool _minusPressed = false;
  bool _plusPressed = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _changeBet(int delta) {
    final p = context.read<GameProvider>();
    p.setBet(p.bet + delta);
  }

  void _startHold(int delta) {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (_) => _changeBet(delta));
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  Widget _counterBtn({required String label, required int delta}) {
    final isPlus = delta > 0;
    final pressed = isPlus ? _plusPressed : _minusPressed;
    void setPressed(bool v) =>
        setState(() => isPlus ? _plusPressed = v : _minusPressed = v);

    return GestureDetector(
      onTapDown: (_) {
        setPressed(true);
        _changeBet(delta);
      },
      onTapUp: (_) => setPressed(false),
      onTapCancel: () {
        setPressed(false);
        _stopHold();
      },
      onLongPressStart: (_) {
        setPressed(true);
        _startHold(delta);
      },
      onLongPressEnd: (_) {
        setPressed(false);
        _stopHold();
      },
      child: AnimatedScale(
        scale: pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: Image.asset('assets/counter_button.png', fit: BoxFit.fill)),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bet = context.select<GameProvider, int>((g) => g.bet);

    return IgnorePointer(
      ignoring: widget.disabled,
      child: Opacity(
        opacity: widget.disabled ? 0.4 : 1.0,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: 212,
            height: 57,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: Image.asset('assets/counter_bg.png', fit: BoxFit.fill)),
                Positioned(
                  left: 0,
                  top: (57 - 52) / 2,
                  width: 47,
                  height: 52,
                  child: _counterBtn(label: '−', delta: -1),
                ),
                Positioned(
                  right: 0,
                  top: (57 - 52) / 2,
                  width: 47,
                  height: 52,
                  child: _counterBtn(label: '+', delta: 1),
                ),
                Center(
                  child: IgnorePointer(
                    child: Text(
                      '$bet',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 3, color: Colors.black87)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
