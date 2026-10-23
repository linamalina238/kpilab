# Вимоги EARS — UC-02 «Оформити й оплатити замовлення»

| id | текст | шаблон | сутність |
|---|---|---|---|
| REQ-01 | WHEN Покупець оформлює замовлення з ≥1 позицією, система SHALL створити Order зі статусом pending і user_id цього Покупця. | WHEN | Order (user_id, status = pending), User |
| REQ-02 | WHEN система створює Order, система SHALL записати в created_at поточні дату й час. | WHEN | Order.created_at |
| REQ-03 | WHEN система створює Order, система SHALL створити один OrderItem з quantity ≥ 1 шт. на кожен обраний Product. | WHEN | Order, OrderItem.quantity, Product |
| REQ-04 | WHEN система створює OrderItem, система SHALL записати в unit_price значення Product.price на цей момент. | WHEN | OrderItem.unit_price, Product.price |
| REQ-05 | WHEN Order створено зі статусом pending, система SHALL надіслати Платіжному сервісу запит на оплату суми добутків quantity × unit_price усіх OrderItem цього Order. | WHEN | Order (status = pending), OrderItem |
| REQ-06 | WHEN Платіжний сервіс підтверджує оплату не пізніше ніж через 30 с після запиту, система SHALL змінити статус Order з pending на paid. | WHEN | Order.status: pending → paid |
| REQ-07 | WHEN Платіжний сервіс відхиляє оплату не пізніше ніж через 30 с після запиту, система SHALL змінити статус Order з pending на cancelled. | WHEN | Order.status: pending → cancelled |
| REQ-08 | IF Платіжний сервіс не відповідає понад 30 с після запиту, THEN система SHALL змінити статус Order з pending на cancelled. | IF-THEN | Order.status: pending → cancelled |
| REQ-09 | WHEN Користувач обирає Category, система SHALL показати перелік Product з category_id цієї Category. | WHEN | Category, Product.category_id |
| REQ-10 | WHEN Покупець відкриває Order зі статусом paid або cancelled, система SHALL показати йому поточний статус цього Order. | WHEN | Order.status, Order.user_id, User |

Межа таймауту: відповідь через 30 с і менше це успіх або відмова (REQ-06, REQ-07), відповідь пізніше за 30 с це таймаут (REQ-08).

Зв'язки на діаграмі: include UC-02 → UC-01 тримається на REQ-09, extend UC-03 → UC-02 тримається на REQ-10 (умова extend: оплату завершено, Order.status = paid або cancelled).

ПРОПОЗИЦІЙ немає: усі сутності, атрибути й статуси взято з моделі Лаби 1.