import 'dart:math';

import 'package:flutter/material.dart';

class WheelPainter extends CustomPainter {
  final double angle;
  final List<String> labels;

  // Alternating segment colors (dark green / golden yellow).
  static const Color _colorA = Color(0xFF2D6B2D);
  static const Color _colorB = Color(0xFFC8960C);

  // TextPainters are keyed by radius and never change — build once, reuse.
  static final Map<double, List<TextPainter>> _textCache = {};

  const WheelPainter({required this.angle, required this.labels});

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

      // Golden on even segments, dark green on odd.
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
  bool shouldRepaint(WheelPainter oldDelegate) => oldDelegate.angle != angle;
}
