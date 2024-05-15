-- Проверка кинотеатра на существование (если не существует, выкидывает ошибку)
CREATE OR REPLACE PROCEDURE cn.is_cinema_exists(cinema_id INTEGER) AS
$$
DECLARE
    cinema_check INTEGER;
BEGIN
    SELECT COUNT(*) INTO cinema_check FROM cn.cinema WHERE cn.cinema.cinema_id = $1;
    IF cinema_check = 0 THEN
        RAISE EXCEPTION 'Кинотеатра с идентификатором % не существует', $1;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Проверка сеанса на существование (если не существует, выкидывает ошибку)
CREATE OR REPLACE PROCEDURE cn.is_session_exists(session_id INTEGER) AS
$$
DECLARE
    session_check INTEGER;
BEGIN
    SELECT COUNT(*) INTO session_check FROM cn.session WHERE cn.session.session_id = $1;
    IF session_check = 0 THEN
        RAISE EXCEPTION 'Сеанса с идентификатором % не существует', $1;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Таблица сеансов в день date в кинотеатре cinema_id (если cinema_id = NULL, то во всех кинотеатрах)
CREATE OR REPLACE FUNCTION cn.sessions_by_day(date DATE, cinema_id INTEGER = NULL) RETURNS SETOF cn.session AS
$$

BEGIN
    IF $2 is NULL THEN
        RETURN QUERY
            SELECT *
            FROM cn.session s
            WHERE s.time::DATE = date;
    ELSE
        CALL cn.is_cinema_exists($2);

        RETURN QUERY
            SELECT *
            FROM cn.session s
            WHERE s.time::DATE = date
              AND s.cinema_id = $2;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Таблица фильмов в день date в кинотеатре cinema_id (если cinema_id = NULL, то во всех кинотеатрах)
CREATE OR REPLACE FUNCTION cn.films_by_day(date DATE, cinema_id_ INTEGER = NULL)
    RETURNS TABLE
            (
                film_id   INTEGER,
                title     VARCHAR(200),
                cinema_id INTEGER
            )
AS
$$
BEGIN
    RETURN QUERY
        WITH grouping(film_id, cinema_id) AS
                 (SELECT s.film_id, s.cinema_id
                  FROM cn.sessions_by_day($1, $2) s
                           LEFT JOIN cn.film ON s.film_id = cn.film.film_id
                  GROUP BY s.film_id, s.cinema_id)
        SELECT grouping.film_id AS film_id, cn.film.title AS title, grouping.cinema_id AS cinema_id
        FROM grouping
                 LEFT JOIN cn.film ON grouping.film_id = cn.film.film_id;
END;
$$ LANGUAGE plpgsql;

-- Финансовая статистика по кинотеатру cinema_id за промежуток времени от start_time до end_time
-- (если cinema_id = NULL, то по всем кинотеатрам, если cinema_id = -1, то по заказам онлайн)
CREATE OR REPLACE FUNCTION cn.cinema_stats(start_time TIMESTAMP, end_time TIMESTAMP, cinema_id_ INTEGER = NULL)
    RETURNS TABLE
            (
                cinema_id      INTEGER,
                payments_count BIGINT,
                sum_payment    NUMERIC,
                avg_payment    NUMERIC,
                sum_discount   NUMERIC,
                avg_discount   NUMERIC
            )
AS
$$
BEGIN

    IF $3 IS NULL THEN
        RETURN QUERY SELECT o.cinema_id,
                            COUNT(*)               AS payments_count,
                            SUM(p.payment_amount)  AS sum_payment,
                            AVG(p.payment_amount)  AS avg_payment,
                            SUM(p.discount_amount) AS sum_discount,
                            AVG(p.discount_amount) AS avg_discount
                     FROM cn.payment p
                              LEFT JOIN cn."order" o ON p.order_id = o.order_id
                     WHERE o.order_dttm >= $1
                       AND o.order_dttm <= $2
                       AND o.cinema_id IS NOT NULL
                     GROUP BY o.cinema_id;
    ELSIF $3 = -1 THEN
        RETURN QUERY SELECT o.cinema_id,
                            COUNT(*)               AS payments_count,
                            SUM(p.payment_amount)  AS sum_payment,
                            AVG(p.payment_amount)  AS avg_payment,
                            SUM(p.discount_amount) AS sum_discount,
                            AVG(p.discount_amount) AS avg_discount
                     FROM cn.payment p
                              LEFT JOIN cn."order" o ON p.order_id = o.order_id
                     WHERE o.order_dttm >= $1
                       AND o.order_dttm <= $2
                       AND o.cinema_id IS NULL
                     GROUP BY o.cinema_id;
    ELSE
        CALL cn.is_cinema_exists($3);

        RETURN QUERY SELECT o.cinema_id,
                            COUNT(*)               AS payments_count,
                            SUM(p.payment_amount)  AS sum_payment,
                            AVG(p.payment_amount)  AS avg_payment,
                            SUM(p.discount_amount) AS sum_discount,
                            AVG(p.discount_amount) AS avg_discount
                     FROM cn.payment p
                              LEFT JOIN cn."order" o ON p.order_id = o.order_id
                     WHERE o.order_dttm >= $1
                       AND o.order_dttm <= $2
                       AND o.cinema_id = $3
                     GROUP BY o.cinema_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Количество купленных мест на сеансе
CREATE OR REPLACE FUNCTION cn.seats_purchased_count(session_id INTEGER) RETURNS INTEGER AS
$$
DECLARE
    result INTEGER;
BEGIN
    CALL cn.is_session_exists($1);

    SELECT COUNT(*) INTO result FROM cn.ticket WHERE cn.ticket.session_id = $1;
    RETURN result;
END;
$$ LANGUAGE plpgsql;