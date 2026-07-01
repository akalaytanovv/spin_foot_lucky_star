class Constants {
  Constants._();

  static const String appMetricaKey = String.fromEnvironment('APP_METRICA_KEY');

  static const int initialBalance = 1000;
  static const int minBet = 1;
  static const int betStep = 10;
  static const int lowBalanceThreshold = 10;
  static const int lowBalanceBonus = 100;
  static const Duration wheelCooldown = Duration(hours: 12);
  static const Duration boostButtonDuration = Duration(seconds: 2);
  static const Duration boostWheelSpinDuration = Duration(milliseconds: 1500);
  static const Duration resultOverlayDuration = Duration(milliseconds: 1500);
  static const List<int> boostMultipliers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  static const int withdrawalCostCoins = 10000;
  static const String withdrawalAmountUsd = r'$5';
  static const String termsUrl = 'https://telegra.ph/Terms-of-Use-Spin-Foot-Lucky-Star-06-30';
  static const String privacyUrl = 'https://telegra.ph/Privacy-Policy-Spin-Foot-Lucky-Star-06-30';
}
