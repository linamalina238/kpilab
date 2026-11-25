# Специфікація: архітектура Online Store

## Намір
Показати архітектуру, що реалізує UC-02 «Оформити й оплатити замовлення» з UC-01 і UC-03: компоненти, інтерфейси, залежності, межу системи й зовнішні інтеграції. Спираюся на Лаби 1–4, нове позначаю ПРОПОЗИЦІЯ з причиною.

## Форма й межа
Component Diagram у PlantUML (`lab5/component-diagram.puml`, код і рендер): provided це lollipop, required це пунктирна залежність до інтерфейсу, межа це package «Online Store».
Всередині: WebUI, BackendAPI, CatalogService, OrderService, NotificationService, ProductRepository, OrderRepository, Database.
Зовні: PaymentService (не актор, Лаба 2 ADR 0003; callback це відповідь на `requestPayment`) і Identity Provider. Покупець актор поза межею зі стрілкою до WebUI.

## Компоненти
| Компонент | Що робить | Звідки |
|---|---|---|
| WebUI (ПРОПОЗИЦІЯ: у Лабах 3–4 Покупець кличе сервіси напряму) | категорія, оформлення, статус, прийом сповіщення; українська | UC-01–03, NFR-01–02 |
| BackendAPI (ПРОПОЗИЦІЯ: місце для NFR) | єдиний вхід, токен, 401/403/503, callback оплати | NFR-04–05 |
| CatalogService | Product за `category_id` | REQ-09 |
| OrderService | Order, OrderItem, запит оплати, відлік 30 с, статус | REQ-01–08, 10 |
| NotificationService (ПРОПОЗИЦІЯ з Лаби 3) | `orderStatusChanged` до WebUI | Лаби 3–4 |
| ProductRepository, OrderRepository | доступ до Product, Order, OrderItem | Лаба 3 |
| Database (ПРОПОЗИЦІЯ) | таблиці ER Лаби 1 | Лаба 1 |

User і Category лежать у Database, але жодна операція Лаб 3–4 їх не читає.

## Інтерфейси (provided → required)
- IApi: BackendAPI → WebUI (`getProducts`, `submitOrder`, `getOrder`, потік сповіщень)
- IPaymentCallback: BackendAPI → PaymentService (`paymentConfirmed`, `paymentRejected`, асинхронна відповідь, поза ліміту сесій)
- ICatalog: CatalogService → BackendAPI (`getProducts(category_id)`)
- IOrders: OrderService → BackendAPI (`submitOrder(user_id, items)`, `getOrder(order_id, user_id)`, `paymentConfirmed`, `paymentRejected`)
- IPaymentRequest: PaymentService → OrderService (`requestPayment(order_id, amount)`)
- INotify: NotificationService → OrderService (`orderStatusChanged`); ISubscribe: NotificationService → BackendAPI (ПРОПОЗИЦІЯ)
- IProductRepo: ProductRepository → CatalogService, OrderService (`findProducts`, `getPrice`)
- IOrderRepo: OrderRepository → OrderService (`saveOrder`, `getOrderStatus`, `updateStatus`, `findOrder`)
- IIdentity: Identity Provider → BackendAPI (`validateToken` → `User.id`)
- SQL: Database → обидва репозиторії

`getOrder(order_id, user_id)` розширює Лабу 3 (ПРОПОЗИЦІЯ): власника Order перевіряє OrderService, BackendAPI віддає 403.

## Залежності
WebUI → IApi; BackendAPI → IIdentity, ICatalog, IOrders, ISubscribe; CatalogService → IProductRepo; OrderService → IProductRepo, IOrderRepo, IPaymentRequest, INotify; репозиторії → SQL; PaymentService → IPaymentCallback.
Залежності йдуть вниз по шарах. Винятки: PaymentService → IPaymentCallback (знизу вгору, з боку зовнішньої системи), OrderService → INotify (в межах шару сервісів) і виклики зовнішніх систем IIdentity та IPaymentRequest.

## Поза обсягом
Адміністрування, `shipped`, повернення коштів, пізня відповідь оплати (Лаба 2); deployment; реєстрація; перезапуск OrderService під час відліку 30 с; час відповіді Identity Provider у NFR-03; email і SMS.

## Критерії прийняття
1. Одна діаграма PlantUML, код і рендер.
2. Межа системи явна, зовнішні системи поза нею.
3. Кожен компонент має provided або required інтерфейс, кожен required має провайдера.
4. Назви сервісів, операцій і повідомлень як у Лабах 3–4; сутності з ER Лаби 1; усе нове має ПРОПОЗИЦІЯ з причиною.
5. Шари UI, API, сервіси, Data Access, БД; до БД лише через репозиторії.
6. Асинхронність оплати збережена: `requestPayment` і callback окремі інтерфейси, відлік 30 с в OrderService.
7. Інтерфейси внутрішніх компонентів лежать усередині package «Online Store»; на межі лише IPaymentRequest, IPaymentCallback і IIdentity, пов'язані із зовнішніми системами.
8. Required-інтерфейси показано однаково: пунктирна залежність споживача до інтерфейсу, як у позначках на діаграмі.
9. Шари розташовано рядами зверху вниз: UI, API, сервіси, Data Access, БД; підписи інтерфейсів не накладаються.