import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../game_provider.dart';

class BetActionButton extends StatefulWidget {
  const BetActionButton({super.key});

  @override
  State<BetActionButton> createState() => _BetActionButtonState();
}

class _BetActionButtonState extends State<BetActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final state = context.select<GameProvider, RoundState>((g) => g.state);
    final isRunning = state == RoundState.running;
    final disabled = state == RoundState.cashedOut || state == RoundState.crashed;
    final asset = isRunning ? 'assets/cash_out_button.png' : 'assets/start_button.png';
    final label = isRunning ? 'Cash Out' : 'Start';

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              if (isRunning) {
                context.read<GameProvider>().cashOut();
              } else {
                context.read<GameProvider>().startRound();
              }
            },
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: (_pressed && !disabled) ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 151,
              height: 57,
              child: Stack(
                children: [
                  Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
                  Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 3, color: Colors.black87)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
