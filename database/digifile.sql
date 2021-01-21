--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)

-- Started on 2021-01-21 11:28:17 WIB

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
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 274 (class 1255 OID 17192)
-- Name: add_file(character varying, character varying, double precision, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_file(_file_name character varying, _directory character varying, _size double precision, _owner character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO files 
(file_name, directory, size, owner, trash_status)
VALUES
(_file_name, _directory, _size, _owner, false);
IF FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

END
$$;


ALTER FUNCTION public.add_file(_file_name character varying, _directory character varying, _size double precision, _owner character varying) OWNER TO akdev;

--
-- TOC entry 273 (class 1255 OID 17191)
-- Name: add_user(character varying, character varying, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_user(_username character varying, _name character varying, _password character varying, _phone character varying, _email character varying, _space integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO users 
(username, name, password, phone, email, space, used_space, role_id, status)
VALUES
(_username, _name, (select digest(_password,'sha256')), _phone, _email, _space, 0, 2, 0);

IF FOUND THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END
$$;


ALTER FUNCTION public.add_user(_username character varying, _name character varying, _password character varying, _phone character varying, _email character varying, _space integer) OWNER TO akdev;

--
-- TOC entry 233 (class 1255 OID 17033)
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
-- TOC entry 220 (class 1255 OID 17007)
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
-- TOC entry 235 (class 1255 OID 17083)
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
-- TOC entry 279 (class 1255 OID 25393)
-- Name: get_activity_detail(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_activity_detail(_username character varying) RETURNS TABLE(activity_date date, description character varying, file_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        log_activity.activity_date,
        detail_activity.description,
        log_activity.file_name
    FROM
        log_activity
    INNER JOIN
        	detail_activity ON log_activity.activity_id = detail_activity.activity_id
    WHERE
        log_activity.username like _username;
END;
$$;


ALTER FUNCTION public.get_activity_detail(_username character varying) OWNER TO akdev;

--
-- TOC entry 271 (class 1255 OID 17187)
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
        files.owner like in_username AND trash_status = false
    ORDER BY file_name ASC;
END;
$$;


ALTER FUNCTION public.get_file_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 270 (class 1255 OID 17184)
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
-- TOC entry 282 (class 1255 OID 25442)
-- Name: get_name(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_name(_username character varying) RETURNS TABLE(name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY EXECUTE (SELECT users.name::varchar FROM users WHERE users.username = _username);
END;
$$;


ALTER FUNCTION public.get_name(_username character varying) OWNER TO akdev;

--
-- TOC entry 237 (class 1255 OID 17092)
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
-- TOC entry 275 (class 1255 OID 17194)
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
END;
$$;


ALTER FUNCTION public.is_admin(in_username character varying) OWNER TO akdev;

--
-- TOC entry 272 (class 1255 OID 17188)
-- Name: is_enough_space(integer, double precision, double precision); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.is_enough_space(in_space integer, in_used_space double precision, in_size double precision) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (in_space - in_used_space > in_size)
        THEN RETURN TRUE;
        ELSE RETURN FALSE;
    END IF;
END
$$;


ALTER FUNCTION public.is_enough_space(in_space integer, in_used_space double precision, in_size double precision) OWNER TO akdev;

--
-- TOC entry 236 (class 1255 OID 17082)
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
-- TOC entry 234 (class 1255 OID 17080)
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
-- TOC entry 276 (class 1255 OID 25381)
-- Name: log_delete_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_delete_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF NEW.trash_status = TRUE THEN
 	INSERT INTO log_activity
 	(file_id, username, activity_id, activity_date, file_name)
 	VALUES
 	(OLD.file_id, OLD.owner, 7, now(), OLD.file_name);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_delete_file() OWNER TO akdev;

--
-- TOC entry 278 (class 1255 OID 25385)
-- Name: log_recovery_trash(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_recovery_trash() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF NEW.trash_status = FALSE THEN
 	INSERT INTO log_activity
 	(file_id, username, activity_id, activity_date, file_name)
 	VALUES
 	(OLD.file_id, OLD.owner, 9, now(), OLD.file_name);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_recovery_trash() OWNER TO akdev;

--
-- TOC entry 277 (class 1255 OID 25378)
-- Name: log_rename_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_rename_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF NEW.file_name <> OLD.file_name THEN
 	INSERT INTO log_activity
 	(file_id, username, activity_id, activity_date, file_name)
 	VALUES
 	(OLD.file_id, OLD.owner, 8, now(), OLD.file_name);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_rename_file() OWNER TO akdev;

--
-- TOC entry 280 (class 1255 OID 25387)
-- Name: log_upload_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_upload_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	INSERT INTO log_activity
 	(file_id, username, activity_id, activity_date, file_name)
 	VALUES
 	(NEW.file_id, NEW.owner, 6, now(), NEW.file_name);

--     UPDATE users set users.used_space = (users.used_space + NEW.size) where users.username = username;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_upload_file() OWNER TO akdev;

--
-- TOC entry 219 (class 1255 OID 17005)
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
-- TOC entry 226 (class 1255 OID 16951)
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
-- TOC entry 269 (class 1255 OID 17183)
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
-- TOC entry 283 (class 1255 OID 25443)
-- Name: search(character varying, integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.search(in_name character varying, in_activity_id integer, in_start_date timestamp without time zone, in_end_date timestamp without time zone) RETURNS TABLE(name character varying, last_activity_date date, last_activity character varying, used_space double precision, space integer, status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT u.name                                             AS nama,
       to_char(t2.activity_date, 'day, DD-MM-YYYY'::date) AS to_char,
       da.description                                     AS last_activity,
       concat(u.used_space, '/', u.space)                 AS kuota,
       sl.description                                     AS status
FROM log_activity la
         JOIN (SELECT log_activity.username,
                      max(log_activity.activity_date) AS activity_date
               FROM log_activity
               GROUP BY log_activity.username) t2
              ON la.username::text = t2.username::text AND la.activity_date = t2.activity_date
         JOIN users u ON u.username::text = la.username::text
         JOIN detail_activity da ON da.activity_id = la.activity_id
         JOIN status_login sl ON u.status_id = sl.status_id
    WHERE u.name = in_name AND
          da.activity_id = in_activity_id AND
          t2.activity_date >= in_start_date AND
          t2.activity_date <= in_end_date
    ;
END;
$$;


ALTER FUNCTION public.search(in_name character varying, in_activity_id integer, in_start_date timestamp without time zone, in_end_date timestamp without time zone) OWNER TO akdev;

--
-- TOC entry 239 (class 1255 OID 17103)
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
-- TOC entry 238 (class 1255 OID 17102)
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
-- TOC entry 281 (class 1255 OID 25447)
-- Name: tambah_used_space(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.tambah_used_space() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE users set "used_space" = (users.used_space + NEW.size) where users.username = OLD.owner;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.tambah_used_space() OWNER TO akdev;

--
-- TOC entry 268 (class 1255 OID 17175)
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
-- TOC entry 206 (class 1259 OID 17093)
-- Name: detail_status; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_status (
    status_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.detail_status OWNER TO akdev;

--
-- TOC entry 210 (class 1259 OID 25457)
-- Name: detail_trash; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_trash (
    trash_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.detail_trash OWNER TO akdev;

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
-- TOC entry 208 (class 1259 OID 17225)
-- Name: log_activity; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.log_activity (
    log_id integer NOT NULL,
    file_id integer,
    username character varying,
    activity_id integer,
    file_name character varying,
    activity_date timestamp without time zone
);


ALTER TABLE public.log_activity OWNER TO akdev;

--
-- TOC entry 207 (class 1259 OID 17223)
-- Name: log_activity_log_id_seq; Type: SEQUENCE; Schema: public; Owner: akdev
--

CREATE SEQUENCE public.log_activity_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_activity_log_id_seq OWNER TO akdev;

--
-- TOC entry 3099 (class 0 OID 0)
-- Dependencies: 207
-- Name: log_activity_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: akdev
--

ALTER SEQUENCE public.log_activity_log_id_seq OWNED BY public.log_activity.log_id;


--
-- TOC entry 205 (class 1259 OID 17009)
-- Name: roles; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.roles (
    role_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.roles OWNER TO akdev;

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
    role_id integer NOT NULL,
    status_id integer NOT NULL
);


ALTER TABLE public.users OWNER TO akdev;

--
-- TOC entry 209 (class 1259 OID 25451)
-- Name: view_log_activity; Type: VIEW; Schema: public; Owner: akdev
--

CREATE VIEW public.view_log_activity AS
 SELECT u.name AS nama,
    to_char(t2.activity_date, 'day, DD-MM-YYYY'::text) AS activity_date,
    da.description AS last_activity,
    concat(u.used_space, '/', u.space) AS kuota,
    sl.description AS status
   FROM ((((public.log_activity la
     JOIN ( SELECT log_activity.username,
            max(log_activity.activity_date) AS activity_date
           FROM public.log_activity
          GROUP BY log_activity.username) t2 ON ((((la.username)::text = (t2.username)::text) AND (la.activity_date = t2.activity_date))))
     JOIN public.users u ON (((u.username)::text = (la.username)::text)))
     JOIN public.detail_activity da ON ((da.activity_id = la.activity_id)))
     JOIN public.detail_status sl ON ((u.status_id = sl.status_id)));


ALTER TABLE public.view_log_activity OWNER TO akdev;

--
-- TOC entry 2924 (class 2604 OID 17228)
-- Name: log_activity log_id; Type: DEFAULT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity ALTER COLUMN log_id SET DEFAULT nextval('public.log_activity_log_id_seq'::regclass);


--
-- TOC entry 3085 (class 0 OID 16887)
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
-- TOC entry 3089 (class 0 OID 17093)
-- Dependencies: 206
-- Data for Name: detail_status; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_status (status_id, description) FROM stdin;
0	nonaktif
1	aktif
\.


--
-- TOC entry 3092 (class 0 OID 25457)
-- Dependencies: 210
-- Data for Name: detail_trash; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_trash (trash_id, description) FROM stdin;
0	nontrash
1	trash
\.


--
-- TOC entry 3087 (class 0 OID 16965)
-- Dependencies: 204
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.files (file_id, file_name, directory, size, trash_status, owner) FROM stdin;
3	poto adi	/home/akdev	0.5	f	akdev
4	potokopi java	a/b/c	6	f	akdev
5	potokopi java	a/b/c	6	f	akdev
7	poto aku	rsf/gege	5	f	rsf
8	poto aku	rsf/gege	5	f	rsf
10	poto aku	rsf/gege	5	f	rsf
11	poto aku lagi	rsf/gege	5	f	rsf
13	ea	eaea	5	f	feals
14	woi	eaea	5	f	akdev
15	hgg	eaea	5	f	rsf
12	ea	eaea	5	t	feals
1	krs	/etc/home	2.5	f	akdev
2	pas poto ktp	/etc/a	1500	f	akdev
17	hgg	eaea	5	f	rsf
19	hgg	eaea	5	f	rsf
25	hgg	eaea	5	f	rsf
26	hgg	eaea	5	f	feals
27	hgg	eaea	5	f	feals
29	hgg	eaea	5	f	feals
\.


--
-- TOC entry 3091 (class 0 OID 17225)
-- Dependencies: 208
-- Data for Name: log_activity; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.log_activity (log_id, file_id, username, activity_id, file_name, activity_date) FROM stdin;
19	15	rsf	6	hgg	2021-01-20 14:08:41.132244
20	12	feals	9	ea	2021-01-20 14:29:35.307428
21	12	feals	9	ea	2021-01-20 14:30:51.450341
22	12	feals	7	ea	2021-01-20 14:32:14.846087
27	17	rsf	6	hgg	2021-01-21 03:39:11.867521
28	19	rsf	6	hgg	2021-01-21 03:44:08.688025
31	25	rsf	6	hgg	2021-01-21 03:57:24.680386
32	26	feals	6	hgg	2021-01-21 03:59:20.872833
33	27	feals	6	hgg	2021-01-21 04:00:00.729751
34	29	feals	6	hgg	2021-01-21 04:03:03.820507
\.


--
-- TOC entry 3088 (class 0 OID 17009)
-- Dependencies: 205
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.roles (role_id, description) FROM stdin;
1	admin
2	user
\.


--
-- TOC entry 3084 (class 0 OID 16874)
-- Dependencies: 201
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.users (username, name, password, phone, email, space, used_space, role_id, status_id) FROM stdin;
akdev	Adi Kurniawan	\\x1e0eb17eda954e512249390012f077a6549fbe2d72c99831dbdc450ed0d0e1f2	082182751010	adikurniawan.dev@gmail.com	\N	\N	1	0
snk	Sinka Juliani	\\x36e8072cf8b4a6b59338f43d3dfab4d99207e670c04bcfc4e0b2fa20518d061a	082182751010	sinka@gmail.com	5	0	2	0
feals	Febyk Alek Satria	\\xf700e1b565c592e99c6040abc7e9f62a19549e066d85a8dfab62c5641d1c92c1	081373107544	febykaleksatria@gmail.com	5	0	2	0
kalala	Nabila Fitriana	\\x893e1fe44c1ee84fde4f5a73e0dcf199437d6652b747e3ca86f473999170cc44	09090909	kalala@gmail.com	5	0	2	0
rsf	Roni Starko Firdaus	\\xb8dde45084eca2f60dfff1647f525b1a9e91a20b2dc15bd9ab002f2d78247a69	0895621854457	rsf.project@gmail.com	5	0	2	0
\.


--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 203
-- Name: files_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.files_file_id_seq', 29, true);


--
-- TOC entry 3101 (class 0 OID 0)
-- Dependencies: 207
-- Name: log_activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.log_activity_log_id_seq', 34, true);


--
-- TOC entry 2928 (class 2606 OID 16894)
-- Name: detail_activity detail_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_activity
    ADD CONSTRAINT detail_activity_pkey PRIMARY KEY (activity_id);


--
-- TOC entry 2934 (class 2606 OID 17101)
-- Name: detail_status detail_status_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_status
    ADD CONSTRAINT detail_status_pk PRIMARY KEY (status_id);


--
-- TOC entry 2930 (class 2606 OID 16972)
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (file_id);


--
-- TOC entry 2938 (class 2606 OID 17234)
-- Name: log_activity log_activity_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity
    ADD CONSTRAINT log_activity_pk PRIMARY KEY (log_id);


--
-- TOC entry 2932 (class 2606 OID 17016)
-- Name: roles role_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- TOC entry 2940 (class 2606 OID 25465)
-- Name: detail_trash status_trash_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_trash
    ADD CONSTRAINT status_trash_pk PRIMARY KEY (trash_id);


--
-- TOC entry 2926 (class 2606 OID 16881)
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (username);


--
-- TOC entry 2935 (class 1259 OID 17099)
-- Name: detail_status_status_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_status_status_id_uindex ON public.detail_status USING btree (status_id);


--
-- TOC entry 2936 (class 1259 OID 17232)
-- Name: log_activity_log_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX log_activity_log_id_uindex ON public.log_activity USING btree (log_id);


--
-- TOC entry 2941 (class 1259 OID 25463)
-- Name: status_trash_trash_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX status_trash_trash_id_uindex ON public.detail_trash USING btree (trash_id);


--
-- TOC entry 2949 (class 2620 OID 25382)
-- Name: files delete_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER delete_file BEFORE UPDATE ON public.files FOR EACH ROW EXECUTE FUNCTION public.log_delete_file();


--
-- TOC entry 2950 (class 2620 OID 25386)
-- Name: files recovery_trash; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER recovery_trash BEFORE UPDATE ON public.files FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash();


--
-- TOC entry 2948 (class 2620 OID 25380)
-- Name: files rename_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER rename_file BEFORE UPDATE ON public.files FOR EACH ROW EXECUTE FUNCTION public.log_rename_file();


--
-- TOC entry 2952 (class 2620 OID 25448)
-- Name: files tambah_used_space; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER tambah_used_space AFTER INSERT ON public.files FOR EACH ROW EXECUTE FUNCTION public.tambah_used_space();


--
-- TOC entry 2951 (class 2620 OID 25388)
-- Name: files upload_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER upload_file AFTER INSERT ON public.files FOR EACH ROW EXECUTE FUNCTION public.log_upload_file();


--
-- TOC entry 2946 (class 2606 OID 17240)
-- Name: log_activity fk_detail_activity; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity
    ADD CONSTRAINT fk_detail_activity FOREIGN KEY (activity_id) REFERENCES public.detail_activity(activity_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2947 (class 2606 OID 17250)
-- Name: log_activity fk_file_id; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity
    ADD CONSTRAINT fk_file_id FOREIGN KEY (file_id) REFERENCES public.files(file_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2944 (class 2606 OID 17245)
-- Name: files fk_owner; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT fk_owner FOREIGN KEY (owner) REFERENCES public.users(username) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2942 (class 2606 OID 17198)
-- Name: users fk_role; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2943 (class 2606 OID 17203)
-- Name: users fk_status; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES public.detail_status(status_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2945 (class 2606 OID 17235)
-- Name: log_activity fk_username; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.log_activity
    ADD CONSTRAINT fk_username FOREIGN KEY (username) REFERENCES public.users(username) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


-- Completed on 2021-01-21 11:28:17 WIB

--
-- PostgreSQL database dump complete
--

