import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/result_overlay_widget.dart';
import 'game_provider.dart';
import 'widgets/ball_widget.dart';
import 'widgets/bet_control_panel/bet_control_panel.dart';
import 'widgets/top_bar.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final showOverlay = game.state == RoundState.cashedOut || game.state == RoundState.crashed;

    return AppBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TopBar(balance: game.balance),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BallWidget(isRunning: game.state == RoundState.running),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _MultiplierLabel(multiplier: game.multiplier, state: game.state),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: const BetControlPanel(),
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

class _MultiplierLabel extends StatelessWidget {
  final double multiplier;
  final RoundState state;

  const _MultiplierLabel({required this.multiplier, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final List<Shadow> shadows;

    switch (state) {
      case RoundState.running:
        color = Colors.white;
        shadows = [
          const Shadow(blurRadius: 12, color: Color(0xFF00E5FF)),
          const Shadow(blurRadius: 24, color: Color(0xFF00E5FF)),
        ];
      case RoundState.cashedOut:
        color = const Color(0xFFFFECAC);
        shadows = [
          const Shadow(blurRadius: 12, color: Color(0xFFFFCC00)),
          const Shadow(blurRadius: 24, color: Color(0xFFFFCC00)),
        ];
      case RoundState.crashed:
        color = const Color(0xFFFF5252);
        shadows = [
          const Shadow(blurRadius: 12, color: Color(0xFFFF1744)),
          const Shadow(blurRadius: 24, color: Color(0xFFFF1744)),
        ];
      case RoundState.idle:
        color = Colors.white.withValues(alpha: 0.35);
        shadows = [];
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'X',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: color,
                shadows: shadows,
              ),
            ),
            TextSpan(
              text: multiplier.toStringAsFixed(2),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: color,
                shadows: shadows,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
