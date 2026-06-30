import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../../shared/widgets/app_background.dart';
import '../game/game_provider.dart';
import 'wheel_provider.dart';
import 'widgets/spin_button.dart';
import 'widgets/watch_claim_overlay.dart';
import 'widgets/wheel_widget.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotationAnimation;

  double _currentAngle = 0;
  bool _isAnimating = false;
  bool _showWatchClaim = false;
  bool _isClaimingAd = false;

  // Center of each segment in radians (0 = top, clockwise).
  // Derived from prize count so it stays in sync if the table changes.
  static final List<double> _centerAngles = () {
    final count = WheelProvider.prizes.length;
    final step = 2 * pi / count;
    return List.generate(count, (i) => i * step + step / 2);
  }();

  static final List<String> _labels = WheelProvider.prizes.map((p) => p.label).toList();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _controller.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!mounted) return;

    AudioService.instance.stopSpin();
    setState(() {
      _currentAngle = _rotationAnimation.value % (2 * pi);
      _isAnimating = false;
      _showWatchClaim = true;
    });
  }

  void _finishClaim() {
    context.read<WheelProvider>().onSpinComplete(context.read<GameProvider>());
    _showPrizeSnackBar();
  }

  void _claimSkip() {
    if (_isClaimingAd) return;
    setState(() => _showWatchClaim = false);
    _finishClaim();
  }

  void _claimWithAd() {
    if (_isClaimingAd) return;

    if (!AdService.instance.isReady) {
      setState(() {
        _showWatchClaim = false;
        _isClaimingAd = false;
      });
      _finishClaim();
      return;
    }

    setState(() => _isClaimingAd = true);

    AdService.instance.showRewarded(
      onRewarded: () {
        if (!mounted) return;
        setState(() => _showWatchClaim = false);
        _finishClaim();
      },
      onAdFinished: () {
        if (!mounted) return;
        setState(() => _isClaimingAd = false);
      },
    );
  }

  void _onSpinPressed() {
    if (_isAnimating || _showWatchClaim || _isClaimingAd) return;
    final wheel = context.read<WheelProvider>();
    wheel.spin();
    _startAnimation(wheel.spinToIndex);
  }

  void _startAnimation(int index) {
    final centerRad = _centerAngles[index];

    // Rotate so that the winning segment's center aligns with the top pointer.
    // Target wheel angle = 2π - centerRad (clockwise rotation to bring segment to top).
    final targetMod = 2 * pi - centerRad;
    double totalAccum = targetMod;
    final minAccum = _currentAngle + 5 * 2 * pi;
    while (totalAccum < minAccum) {
      totalAccum += 2 * pi;
    }

    final deltaRad = totalAccum - _currentAngle;

    _rotationAnimation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle + deltaRad,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.reset();
    setState(() => _isAnimating = true);
    _controller.forward();
    AudioService.instance.playSpin();
  }

  void _showPrizeSnackBar() {
    final prize = context.read<WheelProvider>().lastPrize;
    if (prize == null) return;
    final String message;
    if (prize.coins > 0) {
      message = 'You won ${prize.coins} coins!';
    } else if (prize.freeSpins > 0) {
      message = 'You won ${prize.freeSpins} Free Spins!';
    } else {
      message = 'Better luck next time!';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      appBar: AppBar(
        title: const Text('WHEEL OF LUCK', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = min(constraints.maxWidth, constraints.maxHeight) * 0.92;
                        return WheelWidget(
                          size: size,
                          controller: _controller,
                          rotationAnimation: _rotationAnimation,
                          labels: _labels,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SpinButton(
                  isAnimating: _isAnimating,
                  isBlocked: _showWatchClaim || _isClaimingAd,
                  onPressed: _onSpinPressed,
                ),
                const SizedBox(height: 100),
              ],
            ),
            if (_showWatchClaim)
              Positioned.fill(
                child: WatchClaimOverlay(onClaim: _claimWithAd, onSkip: _claimSkip, isClaiming: _isClaimingAd),
              ),
          ],
        ),
      ),
    );
  }
}
