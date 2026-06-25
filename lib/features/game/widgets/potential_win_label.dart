import 'package:flutter/material.dart';

import '../game_provider.dart';

class PotentialWinLabel extends StatelessWidget {
  final GameProvider game;

  const PotentialWinLabel({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final isRunning = game.state == RoundState.running;
    return Text(
      isRunning ? 'Potential win: ${game.potentialWin}' : 'Bet × multiplier',
      style: TextStyle(
        fontSize: 14,
        color: isRunning ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
    );
  }
}
