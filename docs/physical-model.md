# Физическая модель

Таблица `cn.cinema`:
| Название  | Описание         | Тип данных   | Ограничение |
|-----------|------------------|--------------|-------------|
| `cinema_id` | Идентификатор    | `INTEGER`      | `PRIMARY KEY` |
| `address`   | Адрес кинотеатра | `VARCHAR(300)` | `NOT NULL`    |

Таблица `cn.film`:
| Название | Описание      | Тип данных      | Ограничение   |
|----------|---------------|-----------------|---------------|
| `film_id`  | Идентификатор | `INTEGER`       | `PRIMARY KEY` |
| `title`    | Название      | `VARCHAR(200)`  | `NOT NULL`    |
| `desc`     | Описание      | `VARCHAR(1000)` | `NOT NULL`    |
| `duration` | Длительность  | `INTERVAL`      | `NOT NULL`    |

Таблица `cn.session`:
| Название   | Описание                        | Тип данных          | Ограничение              |
|------------|---------------------------------|---------------------|--------------------------|
| session_id | Идентификатор                   | `INTEGER`           | `PRIMARY KEY`            |
| cinema_id  | Кинотеатр, в котором идет сеанс | `INTEGER`           | `FOREIGN KEY` `NOT NULL` |
| film_id    | Фильм на сеансе                 | `INTEGER`           | `FOREIGN KEY` `NOT NULL` |
| time       | Время сеанса                    | `TIMESTAMP`         | `NOT NULL`               |
| room       | Зал                             | `SMALLINT UNSIGNED` | `NOT NULL`               |
| cost       | Стоимость                       | `DECIMAL(10, 2)`    | `NOT NULL`               |

Таблица `cn.employee`:
| Название    | Описание                      | Тип данных    | Ограничение   |
|-------------|-------------------------------|---------------|---------------|
| `employee_id` | Идентификатор                 | `INTEGER`     | `PRIMARY KEY` |
| `cinema_id`   | Кинотеатр, в котором работает | `INTEGER`     | `FOREIGN KEY` |
| `first_name`  | Имя                           | `VARCHAR(50)` | `NOT NULL`    |
| `mid_name`    | Среднее имя                   | `VARCHAR(50)` | `NOT NULL`    |
| `last_name`   | Фамилия                       | `VARCHAR(50)` | `NOT NULL`    |
| `birth_date`  | Дата рождения                 | `DATE`        | `NOT NULL`    |

Таблица `cn.employees_history`:
| Название     | Описание                | Тип данных | Ограничение                 |
|--------------|-------------------------|------------|-----------------------------|
| `employee_id`  | Работник                | `INTEGER`  | `PRIMARY KEY` `FOREIGN KEY` |
| `cinema_id`    | Предыдущее место работы | `INTEGER`  | `FOREIGN KEY`               |
| `history_dttm` | Время перевода          | `DATE`     | `PRIMARY KEY`               |

Таблица `cn.product`:
| Название   | Описание          | Тип данных       | Ограничение   |
|------------|-------------------|------------------|---------------|
| `product_id` | Идентификатор     | `INTEGER`        | `PRIMARY KEY` |
| `name`       | Название продукта | `VARCHAR(100)`   | `NOT NULL`    |
| `desc`       | Описание          | `VARCHAR(1000)`  | `NOT NULL`    |
| `cost`       | Цена              | `DECIMAL(10, 2)` | `NOT NULL`    |

Таблица `cn.client`:
| Название   | Описание      | Тип данных    | Ограничение   |
|------------|---------------|---------------|---------------|
| client_id  | Идентификатор | `INTEGER`     | `PRIMARY KEY` |
| first_name | Имя           | `VARCHAR(50)` | `NOT NULL`    |
| last_name  | Фамилия       | `VARCHAR(50)` |               |

Таблица `cn.loyalty_card`:
| Название            | Описание                 | Тип данных         | Ограничение   |
|---------------------|--------------------------|--------------------|---------------|
| `loyalty_card_number` | Номер карты              | `BIGINT UNSIGNED`  | `PRIMARY KEY` |
| `customer_id`         | Владелец                 | `INTEGER`          | `FOREIGN KEY` |
| `bonus_amount`        | Текущее количество бонус | `INTEGER UNSIGNED` | `NOT NULL`    |
| `create_dttm`         | Время активации          | `TIMESTAMP`        |               |

Таблица `cn.order`:
| Название    | Описание                              | Тип данных  | Ограничение   |
|-------------|---------------------------------------|-------------|---------------|
| `order_id`    | Идентификатор                         | `INTEGER`   | `PRIMARY KEY` |
| `cinema_id`   | Кинотеатр, в котором заказ был сделан | `INTEGER`   | `FOREIGN KEY` |
| `employee_id` | Работник, который оформил заказ       | `INTEGER`   | `FOREIGN KEY` |
| `customer_id` | Клиент                                | `INTEGER`   | `FOREIGN KEY` |
| `order_dttm`  | Время заказа                          | `TIMESTAMP` | `NOT NULL`    |

Таблица `cn.products_in_orders`:
| Название   | Описание | Тип данных | Ограничение                 |
|------------|----------|------------|-----------------------------|
| `order_id`   | Заказ    | `INTEGER`  | `PRIMARY KEY` `FOREIGN KEY` |
| `product_id` | Товар    | `INTEGER`  | `PRIMARY KEY` `FOREIGN KEY` |

Таблица `cn.ticket`:
| Название   | Описание                      | Тип данных | Ограничение              |
|------------|-------------------------------|------------|--------------------------|
| `ticket_id`  | Идентификатор                 | `INTEGER`           | `PRIMARY KEY`            |
| `order_id`   | Заказ, в котором купили билет | `INTEGER`           | `FOREIGN KEY` `NOT NULL` |
| `session_id` | Сеанс, на который билет       | `INTEGER`           | `FOREIGN KEY` `NOT NULL` |
| `row`        | Ряд                           | `SMALLINT UNSIGNED` | `NOT NULL`               |
| `seat`       | Место                         | `SMALLINT UNSIGNED` | `NOT NULL`               |

Таблица `cn.payment`:
| Название            | Описание                        | Тип данных        | Ограничение              |
|---------------------|---------------------------------|-------------------|--------------------------|
| `payment_id`          | Идентификатор                   | `INTEGER`         | `PRIMARY KEY`            |
| `order_id`            | Заказ                           | `INTEGER`         | `FOREIGN KEY` `NOT NULL` |
| `loyalty_card_number` | Использованная карта лояльности | `BIGINT UNSIGNED` | `FOREIGN KEY`            |
| `payment_amount`      | Сумма заказа                    | `DECIMAL(10, 2)`  | `NOT NULL`               |
| `discount_amount`     | Размер скидки                   | `DECIMAL(10, 2)`  | `NOT NULL`               |