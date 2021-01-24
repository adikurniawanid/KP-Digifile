--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)

-- Started on 2021-01-24 21:05:56 WIB

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
-- TOC entry 245 (class 1255 OID 25737)
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
-- TOC entry 256 (class 1255 OID 25735)
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
-- TOC entry 251 (class 1255 OID 25762)
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
-- TOC entry 234 (class 1255 OID 25782)
-- Name: add_user(character varying, character varying, character varying, character varying, character varying, numeric); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.add_user(in_username character varying, in_name character varying, in_password character varying, in_phone character varying, in_email character varying, in_space numeric) RETURNS boolean
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


ALTER FUNCTION public.add_user(in_username character varying, in_name character varying, in_password character varying, in_phone character varying, in_email character varying, in_space numeric) OWNER TO akdev;

--
-- TOC entry 249 (class 1255 OID 25749)
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
-- TOC entry 236 (class 1255 OID 25787)
-- Name: delete_folder(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.delete_folder(in_folder_id integer, in_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE items SET trash_status = 1
WHERE item_id = in_folder_id
  AND owner = in_username;
END
$$;


ALTER FUNCTION public.delete_folder(in_folder_id integer, in_username character varying) OWNER TO akdev;

--
-- TOC entry 233 (class 1255 OID 25765)
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
-- TOC entry 241 (class 1255 OID 25721)
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
-- TOC entry 257 (class 1255 OID 25803)
-- Name: get_file_list(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_file_list(in_username character varying, in_path character varying) RETURNS TABLE(item_name character varying)
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
        AND type_id = 1
    AND directory = in_path
    ORDER BY item_name ASC;
END;
$$;


ALTER FUNCTION public.get_file_list(in_username character varying, in_path character varying) OWNER TO akdev;

--
-- TOC entry 235 (class 1255 OID 25784)
-- Name: get_folder_list(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_folder_list(in_username character varying, in_path character varying) RETURNS TABLE(item_name character varying)
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
    AND directory = in_path
    
    ORDER BY item_name ASC;
END;
$$;


ALTER FUNCTION public.get_folder_list(in_username character varying, in_path character varying) OWNER TO akdev;

--
-- TOC entry 239 (class 1255 OID 25791)
-- Name: get_information_storage(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_information_storage(in_username character varying) RETURNS TABLE(information character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
     RETURN QUERY SELECT
                    concat(round(u.used_space * 0.000000001, 2), ' Gb dari ', round(u.space * 0.000000001, 2)::integer,  ' Gb telah terpakai')::varchar
             FROM
                 users u
             WHERE u.username = in_username;
END
$$;


ALTER FUNCTION public.get_information_storage(in_username character varying) OWNER TO akdev;

--
-- TOC entry 228 (class 1255 OID 25442)
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
-- TOC entry 237 (class 1255 OID 25788)
-- Name: get_trash_file_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_trash_file_list(in_username character varying) RETURNS TABLE(file_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name
    FROM
        items
    WHERE
        items.owner like in_username
      AND items.trash_status = 1
        AND items.type_id = 1
    ORDER BY items.item_name ASC;
END;
$$;


ALTER FUNCTION public.get_trash_file_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 238 (class 1255 OID 25789)
-- Name: get_trash_folder_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_trash_folder_list(in_username character varying) RETURNS TABLE(folder_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name
    FROM
        items
    WHERE
        items.owner like in_username
      AND items.trash_status = 1
        AND items.type_id = 2
    ORDER BY items.item_name ASC;
END;
$$;


ALTER FUNCTION public.get_trash_folder_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 242 (class 1255 OID 25731)
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
-- TOC entry 230 (class 1255 OID 25588)
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
-- TOC entry 223 (class 1255 OID 17188)
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
-- TOC entry 231 (class 1255 OID 25589)
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
-- TOC entry 222 (class 1255 OID 17080)
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
-- TOC entry 246 (class 1255 OID 25741)
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
-- TOC entry 225 (class 1255 OID 25381)
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
-- TOC entry 248 (class 1255 OID 25746)
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
-- TOC entry 226 (class 1255 OID 25385)
-- Name: log_recovery_trash_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_recovery_trash_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_status = 1
 	       AND NEW.trash_status = 0
 	    AND OLD.type_id = 1
 	    THEN
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(OLD.item_id, OLD.owner, 9, now(), OLD.item_name);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_recovery_trash_file() OWNER TO akdev;

--
-- TOC entry 255 (class 1255 OID 25801)
-- Name: log_recovery_trash_folder(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_recovery_trash_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_status = 1
 	       AND NEW.trash_status = 0
 	    AND OLD.type_id = 2
 	    THEN
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(OLD.item_id, OLD.owner, 5, now(), OLD.item_name);
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_recovery_trash_folder() OWNER TO akdev;

--
-- TOC entry 224 (class 1255 OID 25378)
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
-- TOC entry 232 (class 1255 OID 25544)
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
-- TOC entry 227 (class 1255 OID 25387)
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
-- TOC entry 252 (class 1255 OID 25764)
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
-- TOC entry 253 (class 1255 OID 25799)
-- Name: recovery_trash_file(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.recovery_trash_file(in_file_id integer, in_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE items SET trash_status = 0
WHERE item_id = in_file_id AND owner = in_username;
END
$$;


ALTER FUNCTION public.recovery_trash_file(in_file_id integer, in_username character varying) OWNER TO akdev;

--
-- TOC entry 254 (class 1255 OID 25800)
-- Name: recovery_trash_folder(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.recovery_trash_folder(in_folder_id integer, in_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE items SET trash_status = 0
WHERE item_id = in_folder_id AND owner = in_username;
END
$$;


ALTER FUNCTION public.recovery_trash_folder(in_folder_id integer, in_username character varying) OWNER TO akdev;

--
-- TOC entry 247 (class 1255 OID 16951)
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
-- TOC entry 250 (class 1255 OID 25745)
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
-- TOC entry 240 (class 1255 OID 25792)
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
       concat(round(u.used_space * 0.000000001, 2), ' Gb /', round(u.space * 0.000000001, 2)::integer, ' Gb') AS kuota,
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
-- TOC entry 244 (class 1255 OID 25733)
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
-- TOC entry 243 (class 1255 OID 25732)
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
-- TOC entry 229 (class 1255 OID 25585)
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
-- TOC entry 210 (class 1259 OID 25793)
-- Name: get_log_activity; Type: VIEW; Schema: public; Owner: akdev
--

CREATE VIEW public.get_log_activity AS
 SELECT u.username,
    u.name AS nama,
    to_char((t2.activity_date)::timestamp with time zone, 'day, DD-MM-YYYY'::text) AS activity_date,
    da.description AS last_activity,
    concat(round((u.used_space * 0.000000001), 2), ' Gb / ', (round((u.space * 0.000000001), 2))::integer, ' Gb') AS kuota,
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
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 206
-- Name: log_activity_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: akdev
--

ALTER SEQUENCE public.log_activity_log_id_seq OWNED BY public.logs.log_id;


--
-- TOC entry 2902 (class 2604 OID 17228)
-- Name: logs log_id; Type: DEFAULT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs ALTER COLUMN log_id SET DEFAULT nextval('public.log_activity_log_id_seq'::regclass);


--
-- TOC entry 3072 (class 0 OID 16887)
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
-- TOC entry 3075 (class 0 OID 17009)
-- Dependencies: 204
-- Data for Name: detail_role; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_role (role_id, description) FROM stdin;
1	admin
2	user
\.


--
-- TOC entry 3076 (class 0 OID 17093)
-- Dependencies: 205
-- Data for Name: detail_status; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_status (status_id, description) FROM stdin;
0	nonaktif
1	aktif
\.


--
-- TOC entry 3079 (class 0 OID 25457)
-- Dependencies: 208
-- Data for Name: detail_trash; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_trash (trash_id, description) FROM stdin;
0	nontrash
1	trash
\.


--
-- TOC entry 3080 (class 0 OID 25546)
-- Dependencies: 209
-- Data for Name: detail_type; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_type (type_id, description) FROM stdin;
1	file
2	folder
\.


--
-- TOC entry 3074 (class 0 OID 16965)
-- Dependencies: 203
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.items (item_id, item_name, directory, size, trash_status, owner, type_id) FROM stdin;
58	poto.png	/	10000000	0	rsf	1
61	Kuliah	/	\N	0	rsf	2
62	KRS-2020.pdf	/	10000000	0	feals	1
57	KRS.pdf	/	50000000	0	rsf	1
60	Folder Kuliah	/	\N	0	rsf	2
\.


--
-- TOC entry 3078 (class 0 OID 17225)
-- Dependencies: 207
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.logs (log_id, item_id, username, activity_id, item_name, activity_date) FROM stdin;
109	58	rsf	6	poto.png	2021-01-24 05:05:24.016652
110	59	rsf	6	poto.png	2021-01-24 05:08:20.620154
111	60	rsf	1	Folder Kuliah	2021-01-24 05:13:00.885654
112	61	rsf	1	Kuliah	2021-01-24 05:13:56.022302
113	57	rsf	7	KRS.pdf	2021-01-24 05:32:01.194755
114	60	rsf	4	Folder Kuliah	2021-01-24 05:34:50.499837
115	62	feals	6	KRS.pdf	2021-01-24 07:44:41.884093
116	62	feals	8	KRS.pdf	2021-01-24 13:10:10.613497
117	57	rsf	9	KRS.pdf	2021-01-24 13:20:01.904963
118	57	rsf	7	KRS.pdf	2021-01-24 13:27:38.391316
119	57	rsf	9	KRS.pdf	2021-01-24 13:27:53.312106
120	60	rsf	5	Folder Kuliah	2021-01-24 13:31:47.369371
\.


--
-- TOC entry 3071 (class 0 OID 16874)
-- Dependencies: 200
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.users (username, name, password, phone, email, space, used_space, role_id, status_id) FROM stdin;
rsf	Roni Starko Firdaus	uN3kUITsovYN__Fkf1JbGp6RogstwVvZqwAvLXgkemk=	0895621854457	rsf.project@gmail.com	5000000000	600000000	2	0
akdev	Adi Kurniawan	Hg6xftqVTlEiSTkAEvB3plSfvi1yyZgx29xFDtDQ4fI=	082182751010	adikurniawan.dev@gmail.com	\N	\N	1	1
feals	Febyk Alek Satria	9wDhtWXFkumcYECrx-n2KhlUngZthajfq2LFZB0cksE=	081373107544	febykaleksatria@gmail.com	1000000000	10000000	2	0
kalala	Nabila Fitriana	iT4f5Ewe6E_eT1pz4NzxmUN9ZlK3R-PKhvRzmZFwzEQ=	080808080808	kalala@ymail.com	10000000000	0	2	0
snk	Sinka Juliani	NugHLPi0prWTOPQ9Pfq02ZIH5nDAS8_E4LL6IFGNBho=	082182751010	sinka@gmail.com	5000000000	0	2	0
\.


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 202
-- Name: files_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.files_file_id_seq', 62, true);


--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 206
-- Name: log_activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.log_activity_log_id_seq', 120, true);


--
-- TOC entry 2906 (class 2606 OID 16894)
-- Name: detail_activity detail_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_activity
    ADD CONSTRAINT detail_activity_pkey PRIMARY KEY (activity_id);


--
-- TOC entry 2912 (class 2606 OID 17101)
-- Name: detail_status detail_status_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_status
    ADD CONSTRAINT detail_status_pk PRIMARY KEY (status_id);


--
-- TOC entry 2921 (class 2606 OID 25554)
-- Name: detail_type detail_type_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_type
    ADD CONSTRAINT detail_type_pk PRIMARY KEY (type_id);


--
-- TOC entry 2908 (class 2606 OID 16972)
-- Name: items files_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT files_pkey PRIMARY KEY (item_id);


--
-- TOC entry 2916 (class 2606 OID 17234)
-- Name: logs log_activity_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT log_activity_pk PRIMARY KEY (log_id);


--
-- TOC entry 2910 (class 2606 OID 17016)
-- Name: detail_role role_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- TOC entry 2918 (class 2606 OID 25465)
-- Name: detail_trash status_trash_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_trash
    ADD CONSTRAINT status_trash_pk PRIMARY KEY (trash_id);


--
-- TOC entry 2904 (class 2606 OID 16881)
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (username);


--
-- TOC entry 2913 (class 1259 OID 17099)
-- Name: detail_status_status_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_status_status_id_uindex ON public.detail_status USING btree (status_id);


--
-- TOC entry 2922 (class 1259 OID 25552)
-- Name: detail_type_type_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_type_type_id_uindex ON public.detail_type USING btree (type_id);


--
-- TOC entry 2914 (class 1259 OID 17232)
-- Name: log_activity_log_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX log_activity_log_id_uindex ON public.logs USING btree (log_id);


--
-- TOC entry 2919 (class 1259 OID 25463)
-- Name: status_trash_trash_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX status_trash_trash_id_uindex ON public.detail_trash USING btree (trash_id);


--
-- TOC entry 2936 (class 2620 OID 25763)
-- Name: items add_used_space; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER add_used_space AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.add_used_space();


--
-- TOC entry 2934 (class 2620 OID 25742)
-- Name: items create_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER create_folder AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_create_folder();


--
-- TOC entry 2931 (class 2620 OID 25382)
-- Name: items delete_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER delete_file BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_delete_file();


--
-- TOC entry 2935 (class 2620 OID 25747)
-- Name: items delete_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER delete_folder BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_delete_folder();


--
-- TOC entry 2937 (class 2620 OID 25766)
-- Name: items min_used_space; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER min_used_space BEFORE DELETE ON public.items FOR EACH ROW EXECUTE FUNCTION public.min_used_space();


--
-- TOC entry 2938 (class 2620 OID 25386)
-- Name: items recovery_trash_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER recovery_trash_file BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_file();


--
-- TOC entry 2939 (class 2620 OID 25802)
-- Name: items recovery_trash_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER recovery_trash_folder BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_folder();


--
-- TOC entry 2930 (class 2620 OID 25380)
-- Name: items rename_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER rename_file BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_rename_file();


--
-- TOC entry 2933 (class 2620 OID 25545)
-- Name: items rename_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER rename_folder BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_rename_folder();


--
-- TOC entry 2932 (class 2620 OID 25388)
-- Name: items upload_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER upload_file AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_upload_file();


--
-- TOC entry 2929 (class 2606 OID 17240)
-- Name: logs fk_detail_activity; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_detail_activity FOREIGN KEY (activity_id) REFERENCES public.detail_activity(activity_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2925 (class 2606 OID 17245)
-- Name: items fk_owner; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_owner FOREIGN KEY (owner) REFERENCES public.users(username) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2923 (class 2606 OID 17198)
-- Name: users fk_role; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES public.detail_role(role_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2924 (class 2606 OID 17203)
-- Name: users fk_status; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES public.detail_status(status_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2926 (class 2606 OID 25531)
-- Name: items fk_trash_status; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_trash_status FOREIGN KEY (trash_status) REFERENCES public.detail_trash(trash_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2927 (class 2606 OID 25569)
-- Name: items fk_type_id; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES public.detail_type(type_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2928 (class 2606 OID 17235)
-- Name: logs fk_username; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_username FOREIGN KEY (username) REFERENCES public.users(username) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


-- Completed on 2021-01-24 21:05:56 WIB

--
-- PostgreSQL database dump complete
--

