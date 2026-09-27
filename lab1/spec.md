# Спек — Online Store

## Намір
Інтернет-магазин: перегляд каталогу товарів, оформлення замовлень, керування категоріями.

## Сутності

### User
- id: UUID
- name: string
- email: string

### Category
- id: UUID
- name: string

### Product
- id: UUID
- name: string
- price: decimal
- category_id: UUID (FK -> Category)

### Order
- id: UUID
- user_id: UUID (FK -> User)
- created_at: datetime
- status: string

### OrderItem
- id: UUID
- order_id: UUID (FK -> Order)
- product_id: UUID (FK -> Product)
- quantity: int
- unit_price: decimal   # ціна товару на момент замовлення, не плутати з Product.price

## Зв'язки
- User -> Order (1:N)
- Category -> Product (1:N)
- Order -> OrderItem (1:N)
- Product -> OrderItem (1:N)
- Товар належить рівно одній категорії (1:N, не M:N) — свідоме спрощення моделі, а не замовчування.

OrderItem — асоціативна сутність між Order і Product, бо зв'язок несе власні
атрибути (quantity, unit_price), а не просто M:N без даних.

## Критерії прийняття
- Усі первинні/зовнішні ключі типізовані однаково (UUID), без змішування string/number.
- Модель у 3NF: немає повторюваних груп, немає часткових чи транзитивних залежностей.
- Назви полів у spec.md і в ER-діаграмі збігаються дослівно.
- Зв'язок Order–Product реалізовано через асоціативну сутність OrderItem
  (бо є власні атрибути quantity, unit_price), а не як прямий M:N.
- ER-рендер (Mermaid erDiagram) відповідає цьому опису без розбіжностей.
- Order.status приймає лише значення з фіксованого переліку: pending / paid / shipped / cancelled.