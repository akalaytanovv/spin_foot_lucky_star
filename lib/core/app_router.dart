import 'package:flutter/material.dart';

import '../features/error/error_screen.dart';
import '../features/game/game_screen.dart';
import '../features/lets_play/lets_play_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/wheel/wheel_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const letsPlay = '/lets_play';
  static const game = '/game';
  static const wheel = '/wheel';
  static const settings = '/settings';
  static const error = '/error';

  static const preGameRoutes = {splash, letsPlay};
}

final RouteObserver<ModalRoute<void>> appRouteObserver = RouteObserver<ModalRoute<void>>();

class AppRouter {
  AppRouter({required this.initError});

  final String? initError;

  static bool _gameReached = false;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.splash;

    if (routeName == AppRoutes.game) {
      _gameReached = true;
    }

    if (_gameReached && AppRoutes.preGameRoutes.contains(routeName)) {
      return _animatedRoute(
        settings: const RouteSettings(name: AppRoutes.game),
        page: const GameScreen(),
        allowPop: false,
      );
    }

    final Widget page = switch (routeName) {
      AppRoutes.error => ErrorScreen(message: settings.arguments as String? ?? initError),
      AppRoutes.letsPlay => const LetsPlayScreen(),
      AppRoutes.game => const GameScreen(),
      AppRoutes.wheel => const WheelScreen(),
      AppRoutes.settings => const SettingsScreen(),
      _ => const SplashScreen(),
    };

    return _animatedRoute(
      settings: settings,
      page: page,
      allowPop: routeName != AppRoutes.game,
    );
  }
}

Route<dynamic> _animatedRoute({
  required RouteSettings settings,
  required Widget page,
  required bool allowPop,
}) {
  return _AppPageRoute(
    settings: settings,
    page: page,
    allowPop: allowPop,
  );
}

class _AppPageRoute extends PageRouteBuilder<void> {
  _AppPageRoute({
    required RouteSettings settings,
    required Widget page,
    required this.allowPop,
  }) : super(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final slideIn = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
            final slideOut = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.3, 0.0),
            ).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut));
            return SlideTransition(
              position: slideOut,
              child: SlideTransition(position: slideIn, child: child),
            );
          },
        );

  final bool allowPop;

  @override
  bool get canPop => allowPop;
}
