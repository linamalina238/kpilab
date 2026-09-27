# Сутності

## User

- id: UUID
- name: string
- email: string

## Product

- id: UUID
- name: string
- price: decimal

## Category

- id: UUID
- name: string

## Order

- id: UUID
- created_at: datetime
- status: string

# Зв'язки

User -> Order (1:N)

Category -> Product (1:N)

Order -> Product (M:N)