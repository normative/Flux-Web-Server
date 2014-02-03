﻿/*
DROP FUNCTION getfriends(mytoken text)
*/
/*
raw json call:
http://127.0.0.1:3101/aliases/getfriends?auth_token=AoSZmitKx7Mq8dkXd9QD */

CREATE OR REPLACE FUNCTION getfriends(mytoken text)

RETURNS TABLE(id integer, flux_id integer, flux_username varchar, friend_state integer, am_follower integer, is_following integer)
AS $$
DECLARE
	my_id integer;

	r RECORD;


BEGIN
	SELECT u.id INTO my_id 
	FROM users AS u 
	WHERE authentication_token = mytoken;
	
	CREATE TEMP TABLE mytable
	ON COMMIT DROP
	AS (
		SELECT	c.id AS id,
			u.id AS flux_id, 
 			u.username AS flux_username,
			0 AS friend_state,
			0 AS am_follower, 
			0 AS is_following
		FROM	users u
			INNER JOIN connections c ON ((c.user_id = my_id) AND (c.connections_id = u.id) AND (c.friend_state <> 0))
	);

	FOR r IN
		SELECT DISTINCT(m.flux_id) FROM mytable m
	LOOP
		UPDATE mytable SET am_follower = follow_state.i_follow, 
				   is_following = follow_state.they_follow,
				   friend_state = checkfriendstate(my_id, mytable.flux_id)
		FROM checkfollowerstate(my_id, r.flux_id) AS follow_state
		WHERE mytable.flux_id = r.flux_id;
	END LOOP;

RETURN QUERY	
	SELECT * FROM mytable;
	

END;
$$ LANGUAGE plpgsql;
