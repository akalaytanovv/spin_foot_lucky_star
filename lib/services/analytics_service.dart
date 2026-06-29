import 'dart:async';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/widgets.dart';

import '../core/constants.dart';

class AnalyticsService with WidgetsBindingObserver {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  static const String _appName = 'spin_foot_lucky_star';

  Future<void> init() async {
    await AppMetrica.activate(
      const AppMetricaConfig(
        Constants.appMetricaKey,
        logs: true,
      ),
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      appClose();
    }
  }

  void _report(String event, [Map<String, Object>? params]) {
    unawaited(
      AppMetrica.reportEventWithMap(event, {_appName: params ?? {}}),
    );
  }

  // ── Game cycle ────────────────────────────────────────────────────────────

  void gameStart() => _report('game_start', {'game_name': 'crash'});

  void gameWin() => _report('game_win', {'game_name': 'crash'});

  void gameLoss() => _report('game_loss', {'game_name': 'crash'});

  void betChange() => _report('bet_change', {'game_name': 'crash'});

  // ── Paywalls & Purchases ──────────────────────────────────────────────────

  void paywallView({required String source}) => _report('paywall_view', {'source': source});

  void paywallClose({required String source}) => _report('paywall_close', {'source': source});

  void purchaseClick({required String itemId, required String type}) =>
      _report('purchase_click', {'item_id': itemId, 'type': type});

  void purchaseSuccess({
    required String itemId,
    required double price,
    required String type,
  }) =>
      _report('purchase_success', {
        'item_id': itemId,
        'price': price,
        'type': type,
      });

  void purchaseError({required String itemId, required String type}) =>
      _report('purchase_error', {'item_id': itemId, 'type': type});

  // ── System ────────────────────────────────────────────────────────────────

  void settingsOpen() => _report('settings_open');

  void appClose() => _report('app_close');
}
