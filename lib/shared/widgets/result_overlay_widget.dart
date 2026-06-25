import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/game/game_provider.dart';

class ResultOverlayWidget extends StatefulWidget {
  const ResultOverlayWidget({super.key});

  @override
  State<ResultOverlayWidget> createState() => _ResultOverlayWidgetState();
}

class _ResultOverlayWidgetState extends State<ResultOverlayWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    context.read<GameProvider>().resetRound();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isWin = game.state == RoundState.cashedOut;
    final amount = game.lastWin ?? 0;

    final color = isWin ? Colors.green : Colors.red;
    final label = isWin ? 'WIN' : 'CRASH';
    final amountText = isWin ? '+$amount' : '-${game.bet}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _timer?.cancel();
        _dismiss();
      },
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: color,
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
