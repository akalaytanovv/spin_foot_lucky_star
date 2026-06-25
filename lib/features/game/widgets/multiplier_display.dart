import 'package:flutter/material.dart';

import '../game_provider.dart';

class MultiplierDisplay extends StatelessWidget {
  final GameProvider game;

  const MultiplierDisplay({super.key, required this.game});

  Color _multiplierColor() {
    switch (game.state) {
      case RoundState.running:
        return Colors.green;
      case RoundState.crashed:
        return Colors.red;
      case RoundState.idle:
      case RoundState.cashedOut:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final multiplierText = '${game.multiplier.toStringAsFixed(2)}x';
    final color = _multiplierColor();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 100,
          width: constraints.maxWidth,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              multiplierText,
              style: TextStyle(fontWeight: FontWeight.w900, color: color),
            ),
          ),
        );
      },
    );
  }
}
