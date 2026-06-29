class Constants {
  Constants._();

  static const String appMetricaKey = String.fromEnvironment('APP_METRICA_KEY');

  static const int initialBalance = 1000;
  static const int minBet = 1;
  static const int lowBalanceThreshold = 10;
  static const int lowBalanceBonus = 100;
  static const Duration wheelCooldown = Duration(hours: 12);
  static const int withdrawalCostCoins = 10000;
  static const String withdrawalAmountUsd = r'$5';
  static const String termsUrl = 'https://example.com/terms';
  static const String privacyUrl = 'https://example.com/privacy';
}
