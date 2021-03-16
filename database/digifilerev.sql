--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2 (Ubuntu 13.2-1.pgdg20.04+1)
-- Dumped by pg_dump version 13.2 (Ubuntu 13.2-1.pgdg20.04+1)

-- Started on 2021-03-16 23:23:05 WIB

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
-- TOC entry 262 (class 1255 OID 43533)
-- Name: add_admin(character varying, character varying, character varying, character varying, character varying, character varying, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_admin(id_user_param character varying, username_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO users
        (id, username, password, role_id)
    VALUES
        (id_user_param, username_param, password_param, 1);

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


ALTER FUNCTION public.add_admin(id_user_param character varying, username_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 43405)
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
-- TOC entry 259 (class 1255 OID 43406)
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
-- TOC entry 264 (class 1255 OID 43393)
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
-- TOC entry 260 (class 1255 OID 43528)
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
-- TOC entry 248 (class 1255 OID 43363)
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
-- TOC entry 256 (class 1255 OID 43364)
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
-- TOC entry 251 (class 1255 OID 43366)
-- Name: get_file_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_file_list(id_parent_param character varying) RETURNS TABLE(id_item uuid, item_name character varying)
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
-- TOC entry 230 (class 1255 OID 43367)
-- Name: get_folder_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_folder_list(id_parent_param character varying) RETURNS TABLE(id_item uuid, item_name character varying)
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
-- TOC entry 231 (class 1255 OID 43368)
-- Name: get_information_storage(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_information_storage(user_id_param character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE 
    var_information varchar;
BEGIN
     SELECT concat(round(used_space * 0.000000001, 2), ' Gb dari ', round(space * 0.000000001, 2)::integer,  ' Gb telah terpakai')::varchar
     INTO var_information
     FROM
          user_space
     WHERE user_id = user_id_param;

     RETURN var_information;
END
$$;


ALTER FUNCTION public.get_information_storage(user_id_param character varying) OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 43532)
-- Name: get_item_name(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_item_name(item_id_param character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_name varchar;
BEGIN
     SELECT name
     INTO var_name
     FROM user_detail
     WHERE user_id = item_id_param;

     RETURN var_name;
END
$$;


ALTER FUNCTION public.get_item_name(item_id_param character varying) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 43386)
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
-- TOC entry 263 (class 1255 OID 43739)
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
-- TOC entry 245 (class 1255 OID 43369)
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
-- TOC entry 267 (class 1255 OID 44244)
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
-- TOC entry 246 (class 1255 OID 43370)
-- Name: get_trash_file_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_trash_file_list(user_id_param character varying) RETURNS TABLE(id_item uuid, item_name character varying)
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
-- TOC entry 252 (class 1255 OID 43371)
-- Name: get_trash_folder_list(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_trash_folder_list(user_id_param character varying) RETURNS TABLE(id_item uuid, item_name character varying)
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
-- TOC entry 265 (class 1255 OID 44152)
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
-- TOC entry 232 (class 1255 OID 43392)
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
-- TOC entry 233 (class 1255 OID 43373)
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
-- TOC entry 250 (class 1255 OID 43353)
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
-- TOC entry 234 (class 1255 OID 43375)
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
-- TOC entry 244 (class 1255 OID 43352)
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
-- TOC entry 249 (class 1255 OID 42933)
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
-- TOC entry 238 (class 1255 OID 25741)
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
-- TOC entry 255 (class 1255 OID 42457)
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
-- TOC entry 254 (class 1255 OID 42459)
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
-- TOC entry 240 (class 1255 OID 42982)
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
-- TOC entry 241 (class 1255 OID 42983)
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
-- TOC entry 236 (class 1255 OID 25801)
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
-- TOC entry 239 (class 1255 OID 43376)
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
-- TOC entry 242 (class 1255 OID 43377)
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
-- TOC entry 253 (class 1255 OID 43378)
-- Name: search_item(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_item(user_id_param character varying, keyword_param character varying) RETURNS TABLE(item_id integer, name_item character varying)
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
-- TOC entry 266 (class 1255 OID 44199)
-- Name: search_user(character varying, integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_user(keyword_name_param character varying, keyword_activity_id integer, keyword_start_date date, keyword_end_date date) RETURNS TABLE(id character varying, name character varying, activity_date text, last_activity character varying, kuota text, status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT ud.user_id                       AS id,
       ud.name,
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
          t2.activity_date::date BETWEEN keyword_start_date::date AND keyword_end_date::date;
    END

$$;


ALTER FUNCTION public.search_user(keyword_name_param character varying, keyword_activity_id integer, keyword_start_date date, keyword_end_date date) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 42940)
-- Name: set_offline(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_offline(user_id_param uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_status
    SET status_id = 0
    WHERE user_id = user_id_param;
END
$$;


ALTER FUNCTION public.set_offline(user_id_param uuid) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 43362)
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
-- TOC entry 235 (class 1255 OID 25764)
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
-- TOC entry 237 (class 1255 OID 25762)
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
-- TOC entry 3114 (class 0 OID 0)
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
-- TOC entry 2917 (class 2604 OID 43412)
-- Name: log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- TOC entry 3097 (class 0 OID 16887)
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
-- TOC entry 3098 (class 0 OID 17009)
-- Dependencies: 201
-- Data for Name: detail_role; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_role (id, description) FROM stdin;
1	admin
2	user
\.


--
-- TOC entry 3099 (class 0 OID 17093)
-- Dependencies: 202
-- Data for Name: detail_status; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_status (id, description) FROM stdin;
0	Nonaktif
1	Aktif
\.


--
-- TOC entry 3100 (class 0 OID 25457)
-- Dependencies: 203
-- Data for Name: detail_trash; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_trash (id, description) FROM stdin;
1	trash
0	nontrash
2	permanent_delete
\.


--
-- TOC entry 3101 (class 0 OID 25546)
-- Dependencies: 204
-- Data for Name: detail_type; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_type (id, description) FROM stdin;
2	folder
1	file
\.


--
-- TOC entry 3108 (class 0 OID 43462)
-- Dependencies: 212
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item (id, parent_id, user_id, item_name, size, type_id, trash_id) FROM stdin;
1	a3ecf1cd-005b-4855-900c-4878aae60a0c	a3ecf1cd-005b-4855-900c-4878aae60a0c	Belajar Java I	0	2	2
2	1	a3ecf1cd-005b-4855-900c-4878aae60a0c	Belajar Java I.pdf	25000000	1	2
3	2	a3ecf1cd-005b-4855-900c-4878aae60a0c	ayam	0	2	0
4	3	a3ecf1cd-005b-4855-900c-4878aae60a0c	goreng	0	2	0
5	4	a3ecf1cd-005b-4855-900c-4878aae60a0c	enak	0	2	0
\.


--
-- TOC entry 3105 (class 0 OID 43281)
-- Dependencies: 208
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log (id, user_id, item_id, activity_id, item_name, activity_date) FROM stdin;
53	a3ecf1cd-005b-4855-900c-4878aae60a0c	1	1	Belajar Java	2021-02-15 11:01:34.800986
54	a3ecf1cd-005b-4855-900c-4878aae60a0c	2	6	Belajar Java.pdf	2021-02-15 11:01:37.092486
55	a3ecf1cd-005b-4855-900c-4878aae60a0c	1	4	Belajar Java	2021-02-15 11:01:52.423819
56	a3ecf1cd-005b-4855-900c-4878aae60a0c	2	7	Belajar Java.pdf	2021-02-15 11:01:55.708622
57	a3ecf1cd-005b-4855-900c-4878aae60a0c	1	5	Belajar Java	2021-02-15 11:01:59.008129
58	a3ecf1cd-005b-4855-900c-4878aae60a0c	2	9	Belajar Java.pdf	2021-02-15 11:02:02.948568
59	a3ecf1cd-005b-4855-900c-4878aae60a0c	1	3	Belajar Java	2021-02-15 11:02:11.534844
60	a3ecf1cd-005b-4855-900c-4878aae60a0c	2	8	Belajar Java.pdf	2021-02-15 11:02:15.987103
61	a3ecf1cd-005b-4855-900c-4878aae60a0c	1	4	Belajar Java I	2021-02-15 11:02:59.330791
62	a3ecf1cd-005b-4855-900c-4878aae60a0c	2	7	Belajar Java I.pdf	2021-02-15 11:02:59.330791
63	a3ecf1cd-005b-4855-900c-4878aae60a0c	1	11	Belajar Java I	2021-02-15 11:03:04.55133
64	a3ecf1cd-005b-4855-900c-4878aae60a0c	2	10	Belajar Java I.pdf	2021-02-15 11:03:05.551
65	a3ecf1cd-005b-4855-900c-4878aae60a0c	3	1	ayam	2021-02-19 11:54:39.473445
66	a3ecf1cd-005b-4855-900c-4878aae60a0c	4	1	goreng	2021-02-19 11:54:39.473445
67	a3ecf1cd-005b-4855-900c-4878aae60a0c	5	1	enak	2021-02-19 11:54:39.473445
\.


--
-- TOC entry 3102 (class 0 OID 43253)
-- Dependencies: 205
-- Data for Name: user_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_detail (user_id, name, phone, email, created_date) FROM stdin;
0456d3f5-0967-45b1-ab0c-606b88066e42	Adi Kurniawan	082182751010	adikurniawan.dev@gmail.com	2021-02-08 12:58:35.86089
425b9960-4da4-4688-9ef4-a698e4822125	Febyk Alek Satria	082182751010	febykaleksatria@gmail.com	2021-02-08 12:59:36.85942
2bce3e32-9de8-4634-bf3f-596f2686d672	adi	+6281373107544	f@gmail.com	2021-02-15 19:31:08.905617
9db41e3b-dcc9-4fe0-9605-7ebca53ebaf3	makan	+6281373107544	f@gmail.com	2021-02-16 14:01:12.998273
615e9464-5473-43ee-9e73-9cd019a10f6c	hdsaj	+6212345678910	g@gmail.com	2021-02-16 14:05:33.161252
92138377-0489-469a-8ad8-973368502f38	7777	+62812345678910	r@gmail.con	2021-02-16 14:06:29.787013
0e27752e-f554-44df-a818-b8ee3a51aee5	snk	+628138888888	H@gmail.com	2021-02-16 14:07:35.987989
3d4ee18d-7c22-44ea-9acf-635077cc1fe6	gsagdhsa	+428138888888	f@gmail.com	2021-02-16 14:08:24.377254
ff1c6219-f3d6-4de9-9052-ec8f521caeb2	dakhak	+628138888888	j@gmail.com	2021-02-16 14:08:54.388514
5cea9df2-06e5-40b0-bc68-0dfc91873d9a	hajsh	+628138888888	t@gmail.com	2021-02-16 14:09:24.939229
8a4441fd-1c6f-4c66-8398-030b24c3fabc	hdkah	+628138888888	r@gmail.com	2021-02-16 14:09:53.018151
a3ecf1cd-005b-4855-900c-4878aae60a0c	Roni Starko firdaus	+4281373107544	rsf@gmail.comrsff@@mail	2021-02-08 13:00:05.457645
\.


--
-- TOC entry 3103 (class 0 OID 43259)
-- Dependencies: 206
-- Data for Name: user_space; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_space (user_id, space, used_space) FROM stdin;
425b9960-4da4-4688-9ef4-a698e4822125	1000000000	0
0456d3f5-0967-45b1-ab0c-606b88066e42	21000000000	0
2bce3e32-9de8-4634-bf3f-596f2686d672	2000000000	0
9db41e3b-dcc9-4fe0-9605-7ebca53ebaf3	1000000000	0
615e9464-5473-43ee-9e73-9cd019a10f6c	3000000000	0
92138377-0489-469a-8ad8-973368502f38	5000000000	0
0e27752e-f554-44df-a818-b8ee3a51aee5	7000000000	0
3d4ee18d-7c22-44ea-9acf-635077cc1fe6	6000000000	0
ff1c6219-f3d6-4de9-9052-ec8f521caeb2	6000000000	0
5cea9df2-06e5-40b0-bc68-0dfc91873d9a	6000000000	0
8a4441fd-1c6f-4c66-8398-030b24c3fabc	7000000000	0
a3ecf1cd-005b-4855-900c-4878aae60a0c	5000000000	0
\.


--
-- TOC entry 3104 (class 0 OID 43267)
-- Dependencies: 207
-- Data for Name: user_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_status (user_id, status_id, last_login) FROM stdin;
425b9960-4da4-4688-9ef4-a698e4822125	0	2021-02-08 12:59:36.85942
2bce3e32-9de8-4634-bf3f-596f2686d672	0	2021-02-15 19:31:08.905617
9db41e3b-dcc9-4fe0-9605-7ebca53ebaf3	0	2021-02-16 14:01:12.998273
615e9464-5473-43ee-9e73-9cd019a10f6c	0	2021-02-16 14:05:33.161252
92138377-0489-469a-8ad8-973368502f38	0	2021-02-16 14:06:29.787013
0e27752e-f554-44df-a818-b8ee3a51aee5	0	2021-02-16 14:07:35.987989
3d4ee18d-7c22-44ea-9acf-635077cc1fe6	0	2021-02-16 14:08:24.377254
ff1c6219-f3d6-4de9-9052-ec8f521caeb2	0	2021-02-16 14:08:54.388514
5cea9df2-06e5-40b0-bc68-0dfc91873d9a	0	2021-02-16 14:09:24.939229
8a4441fd-1c6f-4c66-8398-030b24c3fabc	0	2021-02-16 14:09:53.018151
0456d3f5-0967-45b1-ab0c-606b88066e42	1	2021-02-19 19:25:49.407081
a3ecf1cd-005b-4855-900c-4878aae60a0c	1	2021-02-19 19:47:03.939627
\.


--
-- TOC entry 3106 (class 0 OID 43326)
-- Dependencies: 209
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, role_id) FROM stdin;
425b9960-4da4-4688-9ef4-a698e4822125	feals	9wDhtWXFkumcYECrx-n2KhlUngZthajfq2LFZB0cksE=	2
0456d3f5-0967-45b1-ab0c-606b88066e42	akdev	Hg6xftqVTlEiSTkAEvB3plSfvi1yyZgx29xFDtDQ4fI=	1
2bce3e32-9de8-4634-bf3f-596f2686d672	lalala	OrxqdYK3yxxm7BKtGHjw_QiyLwpT6_h9MjMbUTzebr4=	2
9db41e3b-dcc9-4fe0-9605-7ebca53ebaf3	makan	htf4Ez5kQEzJ3z5fY7vR0FhCuETYXCGbyzg9Q_SXmAQ=	2
615e9464-5473-43ee-9e73-9cd019a10f6c	hahah	U1vWuvIRzD1jvQjJXArB0z0UHWIGNImdV51URP4DCGU=	2
92138377-0489-469a-8ad8-973368502f38	sjdgah	_IIme0Xcv4255OwQBVNzz_9B78vFuDowS-Nb1nhx1xA=	2
0e27752e-f554-44df-a818-b8ee3a51aee5	snk	CNC5g3yZ2MaJ0CFEOigb7q0QfLFKwGKTj8ioQ0ar3uA=	2
3d4ee18d-7c22-44ea-9acf-635077cc1fe6	gggg	efBvj94zNGFznyIAkKI8sqefbXFL7hANDktK8kkpRhk=	2
ff1c6219-f3d6-4de9-9052-ec8f521caeb2	chjadh	MYQtAuwYcayiDa3q95mGhWBKGf7L28QoVjRXqbj5YW0=	2
5cea9df2-06e5-40b0-bc68-0dfc91873d9a	989	Ig0gkZemiWJ1vAmILuk4ODw-iiQjqnEyqAtPqMbaCP0=	2
8a4441fd-1c6f-4c66-8398-030b24c3fabc	yyyy	GYRorwYEfWZT7KK4a6fgySYaEsBWHzHwN9lAflujJwc=	2
a3ecf1cd-005b-4855-900c-4878aae60a0c	rsf	uN3kUITsovYN__Fkf1JbGp6RogstwVvZqwAvLXgkemk=	2
\.


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 211
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_id_seq', 67, true);


--
-- TOC entry 2919 (class 2606 OID 42765)
-- Name: detail_activity detail_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_activity
    ADD CONSTRAINT detail_activity_pkey PRIMARY KEY (id);


--
-- TOC entry 2923 (class 2606 OID 42777)
-- Name: detail_status detail_status_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_status
    ADD CONSTRAINT detail_status_pk PRIMARY KEY (id);


--
-- TOC entry 2929 (class 2606 OID 42793)
-- Name: detail_type detail_type_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_type
    ADD CONSTRAINT detail_type_pk PRIMARY KEY (id);


--
-- TOC entry 2943 (class 2606 OID 43469)
-- Name: item item_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pk PRIMARY KEY (id);


--
-- TOC entry 2938 (class 2606 OID 43400)
-- Name: log log_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pk PRIMARY KEY (id);


--
-- TOC entry 2921 (class 2606 OID 42771)
-- Name: detail_role role_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- TOC entry 2926 (class 2606 OID 42785)
-- Name: detail_trash status_trash_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_trash
    ADD CONSTRAINT status_trash_pk PRIMARY KEY (id);


--
-- TOC entry 2932 (class 2606 OID 43258)
-- Name: user_detail user_detail_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT user_detail_pk PRIMARY KEY (user_id);


--
-- TOC entry 2934 (class 2606 OID 43266)
-- Name: user_space user_space_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_space
    ADD CONSTRAINT user_space_pk PRIMARY KEY (user_id);


--
-- TOC entry 2936 (class 2606 OID 43273)
-- Name: user_status user_status_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT user_status_pk PRIMARY KEY (user_id);


--
-- TOC entry 2940 (class 2606 OID 43331)
-- Name: users users_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);


--
-- TOC entry 2924 (class 1259 OID 42778)
-- Name: detail_status_status_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_status_status_id_uindex ON public.detail_status USING btree (id);


--
-- TOC entry 2930 (class 1259 OID 42794)
-- Name: detail_type_type_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_type_type_id_uindex ON public.detail_type USING btree (id);


--
-- TOC entry 2927 (class 1259 OID 42786)
-- Name: status_trash_trash_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX status_trash_trash_id_uindex ON public.detail_trash USING btree (id);


--
-- TOC entry 2941 (class 1259 OID 43329)
-- Name: users_username_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username_uindex ON public.users USING btree (username);


--
-- TOC entry 2957 (class 2620 OID 43480)
-- Name: item log_create_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_create_folder AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_create_folder();


--
-- TOC entry 2958 (class 2620 OID 43481)
-- Name: item log_delete_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_file();


--
-- TOC entry 2955 (class 2620 OID 43529)
-- Name: item log_delete_file_dependency; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_file_dependency AFTER UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.delete_file_dependency();


--
-- TOC entry 2959 (class 2620 OID 43482)
-- Name: item log_delete_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_folder();


--
-- TOC entry 2953 (class 2620 OID 43511)
-- Name: item log_delete_trash_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_trash_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_trash_file();


--
-- TOC entry 2954 (class 2620 OID 43512)
-- Name: item log_delete_trash_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_delete_trash_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_trash_folder();


--
-- TOC entry 2960 (class 2620 OID 43483)
-- Name: item log_recovery_trash_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_recovery_trash_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_file();


--
-- TOC entry 2961 (class 2620 OID 43484)
-- Name: item log_recovery_trash_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_recovery_trash_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_folder();


--
-- TOC entry 2962 (class 2620 OID 43485)
-- Name: item log_rename_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_rename_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_rename_file();


--
-- TOC entry 2963 (class 2620 OID 43486)
-- Name: item log_rename_folder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_rename_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_rename_folder();


--
-- TOC entry 2964 (class 2620 OID 43487)
-- Name: item log_upload_file; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_upload_file AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_upload_file();


--
-- TOC entry 2956 (class 2620 OID 43531)
-- Name: item trigger_used_space_dec; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_used_space_dec BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.used_space_dec();


--
-- TOC entry 2965 (class 2620 OID 43489)
-- Name: item trigger_used_space_inc; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_used_space_inc AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.used_space_inc();


--
-- TOC entry 2948 (class 2606 OID 43314)
-- Name: log fk_activity_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT fk_activity_id FOREIGN KEY (activity_id) REFERENCES public.detail_activity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2949 (class 2606 OID 43523)
-- Name: log fk_item_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT fk_item_id FOREIGN KEY (item_id) REFERENCES public.item(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2950 (class 2606 OID 43347)
-- Name: users fk_role_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_role_id FOREIGN KEY (role_id) REFERENCES public.detail_role(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2946 (class 2606 OID 43304)
-- Name: user_status fk_status_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT fk_status_id FOREIGN KEY (status_id) REFERENCES public.detail_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2952 (class 2606 OID 43505)
-- Name: item fk_trash_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT fk_trash_id FOREIGN KEY (trash_id) REFERENCES public.detail_trash(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2951 (class 2606 OID 43500)
-- Name: item fk_type_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES public.detail_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2944 (class 2606 OID 43332)
-- Name: user_detail fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2945 (class 2606 OID 43337)
-- Name: user_space fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_space
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2947 (class 2606 OID 43342)
-- Name: user_status fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2021-03-16 23:23:05 WIB

--
-- PostgreSQL database dump complete
--

