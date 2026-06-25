import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_provider.dart';

class ActionButton extends StatelessWidget {
  final GameProvider game;

  const ActionButton({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    switch (game.state) {
      case RoundState.idle:
        return _button(
          context,
          label: 'START',
          color: Colors.green,
          onPressed: () => context.read<GameProvider>().startRound(),
        );
      case RoundState.running:
        return _button(
          context,
          label: 'CASHOUT',
          color: Colors.orange,
          onPressed: () => context.read<GameProvider>().cashOut(),
        );
      case RoundState.cashedOut:
      case RoundState.crashed:
        return _button(context, label: 'START', color: Colors.grey, onPressed: null);
    }
  }

  Widget _button(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color : Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
