import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/audio_service.dart';
import '../game/game_provider.dart';
import 'wheel_provider.dart';

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

    setState(() {
      _currentAngle = _rotationAnimation.value % (2 * pi);
      _isAnimating = false;
    });

    AudioService.instance.stopSpin();
    context.read<WheelProvider>().onSpinComplete(context.read<GameProvider>());
    _showPrizeSnackBar();
  }

  void _onSpinPressed() {
    if (_isAnimating) return;
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

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wheel of Fortune'), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = min(constraints.maxWidth, constraints.maxHeight) * 0.92;
                    return _buildWheel(size);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Consumer<WheelProvider>(
                builder: (context, wheel, _) {
                  final active = wheel.canSpin && !_isAnimating;
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: active ? Colors.deepOrange : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      onPressed: active ? _onSpinPressed : null,
                      child: _buildButtonChild(wheel, active: active),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel(double size) {
    // Segment wheel fits inside the outer ring — 84% of the full widget size.
    final segmentsSize = size * 0.84;
    // Center hub size.
    final hubSize = size * 0.22;
    // Pointer triangle size.
    final pointerSize = size * 0.13;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Layer 1 — outer decorative ring (static)
          Image.asset('assets/wheel_outside.png', width: size, height: size, fit: BoxFit.contain),
          // Layer 2 — spinning segments
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                size: Size(segmentsSize, segmentsSize),
                painter: _WheelPainter(angle: _rotationAnimation.value, labels: _labels),
              );
            },
          ),
          // Layer 3 — center hub (static)
          Image.asset('assets/wheel_inside.png', width: hubSize, height: hubSize, fit: BoxFit.contain),
          // Layer 4 — pointer triangle at top (static, above everything)
          Positioned(
            top: (size - segmentsSize) / 2 - pointerSize * 0.92,
            child: Image.asset('assets/wheel_top.png', width: pointerSize, height: pointerSize, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonChild(WheelProvider wheel, {required bool active}) {
    if (_isAnimating) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 10),
          Text('SPINNING...'),
        ],
      );
    }
    if (active) {
      return wheel.freeSpins > 0 ? const Text('FREE SPIN') : const Text('SPIN');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, size: 18),
        const SizedBox(width: 8),
        Text(_formatDuration(wheel.timeUntilNextSpin)),
      ],
    );
  }
}

// ── Wheel painter ─────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final double angle;
  final List<String> labels;

  // Alternating segment colors matching the example (dark green / golden yellow)
  static const Color _colorA = Color(0xFF2D6B2D);
  static const Color _colorB = Color(0xFFC8960C);

  // TextPainters are keyed by radius and never change — build once, reuse.
  static final Map<double, List<TextPainter>> _textCache = {};

  _WheelPainter({required this.angle, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final textPainters = _textCache.putIfAbsent(radius, () => _buildTextPainters(radius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final segCount = labels.length;
    final sweepRad = 2 * pi / segCount;
    final halfSweep = sweepRad / 2;
    final labelRadius = radius * 0.72;
    const startBase = -pi / 2;
    final segRect = Rect.fromCircle(center: Offset.zero, radius: radius);
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < segCount; i++) {
      final startRad = startBase + i * sweepRad;

      // Fill — golden on even segments, dark green on odd
      fillPaint.color = (i % 2 == 0) ? _colorB : _colorA;
      canvas.drawArc(segRect, startRad, sweepRad, true, fillPaint);

      _drawLabel(canvas, labelRadius, startRad + halfSweep, textPainters[i]);
    }

    canvas.restore();
  }

  List<TextPainter> _buildTextPainters(double radius) {
    return labels.map((label) {
      return TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: const Color(0xFF1A3A1A),
            fontSize: radius * 0.10,
            fontWeight: FontWeight.bold,
            // height < 1.0 tightens multi-line spacing without negative values
            height: 0.85,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: radius * 0.55);
    }).toList();
  }

  void _drawLabel(Canvas canvas, double labelRadius, double midRad, TextPainter tp) {
    canvas.save();
    canvas.translate(cos(midRad) * labelRadius, sin(midRad) * labelRadius);
    canvas.rotate(midRad);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) => oldDelegate.angle != angle;
}
