import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/wheel/wheel_provider.dart';

class WheelTimerWidget extends StatelessWidget {
  const WheelTimerWidget({super.key});

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final wheel = context.watch<WheelProvider>();

    if (wheel.canSpin) {
      return Chip(
        avatar: const Icon(Icons.casino_outlined, size: 14),
        label: const Text(
          'WHEEL READY',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.primaryContainer,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }

    return Chip(
      avatar: const Icon(Icons.timer_outlined, size: 14),
      label: Text(
        _formatDuration(wheel.timeUntilNextSpin),
        style: const TextStyle(fontSize: 11),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
