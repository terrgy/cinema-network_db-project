-- Сегодняшние сеансы
CREATE OR REPLACE VIEW cn.today_sessions AS
SELECT *
FROM cn.session s
WHERE extract(DAY FROM s.time) = extract(DAY FROM NOW());

-- Сегодняшние фильмы
CREATE OR REPLACE VIEW cn.today_films(film_id, title, cinema_id) AS
WITH grouping(film_id, cinema_id) AS
         (SELECT s.film_id, cinema_id
          FROM cn.today_sessions s
                   LEFT JOIN cn.film ON s.film_id = cn.film.film_id
          GROUP BY s.film_id, cinema_id)
SELECT grouping.film_id AS film_id, cn.film.title AS title, grouping.cinema_id AS cinema_id
FROM grouping
         LEFT JOIN cn.film ON grouping.film_id = cn.film.film_id;

-- Неактивные карты лояльности (например, для выдачи клиенту)
CREATE OR REPLACE VIEW cn.not_activated_cards AS
SELECT *
FROM cn.loyalty_card
WHERE cn.loyalty_card.client_id IS NULL;

-- Список сотрудников в формате с полным именем в одном столбце
CREATE OR REPLACE VIEW cn.employees_full_name AS
SELECT employee_id,
       cinema_id,
       first_name || ' ' || mid_name || ' ' || last_name AS full_name,
       birth_date
FROM cn.employee;