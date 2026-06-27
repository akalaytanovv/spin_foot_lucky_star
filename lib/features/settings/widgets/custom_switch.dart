import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  static const double _trackW = 42;
  static const double _trackH = 22;
  static const double _pinSize = 14;
  static const double _pinPadding = 4;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: SizedBox(
        width: _trackW,
        height: _trackH,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: value ? const Color(0xFF7BA74F) : const Color(0xFF133D04),
                  borderRadius: BorderRadius.circular(_trackH / 2),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? _trackW - _pinSize - _pinPadding : _pinPadding,
              top: (_trackH - _pinSize) / 2,
              width: _pinSize,
              height: _pinSize,
              child: Container(
                decoration: BoxDecoration(
                  color: value ? const Color(0xFFA9FF09) : const Color(0xFF133D04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
