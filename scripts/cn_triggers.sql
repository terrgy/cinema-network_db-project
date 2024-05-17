-- Автоматическое сохранение истории перемещения работников
CREATE OR REPLACE FUNCTION cn.employees_history_autosave() RETURNS TRIGGER AS
$$
BEGIN
    IF (OLD IS NULL) OR (OLD.cinema_id != NEW.cinema_id) THEN
        INSERT INTO cn.employees_history(employee_id, cinema_id, history_dttm)
            VALUES (NEW.employee_id, NEW.cinema_id, NOW());
    END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER employees_history_autosave_trigger
AFTER UPDATE OR INSERT ON cn.employee
FOR EACH ROW
EXECUTE FUNCTION cn.employees_history_autosave();

-- Запрет на покупку билетов после начала сеанса
CREATE OR REPLACE FUNCTION cn.tickets_after_session_start_ban() RETURNS TRIGGER AS
$$
DECLARE
    ticket_order_dttm TIMESTAMP;
    ticket_session_dttm TIMESTAMP;
BEGIN
    SELECT "order".order_dttm INTO ticket_order_dttm FROM cn."order" WHERE cn."order".order_id = NEW.order_id;
    IF ticket_order_dttm IS NULL THEN
        RAISE EXCEPTION 'Ticket must have existing order';
    END IF;
    SELECT cn.session.time INTO ticket_session_dttm FROM cn.session WHERE cn.session.session_id = NEW.session_id;
    IF ticket_session_dttm IS NULL THEN
        RAISE EXCEPTION 'Ticket must have existing session';
    END IF;
    IF ticket_order_dttm > ticket_session_dttm THEN
        RAISE EXCEPTION 'Ticket can not be bought after its session';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tickets_after_session_start_ban_trigger
BEFORE INSERT ON cn.ticket
FOR EACH ROW
EXECUTE FUNCTION cn.tickets_after_session_start_ban();

-- Запрет на создание пересекающихся сеансов в одном зале
CREATE OR REPLACE FUNCTION cn.sessions_intersection_ban() RETURNS TRIGGER AS
$$
DECLARE
    new_film_duration INTERVAL;
    problem_session INTEGER;
BEGIN
    SELECT cn.film.duration INTO new_film_duration FROM cn.film WHERE cn.film.film_id = NEW.film_id;
    IF new_film_duration IS NULL THEN
        RAISE EXCEPTION 'Session must have existing film';
    END IF;
    SELECT cn.session.session_id INTO problem_session FROM cn.session
                                 LEFT JOIN cn.film ON cn.session.film_id = cn.film.film_id
                                 WHERE (cn.session.cinema_id = NEW.cinema_id) AND (cn.session.room = NEW.room)
                                                   AND (((cn.session.time <= NEW.time) AND (NEW.time <= cn.session.time + cn.film.duration)) OR
                                                        ((cn.session.time <= NEW.time + new_film_duration) AND (NEW.time + new_film_duration <= cn.session.time + cn.film.duration)) OR
                                                        ((NEW.time <= cn.session.time) AND (cn.session.time <= NEW.time + new_film_duration)) OR
                                                        ((NEW.time <= cn.session.time + cn.film.duration) AND (cn.session.time + cn.film.duration <= NEW.time + new_film_duration)))
                                LIMIT 1;
    IF problem_session IS NOT NULL THEN
        RAISE EXCEPTION 'New session is intersecting with session %', problem_session;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER sessions_intersection_ban_trigger
BEFORE INSERT OR UPDATE ON cn.session
FOR EACH ROW
EXECUTE FUNCTION cn.sessions_intersection_ban();