import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../game_provider.dart';

class FixedBetButton extends StatefulWidget {
  final int value;
  final bool disabled;

  const FixedBetButton({super.key, required this.value, required this.disabled});

  @override
  State<FixedBetButton> createState() => _FixedBetButtonState();
}

class _FixedBetButtonState extends State<FixedBetButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              context.read<GameProvider>().setBet(widget.value);
            },
      onTapCancel:
          widget.disabled ? null : () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: (_pressed && !widget.disabled) ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Opacity(
          opacity: widget.disabled ? 0.4 : 1.0,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 55,
              height: 55,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Image.asset('assets/bet_button.png', fit: BoxFit.fill),
                  ),
                  Text(
                    '${widget.value}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
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
