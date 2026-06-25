# Spin Foot Lucky Star — Agent Instructions

Читай этот файл перед каждой задачей. Здесь всё, что нужно знать об архитектуре, правилах и механиках.

---

## Проект

**Название:** Spin Foot Lucky Star  
**Bundle ID:** `com.spinfoot.lucky.star`  
**Платформа:** Android only  
**Тип:** Crash-игра (мяч крутится, множитель растёт, нужно успеть нажать Cashout)  
**Реклама:** start.io, ID `205713239`  

---

## Стек

| Что | Решение |
|-----|---------|
| State management | `provider` + `ChangeNotifier` |
| Навигация | `Navigator.pushNamed` — именованные маршруты в `main.dart` |
| Локальное хранилище | `shared_preferences` |
| Аудио | `audioplayers` |
| Покупки | `in_app_purchase` |
| Вибрация | `vibration` |
| Аналитика | `appmetrica_sdk` |

Версии пакетов — в `pubspec.yaml`. Не добавляй новые пакеты без необходимости.

---

## Структура папок

```
lib/
  main.dart                    # точка входа, маршруты, MultiProvider
  core/
    constants.dart             # цвета, размеры, строки
    app_theme.dart             # ThemeData
  features/
    splash/
      splash_screen.dart
    lets_play/
      lets_play_screen.dart
    game/
      game_screen.dart
      game_provider.dart       # вся игровая логика
    wheel/
      wheel_screen.dart
      wheel_provider.dart
    shop/
      shop_screen.dart
      shop_provider.dart
    settings/
      settings_screen.dart
      settings_provider.dart
    leaderboard/
      leaderboard_screen.dart
    withdrawal/
      withdrawal_screen.dart
      withdrawal_provider.dart
  shared/
    widgets/
      balance_widget.dart      # виджет баланса (используется в нескольких экранах)
      bet_panel_widget.dart    # панель ставки с +/- и InputField
      result_overlay_widget.dart  # оверлей результата (1.5 сек)
  services/
    audio_service.dart         # синглтон для управления звуком
    purchase_service.dart      # обёртка над in_app_purchase
    prefs_service.dart         # обёртка над shared_preferences
    analytics_service.dart     # обёртка над appmetrica_sdk
```

---

## Маршруты (main.dart)

```dart
routes: {
  '/': (context) => const SplashScreen(),
  '/lets_play': (context) => const LetsPlayScreen(),
  '/game': (context) => const GameScreen(),
  '/wheel': (context) => const WheelScreen(),
  '/shop': (context) => const ShopScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/leaderboard': (context) => const LeaderboardScreen(),
  '/withdrawal': (context) => const WithdrawalScreen(),
}
```

---

## Провайдеры (main.dart)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => GameProvider()),
    ChangeNotifierProvider(create: (_) => WheelProvider()),
    ChangeNotifierProvider(create: (_) => ShopProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => WithdrawalProvider()),
  ],
  child: MaterialApp(...)
)
```

Сервисы (AudioService, PrefsService и т.д.) — синглтоны, доступны как `AudioService.instance`.

---

## Паттерн Provider + ChangeNotifier

```dart
// provider
class GameProvider extends ChangeNotifier {
  double _balance = 1000.0;
  double get balance => _balance;

  void addToBalance(double amount) {
    _balance += amount;
    _balance = _balance.roundToDouble(); // ВСЕГДА округляем
    notifyListeners();
  }
}

