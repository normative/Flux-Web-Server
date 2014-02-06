﻿/*
DROP FUNCTION getfollowers(mytoken text, dir integer)
*/
/*
raw json call:
http://127.0.0.1:3101/aliases/getfollowers?auth_token=AoSZmitKx7Mq8dkXd9QD */

CREATE OR REPLACE FUNCTION getfollowers(mytoken text, dir integer)

RETURNS TABLE(id integer, username varchar, friend_state integer, am_follower integer, is_following integer)
AS $$
DECLARE
	my_id integer;
	uid integer;
	cid integer;

	r RECORD;


BEGIN
	SELECT u.id INTO my_id 
	FROM users AS u 
	WHERE authentication_token = mytoken;

	IF (dir = 0) THEN
		CREATE TEMP TABLE mytable
		ON COMMIT DROP
		AS (	SELECT	u.id AS id, 
				u.username AS username,
				0 AS friend_state,
				0 AS am_follower, 
				0 AS is_following
			FROM	users u
				INNER JOIN connections c ON ((c.user_id = my_id) AND (c.connections_id = u.id) AND (c.am_following <> 0))
		);
	ELSE
		CREATE TEMP TABLE mytable
		ON COMMIT DROP
		AS (
			SELECT	u.id AS id, 
				u.username AS username, 
				0 AS friend_state,
				0 AS am_follower, 
				0 AS is_following
			FROM	users u
				INNER JOIN connections c ON ((c.user_id = u.id) AND (c.connections_id = my_id) AND (c.am_following <> 0))
		);
	END IF;

	FOR r IN
		SELECT DISTINCT(m.id) FROM mytable m
	LOOP
		UPDATE	mytable SET am_follower = follow_state.i_follow, 
				   is_following = follow_state.they_follow,
				   friend_state = checkfriendstate(my_id, mytable.id)
		FROM	checkfollowerstate(my_id, r.id) AS follow_state
		WHERE	mytable.id = r.id;

	END LOOP;

RETURN QUERY	
	SELECT DISTINCT m.id, m.username, m.friend_state, m.am_follower, m.is_following 
	FROM mytable m
	ORDER BY m.username;
	
END;
$$ LANGUAGE plpgsql;
