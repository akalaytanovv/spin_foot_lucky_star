import 'package:flutter/material.dart';

class SplashBody extends StatelessWidget {
  final Animation<double> animation;

  const SplashBody({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Spin Foot Lucky Star',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) => LinearProgressIndicator(value: animation.value),
          ),
        ],
      ),
    );
  }
}