// в виджете — читать через context
final game = context.watch<GameProvider>(); // для отображения
final game = context.read<GameProvider>();  // для действий (в onPressed)
```

---

## Правила баланса и ставок

- Баланс и ставки **всегда целые числа** (никаких 1.01, 4.43)
- Максимальная ставка = **90% от баланса** (округлить вниз)
- При балансе < 10 монет → автоматически начислить **+100 монет**, без кулдауна
- Баланс хранится в `shared_preferences`, загружается при старте

---

## Игровая механика (crash-игра)

### Логика раунда

1. Игрок выбирает ставку и нажимает **Start**
2. Мяч начинает вращаться (анимация), множитель растёт с `1.00x`
3. В момент нажатия Start генерируется **точка краша** (когда мяч остановится)
4. Игрок должен нажать **Cashout** до краша
5. Если успел → `выигрыш = ставка × текущий множитель` (округлить до целого)
6. Если не успел → ставка потеряна

### Генерация точки краша

```dart
double _generateCrashPoint() {
  final random = Random();
  final r = random.nextDouble(); // 0.0 до 1.0
  // Минимальный краш 1.00x, дом берёт ~5%
  final crash = 0.95 / (1.0 - r);
  return double.parse(crash.toStringAsFixed(2)).clamp(1.00, 100.00);
}
```

### Рост множителя

```dart
// Вызывается по Timer.periodic каждые 100мс
void _tickMultiplier() {
  _elapsed += 0.1;
  _multiplier = 1.0 + (_elapsed * 0.15); // линейный рост ~0.15x в секунду
  if (_multiplier >= _crashPoint) {
    _crash(); // раунд завершился
  }
  notifyListeners();
}
```

### Состояния раунда (enum)

```dart
enum RoundState { idle, running, cashedOut, crashed }
```

### Бонус от пакетов

Если у игрока активен бонус (из Shop), применяем его при Cashout:
```dart
double winAmount = bet * multiplier;
if (bonusPercent > 0 && bonusExpiry.isAfter(DateTime.now())) {
  winAmount *= (1 + bonusPercent / 100);
}
winAmount = winAmount.roundToDouble();
```

---

## Колесо фортуны (WheelProvider)

- Кулдаун **12 часов** — дата последнего спина хранится в `shared_preferences`
- Постепенное замедление вращения + замедление звука
- Таймер отображается на главном экране и внутри экрана колеса

---

## Панель ставок (BetPanelWidget)

- Кнопки **+** и **−** — можно зажимать (LongPress с повторением через Timer)
- `InputField` для прямого ввода (целые числа, keyboard: number)
- Минимальная ставка: 1 монета
- Максимальная ставка: `(balance * 0.9).floor()`

---

## Экран вывода (WithdrawalScreen)

- Слайдер 0 → баланс, шаг = 1000, подпись `текущее/следующий_порог`
- Кнопка **10 000 → $5**: активна только при балансе ≥ 10 000, иначе полупрозрачная (opacity 0.5, игнорирует нажатия)
- При нажатии: -10 000 с баланса, показать подтверждение
- Методы оплаты — длинный список (Visa, BTC, ETH, Trc20, Google Pay и т.д.)
- Два режима ввода: одно поле (крипта, PayPal и т.д.) или два поля (Name + Card number)

---

## Магазин (ShopProvider)

### Продукты (не-белые прилы)

| ID | Цена | Монеты | Спины | Бонус | Срок |
|----|------|--------|-------|-------|------|
| `sfls_pack_starter` | $2.99 | 1 500 | 3 | +10% | 3 дня |
| `sfls_pack_premium` | $5.99 | 4 500 | 6 | +15% | 7 дней |
| `sfls_pack_vip` | $9.99 | 10 000 | 10 | +25% | 7 дней |

### При покупке

1. Пополнить баланс монетами
2. Начислить фриспины
3. Сохранить `bonusPercent` и `bonusExpiry = DateTime.now() + Duration(days: N)`
4. Всё сохранить в `shared_preferences`

---

## Аудио

`AudioService` — синглтон, инициализируется в `main()`:
- `playBackground()` — зацикленная фоновая музыка
- `playWin()` / `playLose()` — однократный эффект
- `playSpin()` — зацикленный звук вращения (колесо или мяч)
- `stopSpin()` — постепенное замедление pitch перед остановкой
- Учитывает настройки звука из `SettingsProvider`

---

## Вибрация

- Только при крупных событиях: выигрыш, краш, выпадение приза на колесе
- **Не вибрировать** на каждый тик мультипликатора или каждое нажатие
- Использовать `vibration` пакет: `Vibration.vibrate(duration: 200)`

---

## Результат раунда (ResultOverlayWidget)

- Показывается поверх экрана на **1.5 секунды**, затем исчезает
- Нажатие в любом месте → закрывает немедленно
- Показывает: ВЫИГРЫШ / ПРОИГРЫШ + сумму

---

## Terms of Use / Privacy Policy

- Ссылки кликабельны на: `LetsPlayScreen`, `ShopScreen` (везде где есть $ покупки)
- Открывать через `url_launcher` в браузере
- URL хранится в `core/constants.dart`

---

## Настройки (SettingsScreen / SettingsProvider)

- Звук ON/OFF (фоновая музыка)
- Звуковые эффекты ON/OFF
- Вибрация ON/OFF
- Уведомления ON/OFF
- Terms of Use / Privacy Policy (ссылки)

---

## UI / Адаптивность

- Все размеры через `MediaQuery.of(context).size` или `LayoutBuilder`
- **Никаких хардкод пиксельных размеров** для позиционирования
- Используй `Flexible`, `Expanded`, `FittedBox` там, где текст или иконка должны вписываться
- Визуальная обратная связь на каждой кнопке: `InkWell` / `GestureDetector` с анимацией scale (0.95) или изменением цвета

---

## Чего НЕ делать

- Не добавлять новые пакеты без необходимости
- Не создавать абстракции ради абстракций (репозитории, use cases и т.п.)
- Не использовать `double` для отображения баланса — всегда `int` или `toStringAsFixed(0)`
- Не дублировать бизнес-логику в виджетах — вся логика в Provider
- Не хранить состояние в `StatefulWidget` если оно нужно другим экранам
