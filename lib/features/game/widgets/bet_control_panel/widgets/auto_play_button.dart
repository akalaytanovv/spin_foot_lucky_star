import 'package:flutter/material.dart';

class AutoPlayButton extends StatefulWidget {
  const AutoPlayButton({super.key});

  @override
  State<AutoPlayButton> createState() => _AutoPlayButtonState();
}

class _AutoPlayButtonState extends State<AutoPlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 205,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset('assets/autoplay_button.png', fit: BoxFit.fill),
                ),
                const Text(
                  'Auto Play',
                  style: TextStyle(
                    fontSize: 16,
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
    );
  }
}
