/*
DROP FUNCTION getfriends(mytoken text)
*/
/*
raw json call:
http://127.0.0.1:3101/aliases/getfriends?auth_token=AoSZmitKx7Mq8dkXd9QD */

CREATE OR REPLACE FUNCTION getfriends(mytoken text)

RETURNS TABLE(id integer, username varchar, has_pic boolean, friend_state integer, am_follower integer, is_following integer)
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
	AS 
	(	(
		SELECT	u.id AS id, 
 			u.username AS username,
			((u.avatar_file_size IS NOT NULL) AND (u.avatar_file_size > 0)) AS has_pic,
			(c.friend_state + 1) AS friend_state,
			0 AS am_follower, 
			0 AS is_following
		FROM	users u
			INNER JOIN connections c ON ((c.user_id = my_id) AND (c.connections_id = u.id) AND (c.friend_state > 0))
		)
	UNION
		(
		SELECT	u.id AS id, 
 			u.username AS username,
			((u.avatar_file_size IS NOT NULL) AND (u.avatar_file_size > 0)) AS has_pic,
			c.friend_state AS friend_state,
			0 AS am_follower, 
			0 AS is_following
		FROM	users u
			INNER JOIN connections c ON ((c.user_id = u.id) AND (c.connections_id = my_id) AND (c.friend_state = 1))
		)
	);

	FOR r IN
		SELECT DISTINCT(m.id) FROM mytable m
	LOOP
		UPDATE mytable SET am_follower = follow_state.i_follow, 
				   is_following = follow_state.they_follow
		FROM checkfollowerstate(my_id, r.id) AS follow_state
		WHERE mytable.id = r.id;
	END LOOP;

RETURN QUERY	
	SELECT * FROM mytable m
	ORDER BY m.friend_state, m.username;
	

END;
$$ LANGUAGE plpgsql;
