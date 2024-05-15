-- Индекс по времени для сеансов для быстрого поиска
CREATE INDEX IF NOT EXISTS session_time_btree ON cn.session USING btree (time ASC);
-- Отдельный индекс для быстрого поиска всех сеансов по конкретному дню (например, все сеансы на сегодня)
CREATE INDEX IF NOT EXISTS session_time_day ON cn.session (extract(DAY FROM time));

-- Индекс по времени для заказов для быстрого поиска
CREATE INDEX IF NOT EXISTS order_time_btree ON cn.order USING btree (order_dttm ASC);

-- Индекс для поиска по названию фильма (причем сразу в нижнем регистре)
CREATE INDEX IF NOT EXISTS film_title_lower ON cn.film (lower(title));

-- Индекс для быстрого поиска сотрудников по имени-фамилии
CREATE INDEX IF NOT EXISTS employee_first_last_name ON cn.employee ((lower(first_name) || ' ' || lower(last_name)));

-- Индекс для поиска по активированным картам лояльности
CREATE INDEX IF NOT EXISTS loyalty_card_activated ON cn.loyalty_card (client_id) WHERE client_id IS NOT NULL;

-- Индекс для быстрого поиска всех сотрудников кинотеатра
CREATE INDEX IF NOT EXISTS employee_cinema ON cn.employee (cinema_id);

-- Индексы для билетов для быстрого поиска по заказу или по сеансу
CREATE INDEX IF NOT EXISTS ticket_order ON cn.ticket (order_id);
CREATE INDEX IF NOT EXISTS ticket_session ON cn.ticket (session_id);


