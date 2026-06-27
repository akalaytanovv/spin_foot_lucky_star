import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../game_provider.dart';

class X2Panel extends StatelessWidget {
  final bool isOn;
  final bool disabled;
  final double height;

  const X2Panel({super.key, required this.isOn, required this.disabled, required this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : () => context.read<GameProvider>().toggleX2(),
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/bet_x2_bg.png'), fit: BoxFit.fill),
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 157,
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: SizedBox(
                      width: 82,
                      height: 38,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(child: Image.asset('assets/bet_x2_label.png', fit: BoxFit.fill)),
                          const Text(
                            'x2',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: SizedBox(height: 37, child: _X2Switch(isOn: isOn, pinSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _X2Switch extends StatelessWidget {
  final bool isOn;
  final double pinSize;

  const _X2Switch({required this.isOn, required this.pinSize});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final travel = (w - pinSize - 4).clamp(0.0, double.infinity);

        return Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/bet_x2_switch_bg.png', fit: BoxFit.fill)),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: isOn ? travel + 2 : 2,
              top: (h - pinSize) / 2,
              width: pinSize,
              height: pinSize,
              child: Image.asset('assets/bet_x2_switch_pin.png', fit: BoxFit.contain),
            ),
          ],
        );
      },
    );
  }
}
