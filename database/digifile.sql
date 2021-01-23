--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)

-- Started on 2021-01-23 21:57:54 WIB

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
-- TOC entry 3 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 246 (class 1255 OID 25737)
-- Name: add_file(character varying, character varying, numeric, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_file(in_file_name character varying, in_directory character varying, in_size numeric, in_owner character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO items
(item_name, directory, size, owner, trash_status, type_id)
VALUES
(in_file_name, in_directory, in_size, in_owner, 0, 1);
-- IF FOUND THEN
--       RETURN TRUE;
--     ELSE
--       RETURN FALSE;
--     END IF;

END;
$$;


ALTER FUNCTION public.add_file(in_file_name character varying, in_directory character varying, in_size numeric, in_owner character varying) OWNER TO akdev;

--
-- TOC entry 244 (class 1255 OID 25735)
-- Name: add_folder(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_folder(in_folder_name character varying, in_directory character varying, in_owner character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO items
(item_name, directory, owner, trash_status, type_id)
VALUES
(in_folder_name, in_directory, in_owner, 0, 2);
-- IF FOUND THEN
--       RETURN TRUE;
--     ELSE
--       RETURN FALSE;
--     END IF;

END;
$$;


ALTER FUNCTION public.add_folder(in_folder_name character varying, in_directory character varying, in_owner character varying) OWNER TO akdev;

--
-- TOC entry 253 (class 1255 OID 25762)
-- Name: add_used_space(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_used_space() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.type_id = 1 THEN
        UPDATE users SET used_space = used_space + NEW.size
        WHERE username = NEW.owner;
    end if;

 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.add_used_space() OWNER TO akdev;

--
-- TOC entry 237 (class 1255 OID 25720)
-- Name: add_user(character varying, character varying, character varying, character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_user(in_username character varying, in_name character varying, in_password character varying, in_phone character varying, in_email character varying, in_space integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
INSERT INTO users 
(username, name, password, phone, email, space, used_space, role_id, status_id)
VALUES
(in_username, in_name, in_password, in_phone, in_email, (in_space * 1000000000), 0, 2, 0);

IF FOUND THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END
$$;


ALTER FUNCTION public.add_user(in_username character varying, in_name character varying, in_password character varying, in_phone character varying, in_email character varying, in_space integer) OWNER TO akdev;

--
-- TOC entry 251 (class 1255 OID 25749)
-- Name: delete_file(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.delete_file(in_file_id integer, in_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE items SET trash_status = 1
WHERE item_id = in_file_id AND owner = in_username;
END
$$;


ALTER FUNCTION public.delete_file(in_file_id integer, in_username character varying) OWNER TO akdev;

--
-- TOC entry 248 (class 1255 OID 25743)
-- Name: delete_folder(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.delete_folder(in_directory character varying, in_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE items SET trash_status = 1
WHERE directory like '/' || in_directory || '%'
  AND owner = in_username;
END
$$;


ALTER FUNCTION public.delete_folder(in_directory character varying, in_username character varying) OWNER TO akdev;

--
-- TOC entry 238 (class 1255 OID 25765)
-- Name: delete_trash(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.delete_trash(in_item_id integer, in_owner character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
DELETE FROM items
WHERE trash_status = 1 AND item_id = in_item_id  AND   owner = in_owner ;
END
$$;


ALTER FUNCTION public.delete_trash(in_item_id integer, in_owner character varying) OWNER TO akdev;

--
-- TOC entry 240 (class 1255 OID 25721)
-- Name: edit_user(character varying, character varying, numeric, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.edit_user(in_username character varying, in_name character varying, in_space numeric, in_email character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE users SET name = in_name,
                 space = (in_space * 1000000000),
                 email = in_email
WHERE username = in_username;
END
$$;


ALTER FUNCTION public.edit_user(in_username character varying, in_name character varying, in_space numeric, in_email character varying) OWNER TO akdev;

--
-- TOC entry 236 (class 1255 OID 25756)
-- Name: get_file_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_file_list(in_username character varying) RETURNS TABLE(item_name character varying, size numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name, items.size
    FROM
        items
    WHERE
        items.owner = in_username 
      AND trash_status = 0
        AND type_id = 1
    ORDER BY item_name ASC;
END;
$$;


ALTER FUNCTION public.get_file_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 239 (class 1255 OID 25757)
-- Name: get_folder_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_folder_list(in_username character varying) RETURNS TABLE(item_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name
    FROM
        items
    WHERE
        items.owner = in_username 
      AND trash_status = 0
        AND type_id = 2
    ORDER BY item_name ASC;
END;
$$;


ALTER FUNCTION public.get_folder_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 231 (class 1255 OID 25755)
-- Name: get_information_storage(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_information_storage(in_username character varying) RETURNS TABLE(information character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
     RETURN QUERY SELECT
        concat(users.used_space, ' Gb dari ', (users.space * 0.000000001 )::int , ' Gb telah terpakai')::varchar
    FROM
        users
     WHERE users.username = in_username;
END
$$;


ALTER FUNCTION public.get_information_storage(in_username character varying) OWNER TO akdev;

--
-- TOC entry 230 (class 1255 OID 25442)
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
-- TOC entry 229 (class 1255 OID 25493)
-- Name: get_trash_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_trash_list(in_username character varying) RETURNS TABLE(file_name character varying, size numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        files.file_name, files.size
    FROM
        files
    WHERE
        files.owner like in_username AND files.trash_status = 1;
END;
$$;


ALTER FUNCTION public.get_trash_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 241 (class 1255 OID 25731)
-- Name: get_user_log_activity(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_user_log_activity(in_username character varying) RETURNS TABLE(activity_date text, activity text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        to_char(l.activity_date::timestamp with time zone, 'day, DD-MM-YYYY'::text) AS activity_date,
        concat(da.description, ' ' ,l.item_name) as activity
    FROM
        logs l
    INNER JOIN
        	detail_activity da on l.activity_id = da.activity_id
    WHERE
        l.username = in_username;
END;
$$;


ALTER FUNCTION public.get_user_log_activity(in_username character varying) OWNER TO akdev;

--
-- TOC entry 233 (class 1255 OID 25588)
-- Name: is_admin(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.is_admin(in_username character varying) RETURNS TABLE(username character varying, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        users.username,
        dr.description
    FROM
        users
    INNER JOIN
            detail_role dr on users.role_id = dr.role_id
WHERE
        users.username = in_username AND users.role_id = 1;
END;
$$;


ALTER FUNCTION public.is_admin(in_username character varying) OWNER TO akdev;

--
-- TOC entry 224 (class 1255 OID 17188)
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
-- TOC entry 234 (class 1255 OID 25589)
-- Name: is_user(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.is_user(in_username character varying) RETURNS TABLE(username character varying, description character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        users.username,
        dr.description
    FROM
        users
    INNER JOIN
        	detail_role dr on users.role_id = dr.role_id
    WHERE
        users.username = in_username AND users.role_id = 2;
END;
$$;


ALTER FUNCTION public.is_user(in_username character varying) OWNER TO akdev;

--
-- TOC entry 223 (class 1255 OID 17080)
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
-- TOC entry 247 (class 1255 OID 25741)
-- Name: log_create_folder(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_create_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.type_id = 2 THEN
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(NEW.item_id, NEW.owner, 1, now(), NEW.item_name);
END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_create_folder() OWNER TO akdev;

--
-- TOC entry 226 (class 1255 OID 25381)
-- Name: log_delete_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_delete_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_status = 0 AND NEW.trash_status = 1 
 	    AND OLD.type_id = 1
 	    THEN
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(OLD.item_id, OLD.owner, 7, now(), OLD.item_name);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_delete_file() OWNER TO akdev;

--
-- TOC entry 250 (class 1255 OID 25746)
-- Name: log_delete_folder(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_delete_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_status = 0 AND NEW.trash_status = 1
 	    AND OLD.type_id = 2 THEN
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(OLD.item_id, OLD.owner, 4, now(), OLD.item_name);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_delete_folder() OWNER TO akdev;

--
-- TOC entry 227 (class 1255 OID 25385)
-- Name: log_recovery_trash(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_recovery_trash() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_status = 1 AND NEW.trash_status = 0 THEN
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
-- TOC entry 225 (class 1255 OID 25378)
-- Name: log_rename_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_rename_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF NEW.item_name <> OLD.item_name 
 	    AND OLD.type_id = 1 
 	   THEN
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(OLD.item_id, OLD.owner, 8, now(), OLD.item_name);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_rename_file() OWNER TO akdev;

--
-- TOC entry 235 (class 1255 OID 25544)
-- Name: log_rename_folder(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_rename_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF NEW.item_name <> OLD.item_name 
 	    AND OLD.type_id = 2  THEN
 	INSERT INTO logs
 	(username, activity_id, activity_date, item_name)
 	VALUES
 	(OLD.owner, 3, now(), OLD.directory);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_rename_folder() OWNER TO akdev;

--
-- TOC entry 228 (class 1255 OID 25387)
-- Name: log_upload_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_upload_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.type_id = 1 THEN
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(NEW.item_id, NEW.owner, 6, now(), NEW.item_name);
--     UPDATE users set users.used_space = (users.used_space + NEW.size) where users.username = username;
END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_upload_file() OWNER TO akdev;

--
-- TOC entry 254 (class 1255 OID 25764)
-- Name: min_used_space(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.min_used_space() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
        UPDATE users SET used_space = used_space - OLD.size
        WHERE username = OLD.owner;
 RETURN OLD;
 END;
$$;


ALTER FUNCTION public.min_used_space() OWNER TO akdev;

--
-- TOC entry 211 (class 1255 OID 17005)
-- Name: recovery_trash(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.recovery_trash(_file_id integer, _username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE files SET trash_status = 0
WHERE file_id = _file_id AND owner = _username;
END
$$;


ALTER FUNCTION public.recovery_trash(_file_id integer, _username character varying) OWNER TO akdev;

--
-- TOC entry 249 (class 1255 OID 16951)
-- Name: rename_file(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.rename_file(id integer, new_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE items SET item_name = new_name
WHERE item_id = id AND type_id = 1;
END
$$;


ALTER FUNCTION public.rename_file(id integer, new_name character varying) OWNER TO akdev;

--
-- TOC entry 252 (class 1255 OID 25745)
-- Name: rename_folder(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.rename_folder(in_username character varying, in_item_name character varying, in_new_item_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
--     SELECT replace(in_item_name, in_item_name, in_new_item_name) FROM items
UPDATE items SET item_name = in_new_item_name
WHERE item_name = in_item_name
  AND type_id = 2 
  AND owner = in_username;
END
$$;


ALTER FUNCTION public.rename_folder(in_username character varying, in_item_name character varying, in_new_item_name character varying) OWNER TO akdev;

--
-- TOC entry 245 (class 1255 OID 25740)
-- Name: search_owner(character varying, integer, date, date); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.search_owner(in_name character varying, in_activity_id integer, in_start_date date, in_end_date date) RETURNS TABLE(name character varying, last_activity_date text, last_activity character varying, kuota text, status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT u.name                                             AS nama,
       to_char((t2.activity_date)::timestamp without time zone, 'day, DD-MM-YYYY') AS last_activity_date,
       da.description                                     AS last_activity,
       concat(u.used_space, '/', (u.space * 0.000000001)::int, ' Gb')                 AS kuota,
       dl.description                                     AS status
FROM logs la
         JOIN (SELECT logs.username, max(logs.activity_date) AS activity_date
               FROM logs
               GROUP BY logs.username) t2
              ON la.username::text = t2.username::text AND la.activity_date = t2.activity_date

         JOIN users u ON u.username::text = la.username::text
         JOIN detail_activity da ON da.activity_id = la.activity_id
         JOIN detail_status dl ON u.status_id = dl.status_id

    WHERE lower(u.name) like lower('%' || in_name || '%') AND
          da.activity_id = in_activity_id AND
          t2.activity_date::date >= in_start_date::date AND
          t2.activity_date::date <= in_end_date::date;
    END
$$;


ALTER FUNCTION public.search_owner(in_name character varying, in_activity_id integer, in_start_date date, in_end_date date) OWNER TO akdev;

--
-- TOC entry 243 (class 1255 OID 25733)
-- Name: set_offline(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.set_offline(in_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE users SET status_id = 2
WHERE username = in_username;
END
$$;


ALTER FUNCTION public.set_offline(in_username character varying) OWNER TO akdev;

--
-- TOC entry 242 (class 1255 OID 25732)
-- Name: set_online(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.set_online(in_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE users SET status_id = 1
WHERE username = in_username;
END
$$;


ALTER FUNCTION public.set_online(in_username character varying) OWNER TO akdev;

--
-- TOC entry 232 (class 1255 OID 25585)
-- Name: verify_login(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.verify_login(in_username character varying, in_password character varying) RETURNS TABLE(username character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        users.username
    FROM
        users
    WHERE
        users.username = in_username AND password = in_password;
END;
$$;


ALTER FUNCTION public.verify_login(in_username character varying, in_password character varying) OWNER TO akdev;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 201 (class 1259 OID 16887)
-- Name: detail_activity; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_activity (
    activity_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.detail_activity OWNER TO akdev;

--
-- TOC entry 204 (class 1259 OID 17009)
-- Name: detail_role; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_role (
    role_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.detail_role OWNER TO akdev;

--
-- TOC entry 205 (class 1259 OID 17093)
-- Name: detail_status; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_status (
    status_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.detail_status OWNER TO akdev;

--
-- TOC entry 208 (class 1259 OID 25457)
-- Name: detail_trash; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_trash (
    trash_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.detail_trash OWNER TO akdev;

--
-- TOC entry 209 (class 1259 OID 25546)
-- Name: detail_type; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_type (
    type_id integer NOT NULL,
    description character varying NOT NULL
);


ALTER TABLE public.detail_type OWNER TO akdev;

--
-- TOC entry 203 (class 1259 OID 16965)
-- Name: items; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.items (
    item_id integer NOT NULL,
    item_name character varying NOT NULL,
    directory character varying NOT NULL,
    size numeric,
    trash_status integer NOT NULL,
    owner character varying NOT NULL,
    type_id integer NOT NULL
);


ALTER TABLE public.items OWNER TO akdev;

--
-- TOC entry 202 (class 1259 OID 16963)
-- Name: files_file_id_seq; Type: SEQUENCE; Schema: public; Owner: akdev
--

ALTER TABLE public.items ALTER COLUMN item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.files_file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 207 (class 1259 OID 17225)
-- Name: logs; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.logs (
    log_id integer NOT NULL,
    item_id integer,
    username character varying,
    activity_id integer,
    item_name character varying,
    activity_date timestamp without time zone NOT NULL
);


ALTER TABLE public.logs OWNER TO akdev;

--
-- TOC entry 200 (class 1259 OID 16874)
-- Name: users; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.users (
    username character varying(18) NOT NULL,
    name character varying(55) NOT NULL,
    password character varying,
    phone character varying(15) NOT NULL,
    email character varying(30) NOT NULL,
    space numeric,
    used_space numeric,
    role_id integer NOT NULL,
    status_id integer NOT NULL
);


ALTER TABLE public.users OWNER TO akdev;

--
-- TOC entry 210 (class 1259 OID 25604)
-- Name: get_log_activity; Type: VIEW; Schema: public; Owner: akdev
--

CREATE VIEW public.get_log_activity AS
 SELECT u.name AS nama,
    to_char((t2.activity_date)::timestamp with time zone, 'day, DD-MM-YYYY'::text) AS activity_date,
    da.description AS last_activity,
    concat(round((u.used_space * 0.000000001), 2), ' Gb /', (round((u.space * 0.000000001), 2))::integer, ' Gb') AS kuota,
    dl.description AS status
   FROM ((((public.logs la
     JOIN ( SELECT logs.username,
            max(logs.activity_date) AS activity_date
           FROM public.logs
          GROUP BY logs.username) t2 ON ((((la.username)::text = (t2.username)::text) AND (la.activity_date = t2.activity_date))))
     JOIN public.users u ON (((u.username)::text = (la.username)::text)))
     JOIN public.detail_activity da ON ((da.activity_id = la.activity_id)))
     JOIN public.detail_status dl ON ((u.status_id = dl.status_id)))
  WHERE (u.role_id = 2);


ALTER TABLE public.get_log_activity OWNER TO akdev;

--
-- TOC entry 206 (class 1259 OID 17223)
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
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 206
-- Name: log_activity_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: akdev
--

ALTER SEQUENCE public.log_activity_log_id_seq OWNED BY public.logs.log_id;


--
-- TOC entry 2899 (class 2604 OID 17228)
-- Name: logs log_id; Type: DEFAULT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs ALTER COLUMN log_id SET DEFAULT nextval('public.log_activity_log_id_seq'::regclass);


--
-- TOC entry 3068 (class 0 OID 16887)
-- Dependencies: 201
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
-- TOC entry 3071 (class 0 OID 17009)
-- Dependencies: 204
-- Data for Name: detail_role; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_role (role_id, description) FROM stdin;
1	admin
2	user
\.


--
-- TOC entry 3072 (class 0 OID 17093)
-- Dependencies: 205
-- Data for Name: detail_status; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_status (status_id, description) FROM stdin;
0	nonaktif
1	aktif
\.


--
-- TOC entry 3075 (class 0 OID 25457)
-- Dependencies: 208
-- Data for Name: detail_trash; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_trash (trash_id, description) FROM stdin;
0	nontrash
1	trash
\.


--
-- TOC entry 3076 (class 0 OID 25546)
-- Dependencies: 209
-- Data for Name: detail_type; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_type (type_id, description) FROM stdin;
1	file
2	folder
\.


--
-- TOC entry 3070 (class 0 OID 16965)
-- Dependencies: 203
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.items (item_id, item_name, directory, size, trash_status, owner, type_id) FROM stdin;
10	poto aku	/rsf/roni	5	0	rsf	1
8	poto aku	/rsf/roni	5	0	rsf	1
7	poto aku	/rsf/roni	5	0	rsf	1
5	Foto adi k	/a/b/c	6	0	akdev	1
30	hgg	/fealsPunya	5	0	feals	1
29	hgg	/fealsPunya	5	0	feals	1
33	keren	/snk/keren	5	0	snk	1
27	hgg	/fealsPunya	5	0	feals	1
26	hgg	/fealsPunya	5	0	feals	1
14	woi	/eaea	5	0	akdev	1
13	ea	/fealsPunya	5	1	feals	1
36	punya rsf	/	\N	0	rsf	2
37	rsf punya	/	500000	0	rsf	1
39	punya rsf2	/	\N	0	rsf	2
40	rsf punya	/	500000	0	rsf	1
43	rsf punya	/	5000000	0	rsf	1
44	punya rsf2	/	\N	0	rsf	2
45	rsf punya	/	5000000	0	rsf	1
46	rsf punya	/	5000000	0	rsf	1
47	punya rsf2	/	\N	0	rsf	2
25	hgg	/roniPunya	5	1	rsf	1
19	hgg	/roniPunya	5	1	rsf	1
17	hgg	/roniPunya	5	1	rsf	1
15	hgg	/roniPunya	5	1	rsf	1
11	poto aku lagi	/roniPunya/roni	5	1	rsf	1
2	pas poto ktp	/etc/a	1500	1	akdev	1
1	krs	/etc/home	2.5	1	akdev	1
54	test trigger	/	500000	0	rsf	1
52	test trigger	/	500000	1	rsf	1
55	test trigger	/	500000	1	rsf	1
\.


--
-- TOC entry 3074 (class 0 OID 17225)
-- Dependencies: 207
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.logs (log_id, item_id, username, activity_id, item_name, activity_date) FROM stdin;
19	15	rsf	6	hgg	2021-01-20 00:00:00
20	12	feals	9	ea	2021-01-20 00:00:00
21	12	feals	9	ea	2021-01-20 00:00:00
22	12	feals	7	ea	2021-01-20 00:00:00
27	17	rsf	6	hgg	2021-01-21 00:00:00
32	26	feals	6	hgg	2021-01-21 00:00:00
34	29	feals	6	hgg	2021-01-21 00:00:00
35	30	feals	6	hgg	2021-01-21 00:00:00
46	12	feals	9	ea	2021-01-21 00:00:00
47	12	feals	7	ea	2021-01-21 00:00:00
48	12	feals	9	ea	2021-01-21 00:00:00
49	12	feals	7	ea	2021-01-21 00:00:00
50	12	feals	9	ea	2021-01-21 00:00:00
51	13	feals	7	ea	2021-01-21 00:00:00
28	19	rsf	6	hgg	2021-01-21 00:10:00
33	27	feals	6	hgg	2021-01-21 00:20:00
52	12	feals	7	ea	2021-01-21 00:00:10
53	26	feals	9	hgg	2021-01-21 05:47:32.031133
54	27	feals	9	hgg	2021-01-21 05:47:32.031133
56	30	feals	9	hgg	2021-01-21 05:47:32.031133
57	13	feals	7	ea	2021-01-21 05:47:32.031133
58	12	feals	7	ea	2021-01-21 05:47:32.031133
59	30	feals	7	hgg	2021-01-21 05:58:36.152835
60	30	feals	9	hgg	2021-01-21 05:59:13.477145
61	\N	rsf	3	eaea	2021-01-21 06:55:33.065645
62	\N	rsf	3	eaea	2021-01-21 06:55:33.065645
63	\N	rsf	3	eaea	2021-01-21 06:55:33.065645
64	\N	rsf	3	eaea	2021-01-21 06:55:34.065
65	33	snk	6	keren	2021-01-21 07:01:05.97887
66	\N	snk	3	dkp/keren	2021-01-21 08:03:56.245905
67	\N	feals	3	fealsPunya	2021-01-21 08:08:07.696825
68	\N	feals	3	fealsPunya	2021-01-21 08:08:07.696825
69	\N	feals	3	fealsPunya	2021-01-21 08:08:07.696825
70	\N	feals	3	fealsPunya	2021-01-21 08:08:07.696825
72	\N	rsf	3	roniPunya	2021-01-21 08:08:07.696825
73	\N	rsf	3	rsf/roni	2021-01-21 08:08:07.696825
74	\N	rsf	3	rsf/roni	2021-01-21 08:08:07.696825
75	\N	rsf	3	roniPunya	2021-01-21 08:08:07.696825
76	\N	rsf	3	rsf/roni	2021-01-21 08:08:07.696825
77	\N	rsf	3	rsf/roni	2021-01-21 08:08:07.696825
78	\N	rsf	3	roniPunya	2021-01-21 08:08:07.696825
79	\N	feals	3	fealsPunya	2021-01-21 08:08:07.696825
80	\N	akdev	3	a/b/c	2021-01-21 08:08:07.696825
71	\N	akdev	3	eaea	2021-01-23 08:08:07.696
82	\N	snk	3	snk/keren	2021-01-24 08:08:07.696
55	29	feals	9	hgg	2021-01-24 05:47:32.031
31	25	rsf	6	hgg	2021-01-24 00:00:00
81	\N	rsf	3	roniPunya	2021-01-28 08:08:07.696
83	36	rsf	6	punya rsf	2021-01-23 10:41:35.44438
84	37	rsf	6	rsf punya	2021-01-23 10:44:56.186824
85	39	rsf	6	punya rsf2	2021-01-23 10:47:44.504629
86	40	rsf	6	rsf punya	2021-01-23 10:47:46.376537
88	43	rsf	6	rsf punya	2021-01-23 10:54:32.041387
89	46	rsf	6	rsf punya	2021-01-23 10:59:56.939365
90	47	rsf	1	punya rsf2	2021-01-23 11:03:56.081499
91	\N	rsf	3	/rsf/roni	2021-01-23 11:19:20.425066
92	25	rsf	7	hgg	2021-01-23 11:33:51.540239
93	19	rsf	7	hgg	2021-01-23 11:33:51.540239
94	17	rsf	7	hgg	2021-01-23 11:33:51.540239
95	15	rsf	7	hgg	2021-01-23 11:33:51.540239
96	11	rsf	7	poto aku lagi	2021-01-23 11:33:51.540239
97	2	akdev	7	pas poto ktp	2021-01-23 11:38:33.42233
98	1	akdev	7	krs	2021-01-23 11:38:33.42233
99	52	rsf	6	test trigger	2021-01-23 14:22:47.848056
100	53	rsf	6	test trigger	2021-01-23 14:30:34.190594
101	54	rsf	6	test trigger	2021-01-23 14:34:28.256324
102	53	rsf	7	test trigger	2021-01-23 14:34:36.309054
103	52	rsf	7	test trigger	2021-01-23 14:38:07.47111
104	55	rsf	6	test trigger	2021-01-23 14:39:02.306803
105	55	rsf	7	test trigger	2021-01-23 14:39:17.549507
106	56	rsf	6	test trigger	2021-01-23 14:39:49.980887
107	56	rsf	7	test trigger	2021-01-23 14:39:58.66207
\.


--
-- TOC entry 3067 (class 0 OID 16874)
-- Dependencies: 200
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.users (username, name, password, phone, email, space, used_space, role_id, status_id) FROM stdin;
rsf	Roni Starko Firdaus	uN3kUITsovYN__Fkf1JbGp6RogstwVvZqwAvLXgkemk=	0895621854457	rsf.project@gmail.com	5000000000	15000000	2	1
akdev	Adi Kurniawan	Hg6xftqVTlEiSTkAEvB3plSfvi1yyZgx29xFDtDQ4fI=	082182751010	adikurniawan.dev@gmail.com	\N	\N	1	1
feals	Febyk Alek Satria	9wDhtWXFkumcYECrx-n2KhlUngZthajfq2LFZB0cksE=	081373107544	febykaleksatria@gmail.com	1000000000	100000000	2	1
kalala	Nabila Fitriana	iT4f5Ewe6E_eT1pz4NzxmUN9ZlK3R-PKhvRzmZFwzEQ=	080808080808	kalala@ymail.com	10000000000	20000000	2	1
snk	Sinka Juliani	NugHLPi0prWTOPQ9Pfq02ZIH5nDAS8_E4LL6IFGNBho=	082182751010	sinka@gmail.com	5000000000	300000000	2	1
dwsd	asdad	B7j76JA0nGVpOasT9JwQqtyRoeFQG6FUeBV-qHcTJ1k=	sf	sww	0	0	2	0
\.


--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 202
-- Name: files_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.files_file_id_seq', 56, true);


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 206
-- Name: log_activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.log_activity_log_id_seq', 107, true);


--
-- TOC entry 2903 (class 2606 OID 16894)
-- Name: detail_activity detail_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_activity
    ADD CONSTRAINT detail_activity_pkey PRIMARY KEY (activity_id);


--
-- TOC entry 2909 (class 2606 OID 17101)
-- Name: detail_status detail_status_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_status
    ADD CONSTRAINT detail_status_pk PRIMARY KEY (status_id);


--
-- TOC entry 2918 (class 2606 OID 25554)
-- Name: detail_type detail_type_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_type
    ADD CONSTRAINT detail_type_pk PRIMARY KEY (type_id);


--
-- TOC entry 2905 (class 2606 OID 16972)
-- Name: items files_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT files_pkey PRIMARY KEY (item_id);


--
-- TOC entry 2913 (class 2606 OID 17234)
-- Name: logs log_activity_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT log_activity_pk PRIMARY KEY (log_id);


--
-- TOC entry 2907 (class 2606 OID 17016)
-- Name: detail_role role_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- TOC entry 2915 (class 2606 OID 25465)
-- Name: detail_trash status_trash_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_trash
    ADD CONSTRAINT status_trash_pk PRIMARY KEY (trash_id);


--
-- TOC entry 2901 (class 2606 OID 16881)
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (username);


--
-- TOC entry 2910 (class 1259 OID 17099)
-- Name: detail_status_status_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_status_status_id_uindex ON public.detail_status USING btree (status_id);


--
-- TOC entry 2919 (class 1259 OID 25552)
-- Name: detail_type_type_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_type_type_id_uindex ON public.detail_type USING btree (type_id);


--
-- TOC entry 2911 (class 1259 OID 17232)
-- Name: log_activity_log_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX log_activity_log_id_uindex ON public.logs USING btree (log_id);


--
-- TOC entry 2916 (class 1259 OID 25463)
-- Name: status_trash_trash_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX status_trash_trash_id_uindex ON public.detail_trash USING btree (trash_id);


--
-- TOC entry 2934 (class 2620 OID 25763)
-- Name: items add_used_space; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER add_used_space AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.add_used_space();


--
-- TOC entry 2932 (class 2620 OID 25742)
-- Name: items create_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER create_folder AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_create_folder();


--
-- TOC entry 2928 (class 2620 OID 25382)
-- Name: items delete_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER delete_file BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_delete_file();


--
-- TOC entry 2933 (class 2620 OID 25747)
-- Name: items delete_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER delete_folder BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_delete_folder();


--
-- TOC entry 2935 (class 2620 OID 25766)
-- Name: items min_used_space; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER min_used_space BEFORE DELETE ON public.items FOR EACH ROW EXECUTE FUNCTION public.min_used_space();


--
-- TOC entry 2929 (class 2620 OID 25386)
-- Name: items recovery_trash; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER recovery_trash BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash();


--
-- TOC entry 2927 (class 2620 OID 25380)
-- Name: items rename_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER rename_file BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_rename_file();


--
-- TOC entry 2931 (class 2620 OID 25545)
-- Name: items rename_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER rename_folder BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_rename_folder();


--
-- TOC entry 2930 (class 2620 OID 25388)
-- Name: items upload_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER upload_file AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_upload_file();


--
-- TOC entry 2926 (class 2606 OID 17240)
-- Name: logs fk_detail_activity; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_detail_activity FOREIGN KEY (activity_id) REFERENCES public.detail_activity(activity_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2922 (class 2606 OID 17245)
-- Name: items fk_owner; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_owner FOREIGN KEY (owner) REFERENCES public.users(username) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2920 (class 2606 OID 17198)
-- Name: users fk_role; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES public.detail_role(role_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2921 (class 2606 OID 17203)
-- Name: users fk_status; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES public.detail_status(status_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2923 (class 2606 OID 25531)
-- Name: items fk_trash_status; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_trash_status FOREIGN KEY (trash_status) REFERENCES public.detail_trash(trash_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2924 (class 2606 OID 25569)
-- Name: items fk_type_id; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES public.detail_type(type_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2925 (class 2606 OID 17235)
-- Name: logs fk_username; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_username FOREIGN KEY (username) REFERENCES public.users(username) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


-- Completed on 2021-01-23 21:57:54 WIB

--
-- PostgreSQL database dump complete
--

