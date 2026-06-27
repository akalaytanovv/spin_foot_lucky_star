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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [BallWidget(isRunning: game.state == RoundState.running)],
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
