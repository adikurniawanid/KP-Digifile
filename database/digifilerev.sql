PGDMP     6    7                y            digifile_rev     13.2 (Ubuntu 13.2-1.pgdg20.04+1)     13.2 (Ubuntu 13.2-1.pgdg20.04+1) p    &           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            '           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            (           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            )           1262    16478    digifile_rev    DATABASE     a   CREATE DATABASE digifile_rev WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';
    DROP DATABASE digifile_rev;
                akdev    false            *           0    0    DATABASE digifile_rev    ACL     0   GRANT ALL ON DATABASE digifile_rev TO postgres;
                   akdev    false    3113            �            1255    43405 ]   add_file(character varying, character varying, character varying, character varying, numeric)    FUNCTION     �  CREATE FUNCTION public.add_file(item_id_param character varying, parent_id_param character varying, user_id_param character varying, file_name_param character varying, size_param numeric) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO item
    (id, parent_id, user_id, item_name, size, type_id, trash_id)
    VALUES
    (item_id_param, parent_id_param, user_id_param, file_name_param, size_param, 1, 0);
END
$$;
 �   DROP FUNCTION public.add_file(item_id_param character varying, parent_id_param character varying, user_id_param character varying, file_name_param character varying, size_param numeric);
       public          postgres    false            �            1255    43406 V   add_folder(character varying, character varying, character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.add_folder(item_id_param character varying, parent_id_param character varying, user_id_param character varying, folder_name_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO item
    (id, parent_id, user_id, item_name, size, type_id, trash_id)
    VALUES
    (item_id_param, parent_id_param, user_id_param, folder_name_param, 0, 2, 0);
END
$$;
 �   DROP FUNCTION public.add_folder(item_id_param character varying, parent_id_param character varying, user_id_param character varying, folder_name_param character varying);
       public          postgres    false                        1255    43393 �   add_user(character varying, character varying, character varying, character varying, character varying, character varying, numeric)    FUNCTION     B  CREATE FUNCTION public.add_user(id_user_param character varying, username_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric) RETURNS void
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
 �   DROP FUNCTION public.add_user(id_user_param character varying, username_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric);
       public          postgres    false            �            1255    43528    delete_file_dependency()    FUNCTION     �   CREATE FUNCTION public.delete_file_dependency() RETURNS trigger
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
 /   DROP FUNCTION public.delete_file_dependency();
       public          postgres    false            �            1255    43363    delete_item(character varying)    FUNCTION     �   CREATE FUNCTION public.delete_item(item_id_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE item SET trash_id = 1
    WHERE id = item_id_param AND trash_id = 0;
END
$$;
 C   DROP FUNCTION public.delete_item(item_id_param character varying);
       public          postgres    false            �            1255    43364    delete_trash(character varying)    FUNCTION     9  CREATE FUNCTION public.delete_trash(item_id_param character varying) RETURNS void
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
 D   DROP FUNCTION public.delete_trash(item_id_param character varying);
       public          postgres    false            �            1255    43365 q   edit_user(character varying, character varying, character varying, character varying, character varying, numeric)    FUNCTION     s  CREATE FUNCTION public.edit_user(user_id_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric) RETURNS void
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
 �   DROP FUNCTION public.edit_user(user_id_param character varying, name_param character varying, password_param character varying, phone_param character varying, email_param character varying, space_param numeric);
       public          postgres    false                       1255    44322     get_file_list(character varying)    FUNCTION     Y  CREATE FUNCTION public.get_file_list(id_parent_param character varying) RETURNS TABLE(id_item character varying, item_name character varying)
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
 G   DROP FUNCTION public.get_file_list(id_parent_param character varying);
       public          postgres    false                       1255    44323 "   get_folder_list(character varying)    FUNCTION     [  CREATE FUNCTION public.get_folder_list(id_parent_param character varying) RETURNS TABLE(id_item character varying, item_name character varying)
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
 I   DROP FUNCTION public.get_folder_list(id_parent_param character varying);
       public          postgres    false            �            1255    43368 *   get_information_storage(character varying)    FUNCTION     �  CREATE FUNCTION public.get_information_storage(user_id_param character varying) RETURNS character varying
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
 O   DROP FUNCTION public.get_information_storage(user_id_param character varying);
       public          postgres    false                       1255    43532     get_item_name(character varying)    FUNCTION       CREATE FUNCTION public.get_item_name(item_id_param character varying) RETURNS character varying
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
 E   DROP FUNCTION public.get_item_name(item_id_param character varying);
       public          postgres    false            �            1255    43386    get_log_activity(integer)    FUNCTION     f  CREATE FUNCTION public.get_log_activity(page_param integer) RETURNS TABLE(id character varying, name character varying, activity_date text, last_activity character varying, kuota text, status character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
        SELECT * FROM view_log_activity
        LIMIT 10 OFFSET (page_param-1) * 10;
END
$$;
 ;   DROP FUNCTION public.get_log_activity(page_param integer);
       public          postgres    false            �            1255    43739    get_log_activity_count()    FUNCTION     �   CREATE FUNCTION public.get_log_activity_count() RETURNS integer
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
 /   DROP FUNCTION public.get_log_activity_count();
       public          postgres    false            �            1255    43369    get_name(character varying)    FUNCTION       CREATE FUNCTION public.get_name(user_id_param character varying) RETURNS character varying
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
 @   DROP FUNCTION public.get_name(user_id_param character varying);
       public          postgres    false                       1255    44244     get_parent_id(character varying)    FUNCTION     (  CREATE FUNCTION public.get_parent_id(item_id_param character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    DECLARE var_parent_id varchar;
BEGIN
        SELECT item.parent_id INTO var_parent_id FROM item
        WHERE id = item_id_param ;
    return var_parent_id;
END
$$;
 E   DROP FUNCTION public.get_parent_id(item_id_param character varying);
       public          postgres    false                       1255    44324 &   get_trash_file_list(character varying)    FUNCTION     Y  CREATE FUNCTION public.get_trash_file_list(user_id_param character varying) RETURNS TABLE(id_item character varying, item_name character varying)
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
 K   DROP FUNCTION public.get_trash_file_list(user_id_param character varying);
       public          postgres    false                       1255    44325 (   get_trash_folder_list(character varying)    FUNCTION     [  CREATE FUNCTION public.get_trash_folder_list(user_id_param character varying) RETURNS TABLE(id_item character varying, item_name character varying)
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
 M   DROP FUNCTION public.get_trash_folder_list(user_id_param character varying);
       public          postgres    false                       1255    44152 '   get_user_information(character varying)    FUNCTION     �  CREATE FUNCTION public.get_user_information(user_id_param character varying) RETURNS TABLE(username character varying, name character varying, phone character varying, email character varying, space numeric)
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
 L   DROP FUNCTION public.get_user_information(user_id_param character varying);
       public          postgres    false            �            1255    43392 1   get_user_log_activity(character varying, integer)    FUNCTION     k  CREATE FUNCTION public.get_user_log_activity(user_id_param character varying, page_param integer) RETURNS TABLE(activity_date text, activity text)
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
 a   DROP FUNCTION public.get_user_log_activity(user_id_param character varying, page_param integer);
       public          postgres    false            �            1255    43373 .   get_user_log_activity_count(character varying)    FUNCTION       CREATE FUNCTION public.get_user_log_activity_count(user_id_param character varying) RETURNS integer
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
 S   DROP FUNCTION public.get_user_log_activity_count(user_id_param character varying);
       public          postgres    false            �            1255    43353    is_admin(character varying)    FUNCTION       CREATE FUNCTION public.is_admin(user_id_param character varying) RETURNS boolean
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
 @   DROP FUNCTION public.is_admin(user_id_param character varying);
       public          postgres    false            �            1255    43375 +   is_enough_space(character varying, numeric)    FUNCTION     Y  CREATE FUNCTION public.is_enough_space(user_id_param character varying, size_param numeric) RETURNS boolean
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
 [   DROP FUNCTION public.is_enough_space(user_id_param character varying, size_param numeric);
       public          postgres    false            �            1255    43352    is_user(character varying)    FUNCTION     �   CREATE FUNCTION public.is_user(user_id character varying) RETURNS boolean
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
 9   DROP FUNCTION public.is_user(user_id character varying);
       public          postgres    false            �            1255    42933 $   is_username_exist(character varying)    FUNCTION       CREATE FUNCTION public.is_username_exist(username_param character varying) RETURNS boolean
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
 J   DROP FUNCTION public.is_username_exist(username_param character varying);
       public          postgres    false            �            1255    25741    log_create_folder()    FUNCTION     $  CREATE FUNCTION public.log_create_folder() RETURNS trigger
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
 *   DROP FUNCTION public.log_create_folder();
       public          akdev    false            �            1255    42457    log_delete_file()    FUNCTION     W  CREATE FUNCTION public.log_delete_file() RETURNS trigger
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
 (   DROP FUNCTION public.log_delete_file();
       public          postgres    false            �            1255    42459    log_delete_folder()    FUNCTION     Y  CREATE FUNCTION public.log_delete_folder() RETURNS trigger
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
 *   DROP FUNCTION public.log_delete_folder();
       public          postgres    false            �            1255    42982    log_delete_trash_file()    FUNCTION     7  CREATE FUNCTION public.log_delete_trash_file() RETURNS trigger
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
 .   DROP FUNCTION public.log_delete_trash_file();
       public          postgres    false            �            1255    42983    log_delete_trash_folder()    FUNCTION     ]  CREATE FUNCTION public.log_delete_trash_folder() RETURNS trigger
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
 0   DROP FUNCTION public.log_delete_trash_folder();
       public          postgres    false            �            1255    25385    log_recovery_trash_file()    FUNCTION     `  CREATE FUNCTION public.log_recovery_trash_file() RETURNS trigger
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
 0   DROP FUNCTION public.log_recovery_trash_file();
       public          akdev    false            �            1255    25801    log_recovery_trash_folder()    FUNCTION     a  CREATE FUNCTION public.log_recovery_trash_folder() RETURNS trigger
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
 2   DROP FUNCTION public.log_recovery_trash_folder();
       public          akdev    false            �            1255    25378    log_rename_file()    FUNCTION     O  CREATE FUNCTION public.log_rename_file() RETURNS trigger
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
 (   DROP FUNCTION public.log_rename_file();
       public          akdev    false            �            1255    25544    log_rename_folder()    FUNCTION     O  CREATE FUNCTION public.log_rename_folder() RETURNS trigger
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
 *   DROP FUNCTION public.log_rename_folder();
       public          akdev    false            �            1255    25387    log_upload_file()    FUNCTION     "  CREATE FUNCTION public.log_upload_file() RETURNS trigger
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
 (   DROP FUNCTION public.log_upload_file();
       public          akdev    false            �            1255    43376     recovery_item(character varying)    FUNCTION     �   CREATE FUNCTION public.recovery_item(item_id_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE item SET trash_id = 0
    WHERE id = item_id_param;
END
$$;
 E   DROP FUNCTION public.recovery_item(item_id_param character varying);
       public          postgres    false            �            1255    43377 1   rename_item(character varying, character varying)    FUNCTION     �   CREATE FUNCTION public.rename_item(item_id_param character varying, item_name_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE item SET item_name = item_name_param
    WHERE id = item_id_param;
END
$$;
 f   DROP FUNCTION public.rename_item(item_id_param character varying, item_name_param character varying);
       public          postgres    false            	           1255    44327 1   search_item(character varying, character varying)    FUNCTION     �  CREATE FUNCTION public.search_item(user_id_param character varying, keyword_param character varying) RETURNS TABLE(item_id character varying, name_item character varying)
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
 d   DROP FUNCTION public.search_item(user_id_param character varying, keyword_param character varying);
       public          postgres    false            
           1255    44333 3   search_user(character varying, integer, date, date)    FUNCTION     �  CREATE FUNCTION public.search_user(keyword_name_param character varying, keyword_activity_id integer, keyword_start_date date, keyword_end_date date) RETURNS TABLE(id character varying, name character varying, activity_date text, last_activity character varying, kuota text, status character varying)
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
 �   DROP FUNCTION public.search_user(keyword_name_param character varying, keyword_activity_id integer, keyword_start_date date, keyword_end_date date);
       public          postgres    false                       1255    44326    set_offline(character varying)    FUNCTION     �   CREATE FUNCTION public.set_offline(user_id_param character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE user_status
    SET status_id = 0
    WHERE user_id = user_id_param;
END
$$;
 C   DROP FUNCTION public.set_offline(user_id_param character varying);
       public          postgres    false            �            1255    43362    set_online(character varying)    FUNCTION     #  CREATE FUNCTION public.set_online(user_id_param character varying) RETURNS void
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
 B   DROP FUNCTION public.set_online(user_id_param character varying);
       public          postgres    false            �            1255    25764    used_space_dec()    FUNCTION     �  CREATE FUNCTION public.used_space_dec() RETURNS trigger
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
 '   DROP FUNCTION public.used_space_dec();
       public          akdev    false            �            1255    25762    used_space_inc()    FUNCTION       CREATE FUNCTION public.used_space_inc() RETURNS trigger
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
 '   DROP FUNCTION public.used_space_inc();
       public          akdev    false            �            1255    43325 2   verify_login(character varying, character varying)    FUNCTION     U  CREATE FUNCTION public.verify_login(username_param character varying, password_param character varying) RETURNS character varying
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
 g   DROP FUNCTION public.verify_login(username_param character varying, password_param character varying);
       public          postgres    false            �            1259    16887    detail_activity    TABLE     q   CREATE TABLE public.detail_activity (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);
 #   DROP TABLE public.detail_activity;
       public         heap    akdev    false            �            1259    17009    detail_role    TABLE     m   CREATE TABLE public.detail_role (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);
    DROP TABLE public.detail_role;
       public         heap    akdev    false            �            1259    17093    detail_status    TABLE     o   CREATE TABLE public.detail_status (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);
 !   DROP TABLE public.detail_status;
       public         heap    akdev    false            �            1259    25457    detail_trash    TABLE     n   CREATE TABLE public.detail_trash (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);
     DROP TABLE public.detail_trash;
       public         heap    akdev    false            �            1259    25546    detail_type    TABLE     m   CREATE TABLE public.detail_type (
    id integer NOT NULL,
    description character varying(21) NOT NULL
);
    DROP TABLE public.detail_type;
       public         heap    akdev    false            �            1259    43462    item    TABLE     %  CREATE TABLE public.item (
    id character varying(36) NOT NULL,
    parent_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    item_name character varying(250) NOT NULL,
    size numeric NOT NULL,
    type_id integer NOT NULL,
    trash_id integer NOT NULL
);
    DROP TABLE public.item;
       public         heap    postgres    false            �            1259    43281    log    TABLE       CREATE TABLE public.log (
    id integer NOT NULL,
    user_id character varying(36) NOT NULL,
    item_id character varying(36) NOT NULL,
    activity_id integer NOT NULL,
    item_name character varying(255) NOT NULL,
    activity_date timestamp without time zone NOT NULL
);
    DROP TABLE public.log;
       public         heap    postgres    false            �            1259    43410 
   log_id_seq    SEQUENCE     s   CREATE SEQUENCE public.log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.log_id_seq;
       public          postgres    false    208            +           0    0 
   log_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;
          public          postgres    false    211            �            1259    43253    user_detail    TABLE       CREATE TABLE public.user_detail (
    user_id character varying(36) NOT NULL,
    name character varying(30) NOT NULL,
    phone character varying(15) NOT NULL,
    email character varying(50) NOT NULL,
    created_date timestamp without time zone DEFAULT now() NOT NULL
);
    DROP TABLE public.user_detail;
       public         heap    postgres    false            �            1259    43259 
   user_space    TABLE     �   CREATE TABLE public.user_space (
    user_id character varying(36) NOT NULL,
    space numeric NOT NULL,
    used_space numeric NOT NULL
);
    DROP TABLE public.user_space;
       public         heap    postgres    false            �            1259    43267    user_status    TABLE     �   CREATE TABLE public.user_status (
    user_id character varying(36) NOT NULL,
    status_id integer DEFAULT 0 NOT NULL,
    last_login timestamp without time zone DEFAULT now() NOT NULL
);
    DROP TABLE public.user_status;
       public         heap    postgres    false            �            1259    43326    users    TABLE     �   CREATE TABLE public.users (
    id character varying(36) NOT NULL,
    username character varying(35) NOT NULL,
    password character varying(255) NOT NULL,
    role_id integer NOT NULL
);
    DROP TABLE public.users;
       public         heap    postgres    false            �            1259    43354    view_log_activity    VIEW     a  CREATE VIEW public.view_log_activity AS
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
 $   DROP VIEW public.view_log_activity;
       public          postgres    false    205    209    209    208    208    208    207    207    206    206    206    205    202    202    200    200            d           2604    43412    log id    DEFAULT     `   ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);
 5   ALTER TABLE public.log ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    211    208                      0    16887    detail_activity 
   TABLE DATA           :   COPY public.detail_activity (id, description) FROM stdin;
    public          akdev    false    200   ��                 0    17009    detail_role 
   TABLE DATA           6   COPY public.detail_role (id, description) FROM stdin;
    public          akdev    false    201   "�                 0    17093    detail_status 
   TABLE DATA           8   COPY public.detail_status (id, description) FROM stdin;
    public          akdev    false    202   N�                 0    25457    detail_trash 
   TABLE DATA           7   COPY public.detail_trash (id, description) FROM stdin;
    public          akdev    false    203   z�                 0    25546    detail_type 
   TABLE DATA           6   COPY public.detail_type (id, description) FROM stdin;
    public          akdev    false    204   ��       #          0    43462    item 
   TABLE DATA           Z   COPY public.item (id, parent_id, user_id, item_name, size, type_id, trash_id) FROM stdin;
    public          postgres    false    212   ��                  0    43281    log 
   TABLE DATA           Z   COPY public.log (id, user_id, item_id, activity_id, item_name, activity_date) FROM stdin;
    public          postgres    false    208   ��                 0    43253    user_detail 
   TABLE DATA           P   COPY public.user_detail (user_id, name, phone, email, created_date) FROM stdin;
    public          postgres    false    205   8�                 0    43259 
   user_space 
   TABLE DATA           @   COPY public.user_space (user_id, space, used_space) FROM stdin;
    public          postgres    false    206   ��                 0    43267    user_status 
   TABLE DATA           E   COPY public.user_status (user_id, status_id, last_login) FROM stdin;
    public          postgres    false    207   �       !          0    43326    users 
   TABLE DATA           @   COPY public.users (id, username, password, role_id) FROM stdin;
    public          postgres    false    209   g�       ,           0    0 
   log_id_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.log_id_seq', 78, true);
          public          postgres    false    211            f           2606    42765 $   detail_activity detail_activity_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.detail_activity
    ADD CONSTRAINT detail_activity_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.detail_activity DROP CONSTRAINT detail_activity_pkey;
       public            akdev    false    200            j           2606    42777    detail_status detail_status_pk 
   CONSTRAINT     \   ALTER TABLE ONLY public.detail_status
    ADD CONSTRAINT detail_status_pk PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.detail_status DROP CONSTRAINT detail_status_pk;
       public            akdev    false    202            p           2606    42793    detail_type detail_type_pk 
   CONSTRAINT     X   ALTER TABLE ONLY public.detail_type
    ADD CONSTRAINT detail_type_pk PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.detail_type DROP CONSTRAINT detail_type_pk;
       public            akdev    false    204            ~           2606    43469    item item_pk 
   CONSTRAINT     J   ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pk PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.item DROP CONSTRAINT item_pk;
       public            postgres    false    212            y           2606    43400 
   log log_pk 
   CONSTRAINT     H   ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pk PRIMARY KEY (id);
 4   ALTER TABLE ONLY public.log DROP CONSTRAINT log_pk;
       public            postgres    false    208            h           2606    42771    detail_role role_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.detail_role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
 ?   ALTER TABLE ONLY public.detail_role DROP CONSTRAINT role_pkey;
       public            akdev    false    201            m           2606    42785    detail_trash status_trash_pk 
   CONSTRAINT     Z   ALTER TABLE ONLY public.detail_trash
    ADD CONSTRAINT status_trash_pk PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.detail_trash DROP CONSTRAINT status_trash_pk;
       public            akdev    false    203            s           2606    43258    user_detail user_detail_pk 
   CONSTRAINT     ]   ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT user_detail_pk PRIMARY KEY (user_id);
 D   ALTER TABLE ONLY public.user_detail DROP CONSTRAINT user_detail_pk;
       public            postgres    false    205            u           2606    43266    user_space user_space_pk 
   CONSTRAINT     [   ALTER TABLE ONLY public.user_space
    ADD CONSTRAINT user_space_pk PRIMARY KEY (user_id);
 B   ALTER TABLE ONLY public.user_space DROP CONSTRAINT user_space_pk;
       public            postgres    false    206            w           2606    43273    user_status user_status_pk 
   CONSTRAINT     ]   ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT user_status_pk PRIMARY KEY (user_id);
 D   ALTER TABLE ONLY public.user_status DROP CONSTRAINT user_status_pk;
       public            postgres    false    207            {           2606    43331    users users_pk 
   CONSTRAINT     L   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pk;
       public            postgres    false    209            k           1259    42778    detail_status_status_id_uindex    INDEX     ]   CREATE UNIQUE INDEX detail_status_status_id_uindex ON public.detail_status USING btree (id);
 2   DROP INDEX public.detail_status_status_id_uindex;
       public            akdev    false    202            q           1259    42794    detail_type_type_id_uindex    INDEX     W   CREATE UNIQUE INDEX detail_type_type_id_uindex ON public.detail_type USING btree (id);
 .   DROP INDEX public.detail_type_type_id_uindex;
       public            akdev    false    204            n           1259    42786    status_trash_trash_id_uindex    INDEX     Z   CREATE UNIQUE INDEX status_trash_trash_id_uindex ON public.detail_trash USING btree (id);
 0   DROP INDEX public.status_trash_trash_id_uindex;
       public            akdev    false    203            |           1259    43329    users_username_uindex    INDEX     R   CREATE UNIQUE INDEX users_username_uindex ON public.users USING btree (username);
 )   DROP INDEX public.users_username_uindex;
       public            postgres    false    209            �           2620    43480    item log_create_folder    TRIGGER     w   CREATE TRIGGER log_create_folder AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_create_folder();
 /   DROP TRIGGER log_create_folder ON public.item;
       public          postgres    false    237    212            �           2620    43481    item log_delete_file    TRIGGER     t   CREATE TRIGGER log_delete_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_file();
 -   DROP TRIGGER log_delete_file ON public.item;
       public          postgres    false    249    212            �           2620    43529    item log_delete_file_dependency    TRIGGER     �   CREATE TRIGGER log_delete_file_dependency AFTER UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.delete_file_dependency();
 8   DROP TRIGGER log_delete_file_dependency ON public.item;
       public          postgres    false    254    212            �           2620    43482    item log_delete_folder    TRIGGER     x   CREATE TRIGGER log_delete_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_folder();
 /   DROP TRIGGER log_delete_folder ON public.item;
       public          postgres    false    248    212            �           2620    43511    item log_delete_trash_file    TRIGGER     �   CREATE TRIGGER log_delete_trash_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_trash_file();
 3   DROP TRIGGER log_delete_trash_file ON public.item;
       public          postgres    false    239    212            �           2620    43512    item log_delete_trash_folder    TRIGGER     �   CREATE TRIGGER log_delete_trash_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_delete_trash_folder();
 5   DROP TRIGGER log_delete_trash_folder ON public.item;
       public          postgres    false    212    240            �           2620    43483    item log_recovery_trash_file    TRIGGER     �   CREATE TRIGGER log_recovery_trash_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_file();
 5   DROP TRIGGER log_recovery_trash_file ON public.item;
       public          postgres    false    224    212            �           2620    43484    item log_recovery_trash_folder    TRIGGER     �   CREATE TRIGGER log_recovery_trash_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_recovery_trash_folder();
 7   DROP TRIGGER log_recovery_trash_folder ON public.item;
       public          postgres    false    235    212            �           2620    43485    item log_rename_file    TRIGGER     t   CREATE TRIGGER log_rename_file BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_rename_file();
 -   DROP TRIGGER log_rename_file ON public.item;
       public          postgres    false    225    212            �           2620    43486    item log_rename_folder    TRIGGER     x   CREATE TRIGGER log_rename_folder BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_rename_folder();
 /   DROP TRIGGER log_rename_folder ON public.item;
       public          postgres    false    212    228            �           2620    43487    item log_upload_file    TRIGGER     s   CREATE TRIGGER log_upload_file AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.log_upload_file();
 -   DROP TRIGGER log_upload_file ON public.item;
       public          postgres    false    226    212            �           2620    43531    item trigger_used_space_dec    TRIGGER     z   CREATE TRIGGER trigger_used_space_dec BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.used_space_dec();
 4   DROP TRIGGER trigger_used_space_dec ON public.item;
       public          postgres    false    234    212            �           2620    43489    item trigger_used_space_inc    TRIGGER     y   CREATE TRIGGER trigger_used_space_inc AFTER INSERT ON public.item FOR EACH ROW EXECUTE FUNCTION public.used_space_inc();
 4   DROP TRIGGER trigger_used_space_inc ON public.item;
       public          postgres    false    212    236            �           2606    43314    log fk_activity_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.log
    ADD CONSTRAINT fk_activity_id FOREIGN KEY (activity_id) REFERENCES public.detail_activity(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 <   ALTER TABLE ONLY public.log DROP CONSTRAINT fk_activity_id;
       public          postgres    false    2918    208    200            �           2606    43523    log fk_item_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.log
    ADD CONSTRAINT fk_item_id FOREIGN KEY (item_id) REFERENCES public.item(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 8   ALTER TABLE ONLY public.log DROP CONSTRAINT fk_item_id;
       public          postgres    false    2942    208    212            �           2606    43347    users fk_role_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_role_id FOREIGN KEY (role_id) REFERENCES public.detail_role(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT fk_role_id;
       public          postgres    false    209    2920    201            �           2606    43304    user_status fk_status_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT fk_status_id FOREIGN KEY (status_id) REFERENCES public.detail_status(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 B   ALTER TABLE ONLY public.user_status DROP CONSTRAINT fk_status_id;
       public          postgres    false    2922    202    207            �           2606    43505    item fk_trash_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.item
    ADD CONSTRAINT fk_trash_id FOREIGN KEY (trash_id) REFERENCES public.detail_trash(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 :   ALTER TABLE ONLY public.item DROP CONSTRAINT fk_trash_id;
       public          postgres    false    212    2925    203            �           2606    43500    item fk_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.item
    ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES public.detail_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 9   ALTER TABLE ONLY public.item DROP CONSTRAINT fk_type_id;
       public          postgres    false    204    2928    212                       2606    43332    user_detail fk_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_detail
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 @   ALTER TABLE ONLY public.user_detail DROP CONSTRAINT fk_user_id;
       public          postgres    false    2939    209    205            �           2606    43337    user_space fk_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_space
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 ?   ALTER TABLE ONLY public.user_space DROP CONSTRAINT fk_user_id;
       public          postgres    false    2939    209    206            �           2606    43342    user_status fk_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;
 @   ALTER TABLE ONLY public.user_status DROP CONSTRAINT fk_user_id;
       public          postgres    false    209    2939    207               j   x���J�K�MUp��I�2�tI�I-��`ܐ�����ghAN~b
�g
Ԟ�_�ZT������Z�e7�7�[ ���C����E����H&�a����=... 6;            x�3�LL����2�,-N-����� : �            x�3����K�.�L�2�t�1z\\\ XUY         .   x�3�,)J,��2���σ0�8R�r�R�J�SRsRKR�b���� 5&�            x�3�L��II-�2�L��I����� A�N      #   �   x���=jA��z�{��V��!�tN�&�~f!amò���@�V�����l�5J�	���Pe�#6�����7f��F��
��4I�Z������������m}M9Q�CiƬ6����6i112j�'N�aҗ�,��˺�.t���s	o�n�f�����3�X8�9b<0���%�]�M����pw�\0:��7F"&���w��[��p=���y�e=����}���0_9/��          J  x���=��@�X:�\����.�Ƙ�v�M����F00��o��;�����Jy��֮Z!�ʠ�#x[��� �e�)�Ջ�q4���l
�(��i���oc+����c��|����(�xüP^D�J�ds�sr�U���{��P�x�ʕ3�蔦��m���c롗��EfZ(�*��ᅲɼ(Dw���Bُd[�����g�s��W�nB��
��ko���m������P0AG�M/t��Ma��Ҟ7�s�쭵��ePj���C�Jՙ�U����������+mbP����BZ���⿶�B:�q���g;�HN�rH�B�$��g���/}�1�         |   x�5�;! �NAo 3�[im�l��DX����{ų.��͉4��:�[�\h	Wk������[��]]~�c��#O�i��Q{�&�����}��M�CjX4��!m@Ʈ����H)�^N%<         <   x�35KJJ11I�5MN2�51�0յLN��5I12�L547MLM�424�NCS�+F��� ��
         G   x����0��Tad� �ŏ$��܍�j��,�����}�r�(�1��G��5���rJ�      !   `   x�̱C!�Zw1烢�K�@�>�'w�+��0��b�a�l��iIG<o�O�!��ڹMH��I9�Wr�!�V���˓7B�9����{�L��     