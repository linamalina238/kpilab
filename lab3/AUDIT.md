# Аудит

Перевірено `spec.md` і `sequence-diagrams.md` проти моделі Лаби 1 (User, Category, Product, Order, OrderItem; статуси Order: pending, paid, shipped, cancelled) і проти Лаби 2 (`gherkin.feature`, `EARS.md`, `spec.md`, ADR 0003). Spec я писала сама і передавала ШІ лише на аналіз, діаграми ШІ перекладав у Mermaid з мого начерку, а я перевіряла й виправляла. Повний діалог: `ai/conversation-lab3.md` (номер відповіді ШІ = номер мого промпту), помилки ШІ: `ai/errors.md`.

## 1. Учасники ↔ ER Лаби 1

| Учасник діаграми | У моделі Лаби 1 | Висновок |
|---|---|---|
| Покупець | User (`user_id`) | збігається, окремого учасника User немає |
| CatalogService | читає Product за `category_id` | компонент, працює з наявною сутністю |
| OrderService | створює Order і OrderItem, змінює й показує `Order.status` | компонент, працює з наявними сутностями |
| ProductRepository | Product (`category_id`, `price`) | збігається |
| OrderRepository | Order, OrderItem | збігається |
| PaymentService | немає | зовнішня система, participant, не actor (ADR 0003 Лаби 2) |
| Атрибути в повідомленнях: `user_id`, `category_id`, `product_id`, `order_id`, `quantity`, `unit_price`, `price`, `created_at`, `status` | ті самі атрибути (`order_id` — Order.id і OrderItem.order_id, `price` — Product.price) | збігається; `amount` — похідна величина (сума quantity × unit_price) |
| Статуси на діаграмах: pending, paid, cancelled | status | з чотирьох значень Лаби 1, shipped у прецеденті не використовується |

## 2. Кроки Gherkin ↔ повідомлення

| Рядок Gherkin | Повідомлення на діаграмі |
|---|---|
| **S1** Background і Given (Олена, Електроніка, Навушники, Одяг, Футболка) | Note (Given) |
| When відкриває Category «Електроніка» | `getProducts(category_id)` → `findProducts(category_id)` |
| Then показано «Навушники», «Футболка» не показано | return `список Product` |
| When обирає 2 шт. і оформлює замовлення | `submitOrder(user_id, items(product_id, quantity))` |
| Then створено Order pending, `created_at` | `createOrder(user_id, status = pending, created_at)` |
| And створено OrderItem (quantity 2, unit_price 1200.00) | `loop`: `getPrice(product_id)`, `createOrderItem(product_id, quantity, unit_price = price)`; `saveOrder(Order, OrderItem)` |
| And надіслано запит на оплату 2400.00 | `par`: `requestPayment(order_id, amount)` і `startCountdown(order_id, 30 с)` |
| When підтверджує рівно через 30 с | Note про межу 30 с, `paymentConfirmed(order_id)`, `stopCountdown(order_id)` |
| Then статус paid | `getOrderStatus` і `opt` (Order ще pending): `updateStatus(order_id, status = paid)` |
| When відкриває цей Order / Then показано paid | `getOrder(order_id)` → `findOrder` → `status = paid` |
| *(немає рядка)* | return `order_id` Покупцю після `saveOrder`: без нього Покупець не знає, який Order відкривати |
| **S2** Given Order pending, запит надіслано | Note (Given, відлік 30 с іде) |
| When відхиляє через 10 с | Note «через 10 с», `paymentRejected(order_id)`, `stopCountdown(order_id)` |
| Then статус cancelled | `getOrderStatus` і `opt`: `updateStatus(order_id, status = cancelled)` |
| When відкриває / Then показано cancelled | `getOrder` → `status = cancelled` |
| **S3** Given Order pending, запит надіслано | Note (Given, відлік 30 с іде) |
| When немає відповіді 31 с | Note «понад 30 с (у Gherkin 31 с)», `onPaymentTimeout(order_id)` |
| Then статус cancelled | `getOrderStatus` і `opt`: `updateStatus(order_id, status = cancelled)` |
| When відкриває / Then показано cancelled | `getOrder` → `status = cancelled` |

Кроки з EARS, яких немає в Gherkin (критерій 4): `loop` по товарах — REQ-03 («на кожен обраний Product»); відлік 30 с — REQ-06 і REQ-08; перевірка «Order ще pending» — REQ-06, REQ-07, REQ-08 («з pending на …»).

## Перша доробка spec

Після аналізу spec v1 (відповідь 1) я доопрацювала spec одним комітом `8352cdb`: кроки узгодила з Gherkin (Покупець окремо відкриває замовлення, S2 і S3 починаються з Given, у S3 «понад 30 с» замість «відповіді немає 30 с», бо за Лабою 2 рівно 30 с — це ще успіх (REQ-06), а таймаут лише понад 30 с (REQ-08)), учасників прив'язала до ER колонкою «Звідки в моделі», запит на оплату зробила асинхронним (ADR 0001). Три розбіжності нижче ШІ знайшов уже у spec v2 (відповідь 2).

