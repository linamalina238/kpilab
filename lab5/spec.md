# Специфікація: архітектура Online Store

## Намір
Показати архітектуру системи, що реалізує UC-02 «Оформити й оплатити замовлення» разом з UC-01 і UC-03: компоненти, інтерфейси, залежності, межу системи й зовнішні інтеграції. Модель спирається на Лаби 1–4, нове позначено ПРОПОЗИЦІЯ.

## Форма
Component Diagram у PlantUML (`lab5/component-diagram.puml`, код і рендер). Provided-інтерфейс це lollipop, required це socket, межа системи це package «Online Store».

## Межа системи
Всередині: WebUI, BackendAPI, CatalogService, OrderService, NotificationService, ProductRepository, OrderRepository, Database.
Зовні: PaymentService (не актор, Лаба 2 ADR 0003), Identity Provider (ПРОПОЗИЦІЯ), Email-провайдер (ПРОПОЗИЦІЯ). Покупець не компонент.

## Компоненти
| Компонент | Що робить | Звідки |
|---|---|---|
| WebUI | категорія, оформлення, статус; українська мова | UC-01–03, NFR-01, NFR-02 |
| BackendAPI | єдиний вхід REST, перевірка токена, 401 і 403, callback оплати | NFR-05 |
| CatalogService | Product за category_id | REQ-09 |
| OrderService | Order і OrderItem, запит оплати, відлік 30 с, статус | REQ-01–08, REQ-10 |
| NotificationService | orderStatusChanged Покупцю (ПРОПОЗИЦІЯ) | Лаба 3 |
| ProductRepository, OrderRepository | доступ до Product, Order, OrderItem | Лаба 1 |
| Database | таблиці з ER Лаби 1 | Лаба 1 |

## Інтерфейси
- IApi (REST): WebUI, PaymentService (callback) → BackendAPI
- ICatalog: getProducts(category_id)
- IOrders: submitOrder, getOrder
- IPaymentRequest: requestPayment(order_id, amount), зовнішній
- INotify: orderStatusChanged(order_id, status)
- IProductRepo, IOrderRepo, SQL
- IIdentity: validateToken (ПРОПОЗИЦІЯ), IMessageGateway: send(email, text) (ПРОПОЗИЦІЯ)

## Залежності
WebUI → IApi; BackendAPI → IIdentity, ICatalog, IOrders; CatalogService → IProductRepo; OrderService → IProductRepo, IOrderRepo, IPaymentRequest, INotify; NotificationService → IMessageGateway; репозиторії → SQL.

## Поза обсягом
Адміністрування й shipped; повернення коштів; пізня відповідь оплати; deployment; реєстрація користувачів.

## Критерії прийняття
1. Одна діаграма в PlantUML, код і рендер.
2. Межа системи явна (package), зовнішні системи поза нею.
3. Кожен компонент має provided або required інтерфейс, кожен required має провайдера.
4. Назви компонентів і операцій як у Лабах 3 і 4, сутності з ER Лаби 1.
5. Шари: UI, API, сервіси, Data Access, БД; до БД лише через репозиторії.
6. Усе нове має позначку ПРОПОЗИЦІЯ з обґрунтуванням.