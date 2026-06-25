import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/bet_panel_widget.dart';
import '../../shared/widgets/result_overlay_widget.dart';
import 'game_provider.dart';

// ── Ball animation widget ──────────────────────────────────────────────────────

class _BallWidget extends StatefulWidget {
  final bool isRunning;

  const _BallWidget({required this.isRunning});

  @override
  State<_BallWidget> createState() => _BallWidgetState();
}

class _BallWidgetState extends State<_BallWidget> {
  static const _frames = ['assets/ball_dynamic_1.png', 'assets/ball_dynamic_2.png', 'assets/ball_dynamic_3.png'];
  static const _frameDuration = Duration(milliseconds: 70);

  // Native size of the dynamic sprite asset (full canvas with effects).
  static const double _dynamicW = 282;
  static const double _dynamicH = 292;
  // Scale applied to the container (1.0 = native size).
  static const double _scale = 0.7;

  static const double _containerW = _dynamicW * _scale;
  static const double _containerH = _dynamicH * _scale;
  // Native size of the static ball asset relative to the dynamic canvas.
  static const double _staticRatioW = 198 / _dynamicW;
  static const double _staticRatioH = 200 / _dynamicH;
  static const double _staticW = _containerW * _staticRatioW;
  static const double _staticH = _containerH * _staticRatioH;

  int _frameIndex = 0;
  late final ValueNotifier<int> _frameNotifier;

  @override
  void initState() {
    super.initState();
    _frameNotifier = ValueNotifier(0);
    if (widget.isRunning) _startAnimation();
  }

  @override
  void didUpdateWidget(_BallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _frameIndex = 0;
      _startAnimation();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _stopAnimation();
    }
  }

  bool _animating = false;

  void _startAnimation() {
    if (_animating) return;
    _animating = true;
    _scheduleNext();
  }

  void _scheduleNext() {
    if (!_animating || !mounted) return;
    Future.delayed(_frameDuration, () {
      if (!_animating || !mounted) return;
      _frameIndex = (_frameIndex + 1) % _frames.length;
      _frameNotifier.value = _frameIndex;
      _scheduleNext();
    });
  }

  void _stopAnimation() {
    _animating = false;
  }

  @override
  void dispose() {
    _animating = false;
    _frameNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _containerW,
      height: _containerH,
      child: widget.isRunning
          ? ValueListenableBuilder<int>(
              valueListenable: _frameNotifier,
              builder: (_, idx, __) =>
                  Image.asset(_frames[idx], width: _containerW, height: _containerH, fit: BoxFit.fill),
            )
          : Center(
              child: Image.asset('assets/ball_static.png', width: _staticW, height: _staticH),
            ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final showOverlay = game.state == RoundState.cashedOut || game.state == RoundState.crashed;

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
                        _BallWidget(isRunning: game.state == RoundState.running),
                        const SizedBox(height: 20),
                        _MultiplierDisplay(game: game),
                        const SizedBox(height: 8),
                        _PotentialWinLabel(game: game),
                        const SizedBox(height: 20),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final balanceWidth = totalWidth / 3;
          final buttonsWidth = totalWidth * 2 / 3;

          return Row(
            children: [
              // Balance — 1/3 of screen width
              SizedBox(
                width: balanceWidth,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/balance.png', width: balanceWidth, height: 44, fit: BoxFit.contain),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 13, bottom: 3),
                        child: Image.asset('assets/coin.png', width: 28, height: 28),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 3),
                      child: Text(
                        '$balance',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Buttons — 2/3 of screen width, equally spaced
              SizedBox(
                width: buttonsWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TopBarButton(asset: 'assets/shop.png', tooltip: 'Shop', onPressed: () {}),
                    _TopBarButton(asset: 'assets/withdraw.png', tooltip: 'Ball', onPressed: () {}),
                    _TopBarButton(
                      asset: 'assets/wheel.png',
                      tooltip: 'Wheel',
                      onPressed: () => Navigator.pushNamed(context, '/wheel'),
                    ),
                    _TopBarButton(
                      asset: 'assets/settings.png',
                      tooltip: 'Settings',
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final String asset;
  final String tooltip;
  final VoidCallback onPressed;

  const _TopBarButton({required this.asset, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Image.asset(asset, width: 40, height: 40, fit: BoxFit.contain),
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

// ── Potential win label ───────────────────────────────────────────────────────

class _PotentialWinLabel extends StatelessWidget {
  final GameProvider game;

  const _PotentialWinLabel({required this.game});

  @override
  Widget build(BuildContext context) {
    final isRunning = game.state == RoundState.running;
    return Text(
      isRunning ? 'Potential win: ${game.potentialWin}' : 'Bet × multiplier',
      style: TextStyle(fontSize: 14, color: isRunning ? Theme.of(context).colorScheme.primary : Colors.grey),
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
