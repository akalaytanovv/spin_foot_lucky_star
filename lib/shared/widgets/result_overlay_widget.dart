import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../features/game/game_provider.dart';
import '../../features/game/widgets/boost_reward_overlay.dart';

class ResultOverlayWidget extends StatefulWidget {
  const ResultOverlayWidget({super.key});

  @override
  State<ResultOverlayWidget> createState() => _ResultOverlayWidgetState();
}

class _ResultOverlayWidgetState extends State<ResultOverlayWidget> with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _visible = false;
  bool _showBoostButton = false;
  bool _showBoostOverlay = false;
  bool _boostStarted = false;
  bool _showBoostFinalWin = false;
  int _boostBonusAmount = 0;

  AnimationController? _pulse;
  Animation<double>? _pulseScale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final game = context.read<GameProvider>();
      final isWin = game.state == RoundState.cashedOut;

      setState(() => _visible = true);

      if (isWin && !game.autoPlay) {
        _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
        _pulseScale = Tween<double>(
          begin: 0.95,
          end: 1.05,
        ).animate(CurvedAnimation(parent: _pulse!, curve: Curves.easeInOut));
        setState(() => _showBoostButton = true);
        _timer = Timer(Constants.boostButtonDuration, _dismiss);
      } else if (isWin && game.autoPlay) {
        _timer = Timer(Constants.resultOverlayDuration, _dismiss);
      } else {
        _timer = Timer(Constants.resultOverlayDuration, _dismiss);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse?.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted || _showBoostOverlay) return;
    _timer?.cancel();
    context.read<GameProvider>().resetRound();
  }

  void _onBoostPressed() {
    if (_boostStarted || !_showBoostButton) return;
    _boostStarted = true;
    _timer?.cancel();
    setState(() {
      _showBoostButton = false;
      _showBoostOverlay = true;
    });
  }

  void _onBoostAdComplete(int bonus) {
    if (!mounted) return;
    setState(() {
      _showBoostOverlay = false;
      _showBoostFinalWin = true;
      _boostBonusAmount = bonus;
      _visible = true;
    });
    _timer?.cancel();
    _timer = Timer(Constants.resultOverlayDuration, _dismiss);
  }

  void _onBackgroundTap() {
    if (_showBoostOverlay) return;
    if (_boostStarted && !_showBoostFinalWin) return;
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isWin = game.state == RoundState.cashedOut;
    final winAmount = game.lastWin ?? 0;
    final displayAmount = _showBoostFinalWin ? _boostBonusAmount : winAmount;
    final skipBoost = isWin && game.autoPlay && !_showBoostFinalWin;

    final label = isWin ? 'You win!' : 'CRASH';
    final amountText = isWin ? '+$displayAmount' : '-${game.bet}';

    final borderColor = isWin ? const Color(0xFFA9FF09) : const Color(0xFFFF5252);
    final labelColor = isWin ? const Color(0xFFFFE5B4) : const Color(0xFFFF5252);
    final amountColor = isWin ? const Color(0xFFFFECAC) : const Color(0xFFFF5252);
    final glowColor = isWin ? const Color(0xFFFFCC00) : const Color(0xFFFF1744);
    final gradientColors = isWin
        ? const [Color(0xFF1C6040), Color(0xFF133D04)]
        : const [Color(0xFF4A1010), Color(0xFF2A0808)];

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onBackgroundTap,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
              alignment: Alignment.center,
              child: _showBoostOverlay
                  ? const SizedBox.shrink()
                  : AnimatedOpacity(
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
                                  letterSpacing: isWin ? 1 : 3,
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
                              if (_showBoostButton && !skipBoost && !_showBoostFinalWin) ...[
                                const SizedBox(height: 20),
                                ScaleTransition(
                                  scale: _pulseScale ?? const AlwaysStoppedAnimation(1.0),
                                  child: _BoostRewardButton(onTap: _onBoostPressed),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        if (_showBoostOverlay)
          Positioned.fill(
            child: BoostRewardOverlay(baseWin: winAmount, onAdComplete: _onBoostAdComplete),
          ),
      ],
    );
  }
}

class _BoostRewardButton extends StatelessWidget {
  const _BoostRewardButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 2)],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'Boost Reward',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
