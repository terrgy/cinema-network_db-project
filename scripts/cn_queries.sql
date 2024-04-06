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


