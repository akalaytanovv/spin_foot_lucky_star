import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/game/game_provider.dart';

class ResultOverlayWidget extends StatefulWidget {
  const ResultOverlayWidget({super.key});

  @override
  State<ResultOverlayWidget> createState() => _ResultOverlayWidgetState();
}

class _ResultOverlayWidgetState extends State<ResultOverlayWidget> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), _dismiss);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    context.read<GameProvider>().resetRound();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isWin = game.state == RoundState.cashedOut;
    final amount = game.lastWin ?? 0;

    final label = isWin ? 'WIN' : 'CRASH';
    final amountText = isWin ? '+$amount' : '-${game.bet}';

    final borderColor = isWin ? const Color(0xFFA9FF09) : const Color(0xFFFF5252);
    final labelColor = isWin ? const Color(0xFFFFE5B4) : const Color(0xFFFF5252);
    final amountColor = isWin ? const Color(0xFFFFECAC) : const Color(0xFFFF5252);
    final glowColor = isWin ? const Color(0xFFFFCC00) : const Color(0xFFFF1744);
    final gradientColors = isWin
        ? const [Color(0xFF1C6040), Color(0xFF133D04)]
        : const [Color(0xFF4A1010), Color(0xFF2A0808)];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _timer?.cancel();
        _dismiss();
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          color: Colors.black.withValues(alpha: 0.65),
          alignment: Alignment.center,
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedScale(
              scale: _visible ? 1.0 : 0.85,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 2),
                    BoxShadow(color: glowColor.withValues(alpha: 0.25), blurRadius: 48),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(blurRadius: 12, color: glowColor),
                          Shadow(blurRadius: 24, color: glowColor.withValues(alpha: 0.6)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          amountText,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: amountColor,
                            shadows: [
                              Shadow(blurRadius: 12, color: glowColor),
                              Shadow(blurRadius: 24, color: glowColor.withValues(alpha: 0.6)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset('assets/coin.png', width: 32, height: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
