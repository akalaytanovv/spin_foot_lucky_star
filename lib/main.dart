import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/game/game_provider.dart';
import 'features/game/game_screen.dart';
import 'features/lets_play/lets_play_screen.dart';
import 'features/settings/settings_provider.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/wheel/wheel_provider.dart';
import 'features/wheel/wheel_screen.dart';
import 'services/audio_service.dart';
import 'services/prefs_service.dart';

void _logError(Object error, StackTrace? stack) {
  if (kDebugMode) {
    debugPrint('[ERROR] $error');
    if (stack != null) debugPrintStack(stackTrace: stack);
  }
}

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        _logError(details.exception, details.stack);
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true;
    };

    await PrefsService.instance.init();
    if (kDebugMode) {
      await PrefsService.instance.clearLastWheelSpin();
    }
    await AudioService.instance.init();
    runApp(const SpinFootApp());
  }, (error, stack) => _logError(error, stack));
}

class SpinFootApp extends StatelessWidget {
  const SpinFootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => WheelProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Spin Foot Lucky Star',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/lets_play': (context) => const LetsPlayScreen(),
          '/game': (context) => const GameScreen(),
          '/wheel': (context) => const WheelScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
