import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_router.dart';
import '../../../shared/widgets/app_background.dart';
import 'splash_provider.dart';
import 'widgets/splash_body.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSplash());
  }

  Future<void> _runSplash() async {
    if (!mounted) return;

    await Future.wait([
      _controller.forward(from: 0),
      context.read<SplashProvider>().preloadAudio(),
    ]);

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.letsPlay);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(child: SplashBody(animation: _controller));
  }
}
