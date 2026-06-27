import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    runApp(kDebugMode ? DevicePreview(enabled: true, builder: (_) => const SpinFootApp()) : const SpinFootApp());
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
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          textTheme: GoogleFonts.puritanTextTheme().apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final Widget page = switch (settings.name) {
            '/lets_play' => const LetsPlayScreen(),
            '/game' => const GameScreen(),
            '/wheel' => const WheelScreen(),
            '/settings' => const SettingsScreen(),
            _ => const SplashScreen(),
          };
          return PageRouteBuilder(
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
        },
      ),
    );
  }
}
