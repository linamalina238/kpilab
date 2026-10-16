## 1. Вимоги EARS

| id | текст | шаблон | сутність або статус з моделі |
|---|---|---|---|
| REQ-01 | WHEN Покупець надсилає замовлення з ≥1 позицією, система SHALL створити Order зі статусом pending. | WHEN | Order, status = pending |
| REQ-02 | WHEN система створює Order, система SHALL створити один OrderItem на кожен обраний Product. | WHEN | Order, OrderItem, Product |
| REQ-03 | WHEN система створює OrderItem, система SHALL записати в unit_price значення Product.price на цей момент. | WHEN | OrderItem.unit_price, Product.price |
| REQ-04 | IF Покупець вказує quantity менше 1 шт., THEN система SHALL відхилити створення Order. | IF-THEN | OrderItem.quantity, Order |
| REQ-05 | IF Покупець надсилає замовлення без жодної позиції, THEN система SHALL відхилити створення Order. | IF-THEN | Order, OrderItem |
| REQ-06 | WHEN Order створено зі статусом pending, система SHALL надіслати Платіжному сервісу запит на оплату суми добутків quantity × unit_price усіх OrderItem цього Order. | WHEN | Order, status = pending, OrderItem |
| REQ-07 | WHEN Платіжний сервіс підтверджує оплату протягом 30 с після запиту, система SHALL змінити статус Order з pending на paid. | WHEN | Order.status: pending → paid |
| REQ-08 | WHEN Платіжний сервіс відхиляє оплату протягом 30 с після запиту, система SHALL змінити статус Order з pending на cancelled. | WHEN | Order.status: pending → cancelled |
| REQ-09 | IF Платіжний сервіс не відповідає протягом 30 с після запиту, THEN система SHALL змінити статус Order з pending на cancelled. | IF-THEN | Order.status: pending → cancelled |
| REQ-10 | IF відповідь Платіжного сервісу надходить пізніше ніж через 30 с після запиту, THEN система SHALL залишити статус Order cancelled. | IF-THEN | Order, status = cancelled |
| REQ-11 | WHEN Покупець скасовує Order зі статусом pending, система SHALL змінити його статус на cancelled. | WHEN | Order.status: pending → cancelled |
| REQ-12 | IF Покупець скасовує Order зі статусом shipped, THEN система SHALL відхилити скасування. | IF-THEN | Order, status = shipped |
| REQ-13 | WHEN Адміністратор позначає Order зі статусом paid як відправлений, система SHALL змінити його статус на shipped. | WHEN | Order.status: paid → shipped |
| REQ-14 | IF Адміністратор додає Product з category_id неіснуючої Category, THEN система SHALL відхилити додавання. | IF-THEN | Product.category_id, Category |
| REQ-15 | WHEN Покупець обирає Category, система SHALL показати перелік Product з category_id цієї Category. | WHEN | Category, Product.category_id |