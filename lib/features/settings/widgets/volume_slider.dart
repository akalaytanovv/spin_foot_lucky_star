import 'package:flutter/material.dart';

class VolumeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const VolumeSlider({super.key, required this.label, required this.value, required this.onChanged});

  static final _sliderTheme = SliderThemeData(
    trackHeight: 8,
    activeTrackColor: const Color(0xFF7BA74F),
    inactiveTrackColor: const Color(0x597BA74F),
    thumbColor: const Color(0xFFA9FF09),
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
    overlayShape: SliderComponentShape.noOverlay,
    trackShape: const _PillTrackShape(),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFFFE5B4), fontSize: 20, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: _sliderTheme,
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _PillTrackShape extends RoundedRectSliderTrackShape {
  const _PillTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 8;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(offset.dx, trackTop, parentBox.size.width, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2, // required by parent signature, not used
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final radius = Radius.circular(trackRect.height / 2);
    final activePaint = Paint()..color = sliderTheme.activeTrackColor!;
    final inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor!;

    final leftRect = Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    final rightRect = Rect.fromLTRB(thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);

    switch (textDirection) {
      case TextDirection.ltr:
        context.canvas.drawRRect(RRect.fromRectAndCorners(leftRect, topLeft: radius, bottomLeft: radius), activePaint);
        context.canvas.drawRRect(
          RRect.fromRectAndCorners(rightRect, topRight: radius, bottomRight: radius),
          inactivePaint,
        );
      case TextDirection.rtl:
        context.canvas.drawRRect(
          RRect.fromRectAndCorners(rightRect, topRight: radius, bottomRight: radius),
          activePaint,
        );
        context.canvas.drawRRect(
          RRect.fromRectAndCorners(leftRect, topLeft: radius, bottomLeft: radius),
          inactivePaint,
        );
    }
  }
}
