import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../game_provider.dart';
import 'auto_play_dialog.dart';

class AutoPlayButton extends StatefulWidget {
  const AutoPlayButton({super.key});

  @override
  State<AutoPlayButton> createState() => _AutoPlayButtonState();
}

class _AutoPlayButtonState extends State<AutoPlayButton> {
  bool _pressed = false;

  void _onTap(BuildContext context, bool isAutoPlayActive, bool isRunning) {
    if (isAutoPlayActive) {
      context.read<GameProvider>().stopAutoPlay();
    } else if (!isRunning) {
      showAutoPlayDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAutoPlay = context.select<GameProvider, bool>((g) => g.autoPlay);
    final isRunning = context.select<GameProvider, bool>((g) => g.state == RoundState.running);
    final roundsLeft = context.select<GameProvider, int>((g) => g.autoPlayRoundsLeft);

    final disabled = !isAutoPlay && isRunning;
    final label = isAutoPlay ? 'Stop' : 'Auto Play';
    final sublabel = isAutoPlay && roundsLeft > 0 ? '×$roundsLeft' : null;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              _onTap(context, isAutoPlay, isRunning);
            },
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: (_pressed && !disabled) ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Opacity(
          opacity: disabled ? 0.4 : 1.0,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 205,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: Image.asset('assets/autoplay_button.png', fit: BoxFit.fill)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: const [Shadow(blurRadius: 2, color: Colors.black54)],
                        ),
                      ),
                      if (sublabel != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          sublabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                          ),
                        ),
                      ],
                    ],
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
