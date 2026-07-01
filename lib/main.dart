import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/app_router.dart';
import 'features/game/game_provider.dart';
import 'features/settings/settings_provider.dart';
import 'features/splash/splash_provider.dart';
import 'features/wheel/wheel_provider.dart';
import 'services/ad_service.dart';
import 'services/analytics_service.dart';
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

    String? initError;
    try {
      await PrefsService.instance.init();
      if (kDebugMode) {
        await PrefsService.instance.clearLastWheelSpin();
      }
      await AudioService.instance.init();
      await AnalyticsService.instance.init();
      await AdService.instance.init();
    } catch (e, stack) {
      _logError(e, stack);
      initError = e.toString();
    }

    runApp(SpinFootApp(initError: initError));
  }, (error, stack) => _logError(error, stack));
}

class SpinFootApp extends StatelessWidget {
  const SpinFootApp({super.key, this.initError});

  final String? initError;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => WheelProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Spin Foot Lucky Star',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.puritanTextTheme().apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
        initialRoute: initError != null ? AppRoutes.error : AppRoutes.splash,
        onGenerateRoute: AppRouter(initError: initError).onGenerateRoute,
        navigatorObservers: [appRouteObserver],
      ),
    );
  }
}
