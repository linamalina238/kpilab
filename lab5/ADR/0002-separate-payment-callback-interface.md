# ADR 0002: Як PaymentService передає результат оплати

- Статус: прийнято
- Дата: 25.11.2026

## Контекст

У Лабах 3 і 4 результат оплати це окреме асинхронне повідомлення `paymentConfirmed` або `paymentRejected` від PaymentService до OrderService (Лаба 3, ADR 0001). Це відповідь на `requestPayment`, а не ініціатива PaymentService (Лаба 2, ADR 0003). На sequence-діаграмах Лаби 3 повідомлення йшло в OrderService напряму. В архітектурі BackendAPI є єдиним входом, тож треба було вирішити, яким інтерфейсом ці повідомлення потрапляють у систему.

## Розглянуті альтернативи

1. Операції `paymentConfirmed` і `paymentRejected` в IOrders через загальний IApi. Тоді запит PaymentService підпадав би під ліміт сесій (NFR-04) і не мав би окремої перевірки підпису.
2. Окремий інтерфейс `IPaymentCallback` на BackendAPI.
3. Прямий виклик OrderService, як на sequence-діаграмах Лаби 3. Це в обхід BackendAPI, який є єдиним входом.

## Рішення

Обрано варіант 2. `IPaymentCallback` (`paymentConfirmed`, `paymentRejected`) надає BackendAPI, а споживає PaymentService. Далі BackendAPI передає ці операції OrderService через IOrders.

## Наслідки

- Callback поза лімітом сесій (NFR-04).
- Запит від PaymentService проходить окрему перевірку підпису.
- У PaymentService з'являється залежність від внутрішнього компонента: PaymentService → IPaymentCallback (BackendAPI).