import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/image_button.dart';
import '../wheel_provider.dart';

String _formatDuration(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

class SpinButton extends StatefulWidget {
  final bool isAnimating;
  final bool isBlocked;
  final VoidCallback onPressed;

  const SpinButton({super.key, required this.isAnimating, this.isBlocked = false, required this.onPressed});

  @override
  State<SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<SpinButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  bool _pulseActive = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _syncPulse(bool active) {
    if (active == _pulseActive) return;
    _pulseActive = active;
    if (active) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WheelProvider>(
      builder: (context, wheel, _) {
        final active = wheel.canSpin && !widget.isAnimating && !widget.isBlocked;
        _syncPulse(active);

        final hasCountdown = !active && !widget.isAnimating && wheel.timeUntilNextSpin > Duration.zero;
        final String label = wheel.freeSpins > 0 ? 'FREE SPIN' : 'SPIN';

        const buttonHeight = 61.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 58),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              ScaleTransition(
                scale: active ? _scale : const AlwaysStoppedAnimation(1.0),
                child: ImageButton(
                  label: label,
                  height: buttonHeight,
                  isLoading: widget.isAnimating,
                  onPressed: active ? widget.onPressed : null,
                ),
              ),
              if (hasCountdown)
                Positioned(
                  bottom: buttonHeight + 14,
                  child: Text(
                    _formatDuration(wheel.timeUntilNextSpin),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
