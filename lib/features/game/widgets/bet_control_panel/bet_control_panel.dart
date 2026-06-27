import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game_provider.dart';
import 'widgets/auto_play_button.dart';
import 'widgets/bet_action_button.dart';
import 'widgets/bet_counter.dart';
import 'widgets/fixed_bet_button.dart';
import 'widgets/x2_panel.dart';

// Mockup reference: panel width = 411dp.
// Spacing constants (dp, not scaled): topPad=42, row1SidePad=25, gap12=22,
//   row2SidePad=14, gap23=6, bottomPad=22.
// Container heights scale proportionally to panel width via LayoutBuilder.
// Inner widget content uses FittedBox with raw mockup px — no scaling inside widgets.
class BetControlPanel extends StatelessWidget {
  const BetControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isRunning = context.select<GameProvider, bool>(
      (g) => g.state == RoundState.running,
    );
    final x2On = context.select<GameProvider, bool>((g) => g.x2Mode);

    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth;
        final scale = panelWidth / 411;

        const double topPad = 42;
        const double row1SidePad = 25;
        const double gap12 = 22;
        const double row2SidePad = 14;
        const double gap23 = 6;
        const double bottomPad = 22;

        final row1H = 57.0 * scale;
        final row2H = 65.0 * scale;
        final row3H = 50.0 * scale;

        // 4 buttons (flex 55 each) + x2 panel (flex 157) = 377 total inner units.
        // -16 accounts for the FittedBox content inset within each button slot.
        final row2InnerW = panelWidth - row2SidePad * 2;
        final fixedBtnW = ((row2InnerW - 16) * 55.0 / 377.0).clamp(28.0, 72.0);

        // Auto play button ≈ 50% of panel width (205 / 411).
        final autoPlayW = panelWidth * (205.0 / 411.0);

        return Container(
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 12),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bet_card_bg.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: topPad),

              // Row 1: Counter + Action button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: row1SidePad),
                child: SizedBox(
                  height: row1H,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 212,
                        child: BetCounter(disabled: isRunning),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        flex: 151,
                        child: BetActionButton(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: gap12),

              // Row 2: Fixed bets + x2 panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: row2SidePad),
                child: SizedBox(
                  height: row2H,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fixedBtnW,
                        height: fixedBtnW,
                        child: FixedBetButton(value: 1, disabled: isRunning),
                      ),
                      SizedBox(
                        width: fixedBtnW,
                        height: fixedBtnW,
                        child: FixedBetButton(value: 5, disabled: isRunning),
                      ),
                      SizedBox(
                        width: fixedBtnW,
                        height: fixedBtnW,
                        child: FixedBetButton(value: 20, disabled: isRunning),
                      ),
                      SizedBox(
                        width: fixedBtnW,
                        height: fixedBtnW,
                        child: FixedBetButton(value: 100, disabled: isRunning),
                      ),
                      Expanded(
                        child: X2Panel(
                          isOn: x2On,
                          disabled: isRunning,
                          height: row2H - 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: gap23),

              // Row 3: Auto Play
              Center(
                child: SizedBox(
                  height: row3H,
                  width: autoPlayW,
                  child: const AutoPlayButton(),
                ),
              ),

              const SizedBox(height: bottomPad),
            ],
          ),
        );
      },
    );
  }
}
