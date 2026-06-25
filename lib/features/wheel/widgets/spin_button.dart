import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../wheel_provider.dart';
import 'spin_button_child.dart';

class SpinButton extends StatelessWidget {
  final bool isAnimating;
  final VoidCallback onPressed;

  const SpinButton({
    super.key,
    required this.isAnimating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WheelProvider>(
      builder: (context, wheel, _) {
        final active = wheel.canSpin && !isAnimating;
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: active ? Colors.deepOrange : Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            onPressed: active ? onPressed : null,
            child: SpinButtonChild(
              isAnimating: isAnimating,
              active: active,
              freeSpins: wheel.freeSpins,
              timeUntilNextSpin: wheel.timeUntilNextSpin,
            ),
          ),
        );
      },
    );
  }
}
