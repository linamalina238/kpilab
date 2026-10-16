Feature: Оформлення, оплата і скасування замовлення

  Background:
    Given існує User з name "Олена" і email "olena@example.com"
    And існує Category з name "Електроніка"
    And існує Product з name "Навушники", price 1200.00 і category_id категорії "Електроніка"

  # Основний сценарій 1 — оформлення замовлення

  @REQ-01 @REQ-02 @REQ-03 @REQ-06
  Scenario: Покупець оформлює замовлення
    When Покупець надсилає замовлення з 2 шт. Product "Навушники"
    Then створено Order зі статусом pending
    And створено один OrderItem з quantity 2 і unit_price 1200.00
    And Платіжному сервісу надіслано запит на оплату суми 2400.00

  @REQ-04
  Scenario: Замовлення з quantity менше 1 шт. відхиляється
    When Покупець надсилає замовлення з 0 шт. Product "Навушники"
    Then Order не створено

  @REQ-05
  Scenario: Замовлення без позицій відхиляється
    When Покупець надсилає замовлення без жодної позиції
    Then Order не створено

  # Основний сценарій 2 — оплата

  @REQ-07
  Scenario: Платіжний сервіс підтверджує оплату
    Given існує Order зі статусом pending від User "Олена" з одним OrderItem (quantity 2, unit_price 1200.00)
    And Платіжному сервісу надіслано запит на оплату суми 2400.00
    When Платіжний сервіс підтверджує оплату через 10 с
    Then статус Order дорівнює paid

  @REQ-08
  Scenario: Платіжний сервіс відхиляє оплату
    Given існує Order зі статусом pending від User "Олена" з одним OrderItem (quantity 2, unit_price 1200.00)
    And Платіжному сервісу надіслано запит на оплату суми 2400.00
    When Платіжний сервіс відхиляє оплату через 10 с
    Then статус Order дорівнює cancelled

  @REQ-09
  Scenario: Платіжний сервіс не відповідає 30 с
    Given існує Order зі статусом pending від User "Олена" з одним OrderItem (quantity 2, unit_price 1200.00)
    And Платіжному сервісу надіслано запит на оплату суми 2400.00
    When від Платіжного сервісу немає відповіді 30 с
    Then статус Order дорівнює cancelled

  @REQ-09 @REQ-10
  Scenario: Пізня відповідь після таймауту ігнорується
    Given Order отримав статус cancelled, бо Платіжний сервіс не відповів 30 с
    When Платіжний сервіс підтверджує оплату через 45 с після запиту
    Then статус Order залишається cancelled

  # Основний сценарій 3 — скасування замовлення

  @REQ-11
  Scenario: Покупець скасовує неоплачене замовлення
    Given існує Order зі статусом pending від User "Олена"
    When Покупець скасовує цей Order
    Then статус Order дорівнює cancelled

  @REQ-12
  Scenario: Скасування відправленого замовлення відхиляється
    Given існує Order зі статусом shipped від User "Олена"
    When Покупець скасовує цей Order
    Then скасування відхилено
    And статус Order залишається shipped