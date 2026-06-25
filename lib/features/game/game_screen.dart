import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/bet_panel_widget.dart';
import '../../shared/widgets/result_overlay_widget.dart';
import 'game_provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final showOverlay =
        game.state == RoundState.cashedOut || game.state == RoundState.crashed;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(balance: game.balance),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MultiplierDisplay(game: game),
                        const SizedBox(height: 8),
                        _PotentialWinLabel(game: game),
                        const SizedBox(height: 32),
                        const BetPanelWidget(),
                        const SizedBox(height: 24),
                        _ActionButton(game: game),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (showOverlay) const ResultOverlayWidget(),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int balance;

  const _TopBar({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, size: 20),
                const SizedBox(width: 6),
                Text(
                  '$balance',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Wheel',
            onPressed: () => Navigator.pushNamed(context, '/wheel'),
          ),
        ],
      ),
    );
  }
}

// ── Multiplier display ────────────────────────────────────────────────────────

class _MultiplierDisplay extends StatelessWidget {
  final GameProvider game;

  const _MultiplierDisplay({required this.game});

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
    final multiplierText =
        '${game.multiplier.toStringAsFixed(2)}x';
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
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Potential win label ───────────────────────────────────────────────────────

class _PotentialWinLabel extends StatelessWidget {
  final GameProvider game;

  const _PotentialWinLabel({required this.game});

  @override
  Widget build(BuildContext context) {
    final isRunning = game.state == RoundState.running;
    return Text(
      isRunning
          ? 'Potential win: ${game.potentialWin}'
          : 'Bet × multiplier',
      style: TextStyle(
        fontSize: 14,
        color: isRunning
            ? Theme.of(context).colorScheme.primary
            : Colors.grey,
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final GameProvider game;

  const _ActionButton({required this.game});

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
        return _button(
          context,
          label: 'START',
          color: Colors.grey,
          onPressed: null,
        );
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
