--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2 (Ubuntu 13.2-1.pgdg20.04+1)
-- Dumped by pg_dump version 13.2 (Ubuntu 13.2-1.pgdg20.04+1)

-- Started on 2021-03-28 19:41:28 WIB

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
-- TOC entry 251 (class 1255 OID 43405)
-- Name: add_file(character varying, character varying, character varying, character varying, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_file(item_id_param character varying, parent_id_param character varying, user_id_param character varying, file_name_param character varying, size_param numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO item
    (id, parent_id, user_id, item_name, size, type_id, trash_id)
    VALUES
    (item_id_param, parent_id_param, user_id_param, file_name_param, size_param, 1, 0);
END
$$;


ALTER FUNCTION public.add_file(item_id_param character varying, parent_id_param character varying, user_id_param character varying, file_name_param character varying, size_param numeric) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 43406)
-- Name: add_folder(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_folder(item_id_param character varying, parent_id_param character varying, user_id_param character varying, folder_name_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO item
    (id, parent_id, user_id, item_name, size, type_id, trash_id)
    VALUES
    (item_id_param, parent_id_param, user_id_param, folder_name_param, 0, 2, 0);
END
$$;


ALTER FUNCTION public.add_folder(item_id_param character varying, parent_id_param character varying, user_id_param character varying, folder_name_param character varying) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 43393)
-- Name: add_user(character varying, character varying, character varying, character varying, character varying, character varying, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_user(id_user_param character varying, username_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO users
        (id, username, password, role_id)
    VALUES
        (id_user_param, username_param, password_param,2);

    INSERT INTO user_detail
        (user_id, name, phone, email, created_date)
    VALUES
        (id_user_param, name_param, phone_param, email_param, now());

    INSERT INTO user_space
        (user_id, space, used_space)
    VALUES
        (id_user_param, (space_param * 1000000000), 0);

    INSERT INTO user_status
        (user_id, last_login)
    VALUES
        (id_user_param, now());
END
$$;


ALTER FUNCTION public.add_user(id_user_param character varying, username_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 43528)
-- Name: delete_file_dependency(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_file_dependency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
        IF NEW.trash_id = 2
 	    AND OLD.type_id = 2 THEN
 	UPDATE item set trash_id = 2 WHERE parent_id = OLD.id;
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.delete_file_dependency() OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 43363)
-- Name: delete_item(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_item(item_id_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE item SET trash_id = 1
    WHERE id = item_id_param AND trash_id = 0;
END
$$;


ALTER FUNCTION public.delete_item(item_id_param character varying) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 43364)
-- Name: delete_trash(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.delete_trash(item_id_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
--     hapus item
--     DELETE FROM item
--     WHERE id = item_id_param
--     AND trash_id = 1 ;
    
    UPDATE item SET  trash_id = 2
    WHERE id = item_id_param AND trash_id = 1;
END
$$;


ALTER FUNCTION public.delete_trash(item_id_param character varying) OWNER TO postgres;

--
-- TOC entry 229 (class 1255 OID 43365)
-- Name: edit_user(character varying, character varying, character varying, character varying, character varying, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.edit_user(user_id_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_detail SET name = name_param,
                           phone = phone_param,
                           email = email_param
    WHERE user_id = user_id_param;

    UPDATE user_space SET space = (space_param * 1000000000)
    WHERE user_id = user_id_param;
    
    UPDATE users SET password = password_param
    WHERE id = user_id_param;

END
$$;


ALTER FUNCTION public.edit_user(user_id_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 44322)
-- Name: get_file_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_file_list(id_parent_param character varying) RETURNS TABLE(id_item character varying, item_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT item.id, item.item_name FROM item
        WHERE parent_id = id_parent_param
        AND type_id = 1
        AND trash_id = 0;
END
$$;


ALTER FUNCTION public.get_file_list(id_parent_param character varying) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 44323)
-- Name: get_folder_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_folder_list(id_parent_param character varying) RETURNS TABLE(id_item character varying, item_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT item.id, item.item_name FROM item
        WHERE parent_id = id_parent_param
        AND type_id = 2
        AND trash_id = 0;
END
$$;


ALTER FUNCTION public.get_folder_list(id_parent_param character varying) OWNER TO postgres;

--
-- TOC entry 267 (class 1255 OID 44342)
-- Name: get_information_storage(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_information_storage(user_id_param character varying) RETURNS TABLE(var_used_space character varying, var_total_space character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
     SELECT round(used_space * 0.000000001, 2)::varchar, (round(space * 0.000000001, 2)::integer)::varchar
     FROM
          user_space
     WHERE user_id = user_id_param;
END
$$;


ALTER FUNCTION public.get_information_storage(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 43532)
-- Name: get_item_name(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_item_name(item_id_param character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_name varchar;
BEGIN
     SELECT item_name
     INTO var_name
     FROM item
     WHERE id = item_id_param;

     RETURN var_name;
END
$$;


ALTER FUNCTION public.get_item_name(item_id_param character varying) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 43386)
-- Name: get_log_activity(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_log_activity(page_param integer) RETURNS TABLE(id character varying, name character varying, activity_date text, last_activity character varying, kuota text, status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM view_log_activity
        LIMIT 10 OFFSET (page_param-1) * 10;
END
$$;


ALTER FUNCTION public.get_log_activity(page_param integer) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 43739)
-- Name: get_log_activity_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_log_activity_count() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_result int;
BEGIN
    SELECT count(*)
    INTO var_result
    FROM view_log_activity;

     RETURN var_result;
END
$$;


ALTER FUNCTION public.get_log_activity_count() OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 43369)
-- Name: get_name(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_name(user_id_param character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_name varchar;
BEGIN
     SELECT name
     INTO var_name
     FROM user_detail
     WHERE user_id = user_id_param;

     RETURN var_name;
END
$$;


ALTER FUNCTION public.get_name(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 44244)
-- Name: get_parent_id(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_parent_id(item_id_param character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    DECLARE var_parent_id varchar;
BEGIN
        SELECT item.parent_id INTO var_parent_id FROM item
        WHERE id = item_id_param ;
    return var_parent_id;
END
$$;


ALTER FUNCTION public.get_parent_id(item_id_param character varying) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 44324)
-- Name: get_trash_file_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_trash_file_list(user_id_param character varying) RETURNS TABLE(id_item character varying, item_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT item.id, item.item_name FROM item
        WHERE user_id = user_id_param
        AND type_id = 1
        AND trash_id = 1;
END
$$;


ALTER FUNCTION public.get_trash_file_list(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 44325)
-- Name: get_trash_folder_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_trash_folder_list(user_id_param character varying) RETURNS TABLE(id_item character varying, item_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT item.id, item.item_name FROM item
        WHERE user_id = user_id_param
        AND type_id = 2
        AND trash_id = 1;
END
$$;


ALTER FUNCTION public.get_trash_folder_list(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 44152)
-- Name: get_user_information(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_information(user_id_param character varying) RETURNS TABLE(username character varying, name character varying, phone character varying, email character varying, space numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
     RETURN QUERY SELECT u.username, ud.name, ud.phone ,ud.email , (us.space * 0.000000001)
     FROM user_detail ud
     INNER JOIN users u on u.id = ud.user_id
     INNER JOIN user_space us on u.id = us.user_id
     WHERE id = user_id_param;
END
$$;


ALTER FUNCTION public.get_user_information(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 230 (class 1255 OID 43392)
-- Name: get_user_log_activity(character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_log_activity(user_id_param character varying, page_param integer) RETURNS TABLE(activity_date text, activity text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        to_char(l.activity_date::timestamp with time zone, 'Day, DD-MM-YYYY'::text) AS activity_date,
        CASE WHEN (length(concat(da.description, ' ' ,i.item_name)) >= 50)
        THEN overlay(left(concat(da.description, ' ' ,i.item_name),50)placing '...' from 48 for 50)
        ELSE concat(da.description, ' ' ,i.item_name) END
        AS activity
    FROM
        log l
    INNER JOIN detail_activity da on l.activity_id = da.id
    INNER JOIN item i on l.item_id = i.id
    WHERE
        l.user_id = user_id_param
AND l.activity_date >= 'now'::timestamp - '1 month'::interval
    ORDER BY l.activity_date DESC
    LIMIT 10 OFFSET (page_param-1)*10;
END;
$$;


ALTER FUNCTION public.get_user_log_activity(user_id_param character varying, page_param integer) OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 43373)
-- Name: get_user_log_activity_count(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_log_activity_count(user_id_param character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_result int;
BEGIN
    SELECT count(*)
    INTO var_result
    FROM log
    WHERE user_id = user_id_param;

     RETURN var_result;
END
$$;


ALTER FUNCTION public.get_user_log_activity_count(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 44341)
-- Name: get_username(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_username(user_id_param character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_username varchar;
BEGIN
     SELECT username
     INTO var_username
     FROM users
     WHERE id = user_id_param;

     RETURN var_username;
END
$$;


ALTER FUNCTION public.get_username(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 43353)
-- Name: is_admin(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_admin(user_id_param character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS(
            SELECT username
            FROM users
            WHERE id = user_id_param
            AND role_id = 1
    );
END
$$;


ALTER FUNCTION public.is_admin(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 44343)
-- Name: is_duplicate_name(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_duplicate_name(parent_id_param character varying, item_name_param character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS(
            SELECT item_name
            FROM item
            WHERE lower(item_name) = lower(item_name_param)
            AND parent_id = parent_id_param
            AND trash_id = 0
    );
END
$$;


ALTER FUNCTION public.is_duplicate_name(parent_id_param character varying, item_name_param character varying) OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 43375)
-- Name: is_enough_space(character varying, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_enough_space(user_id_param character varying, size_param numeric) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE 
    var_result boolean;
BEGIN
    SELECT (space - used_space) > size_param
    INTO var_result
    FROM user_space
    WHERE user_space.user_id = user_id_param;
    
    RETURN var_result;
END
$$;


ALTER FUNCTION public.is_enough_space(user_id_param character varying, size_param numeric) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 43352)
-- Name: is_user(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_user(user_id character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS(
            SELECT username
            FROM users
            WHERE id = user_id
            AND role_id = 2
    );
END
$$;


ALTER FUNCTION public.is_user(user_id character varying) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 42933)
-- Name: is_username_exist(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_username_exist(username_param character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS(
            SELECT username
            FROM users
            WHERE username = username_param
    );
END
$$;


ALTER FUNCTION public.is_username_exist(username_param character varying) OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 25741)
-- Name: log_create_folder(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_create_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.type_id = 2 THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(NEW.user_id, NEW.id, 1, NEW.item_name, now());
END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_create_folder() OWNER TO akdev;

--
-- TOC entry 248 (class 1255 OID 42457)
-- Name: log_delete_file(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_delete_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_id = 0 AND NEW.trash_id = 1
 	    AND OLD.type_id = 1
 	    THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(OLD.user_id, OLD.id, 7, OLD.item_name, now());
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_delete_file() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 42459)
-- Name: log_delete_folder(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_delete_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_id = 0 AND NEW.trash_id = 1
 	    AND OLD.type_id = 2 THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(OLD.user_id, OLD.id, 4, OLD.item_name, now());
 END IF;
 RETURN NEW;
    
--  	IF OLD.trash_id = 0 AND NEW.trash_id = 1
--  	    AND OLD.type_id = 2 THEN
--  	INSERT INTO log
--  	(user_id, item_id, activity_id, item_name, activity_date)
--  	VALUES
--  	(OLD.user_id, OLD.id, 4, OLD.item_name, now());
--  END IF;
--  RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_delete_folder() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 42982)
-- Name: log_delete_trash_file(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_delete_trash_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.trash_id = 1 AND NEW.trash_id = 2
 	    AND OLD.type_id = 1
 	    THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(OLD.user_id, OLD.id, 10, OLD.item_name, now());
 END IF;
     RETURN NEW;

--     IF OLD.type_id = 1 THEN
--  	INSERT INTO log
--  	(user_id, item_id, activity_id, item_name, activity_date)
--  	VALUES
--  	(OLD.user_id, OLD.id, 10, OLD.item_name, now());
--  	END IF;
--  RETURN OLD;
 END;
$$;


ALTER FUNCTION public.log_delete_trash_file() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 42983)
-- Name: log_delete_trash_folder(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_delete_trash_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	 IF OLD.trash_id = 1 AND NEW.trash_id = 2
 	    AND OLD.type_id = 2 THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(OLD.user_id, OLD.id, 11, OLD.item_name, now());
 	END IF;
 	RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_delete_trash_folder() OWNER TO postgres;

--
-- TOC entry 224 (class 1255 OID 25385)
-- Name: log_recovery_trash_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_recovery_trash_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_id = 1 AND NEW.trash_id = 0
 	    AND OLD.type_id = 1
 	    THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(OLD.user_id, OLD.id, 9,  OLD.item_name, now());
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_recovery_trash_file() OWNER TO akdev;

--
-- TOC entry 234 (class 1255 OID 25801)
-- Name: log_recovery_trash_folder(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_recovery_trash_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF OLD.trash_id = 1 AND NEW.trash_id = 0
 	    AND OLD.type_id = 2
 	    THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(OLD.user_id, OLD.id, 5,OLD.item_name,  now());
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_recovery_trash_folder() OWNER TO akdev;

--
-- TOC entry 225 (class 1255 OID 25378)
-- Name: log_rename_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_rename_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF NEW.item_name != OLD.item_name
 	    AND OLD.type_id = 1
 	   THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(OLD.user_id, OLD.id, 8, OLD.item_name, now());
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_rename_file() OWNER TO akdev;

--
-- TOC entry 228 (class 1255 OID 25544)
-- Name: log_rename_folder(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_rename_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF NEW.item_name != OLD.item_name 
 	    AND OLD.type_id = 2  THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(OLD.user_id, OLD.id, 3, OLD.item_name,  now());
 END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_rename_folder() OWNER TO akdev;

--
-- TOC entry 226 (class 1255 OID 25387)
-- Name: log_upload_file(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_upload_file() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.type_id = 1 THEN
 	INSERT INTO log
 	(user_id, item_id, activity_id, item_name, activity_date)
 	VALUES
 	(NEW.user_id, NEW.id, 6, NEW.item_name, now());
END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_upload_file() OWNER TO akdev;

--
-- TOC entry 237 (class 1255 OID 43376)
-- Name: recovery_item(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recovery_item(item_id_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE item SET trash_id = 0
    WHERE id = item_id_param;
END
$$;


ALTER FUNCTION public.recovery_item(item_id_param character varying) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 43377)
-- Name: rename_item(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.rename_item(item_id_param character varying, item_name_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE item SET item_name = item_name_param
    WHERE id = item_id_param;
END
$$;


ALTER FUNCTION public.rename_item(item_id_param character varying, item_name_param character varying) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 44327)
-- Name: search_item(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_item(user_id_param character varying, keyword_param character varying) RETURNS TABLE(item_id character varying, name_item character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT i.id, i.item_name FROM item i
        WHERE lower(i.item_name) like lower('%' || keyword_param || '%')
          AND i.user_id = user_id_param
        ORDER BY i.type_id,i.item_name;
END
$$;


ALTER FUNCTION public.search_item(user_id_param character varying, keyword_param character varying) OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 44333)
-- Name: search_user(character varying, integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_user(keyword_name_param character varying, keyword_activity_id integer, keyword_start_date date, keyword_end_date date) RETURNS TABLE(id character varying, name character varying, activity_date text, last_activity character varying, kuota text, status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT ud.user_id::varchar                       AS id,
       ud.name::varchar,
       to_char(t2.activity_date::timestamp without time zone,
               'Day, DD-MM-YYYY') AS activity_date,
       da.description                   AS last_activity,
       concat(round(usp.used_space * 0.000000001, 2), ' Gb / ', round(usp.space * 0.000000001, 2)::integer,
              ' Gb')                    AS kuota,
       ds.description                   AS status
FROM log l
         JOIN (SELECT log.user_id,
                      max(log.activity_date) AS activity_date
               FROM log
               GROUP BY log.user_id) t2 ON l.user_id = t2.user_id AND l.activity_date = t2.activity_date
         RIGHT JOIN user_detail ud ON ud.user_id = l.user_id
         LEFT JOIN detail_activity da ON da.id = l.activity_id
         LEFT JOIN user_space usp ON usp.user_id = ud.user_id
         LEFT JOIN user_status us ON ud.user_id = us.user_id
         LEFT JOIN detail_status ds ON us.status_id = ds.id
         LEFT JOIN users u ON u.id = ud.user_id
 WHERE lower(ud.name) like lower('%' || keyword_name_param || '%') AND
          da.id = keyword_activity_id AND
          t2.activity_date::timestamp without time zone BETWEEN keyword_start_date::timestamp without time zone AND keyword_end_date::timestamp without time zone;
    END

$$;


ALTER FUNCTION public.search_user(keyword_name_param character varying, keyword_activity_id integer, keyword_start_date date, keyword_end_date date) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 44326)
-- Name: set_offline(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_offline(user_id_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_status
    SET status_id = 0
    WHERE user_id = user_id_param;
END
$$;


ALTER FUNCTION public.set_offline(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 43362)
-- Name: set_online(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_online(user_id_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_status
    SET status_id = 1
    WHERE user_id = user_id_param;

    UPDATE user_status
    SET last_login = now()
    WHERE user_id = user_id_param;
END
$$;


ALTER FUNCTION public.set_online(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 25764)
-- Name: used_space_dec(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.used_space_dec() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF OLD.trash_id = 0 OR OLD.trash_id = 1 AND NEW.trash_id = 2 THEN
            UPDATE user_space SET used_space = used_space - OLD.size
        WHERE user_id = OLD.user_id;
            end if;
 RETURN new;
--         UPDATE user_space SET used_space = used_space - OLD.size
--         WHERE user_id = OLD.user_id;
--  RETURN OLD;
 END;
$$;


ALTER FUNCTION public.used_space_dec() OWNER TO akdev;

--
-- TOC entry 235 (class 1255 OID 25762)
-- Name: used_space_inc(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.used_space_inc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.type_id = 1 THEN
        UPDATE user_space SET used_space = used_space + NEW.size
        WHERE user_id = NEW.user_id;
    end if;

 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.used_space_inc() OWNER TO akdev;

--
-- TOC entry 227 (class 1255 OID 43325)
-- Name: verify_login(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verify_login(username_param character varying, password_param character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_user_id varchar;
BEGIN
    SELECT id INTO var_user_id FROM users
    WHERE username = username_param AND password = password_param;
    RETURN var_user_id;
END
$$;


ALTER FUNCTION public.verify_login(username_param character varying, password_param character varying) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 200 (class 1259 OID 16887)
-- Name: detail_activity; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_activity (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);


ALTER TABLE public.detail_activity OWNER TO akdev;

--
-- TOC entry 201 (class 1259 OID 17009)
-- Name: detail_role; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_role (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);


ALTER TABLE public.detail_role OWNER TO akdev;

--
-- TOC entry 202 (class 1259 OID 17093)
-- Name: detail_status; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_status (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);


ALTER TABLE public.detail_status OWNER TO akdev;

--
-- TOC entry 203 (class 1259 OID 25457)
-- Name: detail_trash; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_trash (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);


ALTER TABLE public.detail_trash OWNER TO akdev;

--
-- TOC entry 204 (class 1259 OID 25546)
-- Name: detail_type; Type: TABLE; Schema: public; Owner: akdev
--

CREATE TABLE public.detail_type (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);


ALTER TABLE public.detail_type OWNER TO akdev;

--
-- TOC entry 212 (class 1259 OID 43462)
-- Name: item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item (
    id character varying(36) NOT NULL,
    parent_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    item_name character varying(250) NOT NULL,
    size numeric NOT NULL,
    type_id integer NOT NULL,
    trash_id integer NOT NULL
);


ALTER TABLE public.item OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 43281)
-- Name: log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log (
    id integer NOT NULL,
    user_id character varying(36) NOT NULL,
    item_id character varying(36) NOT NULL,
    activity_id integer NOT NULL,
    item_name character varying(255) NOT NULL,
    activity_date timestamp without time zone NOT NULL
);


ALTER TABLE public.log OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 43410)
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_id_seq OWNER TO postgres;

--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 211
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- TOC entry 205 (class 1259 OID 43253)
-- Name: user_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_detail (
    user_id character varying(36) NOT NULL,
    name character varying(30) NOT NULL,
    phone character varying(15) NOT NULL,
    email character varying(50) NOT NULL,
    created_date timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_detail OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 43259)
-- Name: user_space; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_space (
    user_id character varying(36) NOT NULL,
    space numeric NOT NULL,
    used_space numeric NOT NULL
);


ALTER TABLE public.user_space OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 43267)
-- Name: user_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_status (
    user_id character varying(36) NOT NULL,
    status_id integer DEFAULT 0 NOT NULL,
    last_login timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_status OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 43326)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying(36) NOT NULL,
    username character varying(35) NOT NULL,
    password character varying(255) NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 43354)
-- Name: view_log_activity; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_log_activity AS
 SELECT ud.user_id AS id,
    ud.name,
    to_char(t2.activity_date, 'Day, DD-MM-YYYY'::text) AS activity_date,
    da.description AS last_activity,
    concat(round((usp.used_space * 0.000000001), 2), ' Gb / ', (round((usp.space * 0.000000001), 2))::integer, ' Gb') AS kuota,
    ds.description AS status
   FROM (((((((public.log l
     JOIN ( SELECT log.user_id,
            max(log.activity_date) AS activity_date
           FROM public.log
          GROUP BY log.user_id) t2 ON ((((l.user_id)::text = (t2.user_id)::text) AND (l.activity_date = t2.activity_date))))
     RIGHT JOIN public.user_detail ud ON (((ud.user_id)::text = (l.user_id)::text)))
     LEFT JOIN public.detail_activity da ON ((da.id = l.activity_id)))
     LEFT JOIN public.user_space usp ON (((usp.user_id)::text = (ud.user_id)::text)))
     LEFT JOIN public.user_status us ON (((ud.user_id)::text = (us.user_id)::text)))
     LEFT JOIN public.detail_status ds ON ((us.status_id = ds.id)))
     LEFT JOIN public.users u ON (((u.id)::text = (ud.user_id)::text)))
  WHERE (u.role_id = 2)
  ORDER BY ud.name;


ALTER TABLE public.view_log_activity OWNER TO postgres;

--
-- TOC entry 2918 (class 2604 OID 43412)
-- Name: log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- TOC entry 3098 (class 0 OID 16887)
-- Dependencies: 200
-- Data for Name: detail_activity; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_activity (id, description) FROM stdin;
8	Rename File
7	Delete File
10	Delete Trash File
6	Upload File
5	Recovery Folder
4	Delete Folder
3	Rename Folder
2	Upload Folder
1	Create Folder
9	Recovery File
11	Delete Trash Folder
\.


--
-- TOC entry 3099 (class 0 OID 17009)
-- Dependencies: 201
-- Data for Name: detail_role; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_role (id, description) FROM stdin;
1	admin
2	user
\.


--
-- TOC entry 3100 (class 0 OID 17093)
-- Dependencies: 202
-- Data for Name: detail_status; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_status (id, description) FROM stdin;
0	Nonaktif
1	Aktif
\.


--
-- TOC entry 3101 (class 0 OID 25457)
-- Dependencies: 203
-- Data for Name: detail_trash; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_trash (id, description) FROM stdin;
1	trash
0	nontrash
2	permanent_delete
\.


--
-- TOC entry 3102 (class 0 OID 25546)
-- Dependencies: 204
-- Data for Name: detail_type; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_type (id, description) FROM stdin;
2	folder
1	file
\.


--
-- TOC entry 3109 (class 0 OID 43462)
-- Dependencies: 212
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item (id, parent_id, user_id, item_name, size, type_id, trash_id) FROM stdin;
1c8e688b-fbcf-91f4-bf1b-14a1bf9619af	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	coba pertama create	0	2	2
9067a98d-da41-c079-7818-0f2abb14cf84	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	coba pertama create	0	2	2
ca07d529-d7d8-50ea-8931-966b7f863ef3	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	coba pertama create	0	2	2
f41b4be0-d3b6-57ac-1dfd-5c9ce12dc6c5	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	coba pertama create	0	2	0
d0b7256e-01c4-55f8-b5fa-7980f0c18244	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	g.jpg	177881	1	0
68a4df77-240e-7bd1-fa82-4c4423c23df4	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	f.jpg	18896	1	0
c9e0dccc-2078-41c1-99ad-6b41b9224243	8fb9a7da-5ec3-47c9-9274-611849ac51ee	56bbd44b-5cb2-4285-9cf9-4d239e175aec	Belajar Dart Fundamental dan OOP	0	2	0
42eb48f2-d731-400c-a1cf-99bdc29bc11d	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	HelloWorld.doc	250000000	1	1
58b44abf-a99d-4b70-b3a7-9b9b2b280434	8fb9a7da-5ec3-47c9-9274-611849ac51ee	56bbd44b-5cb2-4285-9cf9-4d239e175aec	HelloWorld.dart	15000000	1	0
8fb9a7da-5ec3-47c9-9274-611849ac51ee	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	Belajar Flutter	0	2	0
6a17824d-151c-e996-03ce-e806de2aef5e	56bbd44b-5cb2-4285-9cf9-4d239e175aec	56bbd44b-5cb2-4285-9cf9-4d239e175aec	coba pertama create	0	2	2
\.


--
-- TOC entry 3106 (class 0 OID 43281)
-- Dependencies: 208
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log (id, user_id, item_id, activity_id, item_name, activity_date) FROM stdin;
68	56bbd44b-5cb2-4285-9cf9-4d239e175aec	8fb9a7da-5ec3-47c9-9274-611849ac51ee	1	Belajar Flutter	2021-03-20 08:18:33.438267
69	56bbd44b-5cb2-4285-9cf9-4d239e175aec	58b44abf-a99d-4b70-b3a7-9b9b2b280434	6	HelloWorld.dart	2021-03-20 08:21:16.084374
70	56bbd44b-5cb2-4285-9cf9-4d239e175aec	58b44abf-a99d-4b70-b3a7-9b9b2b280434	7	HelloWorld.dart	2021-03-20 08:22:42.009977
72	56bbd44b-5cb2-4285-9cf9-4d239e175aec	58b44abf-a99d-4b70-b3a7-9b9b2b280434	9	HelloWorld.dart	2021-03-20 08:27:59.646109
73	56bbd44b-5cb2-4285-9cf9-4d239e175aec	42eb48f2-d731-400c-a1cf-99bdc29bc11d	6	HelloWorld.io	2021-03-20 08:44:31.730901
74	56bbd44b-5cb2-4285-9cf9-4d239e175aec	42eb48f2-d731-400c-a1cf-99bdc29bc11d	7	HelloWorld.io	2021-03-20 08:44:36.461669
75	56bbd44b-5cb2-4285-9cf9-4d239e175aec	c9e0dccc-2078-41c1-99ad-6b41b9224243	1	Belajar Dart OOP	2021-03-20 08:47:00.441551
76	56bbd44b-5cb2-4285-9cf9-4d239e175aec	c9e0dccc-2078-41c1-99ad-6b41b9224243	4	Belajar Dart OOP	2021-03-20 08:47:03.115901
77	56bbd44b-5cb2-4285-9cf9-4d239e175aec	c9e0dccc-2078-41c1-99ad-6b41b9224243	5	Belajar Dart OOP	2021-03-20 08:57:51.305832
78	56bbd44b-5cb2-4285-9cf9-4d239e175aec	c9e0dccc-2078-41c1-99ad-6b41b9224243	3	Belajar Dart OOP	2021-03-20 08:59:14.413567
79	56bbd44b-5cb2-4285-9cf9-4d239e175aec	c9e0dccc-2078-41c1-99ad-6b41b9224243	4	Belajar Dart Fundamental dan OOP	2021-03-26 11:45:28.490745
80	56bbd44b-5cb2-4285-9cf9-4d239e175aec	58b44abf-a99d-4b70-b3a7-9b9b2b280434	7	HelloWorld.dart	2021-03-26 12:39:56.984913
81	56bbd44b-5cb2-4285-9cf9-4d239e175aec	8fb9a7da-5ec3-47c9-9274-611849ac51ee	4	Belajar Flutter	2021-03-26 12:40:00.210463
82	56bbd44b-5cb2-4285-9cf9-4d239e175aec	c9e0dccc-2078-41c1-99ad-6b41b9224243	5	Belajar Dart Fundamental dan OOP	2021-03-26 20:50:22.947127
83	56bbd44b-5cb2-4285-9cf9-4d239e175aec	42eb48f2-d731-400c-a1cf-99bdc29bc11d	9	HelloWorld.io	2021-03-26 14:05:45.141072
84	56bbd44b-5cb2-4285-9cf9-4d239e175aec	42eb48f2-d731-400c-a1cf-99bdc29bc11d	8	HelloWorld.io	2021-03-26 14:05:52.887571
85	56bbd44b-5cb2-4285-9cf9-4d239e175aec	42eb48f2-d731-400c-a1cf-99bdc29bc11d	7	HelloWorld.doc	2021-03-26 14:05:56.523281
86	56bbd44b-5cb2-4285-9cf9-4d239e175aec	58b44abf-a99d-4b70-b3a7-9b9b2b280434	9	HelloWorld.dart	2021-03-27 14:22:48.792904
87	56bbd44b-5cb2-4285-9cf9-4d239e175aec	8fb9a7da-5ec3-47c9-9274-611849ac51ee	5	Belajar Flutter	2021-03-27 08:33:02.290104
88	56bbd44b-5cb2-4285-9cf9-4d239e175aec	6a17824d-151c-e996-03ce-e806de2aef5e	1	coba pertama create	2021-03-27 17:31:13.601136
89	56bbd44b-5cb2-4285-9cf9-4d239e175aec	6a17824d-151c-e996-03ce-e806de2aef5e	4	coba pertama create	2021-03-27 10:34:45.51092
90	56bbd44b-5cb2-4285-9cf9-4d239e175aec	6a17824d-151c-e996-03ce-e806de2aef5e	11	coba pertama create	2021-03-27 10:34:48.710189
91	56bbd44b-5cb2-4285-9cf9-4d239e175aec	1c8e688b-fbcf-91f4-bf1b-14a1bf9619af	1	coba pertama create	2021-03-27 17:34:53.343816
92	56bbd44b-5cb2-4285-9cf9-4d239e175aec	1c8e688b-fbcf-91f4-bf1b-14a1bf9619af	4	coba pertama create	2021-03-27 10:37:22.162782
93	56bbd44b-5cb2-4285-9cf9-4d239e175aec	1c8e688b-fbcf-91f4-bf1b-14a1bf9619af	11	coba pertama create	2021-03-27 10:37:32.6794
94	56bbd44b-5cb2-4285-9cf9-4d239e175aec	9067a98d-da41-c079-7818-0f2abb14cf84	1	coba pertama create	2021-03-27 17:37:43.936258
95	56bbd44b-5cb2-4285-9cf9-4d239e175aec	9067a98d-da41-c079-7818-0f2abb14cf84	4	coba pertama create	2021-03-27 10:39:37.1265
96	56bbd44b-5cb2-4285-9cf9-4d239e175aec	9067a98d-da41-c079-7818-0f2abb14cf84	11	coba pertama create	2021-03-27 10:39:41.050646
97	56bbd44b-5cb2-4285-9cf9-4d239e175aec	ca07d529-d7d8-50ea-8931-966b7f863ef3	1	coba pertama create	2021-03-27 17:39:43.25718
98	56bbd44b-5cb2-4285-9cf9-4d239e175aec	ca07d529-d7d8-50ea-8931-966b7f863ef3	4	coba pertama create	2021-03-27 10:41:22.371777
99	56bbd44b-5cb2-4285-9cf9-4d239e175aec	ca07d529-d7d8-50ea-8931-966b7f863ef3	11	coba pertama create	2021-03-27 10:41:24.770572
100	56bbd44b-5cb2-4285-9cf9-4d239e175aec	f41b4be0-d3b6-57ac-1dfd-5c9ce12dc6c5	1	coba pertama create	2021-03-27 17:41:32.743976
101	56bbd44b-5cb2-4285-9cf9-4d239e175aec	d0b7256e-01c4-55f8-b5fa-7980f0c18244	6	g.jpg	2021-03-27 19:31:12.046449
102	56bbd44b-5cb2-4285-9cf9-4d239e175aec	68a4df77-240e-7bd1-fa82-4c4423c23df4	6	f.jpg	2021-03-27 19:31:12.095656
\.


--
-- TOC entry 3103 (class 0 OID 43253)
-- Dependencies: 205
-- Data for Name: user_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_detail (user_id, name, phone, email, created_date) FROM stdin;
ae71ad0e-f498-4066-8c5a-93411b59215f	Roni Starko Firdaus	+6282190908989	rsf.project25@gmail.com	2021-03-26 09:11:54.088792
55d259d5-9ba4-1e8f-89f2-01135c58c817	febyk	+6281373107544	feals@gmail.com	2021-03-26 17:25:11.109723
56bbd44b-5cb2-4285-9cf9-4d239e175aec	Adi Kun	+6282182751010	hello.adikurniawan@gmail.com	2021-03-20 08:12:02.574164
\.


--
-- TOC entry 3104 (class 0 OID 43259)
-- Dependencies: 206
-- Data for Name: user_space; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_space (user_id, space, used_space) FROM stdin;
ae71ad0e-f498-4066-8c5a-93411b59215f	12000000000	0
55d259d5-9ba4-1e8f-89f2-01135c58c817	2000000000	0
56bbd44b-5cb2-4285-9cf9-4d239e175aec	21000000000	500196777
\.


--
-- TOC entry 3105 (class 0 OID 43267)
-- Dependencies: 207
-- Data for Name: user_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_status (user_id, status_id, last_login) FROM stdin;
56bbd44b-5cb2-4285-9cf9-4d239e175aec	1	2021-03-26 19:48:24.413495
ae71ad0e-f498-4066-8c5a-93411b59215f	1	2021-03-26 19:49:42.347643
55d259d5-9ba4-1e8f-89f2-01135c58c817	0	2021-03-26 17:25:11.109723
\.


--
-- TOC entry 3107 (class 0 OID 43326)
-- Dependencies: 209
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, role_id) FROM stdin;
ae71ad0e-f498-4066-8c5a-93411b59215f	rsf	uN3kUITsovYN__Fkf1JbGp6RogstwVvZqwAvLXgkemk=	1
55d259d5-9ba4-1e8f-89f2-01135c58c817	feals	zBH82RmmovZ3fxYnZ5lACRbb9kd5kfGZZW9CeOE2aIQ=	2
56bbd44b-5cb2-4285-9cf9-4d239e175aec	akdev	Hg6xftqVTlEiSTkAEvB3plSfvi1yyZgx29xFDtDQ4fI=	2
\.


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 211
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_id_seq', 102, true);


--
-- TOC entry 2920 (class 2606 OID 42765)
-- Name: detail_activity detail_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_activity
    ADD CONSTRAINT detail_activity_pkey PRIMARY KEY (id);


--
-- TOC entry 2924 (class 2606 OID 42777)
-- Name: detail_status detail_status_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_status
    ADD CONSTRAINT detail_status_pk PRIMARY KEY (id);


--
-- TOC entry 2930 (class 2606 OID 42793)
-- Name: detail_type detail_type_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_type
    ADD CONSTRAINT detail_type_pk PRIMARY KEY (id);


--
-- TOC entry 2944 (class 2606 OID 43469)
-- Name: item item_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pk PRIMARY KEY (id);


--
-- TOC entry 2939 (class 2606 OID 43400)
-- Name: log log_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pk PRIMARY KEY (id);


--
-- TOC entry 2922 (class 2606 OID 42771)
-- Name: detail_role role_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- TOC entry 2927 (class 2606 OID 42785)
-- Name: detail_trash status_trash_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_trash
    ADD CONSTRAINT status_trash_pk PRIMARY KEY (id);


--
-- TOC entry 2933 (class 2606 OID 43258)
-- Name: user_detail user_detail_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT user_detail_pk PRIMARY KEY (user_id);


--
-- TOC entry 2935 (class 2606 OID 43266)
-- Name: user_space user_space_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_space
    ADD CONSTRAINT user_space_pk PRIMARY KEY (user_id);


--
-- TOC entry 2937 (class 2606 OID 43273)
-- Name: user_status user_status_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT user_status_pk PRIMARY KEY (user_id);


--
-- TOC entry 2941 (class 2606 OID 43331)
-- Name: users users_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);


--
-- TOC entry 2925 (class 1259 OID 42778)
-- Name: detail_status_status_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_status_status_id_uindex ON public.detail_status USING btree (id);


--
-- TOC entry 2931 (class 1259 OID 42794)
-- Name: detail_type_type_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_type_type_id_uindex ON public.detail_type USING btree (id);


--
-- TOC entry 2928 (class 1259 OID 42786)
-- Name: status_trash_trash_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX status_trash_trash_id_uindex ON public.detail_trash USING btree (id);


--
-- TOC entry 2942 (class 1259 OID 43329)
-- Name: users_username_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username_uindex ON public.users USING btree (username);


--
-- TOC entry 2958 (class 2620 OID 43480)
-- Name: item log_create_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_create_folder AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_create_folder();


--
-- TOC entry 2959 (class 2620 OID 43481)
-- Name: item log_delete_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_file();


--
-- TOC entry 2956 (class 2620 OID 43529)
-- Name: item log_delete_file_dependency; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_file_dependency AFTER UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.delete_file_dependency();


--
-- TOC entry 2960 (class 2620 OID 43482)
-- Name: item log_delete_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_folder();


--
-- TOC entry 2954 (class 2620 OID 43511)
-- Name: item log_delete_trash_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_trash_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_trash_file();


--
-- TOC entry 2955 (class 2620 OID 43512)
-- Name: item log_delete_trash_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_trash_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_trash_folder();


--
-- TOC entry 2961 (class 2620 OID 43483)
-- Name: item log_recovery_trash_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_recovery_trash_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_file();


--
-- TOC entry 2962 (class 2620 OID 43484)
-- Name: item log_recovery_trash_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_recovery_trash_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_folder();


--
-- TOC entry 2963 (class 2620 OID 43485)
-- Name: item log_rename_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_rename_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_rename_file();


--
-- TOC entry 2964 (class 2620 OID 43486)
-- Name: item log_rename_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_rename_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_rename_folder();


--
-- TOC entry 2965 (class 2620 OID 43487)
-- Name: item log_upload_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_upload_file AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_upload_file();


--
-- TOC entry 2957 (class 2620 OID 43531)
-- Name: item trigger_used_space_dec; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_used_space_dec BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.used_space_dec();


--
-- TOC entry 2966 (class 2620 OID 43489)
-- Name: item trigger_used_space_inc; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_used_space_inc AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.used_space_inc();


--
-- TOC entry 2949 (class 2606 OID 43314)
-- Name: log fk_activity_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT fk_activity_id FOREIGN KEY (activity_id) REFERENCES public.detail_activity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2950 (class 2606 OID 43523)
-- Name: log fk_item_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT fk_item_id FOREIGN KEY (item_id) REFERENCES public.item(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2951 (class 2606 OID 43347)
-- Name: users fk_role_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_role_id FOREIGN KEY (role_id) REFERENCES public.detail_role(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2947 (class 2606 OID 43304)
-- Name: user_status fk_status_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT fk_status_id FOREIGN KEY (status_id) REFERENCES public.detail_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2953 (class 2606 OID 43505)
-- Name: item fk_trash_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT fk_trash_id FOREIGN KEY (trash_id) REFERENCES public.detail_trash(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2952 (class 2606 OID 43500)
-- Name: item fk_type_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES public.detail_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2945 (class 2606 OID 43332)
-- Name: user_detail fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2946 (class 2606 OID 43337)
-- Name: user_space fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_space
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2948 (class 2606 OID 43342)
-- Name: user_status fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2021-03-28 19:41:28 WIB

--
-- PostgreSQL database dump complete
--

