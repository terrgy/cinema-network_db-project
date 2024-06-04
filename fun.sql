EXPLAIN ANALYSE SELECT time FROM cn.session WHERE cn.session.time >= '2024-04-16 20:57:00.000000';

CREATE INDEX session_time_btree ON cn.session USING btree(time ASC);

CREATE INDEX session_time_day ON cn.session(extract(DAY FROM time));

SELECT * FROM cn.sessions_by_day('2024-04-15', 100);
SELECT * FROM cn.films_by_day('2024-04-15', 100);

SELECT NOW()::DATE;

SELECT *
    FROM cn.session s
    WHERE s.time::DATE = '2024-04-15';

SELECT
    o.cinema_id,
    COUNT(*) AS payments_count,
    SUM(p.payment_amount) AS sum_payment,
    AVG(p.payment_amount) AS avg_payment,
    SUM(p.discount_amount) AS sum_discount,
    AVG(p.discount_amount) AS avg_discount
FROM cn.payment p LEFT JOIN cn."order" o ON p.order_id = o.order_id
WHERE o.order_dttm >= '2023-01-01' AND o.order_dttm <= '2024-01-01' AND o.cinema_id IS NOT NULL
GROUP BY o.cinema_id;

SELECT * FROM cn."order";

SELECT * FROM cn.cinema_stats('2023-01-01', '2024-01-01', 4);

SELECT cn.seats_purchased_count(5);
