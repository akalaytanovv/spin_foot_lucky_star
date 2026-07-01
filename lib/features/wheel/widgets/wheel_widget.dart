import 'package:flutter/material.dart';

import 'wheel_painter.dart';

class WheelWidget extends StatelessWidget {
  final double size;
  final AnimationController controller;
  final Animation<double> rotationAnimation;
  final List<String> labels;
  final Widget? centerWidget;

  const WheelWidget({
    super.key,
    required this.size,
    required this.controller,
    required this.rotationAnimation,
    required this.labels,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
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
            animation: rotationAnimation,
            builder: (context, _) {
              return CustomPaint(
                size: Size(segmentsSize, segmentsSize),
                painter: WheelPainter(angle: rotationAnimation.value, labels: labels),
              );
            },
          ),
          // Layer 3 — center hub (static)
          centerWidget ?? Image.asset('assets/wheel_inside.png', width: hubSize, height: hubSize, fit: BoxFit.contain),
          // Layer 4 — pointer triangle at top (static, above everything)
          Positioned(
            top: (size - segmentsSize) / 2 - pointerSize * 0.92,
            child: Image.asset('assets/wheel_top.png', width: pointerSize, height: pointerSize, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
