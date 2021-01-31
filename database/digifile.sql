--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)

-- Started on 2021-01-31 16:56:09 WIB

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
-- TOC entry 255 (class 1255 OID 25737)
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
(item_name, directory, owner, trash_status, type_id, size)
VALUES
(in_folder_name, in_directory, in_owner, 0, 2, 0);
END;
$$;


ALTER FUNCTION public.add_folder(in_folder_name character varying, in_directory character varying, in_owner character varying) OWNER TO akdev;

--
-- TOC entry 250 (class 1255 OID 25762)
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
-- TOC entry 232 (class 1255 OID 25782)
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
-- TOC entry 242 (class 1255 OID 25787)
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
-- TOC entry 231 (class 1255 OID 25765)
-- Name: delete_trash_file(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.delete_trash_file(in_item_id integer, in_owner character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM items
    WHERE trash_status = 1 
    AND item_id = in_item_id  
    AND owner = in_owner
    AND type_id = 1;
END
$$;


ALTER FUNCTION public.delete_trash_file(in_item_id integer, in_owner character varying) OWNER TO akdev;

--
-- TOC entry 244 (class 1255 OID 42274)
-- Name: delete_trash_folder(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.delete_trash_folder(in_item_id integer, in_owner character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_item_name varchar;
    var_directory_depedencies varchar;
BEGIN
    SELECT INTO var_item_name FROM items
    WHERE item_id = in_item_id;
    SELECT INTO var_directory_depedencies concat(directory, item_name,'/') FROM items WHERE item_id = in_item_id;

    --     hapus item depedenci di dalam folder
    DELETE FROM items
    WHERE directory like var_directory_depedencies || '%'
    AND owner = in_owner;

    --     hapus folder
    DELETE FROM items
    WHERE item_id = in_item_id;
    

END
$$;


ALTER FUNCTION public.delete_trash_folder(in_item_id integer, in_owner character varying) OWNER TO akdev;

--
-- TOC entry 245 (class 1255 OID 25721)
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
-- TOC entry 235 (class 1255 OID 42283)
-- Name: get_all_item_list(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_all_item_list(in_username character varying, in_current_path character varying) RETURNS TABLE(item_name character varying, item_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name,
        items.item_id
    FROM
        items
    WHERE
        items.owner like in_username
    AND items.trash_status = 0
    AND directory = in_current_path
    ORDER BY type_id, item_name ASC;
END;
$$;


ALTER FUNCTION public.get_all_item_list(in_username character varying, in_current_path character varying) OWNER TO akdev;

--
-- TOC entry 265 (class 1255 OID 42267)
-- Name: get_all_trash_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_all_trash_list(in_username character varying) RETURNS TABLE(item_name character varying, item_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name,
        items.item_id
    FROM
        items
    WHERE
        items.owner like in_username
      AND items.trash_status = 1
    ORDER BY type_id, item_name ASC;
END;
$$;


ALTER FUNCTION public.get_all_trash_list(in_username character varying) OWNER TO akdev;

--
-- TOC entry 237 (class 1255 OID 42285)
-- Name: get_file_count(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_file_count(in_username character varying, in_current_path character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
   file_count integer;
begin
   select count(*)
   into file_count
   from items
   where owner = in_username
    and type_id = 1
   and trash_status = 0
   and directory = in_current_path;

   return file_count;
end;
$$;


ALTER FUNCTION public.get_file_count(in_username character varying, in_current_path character varying) OWNER TO akdev;

--
-- TOC entry 234 (class 1255 OID 42282)
-- Name: get_file_list(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_file_list(in_username character varying, in_current_path character varying) RETURNS TABLE(file_name character varying, file_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name,
        items.item_id
    FROM
        items
    WHERE
        items.owner = in_username 
      AND trash_status = 0
        AND type_id = 1
    AND directory = in_current_path
    ORDER BY item_name ASC;
END;
$$;


ALTER FUNCTION public.get_file_list(in_username character varying, in_current_path character varying) OWNER TO akdev;

--
-- TOC entry 236 (class 1255 OID 42284)
-- Name: get_folder_count(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_folder_count(in_username character varying, in_current_path character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
   folder_count integer;
begin
   select count(*)
   into folder_count
   from items
   where owner = in_username
    and type_id = 2
   and trash_status = 0
   and directory = in_current_path;

   return folder_count;
end;
$$;


ALTER FUNCTION public.get_folder_count(in_username character varying, in_current_path character varying) OWNER TO akdev;

--
-- TOC entry 268 (class 1255 OID 42281)
-- Name: get_folder_list(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_folder_list(in_username character varying, in_current_path character varying) RETURNS TABLE(folder_name character varying, folder_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name,
        items.item_id
    FROM
        items
    WHERE
        items.owner = in_username 
      AND trash_status = 0
        AND type_id = 2
    AND directory = in_current_path
    
    ORDER BY item_name ASC;
END;
$$;


ALTER FUNCTION public.get_folder_list(in_username character varying, in_current_path character varying) OWNER TO akdev;

--
-- TOC entry 243 (class 1255 OID 25791)
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
-- TOC entry 240 (class 1255 OID 42310)
-- Name: get_item_information(integer); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_item_information(in_item_id integer) RETURNS TABLE(item_name character varying, directory character varying)
    LANGUAGE plpgsql
    AS $$
begin
   return query select items.item_name, items.directory from items where items.item_id = in_item_id;
end;
$$;


ALTER FUNCTION public.get_item_information(in_item_id integer) OWNER TO akdev;

--
-- TOC entry 259 (class 1255 OID 34069)
-- Name: get_name(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_name(in_username character varying) RETURNS TABLE(name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY 
        SELECT users.name FROM users WHERE users.username = in_username;
END;
$$;


ALTER FUNCTION public.get_name(in_username character varying) OWNER TO akdev;

--
-- TOC entry 239 (class 1255 OID 42305)
-- Name: get_search_file_count(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_search_file_count(in_username character varying, in_keyword character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
   file_count integer;
begin
   select count(*)
   into file_count
   from items
   where owner = in_username
    and type_id = 1
   and trash_status = 0
   and lower(item_name) like lower('%' || in_keyword || '%');

   return file_count;
end;
$$;


ALTER FUNCTION public.get_search_file_count(in_username character varying, in_keyword character varying) OWNER TO akdev;

--
-- TOC entry 262 (class 1255 OID 34087)
-- Name: get_trash_file_count(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_trash_file_count(in_username character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
   folder_count integer;
begin
   select count(*)
   into folder_count
   from items
   where owner = in_username
    and type_id = 1
   and trash_status = 1;

   return folder_count;
end;
$$;


ALTER FUNCTION public.get_trash_file_count(in_username character varying) OWNER TO akdev;

--
-- TOC entry 267 (class 1255 OID 42270)
-- Name: get_trash_file_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_trash_file_list(in_username character varying) RETURNS TABLE(file_name character varying, file_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name,
        items.item_id
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
-- TOC entry 261 (class 1255 OID 34086)
-- Name: get_trash_folder_count(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_trash_folder_count(in_username character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
   folder_count integer;
begin
   select count(*)
   into folder_count
   from items
   where owner = in_username
    and type_id = 2
   and trash_status = 1;

   return folder_count;
end;
$$;


ALTER FUNCTION public.get_trash_folder_count(in_username character varying) OWNER TO akdev;

--
-- TOC entry 266 (class 1255 OID 42269)
-- Name: get_trash_folder_list(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_trash_folder_list(in_username character varying) RETURNS TABLE(folder_name character varying, folder_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        items.item_name,
        items.item_id
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
-- TOC entry 269 (class 1255 OID 42323)
-- Name: get_user_information(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_user_information(in_username character varying) RETURNS TABLE(username character varying, name character varying, space integer, email character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT 
    users.username, users.name, (users.space * 0.000000001)::int, users.email 
    FROM users
    WHERE users.username = in_username;
    END;
$$;


ALTER FUNCTION public.get_user_information(in_username character varying) OWNER TO akdev;

--
-- TOC entry 264 (class 1255 OID 34122)
-- Name: get_user_log_activity(character varying, integer); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_user_log_activity(in_username character varying, in_page integer) RETURNS TABLE(activity_date text, activity text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        to_char(l.activity_date::timestamp with time zone, 'Day, DD-MM-YYYY'::text) AS activity_date,
        CASE WHEN (length(concat(da.description, ' ' ,l.item_name)) >= 50)
        THEN overlay(left(concat(da.description, ' ' ,l.item_name),50)placing '...' from 48 for 50)
        ELSE concat(da.description, ' ' ,l.item_name) END
        AS activity
    FROM
        logs l
    INNER JOIN
        	detail_activity da on l.activity_id = da.activity_id
    WHERE
        l.username = in_username
    ORDER BY l.activity_date DESC
    LIMIT 10 OFFSET (in_page-1)*10;    
END;
$$;


ALTER FUNCTION public.get_user_log_activity(in_username character varying, in_page integer) OWNER TO akdev;

--
-- TOC entry 260 (class 1255 OID 34083)
-- Name: get_user_log_activity_count(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.get_user_log_activity_count(in_username character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
   logs_count integer;
begin
   select count(*)
   into logs_count
   from logs
   where username = in_username;

   return logs_count;
end;
$$;


ALTER FUNCTION public.get_user_log_activity_count(in_username character varying) OWNER TO akdev;

--
-- TOC entry 228 (class 1255 OID 25588)
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
-- TOC entry 258 (class 1255 OID 34005)
-- Name: is_enough_space(character varying, numeric); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.is_enough_space(in_username character varying, in_size numeric) RETURNS TABLE(result boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT space - users.used_space > in_size FROM users
    WHERE role_id = 2
    AND username = in_username;
END;
$$;


ALTER FUNCTION public.is_enough_space(in_username character varying, in_size numeric) OWNER TO akdev;

--
-- TOC entry 229 (class 1255 OID 25589)
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
-- TOC entry 224 (class 1255 OID 25381)
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
-- TOC entry 225 (class 1255 OID 25385)
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
-- TOC entry 254 (class 1255 OID 25801)
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
-- TOC entry 223 (class 1255 OID 25378)
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
-- TOC entry 233 (class 1255 OID 25544)
-- Name: log_rename_folder(); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.log_rename_folder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 	IF NEW.item_name <> OLD.item_name 
 	    AND OLD.type_id = 2  THEN
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(OLD.item_id, OLD.owner, 3, now(), OLD.item_name);
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
 	INSERT INTO logs
 	(item_id, username, activity_id, activity_date, item_name)
 	VALUES
 	(NEW.item_id, NEW.owner, 6, now(), NEW.item_name);
END IF;
 RETURN NEW;
 END;
$$;


ALTER FUNCTION public.log_upload_file() OWNER TO akdev;

--
-- TOC entry 251 (class 1255 OID 25764)
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
-- TOC entry 252 (class 1255 OID 25799)
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
-- TOC entry 253 (class 1255 OID 25800)
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
-- TOC entry 241 (class 1255 OID 42314)
-- Name: rename_file(integer, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.rename_file(id integer, new_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE items SET item_name = new_name
WHERE item_id = id 
  AND type_id = 1;
END
$$;


ALTER FUNCTION public.rename_file(id integer, new_name character varying) OWNER TO akdev;

--
-- TOC entry 230 (class 1255 OID 42275)
-- Name: rename_folder(integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.rename_folder(in_item_id integer, in_new_name character varying, in_owner character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    var_nama_awal varchar;
    var_nama_tujuan varchar;
BEGIN
    SELECT directory || item_name INTO var_nama_awal FROM items WHERE item_id = in_item_id;
    SELECT directory || in_new_name INTO var_nama_tujuan FROM items WHERE item_id = in_item_id;

--     ubah folder
    UPDATE items SET item_name = in_new_name
    WHERE item_id = in_item_id
    AND owner = in_owner;
    
--     ubah direktori depedencies
    UPDATE items SET directory =
    replace(directory, var_nama_awal, var_nama_tujuan)
    WHERE owner = in_owner;
END
$$;


ALTER FUNCTION public.rename_folder(in_item_id integer, in_new_name character varying, in_owner character varying) OWNER TO akdev;

--
-- TOC entry 263 (class 1255 OID 34118)
-- Name: search_owner(character varying, integer, date, date); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.search_owner(in_name character varying, in_activity_id integer, in_start_date date, in_end_date date) RETURNS TABLE(username character varying, name character varying, last_activity_date text, last_activity character varying, kuota text, status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
SELECT u.username                                         AS username,
       u.name                                             AS nama,
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
-- TOC entry 238 (class 1255 OID 42306)
-- Name: search_user(character varying, character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.search_user(in_username character varying, in_keyword character varying) RETURNS TABLE(name character varying, item_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT i.item_name, i.item_id FROM items i
    WHERE lower(i.item_name) like lower('%' || in_keyword || '%') 
    AND i.owner = in_username
    ORDER BY i.type_id,i.item_name;
END
$$;


ALTER FUNCTION public.search_user(in_username character varying, in_keyword character varying) OWNER TO akdev;

--
-- TOC entry 257 (class 1255 OID 25733)
-- Name: set_offline(character varying); Type: FUNCTION; Schema: public; Owner: akdev
--

CREATE FUNCTION public.set_offline(in_username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE users SET status_id = 0
WHERE username = in_username;
END
$$;


ALTER FUNCTION public.set_offline(in_username character varying) OWNER TO akdev;

--
-- TOC entry 246 (class 1255 OID 25732)
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
-- TOC entry 227 (class 1255 OID 25585)
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
    size numeric NOT NULL,
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
    item_id integer NOT NULL,
    username character varying NOT NULL,
    activity_id integer NOT NULL,
    item_name character varying NOT NULL,
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
    space numeric NOT NULL,
    used_space numeric NOT NULL,
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
    to_char((t2.activity_date)::timestamp with time zone, 'Day, DD-MM-YYYY'::text) AS activity_date,
    da.description AS last_activity,
    concat(round((u.used_space * 0.000000001), 2), ' Gb / ', (round((u.space * 0.000000001), 2))::integer, ' Gb') AS kuota,
    dl.description AS status
   FROM ((((public.logs la
     JOIN ( SELECT logs.username,
            max(logs.activity_date) AS activity_date
           FROM public.logs
          GROUP BY logs.username) t2 ON ((((la.username)::text = (t2.username)::text) AND (la.activity_date = t2.activity_date))))
     RIGHT JOIN public.users u ON (((u.username)::text = (la.username)::text)))
     LEFT JOIN public.detail_activity da ON ((da.activity_id = la.activity_id)))
     LEFT JOIN public.detail_status dl ON ((u.status_id = dl.status_id)))
  WHERE (u.role_id = 2)
  ORDER BY u.name;


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
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 206
-- Name: log_activity_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: akdev
--

ALTER SEQUENCE public.log_activity_log_id_seq OWNED BY public.logs.log_id;


--
-- TOC entry 2914 (class 2604 OID 17228)
-- Name: logs log_id; Type: DEFAULT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs ALTER COLUMN log_id SET DEFAULT nextval('public.log_activity_log_id_seq'::regclass);


--
-- TOC entry 3084 (class 0 OID 16887)
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
-- TOC entry 3087 (class 0 OID 17009)
-- Dependencies: 204
-- Data for Name: detail_role; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_role (role_id, description) FROM stdin;
1	admin
2	user
\.


--
-- TOC entry 3088 (class 0 OID 17093)
-- Dependencies: 205
-- Data for Name: detail_status; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_status (status_id, description) FROM stdin;
1	Aktif
0	Nonaktif
\.


--
-- TOC entry 3091 (class 0 OID 25457)
-- Dependencies: 208
-- Data for Name: detail_trash; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_trash (trash_id, description) FROM stdin;
0	nontrash
1	trash
\.


--
-- TOC entry 3092 (class 0 OID 25546)
-- Dependencies: 209
-- Data for Name: detail_type; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.detail_type (type_id, description) FROM stdin;
1	file
2	folder
\.


--
-- TOC entry 3086 (class 0 OID 16965)
-- Dependencies: 203
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.items (item_id, item_name, directory, size, trash_status, owner, type_id) FROM stdin;
330	folder ku	/	0	0	rsf	2
434	aku coba	/upload ini/Wallpapers/	497223	0	test	1
437	daming kelar.odt	/	798098	1	ihsan	1
438	mingguan.mkv	/	238874608	1	ihsan	1
326	file1	/folder1/	12345	0	t	1
327	file2	/folder1/BerhasilPliss/	123456	0	t	1
328	folder3	/folder1/BerhasilPliss/	0	0	t	2
329	file4	/folder1/BerhasilPliss/folder3/	123241	0	t	1
324	folder1	/	0	0	t	2
325	BerhasilPliss	/folder1/	0	0	t	2
58	poto.png	/	10000000	1	rsf	1
372	upload ini	/	0	0	test	2
109	aku.kamu.dia.hai.png	/upload/rsf/	0	0	rsf	1
110	aku.kamu.dia.hai.(1)png	/upload/rsf/	0	0	rsf	1
111	aku.kamu.dia.hai(1).png	/upload/rsf/	0	0	rsf	1
62	KRS-2020.pdf	/	10000000	0	feals	1
112	aku.kamu.dia.hai(2).png	/upload/rsf/	0	0	rsf	1
61	Kuliah	/	0	0	rsf	2
60	Folder Kuliah	/	0	0	rsf	2
131	kunnnl	/test/	0	0	rsf	2
69	favicon1 1(1).png	/upload/rsf/test/	5040	0	rsf	1
72	favicon1 1.png	/upload/rsf/undefined/	5040	0	rsf	1
331	adi kurniawan	/folder ku	0	0	rsf	2
332	roni	/folder ku	0	0	rsf	2
122	IMG20201205173857 (1).jpg	/upload/rsf/	4305692	0	rsf	1
87	CamScanner 01-04-2021 14.29.05.pdf	/upload/rsf/	516540	0	rsf	1
120	main.100092.com.squareenix.lis.obb	/upload/rsf/	1024272323	0	rsf	1
101	LPJ COMDEV FIX.docx	/upload/rsf/	2412228	1	rsf	1
435	febyk	/upload ini/Wallpapers/	497223	0	test	1
135	magnifying-glass 1.png	/	584	1	rsf	1
113	aku.kamu.png	/upload/rsf/	0	0	rsf	1
108	budidoremi(1).mp4	/upload/rsf/	50880571	1	rsf	1
121	Chapter 15 - Integration, Impact, and Future of MSS.pdf	/a/b/berhasiltesting/	410866	0	snk	1
141	dxwebsetup(1).exe	/a/b/berhasiltesting/	315624	0	snk	1
132	kunnnl	/test/	0	0	rsf	2
67	docdownloader.com-pdf-interchange-4th-edition-level-1-student-book-dd_7a28a628ad8cf3e3021dea88206e9b68.pdf	/upload/rsf/test/	18297994	0	rsf	1
68	favicon1 1.png	/upload/rsf/test/	5040	0	rsf	1
142	ldplayer_id_2041_ld(1).exe	/a/b/berhasiltesting/	2978488	0	snk	1
137	woi	/	0	0	rsf	2
333	roni	/folder ku/	0	0	rsf	2
436	kpm febyk.pdf	/upload ini/Wallpapers/	453106	0	test	1
300	aktivitas(1).odt	/upload ini/	17002	1	rsf	1
247	aktivitas.odt	/upload ini/	17002	0	rsf	1
248	KPM_Febyk alek satria.pdf	/upload ini/	453106	0	rsf	1
250	aktivitas.odt	/upload ini/kedua/	17002	0	rsf	1
70	IMG20201205173857 (1).jpg	/upload/rsf/test/	4305692	0	rsf	1
71	WhatsApp Image 2020-12-17 at 14.50.48.jpeg	/upload/rsf/undefined/	38176	0	rsf	1
73	favicon1 1(2).png	/upload/rsf/test/	5040	0	rsf	1
74	logo uread.png	/upload/rsf/test/	144484	0	rsf	1
75	favicon1 1.png	/upload/rsf/null/	5040	0	rsf	1
76	logo uread.png	/upload/rsf/null/	144484	0	rsf	1
77	favicon1 1(1).png	/upload/rsf/null/	5040	0	rsf	1
78	coba.jpg	/upload/rsf/null/	191284	0	rsf	1
79	favicon1 1.png	/upload/rsf/null/	5040	0	rsf	1
80	coba(1).jpg	/upload/rsf/null/	191284	0	rsf	1
81	logo uread.png	/upload/rsf/null/	144484	0	rsf	1
82	coba(2).jpg	/upload/rsf/null/	191284	0	rsf	1
83	CV 2020.jpg	/upload/rsf/null/	1561865	0	rsf	1
84	favicon1 1.png	/upload/rsf/	5040	0	rsf	1
85	CV-RONI STARKO FIRDAUS.png	/upload/rsf/	334413	0	rsf	1
86	c25cb7a766b9b04817d29847f37fdecc-template-surat-pernyataan.docx	/upload/rsf/	16746	0	rsf	1
88	Certificate NDSC Beginner _1368-1368.pdf	/upload/rsf/	220099	0	rsf	1
89	CV 2020.jpg	/upload/rsf/	1561865	0	rsf	1
90	CV LENGKAP.pdf	/upload/rsf/	785331	0	rsf	1
91	CV-RONI STARKO FIRDAUS.png	/upload/rsf/	334413	0	rsf	1
334	basing	/Kuliah/	0	0	rsf	2
134	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	/	955144	1	rsf	1
392	febyk 4x6.jpg	/JS1/	712278	0	ema	1
92	CV-FEBYK ALEK SATRIA.jpg	/upload/rsf/	1561865	0	rsf	1
93	CV-ADI KURNIAWAN.docx	/upload/rsf/	1025819	0	rsf	1
94	decision tree.docx	/upload/rsf/	845351	0	rsf	1
95	docdownloader.com-pdf-interchange-4th-edition-level-1-student-book-dd_7a28a628ad8cf3e3021dea88206e9b68.pdf	/upload/rsf/	18297994	0	rsf	1
96	favicon1 1.png	/upload/rsf/	5040	0	rsf	1
97	FISIP_PUTRI AMALIA_07011181722027_082282556151_MASK BY PYN_PMW 2020.pdf	/upload/rsf/	516608	0	rsf	1
98	IMG20201205173857 (1).jpg	/upload/rsf/	4305692	0	rsf	1
99	Interchange 4th Edition Intro Student Book ( PDFDrive ).pdf	/upload/rsf/	61544354	0	rsf	1
100	JS1-20210110T165728Z-001.zip	/upload/rsf/	25623841	0	rsf	1
102	logo uread.png	/upload/rsf/	144484	0	rsf	1
103	KRS_09021181823003_SEMESTER_6_2020-2021.doc	/upload/rsf/	3973	0	rsf	1
104	KHS_09021181823003_SEMESTER_5_2020-2021.doc	/upload/rsf/	5264	0	rsf	1
105	LPJ KOMINFO FIX.docx	/upload/rsf/	4608517	0	rsf	1
106	main.100092.com.squareenix.lis.obb	/upload/rsf/	1024272323	0	rsf	1
107	budidoremi.mp4	/upload/rsf/	50880571	0	rsf	1
123	logo uread.png	/upload/rsf/	144484	0	rsf	1
124	IMG20201205173857 (1)(1).jpg	/upload/rsf/	4305692	0	rsf	1
125	logo uread(1).png	/upload/rsf/	144484	0	rsf	1
338	adi  nak nyoba	/folder ku/	0	0	rsf	2
339	upload ini	/folder ku/	0	0	rsf	2
340	aktivitas.odt	/folder ku/upload ini/	17002	0	rsf	1
341	KPM_Febyk alek satria.pdf	/folder ku/upload ini/	453106	0	rsf	1
342	kedua	/folder ku/upload ini/	0	0	rsf	2
343	aktivitas.odt	/folder ku/upload ini/kedua/	17002	0	rsf	1
344	KPM_Febyk alek satria.pdf	/folder ku/upload ini/kedua/	453106	0	rsf	1
336	Beda Level.jpeg	/folder ku/	87771	0	rsf	1
337	Beda Level(1).jpeg	/folder ku/	87771	0	rsf	1
400	febyk 4x6.jpg	/folder ku/	712278	0	rsf	1
285	kedua	/a/a/b/upload ini/	0	0	rsf	2
288	upload ini	/a/b/	0	0	rsf	2
291	kedua	/a/b/upload ini/	0	0	rsf	2
294	upload ini	/	0	0	rsf	2
297	kedua	/upload ini/	0	0	rsf	2
310	upload ini	/	0	0	ema	2
313	kedua	/upload ini/	0	0	ema	2
317	berhasil	/a/b/berhasiltesting/	0	0	snk	2
149	Programs	/a/b/berhasiltesting/	0	0	snk	2
152	ah	/a/b/berhasiltesting/	0	0	snk	2
156	Programs	/a/b/berhasiltesting/	0	0	snk	2
158	Programs	/a/b/berhasiltesting/	0	0	snk	2
159	Programs	/a/b/berhasiltesting/	0	0	snk	2
160	Programs	/a/b/berhasiltesting/	0	0	snk	2
185	ah	/a/b/berhasiltesting/	0	0	snk	2
187	snk	/a/b/berhasiltesting/	0	0	snk	2
345	upload ini	/Kuliah/	0	0	rsf	2
346	aktivitas.odt	/Kuliah/upload ini/	17002	0	rsf	1
347	KPM_Febyk alek satria.pdf	/Kuliah/upload ini/	453106	0	rsf	1
348	kedua	/Kuliah/upload ini/	0	0	rsf	2
349	aktivitas.odt	/Kuliah/upload ini/kedua/	17002	0	rsf	1
350	KPM_Febyk alek satria.pdf	/Kuliah/upload ini/kedua/	453106	0	rsf	1
352	KPM_Febyk alek satria.pdf	/Kuliah/	453106	0	rsf	1
401	febyk 4x6.jpg	/folder ku/roni/	712278	0	rsf	1
403	wallpaperflare.com_wallpaper.jpg	/upload ini/Wallpapers/	1118861	0	test	1
404	mikael-gustafsson-wallpaper-mikael-gustafsson.jpg	/upload ini/Wallpapers/	521668	0	test	1
405	n4.png	/upload ini/Wallpapers/	42764	0	test	1
406	62436108_10155899187370670_7258125010865225728_o.jpg	/upload ini/Wallpapers/	183670	0	test	1
408	wallhaven-ym56zg_1920x1080.png	/upload ini/Wallpapers/	1907788	0	test	1
402	Wallpapers	/upload ini/	0	0	test	2
407	bisanih	/upload ini/Wallpapers/	477348	0	test	1
410	null	/upload ini/Wallpapers/	2073805	0	test	1
409	null	/upload ini/Wallpapers/	855522	0	test	1
190	Programs	/a/b/berhasiltesting/	0	0	snk	2
351	folder baru	/Kuliah/	0	0	rsf	2
140	ea	/	0	1	rsf	2
133	ggsgs	/test/	0	1	rsf	2
139	gg	/	0	1	rsf	2
138	ea	/	0	0	rsf	2
129	kunnnl	/upload/rsf/test/	0	0	rsf	2
130	kunnnl	/upload/test/	0	0	rsf	2
128	nah adi	/test/	0	1	rsf	2
114	aku.kamu(1).png	/upload/rsf/	0	0	rsf	1
115	aku.kamu(2).png	/upload/rsf/	0	0	rsf	1
116	aku.kamu. wah.ahw .png	/upload/rsf/	0	0	rsf	1
117	aku.kamu. wah.ahw (1).png	/upload/rsf/	0	0	rsf	1
118	aku.kamu. wah.ahw (2).png	/upload/rsf/	0	0	rsf	1
119	aku.kamu. wah.ahw (3).png	/upload/rsf/	0	0	rsf	1
241	kedua	/a/upload ini/	0	0	rsf	2
262	kedua	/a/b/aada/b/upload ini/	0	0	rsf	2
264	kedua	/a/b/aada/b/upload ini/	0	0	rsf	2
270	kedua	/a/b/aada/b/upload ini/	0	0	rsf	2
272	kedua	/a/b/aada/b/upload ini/	0	0	rsf	2
280	kedua	/a/b/aada/b/upload ini/	0	0	rsf	2
192	ah	/a/b/berhasiltesting/	0	0	snk	2
206	snk	/a/b/berhasiltesting/	0	0	snk	2
209	Programs	/a/b/berhasiltesting/	0	0	snk	2
211	ah	/a/b/berhasiltesting/	0	0	snk	2
213	snk	/a/b/berhasiltesting/	0	0	snk	2
216	Programs	/a/b/berhasiltesting/	0	0	snk	2
218	ah	/a/b/berhasiltesting/	0	0	snk	2
220	snk	/a/b/berhasiltesting/	0	0	snk	2
223	Programs	/a/b/berhasiltesting/	0	0	snk	2
225	ah	/a/b/berhasiltesting/	0	0	snk	2
227	Programs	/a/b/berhasiltesting/	0	0	snk	2
230	ah	/a/b/berhasiltesting/	0	0	snk	2
232	eh	/a/b/berhasiltesting/	0	0	snk	2
319	JS1	/	0	0	ema	2
274	upload ini	/a/b/c/d/a/b/	0	0	rsf	2
282	upload ini	/c/a/b/	0	0	rsf	2
266	upload ini	/a/b/g/f/a/b/	0	0	rsf	2
238	upload ini	/a/	0	0	rsf	2
268	upload ini	/a/b/f/f/a/b/	0	0	rsf	2
278	kedua	/a/b/f/f/a/b/upload ini/	0	0	rsf	2
276	upload ini	/a/b/f/f/a/b/	0	0	rsf	2
244	KPM_Febyk alek satria.pdf	/b/	453106	0	rsf	1
260	upload ini	/a/b/f/g/a/b/	0	0	rsf	2
239	aktivitas.odt	/a/upload ini/	17002	0	rsf	1
240	KPM_Febyk alek satria.pdf	/a/upload ini/	453106	0	rsf	1
242	aktivitas.odt	/a/upload ini/kedua/	17002	0	rsf	1
243	KPM_Febyk alek satria.pdf	/a/upload ini/kedua/	453106	0	rsf	1
251	KPM_Febyk alek satria.pdf	/upload ini/kedua/	453106	0	rsf	1
253	aktivitas.odt	/a/b/aada/b/upload ini/	17002	0	rsf	1
254	KPM_Febyk alek satria.pdf	/a/b/aada/b/upload ini/	453106	0	rsf	1
256	aktivitas.odt	/a/b/aada/b/upload ini/kedua/	17002	0	rsf	1
257	KPM_Febyk alek satria.pdf	/a/b/aada/b/upload ini/kedua/	453106	0	rsf	1
259	aktivitas.odt	/a/b/aada/b/upload ini/	17002	0	rsf	1
261	KPM_Febyk alek satria.pdf	/a/b/aada/b/upload ini/	453106	0	rsf	1
263	aktivitas.odt	/a/b/aada/b/upload ini/kedua/	17002	0	rsf	1
265	KPM_Febyk alek satria.pdf	/a/b/aada/b/upload ini/kedua/	453106	0	rsf	1
267	aktivitas.odt	/a/b/aada/b/upload ini/	17002	0	rsf	1
269	KPM_Febyk alek satria.pdf	/a/b/aada/b/upload ini/	453106	0	rsf	1
271	aktivitas.odt	/a/b/aada/b/upload ini/kedua/	17002	0	rsf	1
273	KPM_Febyk alek satria.pdf	/a/b/aada/b/upload ini/kedua/	453106	0	rsf	1
275	aktivitas.odt	/a/b/aada/b/upload ini/	17002	0	rsf	1
277	KPM_Febyk alek satria.pdf	/a/b/aada/b/upload ini/	453106	0	rsf	1
279	aktivitas.odt	/a/b/aada/b/upload ini/kedua/	17002	0	rsf	1
281	KPM_Febyk alek satria.pdf	/a/b/aada/b/upload ini/kedua/	453106	0	rsf	1
283	aktivitas.odt	/a/a/b/upload ini/	17002	0	rsf	1
284	KPM_Febyk alek satria.pdf	/a/a/b/upload ini/	453106	0	rsf	1
286	aktivitas.odt	/a/a/b/upload ini/kedua/	17002	0	rsf	1
287	KPM_Febyk alek satria.pdf	/a/a/b/upload ini/kedua/	453106	0	rsf	1
289	aktivitas.odt	/a/b/upload ini/	17002	0	rsf	1
290	KPM_Febyk alek satria.pdf	/a/b/upload ini/	453106	0	rsf	1
292	aktivitas.odt	/a/b/upload ini/kedua/	17002	0	rsf	1
293	KPM_Febyk alek satria.pdf	/a/b/upload ini/kedua/	453106	0	rsf	1
295	aktivitas.odt	/upload ini/	17002	0	rsf	1
296	KPM_Febyk alek satria.pdf	/upload ini/	453106	0	rsf	1
298	aktivitas.odt	/upload ini/kedua/	17002	0	rsf	1
299	KPM_Febyk alek satria.pdf	/upload ini/kedua/	453106	0	rsf	1
301	KPM_Febyk alek satria(1).pdf	/upload ini/	453106	0	rsf	1
302	aktivitas(1).odt	/upload ini/kedua/	17002	0	rsf	1
303	KPM_Febyk alek satria(1).pdf	/upload ini/kedua/	453106	0	rsf	1
353	logo uread.png	/Kuliah/	144484	0	rsf	1
305	KPM_Febyk alek satria.pdf	/a/b/	453106	0	rsf	1
306	aktivitas(2).odt	/upload ini/	17002	0	rsf	1
307	KPM_Febyk alek satria(2).pdf	/upload ini/	453106	0	rsf	1
308	aktivitas(2).odt	/upload ini/kedua/	17002	0	rsf	1
309	KPM_Febyk alek satria(2).pdf	/upload ini/kedua/	453106	0	rsf	1
312	KPM_Febyk alek satria.pdf	/upload ini/	453106	0	ema	1
314	aktivitas.odt	/upload ini/kedua/	17002	0	ema	1
315	KPM_Febyk alek satria.pdf	/upload ini/kedua/	453106	0	ema	1
316	tes.png	/a/b/berhasiltesting/	2131	0	snk	1
318	oik.jpg	/a/b/berhasiltesting/	123213	0	snk	1
246	upload ini	/	0	0	rsf	2
249	kedua	/upload ini/	0	0	rsf	2
143	Text File(1).txt	/a/b/berhasiltesting/	2	0	snk	1
150	Programs/dxwebsetup.exe	/a/b/berhasiltesting/	315624	0	snk	1
151	Programs/ldplayer_id_2041_ld.exe	/a/b/berhasiltesting/	2978488	0	snk	1
153	Programs/ah/Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
252	upload ini	/a/b/s/d/a/b/	0	0	rsf	2
258	upload ini	/a/b/s/d/a/b/	0	0	rsf	2
255	kedua	/a/b/f/f/a/b/upload ini/	0	0	rsf	2
166	fileKerenSekali.png	/a/b/berhasiltesting/	2112	0	snk	1
234	dxwebsetup(1).exe	/a/b/berhasiltesting/	315624	0	snk	1
235	ldplayer_id_2041_ld(1).exe	/a/b/berhasiltesting/	2978488	0	snk	1
236	Text File(1).txt	/a/b/berhasiltesting/	2	0	snk	1
169	dxwebsetup(12).exe	/a/b/berhasiltesting/	315624	0	snk	1
170	ldplayer_id_2041_ld(10).exe	/a/b/berhasiltesting/	2978488	0	snk	1
171	Text File(10).txt	/a/b/berhasiltesting/	2	0	snk	1
172	Text File(7).txt	/a/b/berhasiltesting/	2	0	snk	1
237	Text File(1).txt	/a/b/berhasiltesting/	2	0	snk	1
245	KPM_Febyk alek satria(1).pdf	/	453106	1	rsf	1
311	aktivitas.odt	/upload ini/	17002	0	ema	1
174	dxwebsetup.exe	/a/b/berhasiltesting/	315624	0	snk	1
175	ldplayer_id_2041_ld.exe	/a/b/berhasiltesting/	2978488	0	snk	1
177	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
179	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
181	dxwebsetup.exe	/a/b/berhasiltesting/	315624	0	snk	1
182	ldplayer_id_2041_ld.exe	/a/b/berhasiltesting/	2978488	0	snk	1
184	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
186	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
188	dxwebsetup.exe	/a/b/berhasiltesting/	315624	0	snk	1
189	ldplayer_id_2041_ld.exe	/a/b/berhasiltesting/	2978488	0	snk	1
191	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
193	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
194	dxwebsetup(1).exe	/a/b/berhasiltesting/	315624	0	snk	1
195	ldplayer_id_2041_ld(1).exe	/a/b/berhasiltesting/	2978488	0	snk	1
196	Text File(1).txt	/a/b/berhasiltesting/	2	0	snk	1
197	Text File(1).txt	/a/b/berhasiltesting/	2	0	snk	1
198	dxwebsetup(2).exe	/a/b/berhasiltesting/	315624	0	snk	1
199	ldplayer_id_2041_ld(2).exe	/a/b/berhasiltesting/	2978488	0	snk	1
200	Text File(2).txt	/a/b/berhasiltesting/	2	0	snk	1
201	Text File(2).txt	/a/b/berhasiltesting/	2	0	snk	1
202	dxwebsetup(3).exe	/a/b/berhasiltesting/	315624	0	snk	1
203	ldplayer_id_2041_ld(3).exe	/a/b/berhasiltesting/	2978488	0	snk	1
204	Text File(3).txt	/a/b/berhasiltesting/	2	0	snk	1
205	Text File(3).txt	/a/b/berhasiltesting/	2	0	snk	1
207	dxwebsetup.exe	/a/b/berhasiltesting/	315624	0	snk	1
208	ldplayer_id_2041_ld.exe	/a/b/berhasiltesting/	2978488	0	snk	1
210	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
212	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
214	dxwebsetup.exe	/a/b/berhasiltesting/	315624	0	snk	1
215	ldplayer_id_2041_ld.exe	/a/b/berhasiltesting/	2978488	0	snk	1
217	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
219	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
221	dxwebsetup.exe	/a/b/berhasiltesting/	315624	0	snk	1
222	ldplayer_id_2041_ld.exe	/a/b/berhasiltesting/	2978488	0	snk	1
224	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
226	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
228	dxwebsetup.exe	/a/b/berhasiltesting/	315624	0	snk	1
229	ldplayer_id_2041_ld.exe	/a/b/berhasiltesting/	2978488	0	snk	1
231	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
233	Text File.txt	/a/b/berhasiltesting/	2	0	snk	1
304	KPM_Febyk alek satria(2).pdf	/	453106	1	rsf	1
323	Silabus JS-1.pdf	/JS1/	231035	0	ema	1
162	Programs	/a/b/berhasiltesting/	0	0	snk	2
163	ah	/a/b/berhasiltesting/	0	0	snk	2
164	eh	/a/b/berhasiltesting/	0	0	snk	2
165	cobaRenameFile	/a/b/berhasiltesting/	0	0	snk	2
168	b	/a/b/berhasiltesting/	0	0	snk	2
167	a	/a/b/berhasiltesting/	0	0	snk	2
173	Programs	/a/b/berhasiltesting/	0	0	snk	2
176	ah	/a/b/berhasiltesting/	0	0	snk	2
178	eh	/a/b/berhasiltesting/	0	0	snk	2
180	snk	/a/b/berhasiltesting/	0	0	snk	2
183	Programs	/a/b/berhasiltesting/	0	0	snk	2
354	favicon1 1.png	/Kuliah/	5040	0	rsf	1
322	JS 1- Electronic Book.pdf	/JS1/	26039194	1	ema	1
\.


--
-- TOC entry 3090 (class 0 OID 17225)
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
121	67	rsf	6	docdownloader.com-pdf-interchange-4th-edition-level-1-student-book-dd_7a28a628ad8cf3e3021dea88206e9b68.pdf	2021-01-26 14:40:54.828955
122	68	rsf	6	favicon1 1.png	2021-01-26 14:44:42.993064
123	69	rsf	6	favicon1 1(1).png	2021-01-26 14:47:46.398869
124	70	rsf	6	IMG20201205173857 (1).jpg	2021-01-26 14:50:55.225441
125	71	rsf	6	WhatsApp Image 2020-12-17 at 14.50.48.jpeg	2021-01-26 14:54:05.95829
126	72	rsf	6	favicon1 1.png	2021-01-26 15:09:26.157409
127	73	rsf	6	favicon1 1(2).png	2021-01-26 15:10:50.934977
128	74	rsf	6	logo uread.png	2021-01-26 15:11:19.566184
129	75	rsf	6	favicon1 1.png	2021-01-26 15:12:47.384226
130	76	rsf	6	logo uread.png	2021-01-26 15:13:29.810503
131	77	rsf	6	favicon1 1(1).png	2021-01-26 15:14:39.185978
132	78	rsf	6	coba.jpg	2021-01-26 16:15:40.791669
133	79	rsf	6	favicon1 1.png	2021-01-26 16:15:40.801207
134	80	rsf	6	coba(1).jpg	2021-01-26 16:21:27.351118
135	81	rsf	6	logo uread.png	2021-01-26 16:21:27.361243
136	82	rsf	6	coba(2).jpg	2021-01-26 16:25:50.983045
137	83	rsf	6	CV 2020.jpg	2021-01-26 16:25:51.000363
138	84	rsf	6	favicon1 1.png	2021-01-26 16:26:58.322775
139	85	rsf	6	CV-RONI STARKO FIRDAUS.png	2021-01-26 16:26:58.353884
140	86	rsf	6	c25cb7a766b9b04817d29847f37fdecc-template-surat-pernyataan.docx	2021-01-26 16:32:22.078219
141	87	rsf	6	CamScanner 01-04-2021 14.29.05.pdf	2021-01-26 16:32:22.093613
142	88	rsf	6	Certificate NDSC Beginner _1368-1368.pdf	2021-01-26 16:32:22.100689
143	89	rsf	6	CV 2020.jpg	2021-01-26 16:32:22.107113
144	90	rsf	6	CV LENGKAP.pdf	2021-01-26 16:32:22.115489
145	91	rsf	6	CV-RONI STARKO FIRDAUS.png	2021-01-26 16:32:22.122663
146	92	rsf	6	CV-FEBYK ALEK SATRIA.jpg	2021-01-26 16:32:22.130655
147	93	rsf	6	CV-ADI KURNIAWAN.docx	2021-01-26 16:32:22.138249
148	94	rsf	6	decision tree.docx	2021-01-26 16:32:22.14501
149	95	rsf	6	docdownloader.com-pdf-interchange-4th-edition-level-1-student-book-dd_7a28a628ad8cf3e3021dea88206e9b68.pdf	2021-01-26 16:32:22.151541
150	96	rsf	6	favicon1 1.png	2021-01-26 16:32:22.230444
151	97	rsf	6	FISIP_PUTRI AMALIA_07011181722027_082282556151_MASK BY PYN_PMW 2020.pdf	2021-01-26 16:32:22.234645
152	98	rsf	6	IMG20201205173857 (1).jpg	2021-01-26 16:32:22.240332
153	99	rsf	6	Interchange 4th Edition Intro Student Book ( PDFDrive ).pdf	2021-01-26 16:32:22.254108
154	100	rsf	6	JS1-20210110T165728Z-001.zip	2021-01-26 16:32:22.402046
155	101	rsf	6	LPJ COMDEV FIX.docx	2021-01-26 16:32:22.47744
156	102	rsf	6	logo uread.png	2021-01-26 16:32:22.485307
157	103	rsf	6	KRS_09021181823003_SEMESTER_6_2020-2021.doc	2021-01-26 16:32:22.489404
158	104	rsf	6	KHS_09021181823003_SEMESTER_5_2020-2021.doc	2021-01-26 16:32:22.493401
159	105	rsf	6	LPJ KOMINFO FIX.docx	2021-01-26 16:32:22.497324
160	106	rsf	6	main.100092.com.squareenix.lis.obb	2021-01-26 16:48:52.730306
161	107	rsf	6	budidoremi.mp4	2021-01-26 17:15:42.614071
162	108	rsf	6	budidoremi(1).mp4	2021-01-26 17:18:02.198193
163	109	rsf	6	aku.kamu.dia.hai.png	2021-01-26 17:38:28.357667
164	110	rsf	6	aku.kamu.dia.hai.(1)png	2021-01-26 17:38:35.55414
165	111	rsf	6	aku.kamu.dia.hai(1).png	2021-01-26 17:54:08.925791
166	112	rsf	6	aku.kamu.dia.hai(2).png	2021-01-26 17:54:19.281975
167	113	rsf	6	aku.kamu.png	2021-01-26 17:55:29.324502
168	114	rsf	6	aku.kamu(1).png	2021-01-26 17:55:32.088781
169	115	rsf	6	aku.kamu(2).png	2021-01-26 17:55:37.618425
170	116	rsf	6	aku.kamu. wah.ahw .png	2021-01-26 18:00:53.733051
171	117	rsf	6	aku.kamu. wah.ahw (1).png	2021-01-26 18:00:59.567066
172	118	rsf	6	aku.kamu. wah.ahw (2).png	2021-01-26 18:01:12.162018
173	119	rsf	6	aku.kamu. wah.ahw (3).png	2021-01-26 18:01:55.479661
174	120	rsf	6	main.100092.com.squareenix.lis.obb	2021-01-26 18:29:37.483589
175	121	snk	6	Chapter 15 - Integration, Impact, and Future of MSS.pdf	2021-01-26 20:21:25.40318
176	122	rsf	6	IMG20201205173857 (1).jpg	2021-01-26 21:06:27.520515
177	123	rsf	6	logo uread.png	2021-01-26 21:06:27.9116
178	124	rsf	6	IMG20201205173857 (1)(1).jpg	2021-01-26 21:06:28.798552
179	125	rsf	6	logo uread(1).png	2021-01-26 21:06:28.817679
180	126	rsf	1	adi cihuy	2021-01-26 21:47:50.457888
181	128	rsf	1	nah adi	2021-01-26 21:52:32.496798
182	129	rsf	1	kunnnl	2021-01-26 21:54:17.846078
183	130	rsf	1	kunnnl	2021-01-26 21:57:17.251274
184	131	rsf	1	kunnnl	2021-01-26 21:57:42.847819
185	132	rsf	1	kunnnl	2021-01-26 21:57:55.648061
186	133	rsf	1	ggsgs	2021-01-26 22:01:42.757876
187	134	rsf	6	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-26 22:12:50.179379
188	135	rsf	6	magnifying-glass 1.png	2021-01-26 22:14:52.607449
189	136	rsf	6	magnifying-glass 1(1).png	2021-01-26 22:15:27.007149
190	122	rsf	7	IMG20201205173857 (1).jpg	2021-01-27 12:52:46.341965
191	120	rsf	7	main.100092.com.squareenix.lis.obb	2021-01-27 12:52:49.68211
192	108	rsf	7	budidoremi(1).mp4	2021-01-27 12:52:52.448509
193	101	rsf	7	LPJ COMDEV FIX.docx	2021-01-27 12:53:01.943359
194	87	rsf	7	CamScanner 01-04-2021 14.29.05.pdf	2021-01-27 12:53:14.801471
195	126	rsf	4	adi cihuy	2021-01-27 19:04:25.273523
196	137	rsf	1	woi	2021-01-27 19:05:18.669877
197	138	rsf	1	ea	2021-01-27 19:05:21.959856
198	139	rsf	1	gg	2021-01-27 19:05:24.671453
199	140	rsf	1	ea	2021-01-27 19:05:28.682925
200	140	rsf	4	ea	2021-01-27 19:07:30.412677
201	128	rsf	4	nah adi	2021-01-27 19:07:30.412677
202	133	rsf	4	ggsgs	2021-01-27 19:07:30.412677
203	139	rsf	4	gg	2021-01-27 19:07:30.412677
204	138	rsf	4	ea	2021-01-27 19:07:30.412677
205	138	rsf	5	ea	2021-01-27 20:06:25.291694
206	141	snk	6	dxwebsetup(1).exe	2021-01-28 16:51:08.502782
207	142	snk	6	ldplayer_id_2041_ld(1).exe	2021-01-28 16:51:08.535856
208	143	snk	6	Text File(1).txt	2021-01-28 16:51:08.551777
209	144	snk	1	Programs	2021-01-28 17:36:21.619791
210	145	snk	6	Programs/dxwebsetup.exe	2021-01-28 17:36:21.631609
211	146	snk	6	Programs/ldplayer_id_2041_ld.exe	2021-01-28 17:36:21.644195
212	147	snk	1	ah	2021-01-28 17:36:21.661153
213	148	snk	6	Programs/ah/Text File.txt	2021-01-28 17:36:21.665736
214	149	snk	1	Programs	2021-01-28 17:42:54.195828
215	150	snk	6	Programs/dxwebsetup.exe	2021-01-28 17:42:54.230121
216	151	snk	6	Programs/ldplayer_id_2041_ld.exe	2021-01-28 17:42:54.247139
217	152	snk	1	ah	2021-01-28 17:42:54.275561
218	153	snk	6	Programs/ah/Text File.txt	2021-01-28 17:42:54.28489
219	154	snk	1	testHapus	2021-01-28 10:47:16.562421
220	155	snk	6	testhapusFile	2021-01-28 10:47:16.562421
221	156	snk	1	Programs	2021-01-28 17:47:24.823146
222	157	snk	6	testhapusfungsihapus	2021-01-28 10:47:44.148385
223	158	snk	1	Programs	2021-01-28 17:50:23.899326
224	159	snk	1	Programs	2021-01-28 17:51:22.897193
225	160	snk	1	Programs	2021-01-28 17:52:56.912478
226	161	snk	6	testFileSNK	2021-01-28 10:58:46.065596
227	162	snk	1	Programs	2021-01-28 18:02:52.848365
228	163	snk	1	ah	2021-01-28 18:02:53.009075
229	164	snk	1	eh	2021-01-28 18:07:30.714101
230	165	snk	1	cobaRenameFile	2021-01-28 11:18:08.48297
231	166	snk	6	fileKerenSekali.png	2021-01-28 11:20:11.134343
232	167	snk	1	a	2021-01-28 11:20:11.134343
233	168	snk	1	b	2021-01-28 11:20:11.134343
237	169	snk	6	dxwebsetup(12).exe	2021-01-28 18:24:13.33079
238	170	snk	6	ldplayer_id_2041_ld(10).exe	2021-01-28 18:24:13.34467
239	171	snk	6	Text File(10).txt	2021-01-28 18:24:13.386146
240	172	snk	6	Text File(7).txt	2021-01-28 18:24:13.484924
242	173	snk	1	Programs	2021-01-28 18:25:53.882991
243	174	snk	6	dxwebsetup.exe	2021-01-28 18:25:53.900456
244	175	snk	6	ldplayer_id_2041_ld.exe	2021-01-28 18:25:53.910909
245	176	snk	1	ah	2021-01-28 18:25:53.927176
246	177	snk	6	Text File.txt	2021-01-28 18:25:53.934676
247	178	snk	1	eh	2021-01-28 18:25:53.943129
248	179	snk	6	Text File.txt	2021-01-28 18:25:53.948953
249	180	snk	1	snk	2021-01-28 18:28:38.871342
250	181	snk	6	dxwebsetup.exe	2021-01-28 18:28:38.906526
251	182	snk	6	ldplayer_id_2041_ld.exe	2021-01-28 18:28:38.921576
252	183	snk	1	Programs	2021-01-28 18:28:38.941192
253	184	snk	6	Text File.txt	2021-01-28 18:28:38.948949
254	185	snk	1	ah	2021-01-28 18:28:38.960353
255	186	snk	6	Text File.txt	2021-01-28 18:28:38.96628
256	187	snk	1	snk	2021-01-28 18:31:47.44468
257	188	snk	6	dxwebsetup.exe	2021-01-28 18:31:47.535274
258	189	snk	6	ldplayer_id_2041_ld.exe	2021-01-28 18:31:47.551461
259	190	snk	1	Programs	2021-01-28 18:31:47.576015
260	191	snk	6	Text File.txt	2021-01-28 18:31:47.581725
261	192	snk	1	ah	2021-01-28 18:31:47.592028
262	193	snk	6	Text File.txt	2021-01-28 18:31:47.603187
263	194	snk	6	dxwebsetup(1).exe	2021-01-28 18:33:05.538761
264	195	snk	6	ldplayer_id_2041_ld(1).exe	2021-01-28 18:33:05.571097
265	196	snk	6	Text File(1).txt	2021-01-28 18:33:05.587884
266	197	snk	6	Text File(1).txt	2021-01-28 18:33:05.598256
267	198	snk	6	dxwebsetup(2).exe	2021-01-28 18:34:51.24173
268	199	snk	6	ldplayer_id_2041_ld(2).exe	2021-01-28 18:34:51.265935
269	200	snk	6	Text File(2).txt	2021-01-28 18:34:51.30124
270	201	snk	6	Text File(2).txt	2021-01-28 18:34:51.356032
271	202	snk	6	dxwebsetup(3).exe	2021-01-28 18:36:11.38095
272	203	snk	6	ldplayer_id_2041_ld(3).exe	2021-01-28 18:36:11.395899
273	204	snk	6	Text File(3).txt	2021-01-28 18:36:11.431034
274	205	snk	6	Text File(3).txt	2021-01-28 18:36:11.465574
275	206	snk	1	snk	2021-01-28 18:36:39.79276
276	207	snk	6	dxwebsetup.exe	2021-01-28 18:36:39.824752
277	208	snk	6	ldplayer_id_2041_ld.exe	2021-01-28 18:36:39.836445
278	209	snk	1	Programs	2021-01-28 18:36:39.852951
279	210	snk	6	Text File.txt	2021-01-28 18:36:39.858534
280	211	snk	1	ah	2021-01-28 18:36:39.868247
281	212	snk	6	Text File.txt	2021-01-28 18:36:39.873514
282	213	snk	1	snk	2021-01-28 18:39:01.801262
283	214	snk	6	dxwebsetup.exe	2021-01-28 18:39:01.835135
284	215	snk	6	ldplayer_id_2041_ld.exe	2021-01-28 18:39:01.852795
285	216	snk	1	Programs	2021-01-28 18:39:01.881475
286	217	snk	6	Text File.txt	2021-01-28 18:39:01.889497
287	218	snk	1	ah	2021-01-28 18:39:01.906137
288	219	snk	6	Text File.txt	2021-01-28 18:39:01.91197
289	220	snk	1	snk	2021-01-28 18:41:39.138325
290	221	snk	6	dxwebsetup.exe	2021-01-28 18:41:39.270034
291	222	snk	6	ldplayer_id_2041_ld.exe	2021-01-28 18:41:39.285596
292	223	snk	1	Programs	2021-01-28 18:41:39.30914
293	224	snk	6	Text File.txt	2021-01-28 18:41:39.31566
294	225	snk	1	ah	2021-01-28 18:41:39.327657
295	226	snk	6	Text File.txt	2021-01-28 18:41:39.333962
296	227	snk	1	Programs	2021-01-28 18:43:55.422323
297	228	snk	6	dxwebsetup.exe	2021-01-28 18:43:55.459172
298	229	snk	6	ldplayer_id_2041_ld.exe	2021-01-28 18:43:55.475913
299	230	snk	1	ah	2021-01-28 18:43:55.501413
300	231	snk	6	Text File.txt	2021-01-28 18:43:55.50844
301	232	snk	1	eh	2021-01-28 18:43:55.519928
302	233	snk	6	Text File.txt	2021-01-28 18:43:55.526301
303	234	snk	6	dxwebsetup(1).exe	2021-01-28 18:44:31.632377
304	235	snk	6	ldplayer_id_2041_ld(1).exe	2021-01-28 18:44:31.641148
305	236	snk	6	Text File(1).txt	2021-01-28 18:44:31.662455
306	237	snk	6	Text File(1).txt	2021-01-28 18:44:31.67239
307	238	rsf	1	upload ini	2021-01-28 19:13:59.492064
308	239	rsf	6	aktivitas.odt	2021-01-28 19:13:59.611881
309	240	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:13:59.639188
310	241	rsf	1	kedua	2021-01-28 19:13:59.658795
311	242	rsf	6	aktivitas.odt	2021-01-28 19:13:59.66273
312	243	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:13:59.670359
313	244	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:17:19.939253
314	245	rsf	6	KPM_Febyk alek satria(1).pdf	2021-01-28 19:20:16.979325
315	246	rsf	1	upload ini	2021-01-28 19:22:22.278006
316	247	rsf	6	aktivitas.odt	2021-01-28 19:22:22.297994
317	248	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:22:22.3107
318	249	rsf	1	kedua	2021-01-28 19:22:22.321409
319	250	rsf	6	aktivitas.odt	2021-01-28 19:22:22.327577
320	251	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:22:22.339029
321	252	rsf	1	upload ini	2021-01-28 19:23:44.584982
322	253	rsf	6	aktivitas.odt	2021-01-28 19:23:44.590631
323	254	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:23:44.60084
324	255	rsf	1	kedua	2021-01-28 19:23:44.61301
325	256	rsf	6	aktivitas.odt	2021-01-28 19:23:44.619165
326	257	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:23:44.628047
327	258	rsf	1	upload ini	2021-01-28 19:26:40.696162
328	259	rsf	6	aktivitas.odt	2021-01-28 19:26:40.710375
329	260	rsf	1	upload ini	2021-01-28 19:26:40.724864
330	261	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:26:40.730985
331	262	rsf	1	kedua	2021-01-28 19:26:40.74344
332	263	rsf	6	aktivitas.odt	2021-01-28 19:26:40.749909
333	264	rsf	1	kedua	2021-01-28 19:26:40.759425
334	265	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:26:40.76375
335	266	rsf	1	upload ini	2021-01-28 19:30:01.502754
336	267	rsf	6	aktivitas.odt	2021-01-28 19:30:01.516705
337	268	rsf	1	upload ini	2021-01-28 19:30:01.534287
338	269	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:30:01.54132
339	270	rsf	1	kedua	2021-01-28 19:30:01.552692
340	271	rsf	6	aktivitas.odt	2021-01-28 19:30:01.558569
341	272	rsf	1	kedua	2021-01-28 19:30:01.568346
342	273	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:30:01.574186
343	274	rsf	1	upload ini	2021-01-28 19:31:04.442952
344	275	rsf	6	aktivitas.odt	2021-01-28 19:31:04.458733
345	276	rsf	1	upload ini	2021-01-28 19:31:04.477157
346	277	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:31:04.483977
347	278	rsf	1	kedua	2021-01-28 19:31:04.495543
348	279	rsf	6	aktivitas.odt	2021-01-28 19:31:04.501813
349	280	rsf	1	kedua	2021-01-28 19:31:04.512061
350	281	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:31:04.517488
351	282	rsf	1	upload ini	2021-01-28 19:41:01.6873
352	283	rsf	6	aktivitas.odt	2021-01-28 19:41:01.701494
353	284	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:41:01.717796
354	285	rsf	1	kedua	2021-01-28 19:41:01.72992
355	286	rsf	6	aktivitas.odt	2021-01-28 19:41:01.736091
356	287	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:41:01.748552
357	288	rsf	1	upload ini	2021-01-28 19:43:25.821144
358	289	rsf	6	aktivitas.odt	2021-01-28 19:43:25.826704
359	290	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:43:25.838999
360	291	rsf	1	kedua	2021-01-28 19:43:25.847503
361	292	rsf	6	aktivitas.odt	2021-01-28 19:43:25.851502
362	293	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:43:25.859155
363	294	rsf	1	upload ini	2021-01-28 19:44:15.511193
364	295	rsf	6	aktivitas.odt	2021-01-28 19:44:15.515975
365	296	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:44:15.524497
366	297	rsf	1	kedua	2021-01-28 19:44:15.534064
367	298	rsf	6	aktivitas.odt	2021-01-28 19:44:15.539327
368	299	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:44:15.547241
369	300	rsf	6	aktivitas(1).odt	2021-01-28 19:45:32.160778
370	301	rsf	6	KPM_Febyk alek satria(1).pdf	2021-01-28 19:45:32.197841
371	302	rsf	6	aktivitas(1).odt	2021-01-28 19:45:32.210245
372	303	rsf	6	KPM_Febyk alek satria(1).pdf	2021-01-28 19:45:32.221166
373	304	rsf	6	KPM_Febyk alek satria(2).pdf	2021-01-28 19:47:29.515806
374	305	rsf	6	KPM_Febyk alek satria.pdf	2021-01-28 19:48:05.445783
375	306	rsf	6	aktivitas(2).odt	2021-01-28 20:13:28.989851
376	307	rsf	6	KPM_Febyk alek satria(2).pdf	2021-01-28 20:13:29.012994
377	308	rsf	6	aktivitas(2).odt	2021-01-28 20:13:29.025251
378	309	rsf	6	KPM_Febyk alek satria(2).pdf	2021-01-28 20:13:29.037511
379	310	ema	1	upload ini	2021-01-28 20:16:01.167299
380	311	ema	6	aktivitas.odt	2021-01-28 20:16:01.174657
381	312	ema	6	KPM_Febyk alek satria.pdf	2021-01-28 20:16:01.188724
382	313	ema	1	kedua	2021-01-28 20:16:01.198805
383	314	ema	6	aktivitas.odt	2021-01-28 20:16:01.204663
384	315	ema	6	KPM_Febyk alek satria.pdf	2021-01-28 20:16:01.213606
385	316	snk	6	tes.png	2021-01-28 16:23:04.849236
386	317	snk	1	tesubah	2021-01-28 16:23:04.849236
387	318	snk	6	oik.jpg	2021-01-28 16:23:04.849236
394	319	ema	1	JS1	2021-01-28 23:47:12.391038
395	320	ema	6	Beda Level.jpeg	2021-01-28 23:47:12.403683
396	321	ema	6	Super Jago Speaking 1.jpeg	2021-01-28 23:47:12.419307
397	322	ema	6	JS 1- Electronic Book.pdf	2021-01-28 23:47:12.432541
398	323	ema	6	Silabus JS-1.pdf	2021-01-28 23:47:12.493932
399	324	t	1	folder1	2021-01-28 17:47:23.649911
400	325	t	1	folder2	2021-01-28 17:47:23.649911
401	326	t	6	file1	2021-01-28 17:47:23.649911
402	327	t	6	file2	2021-01-28 17:47:23.649911
403	328	t	1	folder3	2021-01-28 17:47:23.649911
404	329	t	6	file4	2021-01-28 17:48:37.43048
408	324	t	3	folder a	2021-01-28 17:55:10.744919
409	325	t	3	folder2	2021-01-28 19:54:26.685744
410	325	t	3	BerhasilPlis	2021-01-28 19:59:36.770688
411	330	rsf	1	folder ku	2021-01-29 05:36:06.025366
412	331	rsf	1	adi kurniawan	2021-01-29 05:36:31.029353
413	332	rsf	1	roni	2021-01-29 05:38:57.870032
414	333	rsf	1	roni	2021-01-29 05:43:07.813595
415	334	rsf	1	basing	2021-01-29 05:44:26.376486
416	335	rsf	6	Beda Level.jpeg	2021-01-29 16:29:12.91789
417	336	rsf	6	Beda Level.jpeg	2021-01-29 16:31:34.668568
418	337	rsf	6	Beda Level(1).jpeg	2021-01-29 16:32:39.181071
419	338	rsf	1	adi  nak nyoba	2021-01-29 16:33:19.800407
420	339	rsf	1	upload ini	2021-01-29 16:35:28.856137
421	340	rsf	6	aktivitas.odt	2021-01-29 16:35:28.864805
422	341	rsf	6	KPM_Febyk alek satria.pdf	2021-01-29 16:35:28.877181
423	342	rsf	1	kedua	2021-01-29 16:35:28.88663
424	343	rsf	6	aktivitas.odt	2021-01-29 16:35:28.89079
425	344	rsf	6	KPM_Febyk alek satria.pdf	2021-01-29 16:35:28.89836
426	345	rsf	1	upload ini	2021-01-29 16:51:53.710661
427	346	rsf	6	aktivitas.odt	2021-01-29 16:51:53.727194
428	347	rsf	6	KPM_Febyk alek satria.pdf	2021-01-29 16:51:53.742158
429	348	rsf	1	kedua	2021-01-29 16:51:53.75227
430	349	rsf	6	aktivitas.odt	2021-01-29 16:51:53.757121
431	350	rsf	6	KPM_Febyk alek satria.pdf	2021-01-29 16:51:53.76541
432	351	rsf	1	folder baru	2021-01-29 16:55:18.508987
433	352	rsf	6	KPM_Febyk alek satria.pdf	2021-01-29 16:55:35.861852
434	134	rsf	7	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 17:54:29.103347
435	352	rsf	7	KPM_Febyk alek satria.pdf	2021-01-29 11:35:05.496898
436	352	rsf	9	KPM_Febyk alek satria.pdf	2021-01-29 11:35:16.85793
437	134	rsf	9	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 18:55:12.029568
438	134	rsf	7	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 21:40:49.277067
439	134	rsf	9	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 21:41:56.659099
440	134	rsf	7	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 21:46:42.781672
441	134	rsf	9	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 21:55:04.847772
442	122	rsf	9	IMG20201205173857 (1).jpg	2021-01-29 22:18:05.483814
443	134	rsf	7	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 22:19:12.152643
444	87	rsf	9	CamScanner 01-04-2021 14.29.05.pdf	2021-01-29 22:49:04.634007
445	134	rsf	9	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 22:49:33.817358
446	134	rsf	7	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 22:50:06.687407
447	120	rsf	9	main.100092.com.squareenix.lis.obb	2021-01-29 22:53:47.885923
448	134	rsf	9	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-29 22:54:36.100791
449	245	rsf	7	KPM_Febyk alek satria(1).pdf	2021-01-30 00:06:52.967166
450	245	rsf	9	KPM_Febyk alek satria(1).pdf	2021-01-30 00:07:20.919511
451	245	rsf	7	KPM_Febyk alek satria(1).pdf	2021-01-30 00:08:30.034976
452	245	rsf	9	KPM_Febyk alek satria(1).pdf	2021-01-30 00:08:36.793334
453	245	rsf	7	KPM_Febyk alek satria(1).pdf	2021-01-30 00:09:02.296624
454	245	rsf	9	KPM_Febyk alek satria(1).pdf	2021-01-30 00:09:09.970056
455	57	rsf	7	KRS.pdf	2021-01-30 00:11:38.340489
456	57	rsf	9	KRS.pdf	2021-01-30 00:11:46.326707
457	57	rsf	7	KRS.pdf	2021-01-30 00:13:22.171884
458	57	rsf	9	KRS.pdf	2021-01-30 00:13:31.40771
459	353	rsf	6	logo uread.png	2021-01-30 00:30:10.921764
460	354	rsf	6	favicon1 1.png	2021-01-30 00:31:05.077641
461	134	rsf	7	Screenshot_2021-01-11-20-18-31-185_us.zoom.videomeetings.jpg	2021-01-30 00:31:48.084197
462	355	test	6	coba.jpg	2021-01-30 00:36:44.435173
463	356	test	6	docdownloader.com-pdf-interchange-4th-edition-level-1-student-book-dd_7a28a628ad8cf3e3021dea88206e9b68.pdf	2021-01-30 00:41:44.648704
464	357	test	6	docdownloader.com-pdf-interchange-4th-edition-level-1-student-book-dd_7a28a628ad8cf3e3021dea88206e9b68(1).pdf	2021-01-30 00:42:18.075215
465	358	test	1	null	2021-01-30 00:43:12.8516
466	359	test	6	docdownloader.com-pdf-interchange-4th-edition-level-1-student-book-dd_7a28a628ad8cf3e3021dea88206e9b68.pdf	2021-01-30 00:43:50.653366
467	360	test	6	docdownloader.com-pdf-interchange-4th-edition-level-1-student-book-dd_7a28a628ad8cf3e3021dea88206e9b68(1).pdf	2021-01-30 00:43:56.583499
468	361	test	1	kisanak	2021-01-30 00:45:51.37101
469	362	test	1	kisanak	2021-01-30 00:47:15.548637
470	363	test	1	ungu	2021-01-30 00:47:37.355477
471	364	test	6	coba.jpg	2021-01-30 00:48:32.417087
472	365	test	6	Chapter 15 - Integration, Impact, and Future of MSS.pdf	2021-01-30 00:49:37.999969
473	366	test	6	Chapter 15 - Integration, Impact, and Future of MSS(1).pdf	2021-01-30 00:50:26.57169
474	367	test	1	dsads	2021-01-30 00:51:28.992068
475	368	test	1	woik	2021-01-30 00:52:28.590787
476	369	test	1	kisanak 2	2021-01-30 00:52:57.261597
477	370	test	1	anak kisanak	2021-01-30 00:53:32.791896
478	371	test	1	kisanak kisanak	2021-01-30 00:54:18.565932
479	372	test	1	upload ini	2021-01-30 00:56:51.961385
480	373	test	6	aktivitas.odt	2021-01-30 00:56:51.968247
481	374	test	6	KPM_Febyk alek satria.pdf	2021-01-30 00:56:51.982912
482	375	test	1	kedua	2021-01-30 00:56:51.994521
483	376	test	6	aktivitas.odt	2021-01-30 00:56:52.002153
484	377	test	6	KPM_Febyk alek satria.pdf	2021-01-30 00:56:52.012897
485	378	test	1	Wallpapers	2021-01-30 00:58:20.229006
486	379	test	6	wallpaperflare.com_wallpaper.jpg	2021-01-30 00:58:20.235179
487	380	test	6	mikael-gustafsson-wallpaper-mikael-gustafsson.jpg	2021-01-30 00:58:20.250321
488	381	test	6	n4.png	2021-01-30 00:58:20.26431
489	382	test	6	62436108_10155899187370670_7258125010865225728_o.jpg	2021-01-30 00:58:20.276222
490	383	test	6	mikael-gustafsson-amongtrees-2-8.jpg	2021-01-30 00:58:20.288445
491	384	test	6	wallhaven-ym56zg_1920x1080.png	2021-01-30 00:58:20.301071
492	385	test	6	1wallpaperflare.com_wallpaper.jpg	2021-01-30 00:58:20.316473
493	386	test	6	star.png	2021-01-30 00:58:20.333689
494	320	ema	7	Beda Level.jpeg	2021-01-30 01:00:19.229997
495	373	test	7	aktivitas.odt	2021-01-30 01:00:29.67336
496	374	test	7	KPM_Febyk alek satria.pdf	2021-01-30 01:00:33.661496
497	375	test	4	kedua	2021-01-29 18:20:31.429302
498	135	rsf	7	magnifying-glass 1.png	2021-01-30 01:41:39.547168
499	388	test	1	kedua	2021-01-29 18:45:58.579978
500	389	test	1	kedua	2021-01-29 18:47:29.689567
501	391	test	1	kedua	2021-01-29 18:49:58.121315
502	58	rsf	7	poto.png	2021-01-30 01:50:48.210956
503	136	rsf	7	magnifying-glass 1(1).png	2021-01-30 01:51:41.972761
504	391	test	3	kedua	2021-01-29 18:53:15.640873
505	57	rsf	7	KRS.pdf	2021-01-30 01:53:58.98521
506	245	rsf	7	KPM_Febyk alek satria(1).pdf	2021-01-30 01:54:22.637825
507	321	ema	7	Super Jago Speaking 1.jpeg	2021-01-30 01:55:53.570758
508	392	ema	6	febyk 4x6.jpg	2021-01-30 01:59:00.263929
509	393	test	1	gege	2021-01-29 19:00:09.917664
510	394	test	1	Wallpapers	2021-01-29 19:05:41.624886
511	395	test	1	gege	2021-01-29 19:09:10.641241
513	398	test	1	gege	2021-01-29 19:11:22.532967
514	399	test	1	Wallpapers	2021-01-29 19:11:22.532967
515	400	rsf	6	febyk 4x6.jpg	2021-01-30 02:12:53.254362
516	401	rsf	6	febyk 4x6.jpg	2021-01-30 02:14:50.480591
517	402	test	1	Wallpapers	2021-01-30 02:15:07.606825
518	403	test	6	wallpaperflare.com_wallpaper.jpg	2021-01-30 02:15:07.615371
519	404	test	6	mikael-gustafsson-wallpaper-mikael-gustafsson.jpg	2021-01-30 02:15:07.626948
520	405	test	6	n4.png	2021-01-30 02:15:07.638847
521	406	test	6	62436108_10155899187370670_7258125010865225728_o.jpg	2021-01-30 02:15:07.64914
522	407	test	6	mikael-gustafsson-amongtrees-2-8.jpg	2021-01-30 02:15:07.660378
523	408	test	6	wallhaven-ym56zg_1920x1080.png	2021-01-30 02:15:07.671974
524	409	test	6	1wallpaperflare.com_wallpaper.jpg	2021-01-30 02:15:07.687517
525	410	test	6	star.png	2021-01-30 02:15:07.700837
526	411	test	1	Wallpapers	2021-01-30 02:15:57.213661
527	412	test	6	wallpaperflare.com_wallpaper.jpg	2021-01-30 02:15:57.220883
528	413	test	6	mikael-gustafsson-wallpaper-mikael-gustafsson.jpg	2021-01-30 02:15:57.237864
529	414	test	6	n4.png	2021-01-30 02:15:57.24721
530	415	test	6	62436108_10155899187370670_7258125010865225728_o.jpg	2021-01-30 02:15:57.257031
531	416	test	6	mikael-gustafsson-amongtrees-2-8.jpg	2021-01-30 02:15:57.265748
532	417	test	6	wallhaven-ym56zg_1920x1080.png	2021-01-30 02:15:57.280882
533	418	test	6	1wallpaperflare.com_wallpaper.jpg	2021-01-30 02:15:57.292822
534	419	test	6	star.png	2021-01-30 02:15:57.302499
535	411	test	4	Wallpapers	2021-01-29 19:16:47.542795
536	420	test	1	Wallpapers	2021-01-30 02:18:39.891276
537	421	test	6	wallpaperflare.com_wallpaper.jpg	2021-01-30 02:18:39.898469
538	422	test	6	mikael-gustafsson-wallpaper-mikael-gustafsson.jpg	2021-01-30 02:18:39.913968
539	423	test	6	n4.png	2021-01-30 02:18:39.928628
540	424	test	6	62436108_10155899187370670_7258125010865225728_o.jpg	2021-01-30 02:18:39.942337
541	425	test	6	mikael-gustafsson-amongtrees-2-8.jpg	2021-01-30 02:18:39.957026
542	426	test	6	wallhaven-ym56zg_1920x1080.png	2021-01-30 02:18:39.971106
545	420	test	4	Wallpapers	2021-01-29 19:19:02.043203
543	427	test	6	1wallpaperflare.com_wallpaper.jpg	2021-01-30 02:18:39.986577
544	428	test	6	star.png	2021-01-30 02:18:40.001595
546	429	test	1	ERD	2021-01-30 02:22:51.581748
547	430	test	6	ActivityDiagram.jpg	2021-01-30 02:22:51.599139
548	431	test	6	ClassDiagram.jpg	2021-01-30 02:22:51.615243
549	432	test	6	Usecase.jpg	2021-01-30 02:22:51.627515
550	433	test	6	UserFlow.jpg	2021-01-30 02:22:51.639376
551	429	test	4	ERD	2021-01-29 19:23:32.194293
552	402	test	4	Wallpapers	2021-01-29 19:31:59.308547
553	402	test	5	Wallpapers	2021-01-30 02:32:53.099273
554	434	test	6	daming kelar.pdf	2021-01-30 02:37:58.448722
555	434	test	7	daming kelar.pdf	2021-01-30 02:38:28.265217
556	434	test	9	daming kelar.pdf	2021-01-29 19:39:42.463342
557	407	test	8	mikael-gustafsson-amongtrees-2-8.jpg	2021-01-30 02:40:25.306583
558	434	test	8	daming kelar.pdf	2021-01-30 02:44:38.146513
559	410	test	8	star.png	2021-01-30 02:48:26.997782
560	435	test	6	daming kelar(1).pdf	2021-01-30 02:48:57.516908
561	409	test	8	1wallpaperflare.com_wallpaper.jpg	2021-01-30 02:49:13.463803
562	435	test	8	daming kelar(1).pdf	2021-01-30 02:49:55.485353
563	435	test	8	adi.pdf	2021-01-30 02:58:56.784515
564	436	test	6	KPM_Febyk alek satria.pdf	2021-01-30 03:01:01.05395
565	436	test	8	KPM_Febyk alek satria.pdf	2021-01-30 03:01:17.473878
566	300	rsf	7	aktivitas(1).odt	2021-01-30 03:41:43.58725
567	304	rsf	7	KPM_Febyk alek satria(2).pdf	2021-01-30 04:23:22.223247
568	322	ema	7	JS 1- Electronic Book.pdf	2021-01-30 14:34:26.90882
569	437	ihsan	6	daming kelar.odt	2021-01-30 14:51:34.173205
570	311	ema	7	aktivitas.odt	2021-01-30 14:55:22.251419
571	438	ihsan	6	sistem pakar minggu 1.mkv	2021-01-30 14:55:24.839506
572	311	ema	9	aktivitas.odt	2021-01-30 14:57:37.374832
573	438	ihsan	8	sistem pakar minggu 1.mkv	2021-01-30 14:59:34.761462
574	437	ihsan	7	daming kelar.odt	2021-01-30 15:00:25.814608
575	438	ihsan	7	mingguan.mkv	2021-01-30 15:00:32.977819
\.


--
-- TOC entry 3083 (class 0 OID 16874)
-- Dependencies: 200
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: akdev
--

COPY public.users (username, name, password, phone, email, space, used_space, role_id, status_id) FROM stdin;
test	test1	n4bQgYhMfWWaL-qgxVrQFaO_TxsrC4Is0V1sFbDwCgg=	098931	febykaleksatria@gmail.com	10000000000	8628978	2	0
akdev	Adi Kurniawan	Hg6xftqVTlEiSTkAEvB3plSfvi1yyZgx29xFDtDQ4fI=	082182751010	adikurniawan.dev@gmail.com	0	0	1	1
feals	Febyk Alek Satria	9wDhtWXFkumcYECrx-n2KhlUngZthajfq2LFZB0cksE=	081373107544	febykaleksatria@gmail.com	5000000000	10000000	2	0
ema	Ema Hermawati SPd	jBWnY4gtSGIQ3j9R3nOsFZz4tFGiINIGvet_JXiHg2k=	081373107544	ema@gmail.com	5000000000	27922723	2	1
ihsan	ihsan	ypeBEsobvcr6wjGzmiPcTaeG7_gUfE5yuYB3ha_uSLs=	328473284	ihsan@email.com	2000000000	239672706	2	0
snk	Sinka Juliani	NugHLPi0prWTOPQ9Pfq02ZIH5nDAS8_E4LL6IFGNBho=	082182751010	sinka@gmail.com	10000000000	277777999	2	0
t	Akun Test Database	47mKTaMaEn1L3m5DAz9muidMqw636xxw7EFAK_YnPdg=	08080808	t@mail.com	20000000000	259042	2	0
admin	Admin Digifile	SEnOpuePqw9Vxa4JAj6dkV_dAPfDp7dAGAYYXiT7O6Q=			0	0	1	1
rsf	Roni Starko	uN3kUITsovYN__Fkf1JbGp6RogstwVvZqwAvLXgkemk=	0895621854457	rsf.project@gmail.com	10000000000	2876321616	2	0
\.


--
-- TOC entry 3099 (class 0 OID 0)
-- Dependencies: 202
-- Name: files_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.files_file_id_seq', 438, true);


--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 206
-- Name: log_activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: akdev
--

SELECT pg_catalog.setval('public.log_activity_log_id_seq', 575, true);


--
-- TOC entry 2918 (class 2606 OID 16894)
-- Name: detail_activity detail_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_activity
    ADD CONSTRAINT detail_activity_pkey PRIMARY KEY (activity_id);


--
-- TOC entry 2924 (class 2606 OID 17101)
-- Name: detail_status detail_status_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_status
    ADD CONSTRAINT detail_status_pk PRIMARY KEY (status_id);


--
-- TOC entry 2933 (class 2606 OID 25554)
-- Name: detail_type detail_type_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_type
    ADD CONSTRAINT detail_type_pk PRIMARY KEY (type_id);


--
-- TOC entry 2920 (class 2606 OID 16972)
-- Name: items files_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT files_pkey PRIMARY KEY (item_id);


--
-- TOC entry 2928 (class 2606 OID 17234)
-- Name: logs log_activity_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT log_activity_pk PRIMARY KEY (log_id);


--
-- TOC entry 2922 (class 2606 OID 17016)
-- Name: detail_role role_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- TOC entry 2930 (class 2606 OID 25465)
-- Name: detail_trash status_trash_pk; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.detail_trash
    ADD CONSTRAINT status_trash_pk PRIMARY KEY (trash_id);


--
-- TOC entry 2916 (class 2606 OID 16881)
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (username);


--
-- TOC entry 2925 (class 1259 OID 17099)
-- Name: detail_status_status_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_status_status_id_uindex ON public.detail_status USING btree (status_id);


--
-- TOC entry 2934 (class 1259 OID 25552)
-- Name: detail_type_type_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX detail_type_type_id_uindex ON public.detail_type USING btree (type_id);


--
-- TOC entry 2926 (class 1259 OID 17232)
-- Name: log_activity_log_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX log_activity_log_id_uindex ON public.logs USING btree (log_id);


--
-- TOC entry 2931 (class 1259 OID 25463)
-- Name: status_trash_trash_id_uindex; Type: INDEX; Schema: public; Owner: akdev
--

CREATE UNIQUE INDEX status_trash_trash_id_uindex ON public.detail_trash USING btree (trash_id);


--
-- TOC entry 2948 (class 2620 OID 25763)
-- Name: items add_used_space; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER add_used_space AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.add_used_space();


--
-- TOC entry 2946 (class 2620 OID 25742)
-- Name: items create_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER create_folder AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_create_folder();


--
-- TOC entry 2943 (class 2620 OID 25382)
-- Name: items delete_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER delete_file BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_delete_file();


--
-- TOC entry 2947 (class 2620 OID 25747)
-- Name: items delete_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER delete_folder BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_delete_folder();


--
-- TOC entry 2949 (class 2620 OID 25766)
-- Name: items min_used_space; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER min_used_space BEFORE DELETE ON public.items FOR EACH ROW EXECUTE FUNCTION public.min_used_space();


--
-- TOC entry 2950 (class 2620 OID 25386)
-- Name: items recovery_trash_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER recovery_trash_file BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_file();


--
-- TOC entry 2951 (class 2620 OID 25802)
-- Name: items recovery_trash_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER recovery_trash_folder BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_folder();


--
-- TOC entry 2942 (class 2620 OID 25380)
-- Name: items rename_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER rename_file BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_rename_file();


--
-- TOC entry 2945 (class 2620 OID 25545)
-- Name: items rename_folder; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER rename_folder BEFORE UPDATE ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_rename_folder();


--
-- TOC entry 2944 (class 2620 OID 25388)
-- Name: items upload_file; Type: TRIGGER; Schema: public; Owner: akdev
--

CREATE TRIGGER upload_file AFTER INSERT ON public.items FOR EACH ROW EXECUTE FUNCTION public.log_upload_file();


--
-- TOC entry 2941 (class 2606 OID 17240)
-- Name: logs fk_detail_activity; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_detail_activity FOREIGN KEY (activity_id) REFERENCES public.detail_activity(activity_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2937 (class 2606 OID 17245)
-- Name: items fk_owner; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_owner FOREIGN KEY (owner) REFERENCES public.users(username) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2935 (class 2606 OID 17198)
-- Name: users fk_role; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES public.detail_role(role_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2936 (class 2606 OID 17203)
-- Name: users fk_status; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_status FOREIGN KEY (status_id) REFERENCES public.detail_status(status_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2938 (class 2606 OID 25531)
-- Name: items fk_trash_status; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_trash_status FOREIGN KEY (trash_status) REFERENCES public.detail_trash(trash_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2939 (class 2606 OID 25569)
-- Name: items fk_type_id; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES public.detail_type(type_id) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


--
-- TOC entry 2940 (class 2606 OID 17235)
-- Name: logs fk_username; Type: FK CONSTRAINT; Schema: public; Owner: akdev
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT fk_username FOREIGN KEY (username) REFERENCES public.users(username) ON UPDATE CASCADE ON DELETE RESTRICT NOT VALID;


-- Completed on 2021-01-31 16:56:10 WIB

--
-- PostgreSQL database dump complete
--