## Топ-3 розбіжності

### Розбіжність 1. Критерій 4 не працював для частини Gherkin

**Було.** Критерій 4: «Кожен крок When/Then з Gherkin має своє повідомлення на діаграмі в тому ж порядку». У S1 бракувало `user_id`, `created_at`, кількості й суми.
**Чому погано.** У S3 «немає відповіді 31 с» повідомленням бути не може, а два Then у S1 (показано «Навушники», не показано «Футболка») — це одна відповідь. Критерій неможливо виконати, а кроки S1 не покривали G21–G25.
**Промпт і фідбек.** `ai/conversation-lab3.md`, відповідь 2, п. 1 і п. 3 (критерій 4); мій фідбек — промпт 3, п. 1.
**Додаткова spec.** Критерій 4: When — повідомлення, Then — повідомлення або return, Given і відсутність відповіді — Note; кроки з EARS пояснюються в AUDIT. Коміт `be9748e`.
**Виправлення.** Кроки S1 доповнено (`user_id`, `created_at`, кількість, сума), на діаграмах Given і відсутність відповіді показано Note. Коміти `be9748e`, `9170441`, `53ce2b8`.

### Розбіжність 2. Не визначено, що відбувається з відліком 30 с і зі статусом

**Було.** У spec був лише запуск відліку 30 с. Не сказано, що буде з відліком, коли відповідь прийшла, хто виграє рівно на 30-й секунді і з якого статусу дозволено змінювати Order.
**Чому погано.** Без зупинки відліку в S1 і S2 таймаут пізніше міг би скасувати вже оплачене замовлення. Межа 30 с з Лаби 2 (REQ-06: «не пізніше ніж через 30 с», REQ-08: «понад 30 с») і умова «з pending на …» у spec не були відображені.
**Промпт і фідбек.** `ai/conversation-lab3.md`, відповідь 2, п. 4 і п. 5 (питання 2); мій фідбек — промпт 3, п. 2.
**Додаткова spec.** Кроки S1–S3 («зупиняє відлік», «якщо Order ще pending») і критерій 8 (межа 30 с, переходи статусів). Коміт `38dcbd3`; уточнення «пізня відповідь» у критерії 8 — коміт `fc932bb`.
**Виправлення.** На діаграмах `stopCountdown(order_id)`, Note про межу 30 с у S1 і `opt` «Order ще pending» у S1–S3. Коміти `9170441`, `031572e`.

### Розбіжність 3. Критерії фрагментів і activation bars слабші за завдання

**Було.** Критерій 2: «У кожній діаграмі є щонайменше один фрагмент `alt`/`opt`/`loop`; у наборі є хоча б один `par`». Критерій 6: «Activation bars не обриваються всередині однієї гілки фрагмента».
**Чому погано.** Для S2 і S3 фрагмент не названо, а `par`, запланований у S1, не належить до `alt`/`opt`/`loop`. Критерій 6 слабший за формулювання завдання: bar має починатися до фрагмента й закінчуватися після нього.
**Промпт і фідбек.** `ai/conversation-lab3.md`, відповідь 2, п. 3 (критерії 2 і 6) і п. 5 (питання 1 і 5); мій фідбек — промпт 3, п. 3.
**Додаткова spec.** Критерій 2 з фрагментами для кожної діаграми (S1: `loop`, `par`, `opt`; S2 і S3: `opt`), критерій 6 дослівно з завдання. Коміт `dadd53c`.
**Виправлення.** Фрагменти на діаграмах відповідають критерію 2. Bar OrderService у S1 починається до `loop` і закінчується після `par`, новий bar від відповіді PaymentService накриває `opt`, так само в S2 і S3. Коміти `9170441`, `031572e`, `53ce2b8`.

## Інші знахідки

- **Самовиклики без return.** Критерій 5 вимагав return на кожен виклик, а самовиклики OrderService його не мають. Дописала, що це внутрішні дії (відповідь 5, коміт `1cd5901`).
- **Правило назв.** `paymentConfirmed`, `paymentRejected`, `onPaymentTimeout` — події, а не «дієслово + об'єкт»; `amount` — похідна величина. Критерій 7 уточнено (відповідь 6, коміт `d2c5ca1`).
- **Bars репозиторіїв.** OrderRepository має окремий bar на кожен виклик (`getOrderStatus` поза `opt`, `updateStatus` усередині). Критерій 6 застосовую до безперервної роботи OrderService; репозиторій між викликами не працює.
- **`order_id` Покупцю в S1.** Повідомлення без рядка в Gherkin (розділ 2), додано свідомо (коміт `d9bcea9`).
- **Рендер.** Діаграми рендеряться в прев'ю GitHub з коду в `sequence-diagrams.md` (перевірила сама), синтаксис додатково перевірив ШІ парсером Mermaid.

## Висновок

Три розбіжності між spec, Gherkin, EARS і завданням виправлено зміною критеріїв у `spec.md` окремими комітами, а не ручним патчем діаграм. Учасники відповідають ER Лаби 1, кроки відповідають сценаріям Gherkin Лаби 2, кроки з EARS пояснено.