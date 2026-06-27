import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/image_button.dart';
import '../wheel_provider.dart';

String _formatDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

class SpinButton extends StatelessWidget {
  final bool isAnimating;
  final VoidCallback onPressed;

  const SpinButton({super.key, required this.isAnimating, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<WheelProvider>(
      builder: (context, wheel, _) {
        final active = wheel.canSpin && !isAnimating;
        final hasCountdown = !active && !isAnimating && wheel.timeUntilNextSpin > Duration.zero;
        final String label = wheel.freeSpins > 0 ? 'FREE SPIN' : 'SPIN';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 58),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasCountdown) ...[
                Text(
                  _formatDuration(wheel.timeUntilNextSpin),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              ImageButton(label: label, height: 61, isLoading: isAnimating, onPressed: active ? onPressed : null),
            ],
          ),
        );
      },
    );
  }
}
