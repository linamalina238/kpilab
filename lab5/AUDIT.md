# Аудит

Перевірено `spec.md` і `component-diagram.puml` проти Лаб 1–4. Spec я писала сама й давала ШІ на аналіз, першу діаграму зробив ШІ, розбіжності я знайшла, звіряючи її зі spec. Виправлену діаграму ШІ лише відрендерив і поправив розкладку. Тексти ADR написав ШІ за моїми тезами (промпт 6), я перевірила їх зі spec і діаграмою й виправила неточності. Діалог: `ai/chat-chronology.md`, помилки ШІ: `ai/errors.md`.

## 1. Компоненти ↔ Лаби 1–4

| Компонент | Звідки |
|---|---|
| CatalogService, OrderService, ProductRepository, OrderRepository | Лаба 3 (`getProducts`, `submitOrder`, `saveOrder` тощо) |
| NotificationService | `orderStatusChanged`, ПРОПОЗИЦІЯ Лаби 3 |
| WebUI, BackendAPI | ПРОПОЗИЦІЯ з причиною в spec |
| Database | ПРОПОЗИЦІЯ, таблиці ER Лаби 1; причини в spec спершу не було |
| Identity Provider (зовні) | ПРОПОЗИЦІЯ для 401 і 403; позначки й причини в spec спершу не було |
| PaymentService (зовні) | Лаба 3, не актор (ADR 0003 Лаби 2) |

Для Database та Identity Provider причини додано в spec пізніше, див. «Інші знахідки».

## 2. Інтерфейси і повідомлення

11 інтерфейсів, у кожного один провайдер, 13 залежностей ведуть до існуючих інтерфейсів. Повідомлення Лаб 3–4 йдуть через них так:
- `getProducts` / `submitOrder` / `getOrder`: WebUI → IApi → BackendAPI → ICatalog або IOrders → сервіс → IProductRepo чи IOrderRepo.
- `getOrder(order_id, user_id)`: OrderService перевіряє `Order.user_id = User.id`, BackendAPI віддає 403.
- `requestPayment`: OrderService → IPaymentRequest → PaymentService.
- `paymentConfirmed`, `paymentRejected`: PaymentService → IPaymentCallback → BackendAPI → IOrders → OrderService (ADR 0002).
- `orderStatusChanged`: OrderService → INotify → NotificationService → ISubscribe → BackendAPI → IApi → WebUI (ADR 0001).
- Відлік 30 с: усередині OrderService.

Межа: усередині 8 компонентів, зовні PaymentService, Identity Provider і Покупець; на межі лише IPaymentRequest, IPaymentCallback, IIdentity.

## Топ-3 розбіжності

### 1. `user_id` не доходив до BackendAPI
**Було.** У першій версії spec IOrders мав `submitOrder, getOrder` без параметрів, тож власника Order для 403 було нікому перевірити. ШІ спершу пояснив це вигаданою роллю `User.role`.
**Промпт і фідбек.** `ai/chat-chronology.md`, мій промпт 2, відповідь ШІ 3.
**Spec.** `submitOrder(user_id, items)`, `getOrder(order_id, user_id)`, власника перевіряє OrderService. Коміт `1f9d01f`. Діаграму не змінювала: її зроблено вже за цим spec.

### 2. Інтерфейси поза межею, шари не видно
**Було.** ICatalog, IOrders, IProductRepo та інші стояли поза package; усі компоненти в одному ряду, підписи IIdentity і INotify накладались.
**Промпт.** `ai/chat-chronology.md`, промпт 5; помилка 2 в `ai/errors.md`.
**Spec.** Критерії 7 і 9, коміти `c45c2fd` і `096cce7`. **Діаграма.** Виправлено, коміт `4a15790`.

### 3. Required не за позначками spec
**Було.** У spec required це socket, а на діаграмі пунктир.
**Промпт.** `ai/chat-chronology.md`, промпт 4 (spec і прохання зробити діаграму); помилка 3 в `ai/errors.md`.
**Spec.** Критерій 8 і правка «Форма», коміт `82056d7`. Діаграму не змінювала: socket у PlantUML (`-0)-`) у перевірках малювався лише між двома компонентами, а в моєму spec інтерфейси окремі елементи з операціями й лежать усередині межі (критерій 7), тому required показано пунктирною залежністю до інтерфейсу (допустима UML-нотація).

## Інші знахідки

- «Усе йде вниз» було неточно: додано перелік винятків, коміт `c497e06`.
- Не були названі провайдери IProductRepo і IOrderRepo: коміт `4aef18d`.
- Identity Provider, IIdentity і Database не мали ПРОПОЗИЦІЯ з причиною (критерій 4): додано, коміт `608a06f`.
- `getOrderStatus` лишила в IOrderRepo, бо назви беру з Лаби 3 (критерій 4). У Лабі 4 перевірку «Order ще pending» прибрано структурою «перша подія виграє», але sequence-діаграми Лаби 3 з `getOrderStatus` не змінювалися (Лаба 4, ADR 0001).
- ADR 0001, 0002: коміт `5c33073`.

## Висновок

Три розбіжності виправлено: `user_id` і socket зміною spec, інтерфейси й шари зміною діаграми за критеріями 7 і 9. Кожен компонент і залежність трасується до Лаб 1–4 або має позначку ПРОПОЗИЦІЯ з причиною в spec, кожен required має провайдера, межа явна.