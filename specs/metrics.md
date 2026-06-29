Пример, как реализовывать события
AppMetrica.reportEventWithMap('game_start', {
  'plinko_gold': {}  // создаст второй уровень
});
Как отправляем данные:
Пример:

AppMetrica.reportEventWithMap(
'purchase_success',
{
  'lucky_dynasty': {
      item_id: ID товара.
      price: число (цена в валюте стора).
      type: категория (coin / sub).
   }
});
Игровой цикл
game start — Вход в конкретную игру (param: game_name)
game_win — Факт любого выигрыша (param: game_name)
game_loss — Факт любого проигрыша (param: game_name)
bet change — Изменение размера ставки (param: game_name)
Пейволлы и Покупки
paywall_view — Показ экрана оплаты (param source: onboarding, shop)
paywall_close — Закрытие любого пейволла/shop без покупки (param: source)
purchase_click — Нажатие на кнопку покупки или оформления (param: item_id, type: coin/sub)
purchase_success — Успешная оплата (param: item_id, price, type: coin/sub)
purchase_error — Ошибка или отмена оплаты (param: item_id, type)
Системные
settings_open — Заход в настройки
app_close — Выход из приложения / закрытие сессии
