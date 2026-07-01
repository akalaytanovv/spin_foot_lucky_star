# spin_foot_lucky_star

Flutter-приложение Spin Foot Lucky Star.

## Сборка и запуск

Для работы AppMetrica ключ передаётся на этапе компиляции через `--dart-define`. Без него `Constants.appMetricaKey` будет пустой строкой и аналитика не инициализируется.

### Локальная разработка

Создайте в корне проекта файл `dart_defines.json` (он в `.gitignore` и не коммитится):

```json
{
  "APP_METRICA_KEY": "<ваш-ключ-appmetrica>"
}
```

Запуск и сборка с этим файлом:

```bash
flutter run --dart-define-from-file=dart_defines.json
flutter build apk --release --dart-define-from-file=dart_defines.json
flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

Конфигурации запуска в VS Code / Cursor уже подключают `dart_defines.json` через `--dart-define-from-file`.

### Альтернатива: передать ключ напрямую

```bash
flutter run --dart-define=APP_METRICA_KEY=<ваш-ключ-appmetrica>
flutter build apk --release --dart-define=APP_METRICA_KEY=<ваш-ключ-appmetrica>
```

Ключ берётся из кабинета AppMetrica для приложения с bundle ID `com.spinfoot.lucky.star`.
