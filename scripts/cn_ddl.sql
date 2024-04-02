CREATE SCHEMA IF NOT EXISTS cn;

CREATE TABLE IF NOT EXISTS cn.cinema
(
    cinema_id INTEGER      NOT NULL PRIMARY KEY,
    address   VARCHAR(300) NOT NULL
);

CREATE TABLE IF NOT EXISTS cn.film
(
    film_id     INTEGER       NOT NULL PRIMARY KEY,
    title       VARCHAR(200)  NOT NULL,
    description VARCHAR(1000) NOT NULL,
    duration    INTERVAL      NOT NULL
);

CREATE TABLE IF NOT EXISTS cn.session
(
    session_id INTEGER                     NOT NULL PRIMARY KEY,
    cinema_id  INTEGER                     NOT NULL,
    film_id    INTEGER                     NOT NULL,
    time       TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    room       SMALLINT                    NOT NULL CHECK ( room >= 0 ),
    cost       DECIMAL(10, 2)              NOT NULL CHECK (cost >= 0),

    CONSTRAINT fk_cinema_id FOREIGN KEY (cinema_id) REFERENCES cn.cinema (cinema_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_film_id FOREIGN KEY (film_id) REFERENCES cn.film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cn.employee
(
    employee_id INTEGER     NOT NULL PRIMARY KEY,
    cinema_id   INTEGER,
    first_name  VARCHAR(50) NOT NULL,
    mid_name    VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50),
    birth_date  DATE        NOT NULL,

    CONSTRAINT fk_cinema_id FOREIGN KEY (cinema_id) REFERENCES cn.cinema (cinema_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cn.employees_history
(
    employee_id  INTEGER NOT NULL,
    cinema_id    INTEGER,
    history_dttm DATE    NOT NULL,

    PRIMARY KEY (employee_id, history_dttm),
    CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES cn.employee (employee_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cinema_id FOREIGN KEY (cinema_id) REFERENCES cn.cinema (cinema_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cn.product
(
    product_id  INTEGER        NOT NULL PRIMARY KEY,
    name        VARCHAR(100)   NOT NULL,
    description VARCHAR(1000)  NOT NULL,
    cost        DECIMAL(10, 2) NOT NULL CHECK (cost >= 0)
);

CREATE TABLE IF NOT EXISTS cn.client
(
    client_id  INTEGER     NOT NULL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS cn.loyalty_card
(
    loyalty_card_number BIGINT  NOT NULL PRIMARY KEY CHECK (loyalty_card_number >= 100000000000000 AND
                                                            loyalty_card_number <= 999999999999999),
    client_id           INTEGER,
    bonus_amount        INTEGER NOT NULL CHECK (bonus_amount >= 0),
    create_dttm         TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_customer_id FOREIGN KEY (client_id) REFERENCES cn.client (client_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cn.order
(
    order_id    INTEGER NOT NULL PRIMARY KEY,
    cinema_id   INTEGER,
    employee_id INTEGER,
    client_id   INTEGER,
    order_dttm  TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cinema_id FOREIGN KEY (cinema_id) REFERENCES cn.cinema (cinema_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES cn.employee (employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_client_id FOREIGN KEY (client_id) REFERENCES cn.client (client_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cn.products_in_orders
(
    order_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,

    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES cn.order (order_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES cn.product (product_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cn.ticket
(
    ticket_id  INTEGER  NOT NULL PRIMARY KEY,
    order_id   INTEGER  NOT NULL,
    session_id INTEGER  NOT NULL,
    row        SMALLINT NOT NULL CHECK (row > 0),
    seat       SMALLINT NOT NULL CHECK (seat > 0),

    CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES cn.order (order_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_session_id FOREIGN KEY (session_id) REFERENCES cn.session (session_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS cn.payment
(
    payment_id          INTEGER        NOT NULL PRIMARY KEY,
    order_id            INTEGER        NOT NULL,
    loyalty_card_number BIGINT,
    payment_amount      DECIMAL(10, 2) NOT NULL CHECK (payment_amount > 0),
    discount_amount     DECIMAL(10, 2) NOT NULL CHECK (discount_amount >= 0),

    CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES cn.order (order_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_loyalty_card_number FOREIGN KEY (loyalty_card_number) REFERENCES cn.loyalty_card (loyalty_card_number) ON DELETE SET NULL ON UPDATE CASCADE
);