import 'package:flutter/material.dart';

String _formatDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

class SpinButtonChild extends StatelessWidget {
  final bool isAnimating;
  final bool active;
  final int freeSpins;
  final Duration timeUntilNextSpin;

  const SpinButtonChild({
    super.key,
    required this.isAnimating,
    required this.active,
    required this.freeSpins,
    required this.timeUntilNextSpin,
  });

  @override
  Widget build(BuildContext context) {
    if (isAnimating) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 10),
          Text('SPINNING...'),
        ],
      );
    }
    if (active) {
      return freeSpins > 0 ? const Text('FREE SPIN') : const Text('SPIN');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, size: 18),
        const SizedBox(width: 8),
        Text(_formatDuration(timeUntilNextSpin)),
      ],
    );
  }
}
