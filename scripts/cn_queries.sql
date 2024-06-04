-- 1. Вывести номера заказов и суммарную стоимость билетов в них, в которых купили как минимум 2 билета
SELECT t.order_id, COUNT(t.ticket_id), SUM(s.cost) FROM cn.ticket t LEFT OUTER JOIN cn.session s ON t.session_id = s.session_id GROUP BY t.order_id HAVING COUNT(t.ticket_id) > 1;

-- 2. Вывести сеансы в конкретном кинотеатре в хронологическом порядке
SELECT * FROM cn.session s WHERE s.cinema_id = 1 ORDER BY time;

-- 3. Вывести для всех работников историю перемещения с указанием, в какой раз работник переместился
SELECT *,
row_number() OVER (PARTITION BY employee_id ORDER BY history_dttm) AS move_number
FROM cn.employees_history  ORDER BY history_dttm;

-- 4. Вывести все заказы, к которым привязан клиент, с указанием предыдущего и следующего заказов
SELECT *,
LAG(order_id) OVER (PARTITION BY client_id ORDER BY order_dttm) AS prev_order,
LEAD(order_id) OVER (PARTITION BY client_id ORDER BY order_dttm) AS next_order
FROM cn.order WHERE client_id IS NOT NULL;

-- 5. Вывести среднюю стоимость сеанса фильма с id=4 по кинотеатрам
SELECT *,
AVG(cost) OVER (PARTITION BY cinema_id) AS avg_cost
FROM cn.session WHERE film_id = 4;

-- 6. Вывести информацию об оплатах за последний год с нарастающей суммой оплаты
SELECT payment_id, payment_amount, cn.order.order_dttm,
SUM(payment_amount) OVER (ORDER BY cn."order".order_dttm)
FROM cn.payment LEFT OUTER JOIN cn."order" ON cn.payment.order_id = cn."order".order_id
WHERE order_dttm >= NOW() - INTERVAL '1 year';

-- 7. Вывести все уникальные имя-фамилия среди работников сети
SELECT DISTINCT first_name, mid_name FROM cn.employee;

-- 8. Вывести только информацию про товары-попкорн
SELECT * FROM cn.product WHERE LOWER(cn.product.name) LIKE '%попкорн%';

-- 9. Вывести статистику по товарам: товар - сколько раз его покупали
WITH buy_count AS
(SELECT product_id, COUNT(order_id) AS buy_count FROM cn.products_in_orders GROUP BY product_id ORDER BY product_id)
SELECT name, buy_count FROM cn.product LEFT OUTER JOIN buy_count ON cn.product.product_id = buy_count.product_id ORDER BY buy_count DESC ;

-- 10. Вывести кол-во клиентов с бонусной картой
SELECT (SELECT COUNT(*) FROM cn.client) AS total_count, (SELECT COUNT(*) FROM cn.client LEFT OUTER JOIN cn.loyalty_card ON cn.client.client_id = cn.loyalty_card.client_id
WHERE loyalty_card.loyalty_card_number IS NOT NULL) AS with_card;