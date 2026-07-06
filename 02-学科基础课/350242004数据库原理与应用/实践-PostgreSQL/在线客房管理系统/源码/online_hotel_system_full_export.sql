--
-- PostgreSQL database dump
--

\restrict VaMdf3XKzeud5cUZKLhtUQgJ6plH0feEQwmlcOZEDBvrAG16sdrb7mzA01Glvq8

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: add_order(integer, integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_order(p_user_id integer, p_room_id integer, p_check_in_time timestamp without time zone, p_check_out_time timestamp without time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    nights INT;
    room_price DECIMAL(10, 2);
    total_amount DECIMAL(10, 2);
BEGIN
    SELECT price INTO room_price FROM rooms WHERE room_id = p_room_id;
    nights := EXTRACT(DAY FROM (p_check_out_time - p_check_in_time));
    IF nights <= 0 THEN
        nights := 1;
    END IF;
    total_amount := calculate_total_amount(room_price, nights);
    
    INSERT INTO orders (user_id, order_status, total_amount, order_time)
    VALUES (p_user_id, 'Pending', total_amount, CURRENT_TIMESTAMP);
    
    INSERT INTO reservations (user_id, room_id, check_in_time, check_out_time, reservation_status)
    VALUES (p_user_id, p_room_id, p_check_in_time, p_check_out_time, 'Pending');
END;
$$;


ALTER FUNCTION public.add_order(p_user_id integer, p_room_id integer, p_check_in_time timestamp without time zone, p_check_out_time timestamp without time zone) OWNER TO postgres;

--
-- Name: calculate_total_amount(numeric, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_total_amount(room_price numeric, nights integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    total DECIMAL(10, 2);
BEGIN
    total := room_price * nights;
    RETURN total;
END;
$$;


ALTER FUNCTION public.calculate_total_amount(room_price numeric, nights integer) OWNER TO postgres;

--
-- Name: calculate_user_orders(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_user_orders() RETURNS TABLE(result_user_id integer, result_order_count bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR SELECT u.user_id FROM users u ORDER BY u.user_id;
BEGIN
    DELETE FROM user_order_summary;
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;

        INSERT INTO user_order_summary (user_id, order_count, total_spent)
        SELECT rec.user_id, COUNT(*), COALESCE(SUM(total_amount), 0)
        FROM orders
        WHERE orders.user_id = rec.user_id;

        result_user_id := rec.user_id;
        result_order_count := (SELECT COUNT(*) FROM orders WHERE orders.user_id = rec.user_id);
        RETURN NEXT;
    END LOOP;
    CLOSE cur;
    RETURN;
END;
$$;


ALTER FUNCTION public.calculate_user_orders() OWNER TO postgres;

--
-- Name: trg_audit_orders_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_audit_orders_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (OLD.user_id, 'DELETE ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN OLD;
END;
$$;


ALTER FUNCTION public.trg_audit_orders_delete() OWNER TO postgres;

--
-- Name: trg_audit_orders_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_audit_orders_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (NEW.user_id, 'INSERT ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_audit_orders_insert() OWNER TO postgres;

--
-- Name: trg_audit_orders_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_audit_orders_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO audit_log (user_id, action, table_name, timestamp)
    VALUES (NEW.user_id, 'UPDATE ORDER', 'orders', CURRENT_TIMESTAMP);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_audit_orders_update() OWNER TO postgres;

--
-- Name: trg_update_room_average_rating(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_update_room_average_rating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_rating DECIMAL(3, 2);
BEGIN
    SELECT COALESCE(AVG(rating), 0) INTO avg_rating
    FROM reviews
    WHERE room_id = NEW.room_id;
    UPDATE rooms SET average_rating = avg_rating WHERE room_id = NEW.room_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_update_room_average_rating() OWNER TO postgres;

--
-- Name: trg_update_room_status_on_cancel(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_update_room_status_on_cancel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.reservation_status = 'Cancelled' AND OLD.reservation_status <> 'Cancelled' THEN
        UPDATE rooms SET status = 'Available' WHERE room_id = NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_update_room_status_on_cancel() OWNER TO postgres;

--
-- Name: trg_update_room_status_on_reservation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_update_room_status_on_reservation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.reservation_status IN ('Pending', 'Paid') THEN
        UPDATE rooms SET status = 'Booked' WHERE room_id = NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_update_room_status_on_reservation() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    log_id integer NOT NULL,
    user_id integer,
    action character varying(100),
    table_name character varying(50),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: audit_log_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_log_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_log_log_id_seq OWNER TO postgres;

--
-- Name: audit_log_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_log_log_id_seq OWNED BY public.audit_log.log_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    user_id integer NOT NULL,
    order_status character varying(20) DEFAULT 'Pending'::character varying,
    total_amount numeric(10,2) NOT NULL,
    order_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: reservations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservations (
    reservation_id integer NOT NULL,
    user_id integer NOT NULL,
    room_id integer NOT NULL,
    check_in_time timestamp without time zone NOT NULL,
    check_out_time timestamp without time zone NOT NULL,
    reservation_status character varying(20) DEFAULT 'Pending'::character varying
);


ALTER TABLE public.reservations OWNER TO postgres;

--
-- Name: reservations_reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservations_reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservations_reservation_id_seq OWNER TO postgres;

--
-- Name: reservations_reservation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservations_reservation_id_seq OWNED BY public.reservations.reservation_id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    review_id integer NOT NULL,
    order_id integer NOT NULL,
    user_id integer NOT NULL,
    room_id integer NOT NULL,
    content character varying(500),
    rating numeric(3,2),
    CONSTRAINT reviews_rating_check CHECK (((rating >= (1)::numeric) AND (rating <= (5)::numeric)))
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_review_id_seq OWNER TO postgres;

--
-- Name: reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reviews_review_id_seq OWNED BY public.reviews.review_id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    room_id integer NOT NULL,
    room_number character varying(20) NOT NULL,
    room_type character varying(50) NOT NULL,
    price numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'Available'::character varying,
    description text,
    average_rating numeric(3,2) DEFAULT 0.00
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- Name: rooms_import_test; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms_import_test (
    room_id integer,
    room_number character varying(20),
    room_type character varying(50),
    price numeric(10,2),
    status character varying(20),
    description text,
    average_rating numeric(3,2)
);


ALTER TABLE public.rooms_import_test OWNER TO postgres;

--
-- Name: rooms_room_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rooms_room_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rooms_room_id_seq OWNER TO postgres;

--
-- Name: rooms_room_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_room_id_seq OWNED BY public.rooms.room_id;


--
-- Name: user_order_summary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_order_summary (
    user_id integer NOT NULL,
    order_count integer DEFAULT 0,
    total_spent numeric(10,2) DEFAULT 0.00
);


ALTER TABLE public.user_order_summary OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    sex boolean,
    password character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    phone character(11),
    address text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: user_order_summary_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_order_summary_view AS
 SELECT u.user_id,
    u.username,
    count(o.order_id) AS order_count,
    COALESCE(sum(o.total_amount), (0)::numeric) AS total_spent
   FROM (public.users u
     LEFT JOIN public.orders o ON ((u.user_id = o.user_id)))
  GROUP BY u.user_id, u.username;


ALTER VIEW public.user_order_summary_view OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: audit_log log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN log_id SET DEFAULT nextval('public.audit_log_log_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: reservations reservation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations ALTER COLUMN reservation_id SET DEFAULT nextval('public.reservations_reservation_id_seq'::regclass);


--
-- Name: reviews review_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews ALTER COLUMN review_id SET DEFAULT nextval('public.reviews_review_id_seq'::regclass);


--
-- Name: rooms room_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN room_id SET DEFAULT nextval('public.rooms_room_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_log (log_id, user_id, action, table_name, "timestamp") FROM stdin;
1	2	INSERT ORDER	orders	2026-07-01 13:20:32.808
2	2	UPDATE ORDER	orders	2026-07-01 13:20:32.820184
3	1	INSERT ORDER	orders	2026-07-01 13:20:32.942696
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, user_id, order_status, total_amount, order_time) FROM stdin;
1	1	Completed	499.99	2026-07-01 13:20:17.878772
2	2	Pending	299.99	2026-07-01 13:20:17.878772
3	3	Pending	599.97	2026-07-01 13:20:17.878772
4	1	Pending	599.97	2026-07-01 13:20:23.692401
5	2	Completed	399.99	2026-07-01 13:20:32.808
6	1	Pending	599.97	2026-07-01 13:20:32.942696
\.


--
-- Data for Name: reservations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservations (reservation_id, user_id, room_id, check_in_time, check_out_time, reservation_status) FROM stdin;
2	2	102	2025-06-01 14:00:00	2025-06-05 12:00:00	Pending
3	3	103	2025-07-01 14:00:00	2025-07-03 12:00:00	Pending
4	1	101	2025-08-01 14:00:00	2025-08-05 12:00:00	Pending
5	2	103	2025-09-01 14:00:00	2025-09-03 12:00:00	Cancelled
6	1	103	2025-10-01 14:00:00	2025-10-04 12:00:00	Pending
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (review_id, order_id, user_id, room_id, content, rating) FROM stdin;
1	1	1	101	Great room!	5.00
2	2	2	102	Good service	4.00
3	3	3	103	Excellent experience	5.00
4	5	2	103	Nice suite	4.50
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (room_id, room_number, room_type, price, status, description, average_rating) FROM stdin;
102	A1803	Double	299.99	Booked	A double room	0.00
101	A1801	Single	199.99	Booked	A single room	0.00
103	A1804	Suite	499.99	Booked	A luxurious suite	4.75
\.


--
-- Data for Name: rooms_import_test; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms_import_test (room_id, room_number, room_type, price, status, description, average_rating) FROM stdin;
102	A1803	Double	299.99	Booked	A double room	0.00
101	A1801	Single	199.99	Booked	A single room	0.00
103	A1804	Suite	499.99	Booked	A luxurious suite	4.75
\.


--
-- Data for Name: user_order_summary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_order_summary (user_id, order_count, total_spent) FROM stdin;
1	2	1099.96
2	1	299.99
3	1	599.97
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, sex, password, email, phone, address) FROM stdin;
1	Name1	f	7c6a180b36896a0a8c02787eeafb0e4c	user1@example.com	13312678900	123 Main St
2	Name2	f	6f9dff5af05096ea9f23cc7bedd65683	User2@163.com	13312678905	西安市
3	Name3	t	874fcc6e14275dde5a23319c9ce5f8e4	User3@163.com	13312670043	北京市海淀区
\.


--
-- Name: audit_log_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_log_log_id_seq', 3, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 6, true);


--
-- Name: reservations_reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservations_reservation_id_seq', 6, true);


--
-- Name: reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reviews_review_id_seq', 4, true);


--
-- Name: rooms_room_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_room_id_seq', 103, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 3, true);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (log_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (reservation_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (room_id);


--
-- Name: user_order_summary user_order_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_order_summary
    ADD CONSTRAINT user_order_summary_pkey PRIMARY KEY (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_orders_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_user_id ON public.orders USING btree (user_id);


--
-- Name: idx_reservations_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_room_id ON public.reservations USING btree (room_id);


--
-- Name: idx_reservations_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservations_user_id ON public.reservations USING btree (user_id);


--
-- Name: idx_reviews_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reviews_order_id ON public.reviews USING btree (order_id);


--
-- Name: idx_reviews_room_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reviews_room_id ON public.reviews USING btree (room_id);


--
-- Name: idx_rooms_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_rooms_type ON public.rooms USING btree (room_type);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: orders audit_orders_delete; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER audit_orders_delete AFTER DELETE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.trg_audit_orders_delete();


--
-- Name: orders audit_orders_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER audit_orders_insert AFTER INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.trg_audit_orders_insert();


--
-- Name: orders audit_orders_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER audit_orders_update AFTER UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.trg_audit_orders_update();


--
-- Name: reviews update_room_average_rating; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_room_average_rating AFTER INSERT ON public.reviews FOR EACH ROW EXECUTE FUNCTION public.trg_update_room_average_rating();


--
-- Name: reservations update_room_status_on_cancel; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_room_status_on_cancel AFTER UPDATE ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.trg_update_room_status_on_cancel();


--
-- Name: reservations update_room_status_on_reservation; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_room_status_on_reservation AFTER INSERT ON public.reservations FOR EACH ROW EXECUTE FUNCTION public.trg_update_room_status_on_reservation();


--
-- Name: orders fk_orders_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reservations fk_reservations_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservations_room FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reservations fk_reservations_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservations
    ADD CONSTRAINT fk_reservations_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reviews fk_reviews_order; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_reviews_order FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reviews fk_reviews_room; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_reviews_room FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reviews fk_reviews_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO hotel_admin;
GRANT USAGE ON SCHEMA public TO hotel_user;
GRANT USAGE ON SCHEMA public TO hotel_readonly;


--
-- Name: TABLE audit_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.audit_log TO hotel_admin;
GRANT SELECT ON TABLE public.audit_log TO hotel_readonly;


--
-- Name: SEQUENCE audit_log_log_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.audit_log_log_id_seq TO hotel_admin;
GRANT SELECT,USAGE ON SEQUENCE public.audit_log_log_id_seq TO hotel_user;


--
-- Name: TABLE orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.orders TO hotel_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.orders TO hotel_user;
GRANT SELECT ON TABLE public.orders TO hotel_readonly;


--
-- Name: SEQUENCE orders_order_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.orders_order_id_seq TO hotel_admin;
GRANT SELECT,USAGE ON SEQUENCE public.orders_order_id_seq TO hotel_user;


--
-- Name: TABLE reservations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.reservations TO hotel_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reservations TO hotel_user;
GRANT SELECT ON TABLE public.reservations TO hotel_readonly;


--
-- Name: SEQUENCE reservations_reservation_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.reservations_reservation_id_seq TO hotel_admin;
GRANT SELECT,USAGE ON SEQUENCE public.reservations_reservation_id_seq TO hotel_user;


--
-- Name: TABLE reviews; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.reviews TO hotel_admin;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.reviews TO hotel_user;
GRANT SELECT ON TABLE public.reviews TO hotel_readonly;


--
-- Name: SEQUENCE reviews_review_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.reviews_review_id_seq TO hotel_admin;
GRANT SELECT,USAGE ON SEQUENCE public.reviews_review_id_seq TO hotel_user;


--
-- Name: TABLE rooms; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.rooms TO hotel_admin;
GRANT SELECT ON TABLE public.rooms TO hotel_user;
GRANT SELECT ON TABLE public.rooms TO hotel_readonly;


--
-- Name: SEQUENCE rooms_room_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.rooms_room_id_seq TO hotel_admin;
GRANT SELECT,USAGE ON SEQUENCE public.rooms_room_id_seq TO hotel_user;


--
-- Name: TABLE user_order_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_order_summary TO hotel_admin;
GRANT SELECT ON TABLE public.user_order_summary TO hotel_readonly;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO hotel_admin;
GRANT SELECT ON TABLE public.users TO hotel_user;
GRANT SELECT ON TABLE public.users TO hotel_readonly;


--
-- Name: TABLE user_order_summary_view; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_order_summary_view TO hotel_admin;
GRANT SELECT ON TABLE public.user_order_summary_view TO hotel_readonly;


--
-- Name: SEQUENCE users_user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.users_user_id_seq TO hotel_admin;
GRANT SELECT,USAGE ON SEQUENCE public.users_user_id_seq TO hotel_user;


--
-- PostgreSQL database dump complete
--

\unrestrict VaMdf3XKzeud5cUZKLhtUQgJ6plH0feEQwmlcOZEDBvrAG16sdrb7mzA01Glvq8

