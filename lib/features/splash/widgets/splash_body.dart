import 'package:flutter/material.dart';

class SplashBody extends StatelessWidget {
  final Animation<double> animation;

  const SplashBody({super.key, required this.animation});

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
                Image.asset(
                  'assets/logo.png',
                  width: screenWidth / 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Let's get started",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 48, left: 40, right: 40),
            child: Column(
              children: [
                const Text(
                  'Loading',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) =>
                      LinearProgressIndicator(value: animation.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
