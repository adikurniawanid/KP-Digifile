--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)

-- Started on 2021-01-17 23:41:49 WIB

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 17126)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 232 (class 1255 OID 17044)
-- Name: add_file(character varying, character varying, double precision, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_file(_file_name character varying, _directory character varying, _size double precision, _owner character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO files 
(file_name, directory, size, owner, trash_status)
VALUES
(_file_name, _directory, _size, _owner, false);
END
$$;


ALTER FUNCTION public.add_file(_file_name character varying, _directory character varying, _size double precision, _owner character varying) OWNER TO akdev;

--
-- TOC entry 237 (class 1255 OID 17002)
-- Name: add_user(character varying, character varying, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_user(_username character varying, _name character varying, _password character varying, _phone character varying, _email character varying, _space integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO users 
(username, name, password, phone, email, space, used_space, role_id, status)
VALUES
(_username, _name, (select digest(_password,'sha256')), _phone, _email, _space, 0, 2, 0);
END
$$;


ALTER FUNCTION public.add_user(_username character varying, _name character varying, _password character varying, _phone character varying, _email character varying, _space integer) OWNER TO akdev;

--
-- TOC entry 231 (class 1255 OID 17033)
-- Name: add_user_space(character varying, integer); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_user_space(_username character varying, _space integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE users SET space = space + _space
WHERE username = _username;
END
$$;


ALTER FUNCTION public.add_user_space(_username character varying, _space integer) OWNER TO akdev;

--
-- TOC entry 218 (class 1255 OID 17007)
-- Name: delete_file(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.delete_file(_file_id integer, _username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE files SET trash_status = true
WHERE file_id = _file_id AND owner = _username;
END
$$;


ALTER FUNCTION public.delete_file(_file_id integer, _username character varying) OWNER TO akdev;

--
-- TOC entry 236 (class 1255 OID 17083)
-- Name: delete_trash(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.delete_trash(_file_id integer, _owner character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
DELETE FROM files 
WHERE trash_status = true AND file_id = _file_id  AND   owner =_owner ;
END
$$;


ALTER FUNCTION public.delete_trash(_file_id integer, _owner character varying) OWNER TO akdev;

--
-- TOC entry 233 (class 1255 OID 17046)
-- Name: get_activity_detail(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_activity_detail(_username character varying) RETURNS TABLE(activity_date date, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        log_activity.activity_date,
        detail_activity.description
    FROM
        log_activity
    INNER JOIN
        	detail_activity ON log_activity.log_id = detail_activity.activity_id
    WHERE
        log_activity.username like _username;
END; $$;


ALTER FUNCTION public.get_activity_detail(_username character varying) OWNER TO akdev;

--
-- TOC entry 239 (class 1255 OID 17091)
-- Name: get_file_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_file_list(in_username character varying) RETURNS TABLE(file_name character varying, size double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        files.file_name, files.size
    FROM
        files
    WHERE
        files.owner like in_username AND trash_status = false;
END;
$$;


ALTER FUNCTION public.get_file_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 273 (class 1255 OID 17184)
-- Name: get_information_storage(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_information_storage(in_username character varying) RETURNS TABLE(used_space double precision, space integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
     RETURN QUERY SELECT
        users.used_space, users.space
    FROM
        users
     WHERE users.username = in_username;
END
$$;


ALTER FUNCTION public.get_information_storage(in_username character varying) OWNER TO akdev;

--
-- TOC entry 240 (class 1255 OID 17092)
-- Name: get_trash_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_trash_list(in_username character varying) RETURNS TABLE(file_name character varying, size double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        files.file_name, files.size
    FROM
        files
    WHERE
        files.owner like in_username AND files.trash_status = true;
END;
$$;


ALTER FUNCTION public.get_trash_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 234 (class 1255 OID 17079)
-- Name: is_admin(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.is_admin(in_username character varying) RETURNS TABLE(username character varying, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        users.username,
        roles.description
    FROM
        users
    INNER JOIN
        	roles ON roles.role_id = users.role_id
    WHERE
        users.username like in_username AND users.role_id = 1;
END; $$;


ALTER FUNCTION public.is_admin(in_username character varying) OWNER TO akdev;

--
-- TOC entry 238 (class 1255 OID 17082)
-- Name: is_user(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.is_user(in_username character varying) RETURNS TABLE(username character varying, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        users.username,
        roles.description
    FROM
        users
    INNER JOIN
        	roles ON roles.role_id = users.role_id
    WHERE
        users.username like in_username AND users.role_id = 2;
END;
$$;


ALTER FUNCTION public.is_user(in_username character varying) OWNER TO akdev;

--
-- TOC entry 235 (class 1255 OID 17080)
-- Name: is_username_exist(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.is_username_exist(in_username character varying) RETURNS TABLE(username character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        users.username
    FROM
        users
    WHERE
        users.username like in_username;
END; $$;


ALTER FUNCTION public.is_username_exist(in_username character varying) OWNER TO akdev;

--
-- TOC entry 217 (class 1255 OID 17005)
-- Name: recovery_trash(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.recovery_trash(_file_id integer, _username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE files SET trash_status = false
WHERE file_id = _file_id AND owner = _username;
END
$$;


ALTER FUNCTION public.recovery_trash(_file_id integer, _username character varying) OWNER TO akdev;

--
-- TOC entry 224 (class 1255 OID 16951)
-- Name: rename_file(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.rename_file(id integer, new_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE files SET file_name = new_name
WHERE file_id = id;
END
$$;


ALTER FUNCTION public.rename_file(id integer, new_name character varying) OWNER TO akdev;

--
-- TOC entry 272 (class 1255 OID 17183)
-- Name: rename_folder(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.rename_folder(id integer, new_directory character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE files SET directory = new_directory
WHERE file_id = id;
END
$$;


ALTER FUNCTION public.rename_folder(id integer, new_directory character varying) OWNER TO akdev;

--
-- TOC entry 274 (class 1255 OID 17185)
-- Name: search(character varying, integer, date, date); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.search(in_name character varying, in_activity_id integer, in_start_date date, in_end_date date) RETURNS TABLE(name character varying, last_activity_date date, last_activity character varying, used_space double precision, space integer, status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.username as Nama,
        la.activity_date as Last_Activity_Date,
        da.description as Last_Activity,
        u.space as Space,
        u.used_space as Used_Space,
        sl.description as Status
    FROM
        users u
    LEFT JOIN log_activity la on u.username = la.username
    LEFT JOIN detail_activity da on da.activity_id = la.activity_id
    LEFT JOIN status_login sl on u.status = sl.status_id
    WHERE
    u.username = in_name
    AND la.activity_id = in_activity_id
    AND la.activity_date >= in_start_date
    AND la.activity_date <= in_end_date;

END;
$$;


ALTER FUNCTION public.search(in_name character varying, in_activity_id integer, in_start_date date, in_end_date date) OWNER TO akdev;

--
-- TOC entry 242 (class 1255 OID 17103)
-- Name: set_offline(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.set_offline(_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE users SET status = 2
WHERE username = _username;
END
$$;


ALTER FUNCTION public.set_offline(_username character varying) OWNER TO akdev;

--
-- TOC entry 241 (class 1255 OID 17102)
-- Name: set_online(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.set_online(_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE users SET status = 1
WHERE username = _username;
END
$$;


ALTER FUNCTION public.set_online(_username character varying) OWNER TO akdev;

--
-- TOC entry 271 (class 1255 OID 17175)
-- Name: verify_login(character varying, bytea); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.verify_login(in_username character varying, in_password bytea) RETURNS TABLE(username character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        users.username
    FROM
        users
    WHERE
        users.username like in_username AND password like (select digest(in_password,'sha256'));
END;
$$;


ALTER FUNCTION public.verify_login(in_username character varying, in_password bytea) OWNER TO akdev;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 202 (class 1259 OID 16887)
-- Name: detail_activity; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_activity (
    activity_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.detail_activity OWNER TO akdev;

--
-- TOC entry 204 (class 1259 OID 16965)
-- Name: files; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.files (
    file_id integer NOT NULL,
    file_name character varying NOT NULL,
    directory character varying NOT NULL,
    size double precision NOT NULL,
    trash_status boolean NOT NULL,
    owner character varying NOT NULL
);


ALTER TABLE public.files OWNER TO akdev;

--
-- TOC entry 203 (class 1259 OID 16963)
-- Name: files_file_id_seq; Type: SEQUENCE; Schema: public; Owner: akdev
--

ALTER TABLE public.files ALTER COLUMN file_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.files_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999
    CACHE 1
);


--
-- TOC entry 206 (class 1259 OID 16975)
-- Name: log_activity; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.log_activity (
    log_id integer NOT NULL,
    username character varying NOT NULL,
    file_id integer NOT NULL,
    activity_id integer NOT NULL,
    activity_date date NOT NULL
);


ALTER TABLE public.log_activity OWNER TO akdev;

--
-- TOC entry 205 (class 1259 OID 16973)
-- Name: log_activity_log_id_seq; Type: SEQUENCE; Schema: public; Owner: akdev
--

ALTER TABLE public.log_activity ALTER COLUMN log_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.log_activity_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999
    CACHE 1
);


--
-- TOC entry 207 (class 1259 OID 17009)
-- Name: roles; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.roles (
    role_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.roles OWNER TO akdev;

--
-- TOC entry 208 (class 1259 OID 17093)
-- Name: status_login; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.status_login (
    status_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.status_login OWNER TO akdev;

--
-- TOC entry 201 (class 1259 OID 16874)
-- Name: users; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.users (
    username character varying(18) NOT NULL,
    name character varying(55) NOT NULL,
    password bytea NOT NULL,
    phone character varying(15) NOT NULL,
    email character varying(30) NOT NULL,
    space integer,
    used_space double precision,
    role_id integer,
    status integer
);


ALTER TABLE public.users OWNER TO akdev;

--
-- TOC entry 3057 (class 0 OID 16887)
-- Dependencies: 202
-- Data for Name: detail_activity; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_activity (activity_id, description) FROM stdin;
1	Create Folder
2	Upload Folder
3	Rename Folder
4	Delete Folder
5	Recovery Folder
6	Upload File
7	Delete File
8	Rename File
9	Recovery File
\.


--
-- TOC entry 3059 (class 0 OID 16965)
-- Dependencies: 204
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.files (file_id, file_name, directory, size, trash_status, owner) FROM stdin;
2	pas poto ktp	/etc/a	1500	f	akdev
3	poto adi	/home/akdev	0.5	f	akdev
1	krs	/etc/home	2.5	t	akdev
\.


--
-- TOC entry 3061 (class 0 OID 16975)
-- Dependencies: 206
-- Data for Name: log_activity; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.log_activity (log_id, username, file_id, activity_id, activity_date) FROM stdin;
\.


--
-- TOC entry 3062 (class 0 OID 17009)
-- Dependencies: 207
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.roles (role_id, description) FROM stdin;
1	admin
2	user
\.


--
-- TOC entry 3063 (class 0 OID 17093)
-- Dependencies: 208
-- Data for Name: status_login; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.status_login (status_id, description) FROM stdin;
1	aktif
0	nonaktif
\.


--
-- TOC entry 3056 (class 0 OID 16874)
-- Dependencies: 201
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.users (username, name, password, phone, email, space, used_space, role_id, status) FROM stdin;
snk	Sinka Juliani	\\x36e8072cf8b4a6b59338f43d3dfab4d99207e670c04bcfc4e0b2fa20518d061a	082182751010	sinka@gmail.com	5	0	2	0
akdev	Adi Kurniawan	\\x1e0eb17eda954e512249390012f077a6549fbe2d72c99831dbdc450ed0d0e1f2	082182751010	adikurniawan.dev@gmail.com	\N	\N	1	0
rsf	Roni Starko Firdaus	\\xb8dde45084eca2f60dfff1647f525b1a9e91a20b2dc15bd9ab002f2d78247a69	0895621854457	rsf.project@gmail.com	5	0	2	0
feals	Febyk Alek Satria	\\xf700e1b565c592e99c6040abc7e9f62a19549e066d85a8dfab62c5641d1c92c1	081373107544	febykaleksatria@gmail.com	5	0	2	0
\.


--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 203
-- Name: files_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.files_file_id_seq', 3, true);


--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 205
-- Name: log_activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.log_activity_log_id_seq', 3, true);


--
-- TOC entry 2911 (class 2606 OID 16894)
-- Name: detail_activity detail_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_activity
    ADD CONSTRAINT detail_activity_pkey PRIMARY KEY (activity_id);


--
-- TOC entry 2919 (class 2606 OID 17101)
-- Name: status_login detail_status_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.status_login
    ADD CONSTRAINT detail_status_pk PRIMARY KEY (status_id);


--
-- TOC entry 2913 (class 2606 OID 16972)
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (file_id);


--
-- TOC entry 2915 (class 2606 OID 16982)
-- Name: log_activity log_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity
    ADD CONSTRAINT log_activity_pkey PRIMARY KEY (log_id);


--
-- TOC entry 2917 (class 2606 OID 17016)
-- Name: roles role_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- TOC entry 2909 (class 2606 OID 16881)
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (username);


--
-- TOC entry 2920 (class 1259 OID 17099)
-- Name: detail_status_status_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_status_status_id_uindex ON public.status_login USING btree (status_id);


--
-- TOC entry 2923 (class 2606 OID 16983)
-- Name: log_activity fk_activity_id; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity
    ADD CONSTRAINT fk_activity_id FOREIGN KEY (activity_id) REFERENCES public.detail_activity(activity_id);


--
-- TOC entry 2924 (class 2606 OID 16988)
-- Name: log_activity fk_file_id; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity
    ADD CONSTRAINT fk_file_id FOREIGN KEY (file_id) REFERENCES public.files(file_id);


--
-- TOC entry 2921 (class 2606 OID 17017)
-- Name: users fk_level; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_level FOREIGN KEY (role_id) REFERENCES public.roles(role_id) NOT VALID;


--
-- TOC entry 2922 (class 2606 OID 17105)
-- Name: users fk_status; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_status FOREIGN KEY (status) REFERENCES public.status_login(status_id);


--
-- TOC entry 2925 (class 2606 OID 16993)
-- Name: log_activity fk_username; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity
    ADD CONSTRAINT fk_username FOREIGN KEY (username) REFERENCES public.users(username);


-- Completed on 2021-01-17 23:41:49 WIB

--
-- PostgreSQL database dump complete
--

