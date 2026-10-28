# Специфікація: взаємодія в UC-02 «Оформити й оплатити замовлення»

## Намір
Показати, що відбувається всередині системи в трьох сценаріях UC-02 з Лаби 2: хто кого викликає, у якому порядку і як змінюється статус замовлення.

## Сценарії (з `lab2/gherkin.feature`)
| # | Сценарій | Діаграма |
|---|---|---|
| S1 | Оплата підтверджена не пізніше ніж за 30 с | розділ S1 у `sequence-diagrams.md` |
| S2 | Платіжний сервіс відхиляє оплату | розділ S2 у `sequence-diagrams.md` |
| S3 | Відповіді немає понад 30 с | розділ S3 у `sequence-diagrams.md` |

S1 включає кроки UC-01 (перегляд категорії) і UC-03 (перегляд статусу), як і перший сценарій Gherkin.

## Учасники
| Учасник | Тип | Звідки в моделі (ER Лаби 1) |
|---|---|---|
| Покупець | actor | User (user_id) |
| CatalogService | сервіс | читає Product за category_id |
| OrderService | сервіс | створює Order і OrderItem, змінює і показує Order.status |
| ProductRepository | дані | Product (category_id, price) |
| OrderRepository | дані | Order, OrderItem |
| PaymentService | зовнішня система | в ER немає (ADR 0003 Лаби 2) |

## Кроки сценаріїв
- **S1:** Покупець відкриває категорію → CatalogService бере з ProductRepository товари з `category_id` → Покупець обирає товар і кількість, оформлює замовлення → OrderService бере ціну з ProductRepository, створює Order (`pending`, `user_id`, `created_at`) і OrderItem (`quantity`, `unit_price`), зберігає через OrderRepository і повертає Покупцю `order_id` → надсилає запит на оплату суми `quantity × unit_price` і одночасно починає відлік 30 с → PaymentService підтверджує не пізніше ніж за 30 с → OrderService зупиняє відлік і, якщо Order ще `pending`, ставить `paid` → Покупець відкриває замовлення і бачить `paid`.
- **S2:** Given: Order `pending`, запит на оплату надіслано, відлік 30 с іде → PaymentService відхиляє → OrderService зупиняє відлік і, якщо Order ще `pending`, ставить `cancelled` → Покупець відкриває замовлення і бачить `cancelled`.
- **S3:** Given як у S2 → відповіді немає понад 30 с → спрацьовує відлік в OrderService → якщо Order ще `pending`, ставить `cancelled` → Покупець відкриває замовлення і бачить `cancelled`.

Показ статусу `pending` поза обсягом: REQ-10 описує лише `paid` і `cancelled`.

## Критерії прийняття
1. Кожен сценарій має свою діаграму (Mermaid `sequenceDiagram`, код + рендер).
2. Фрагменти: у S1 `loop` по товарах, `par` (запит на оплату і відлік 30 с) і `opt` (Order ще `pending`); у S2 і S3 `opt`.
3. Учасники відповідають ER Лаби 1 за таблицею «Учасники»: сервіси й репозиторії працюють з наявними сутностями, Покупець — це User, PaymentService — зовнішня система (participant, не actor). Статуси Order лише з Лаби 1: pending, paid, shipped, cancelled.
4. Кроки йдуть у порядку Gherkin: When — повідомлення, Then — повідомлення або return, Given і відсутність відповіді (S3) — примітка (Note). Кроки з EARS, яких немає в Gherkin (`loop` по товарах, відлік 30 с, перевірка «Order ще `pending`»), пояснюю в AUDIT.
5. Кожен виклик має return, крім асинхронних: запиту на оплату, відповіді PaymentService і події таймауту. 30 с рахує OrderService. Самовиклики OrderService (createOrder, createOrderItem, startCountdown, stopCountdown) — внутрішні дії без return.
6. Activation bar учасника, що працює поза фрагментом або в кількох гілках, починається до фрагмента і закінчується після нього, а не обривається в одній гілці.
7. Назви: синхронні виклики — дієслово + об'єкт (`submitOrder`, `getPrice`), асинхронні події — назва події (`paymentConfirmed`, `onPaymentTimeout`). Параметри — атрибути або сутності з ER (`saveOrder(Order, OrderItem)`) і похідні від них величини (`amount` — сума quantity × unit_price).
8. Межа 30 с як у Лабі 2: відповідь не пізніше ніж за 30 с (і рівно на 30-й секунді) вчасна, таймаут лише понад 30 с. Статус змінюється тільки з `pending` на `paid` або `cancelled` (REQ-06, 07, 08); якщо статус уже не `pending` (пізня відповідь), це поза обсягом (Лаба 2, «Поза обсягом» п. 6).