import 'package:flutter/material.dart';

class SplashBody extends StatelessWidget {
  final Animation<double> animation;

  const SplashBody({super.key, required this.animation});

  Widget _borderedText(String text, TextStyle style) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = const Color(0xFF1C6040),
          ),
        ),
        Text(text, style: style.copyWith(color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: screenWidth / 2),
                const SizedBox(height: 16),
                _borderedText('Welcome', const TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                _borderedText("Let's get started", const TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 48, left: 50, right: 50),
            child: Column(
              children: [
                _borderedText('Loading...', const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) => Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF89E684),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFF1F5C09), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: LayoutBuilder(
                        builder: (context, constraints) => Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: constraints.maxWidth * animation.value,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: const LinearGradient(colors: [Color(0xFFFFFF27), Color(0xFFAC8402)]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
