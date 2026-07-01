import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../services/ad_service.dart';
import '../../wheel/widgets/wheel_widget.dart';
import '../game_provider.dart';

class BoostRewardOverlay extends StatefulWidget {
  const BoostRewardOverlay({super.key, required this.baseWin, required this.onComplete});

  final int baseWin;
  final VoidCallback onComplete;

  @override
  State<BoostRewardOverlay> createState() => _BoostRewardOverlayState();
}

class _BoostRewardOverlayState extends State<BoostRewardOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotationAnimation;

  late final int _multiplier;
  late final int _bonus;
  late final int _winIndex;

  double _currentAngle = 0;
  bool _isSpinning = true;
  bool _isClaimingAd = false;

  static final List<String> _labels = Constants.boostMultipliers.map((m) => 'x$m').toList();

  static final List<double> _centerAngles = () {
    final count = Constants.boostMultipliers.length;
    final step = 2 * pi / count;
    return List.generate(count, (i) => i * step + step / 2);
  }();

  @override
  void initState() {
    super.initState();
    final game = context.read<GameProvider>();
    _multiplier = game.pickBoostMultiplier();
    _bonus = game.calculateBoostBonus(widget.baseWin, _multiplier);
    _winIndex = Constants.boostMultipliers.indexOf(_multiplier);

    _controller = AnimationController(vsync: this, duration: Constants.boostWheelSpinDuration);
    _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _controller.addStatusListener(_onAnimationStatus);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startSpin());
  }

  void _startSpin() {
    final centerRad = _centerAngles[_winIndex];
    final targetMod = 2 * pi - centerRad;
    var totalAccum = targetMod;
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
    setState(() => _isSpinning = true);
    _controller.forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (!mounted) return;
    setState(() {
      _currentAngle = _rotationAnimation.value % (2 * pi);
      _isSpinning = false;
    });
  }

  Future<void> _finishClaim() async {
    await context.read<GameProvider>().claimBoostReward(_bonus);
    if (!mounted) return;
    widget.onComplete();
  }

  void _claimWithAd() {
    if (_isClaimingAd || _isSpinning) return;

    if (!AdService.instance.isReady) {
      _finishClaim();
      return;
    }

    setState(() => _isClaimingAd = true);

    AdService.instance.showRewarded(
      onRewarded: () {
        if (!mounted) return;
        _finishClaim();
      },
      onAdFinished: () {
        if (!mounted) return;
        setState(() => _isClaimingAd = false);
      },
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCenterHub(double wheelSize) {
    const amountStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Color(0xFFFFECAC),
      fontSize: 26,
      fontWeight: FontWeight.w900,
      shadows: [Shadow(blurRadius: 8, color: Color(0xFFFFCC00))],
    );
    const multiplierStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Color(0xFFFFE5B4),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return Container(
      width: wheelSize * 0.38,
      height: wheelSize * 0.38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFF1C6040), Color(0xFF133D04)]),
        border: Border.all(color: const Color(0xFFA9FF09), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFFFFCC00).withValues(alpha: 0.4), blurRadius: 16)],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 32, child: Text(_isSpinning ? '' : '${widget.baseWin}', style: amountStyle)),
          SizedBox(height: 26, child: Text(_isSpinning ? '' : 'x$_multiplier', style: multiplierStyle)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wheelSize = min(constraints.maxWidth, constraints.maxHeight) * 0.68;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WheelWidget(
                size: wheelSize,
                controller: _controller,
                rotationAnimation: _rotationAnimation,
                labels: _labels,
                centerWidget: _buildCenterHub(wheelSize),
              ),
              const SizedBox(height: 24),
              _ClaimButton(
                onTap: (_isSpinning || _isClaimingAd) ? null : _claimWithAd,
                isLoading: _isClaimingAd,
                enabled: !_isSpinning,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.onTap, this.isLoading = false, this.enabled = true});

  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final inactive = !enabled && !isLoading;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: inactive ? 0.45 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: inactive
                  ? [const Color(0xFF888888), const Color(0xFF555555)]
                  : const [Color(0xFFFFD700), Color(0xFFFF8C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: inactive
                ? []
                : [BoxShadow(color: Colors.orange.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 2)],
          ),
          child: SizedBox(
            width: 88,
            height: 28,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Claim!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
