
DROP FUNCTION getfollowers(mytoken text, dir integer);

/*
raw json call:
http://127.0.0.1:3101/aliases/getfollowers?auth_token=AoSZmitKx7Mq8dkXd9QD 
*/

CREATE OR REPLACE FUNCTION getfollowers(mytoken text, dir integer)

RETURNS TABLE(id integer, username varchar, has_pic boolean, am_follower integer, is_following integer)
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
		-- people I follow
		CREATE TEMP TABLE mytable
		ON COMMIT DROP
		AS (	
			SELECT	u.id AS id, 
				u.username AS username,
				((u.avatar_file_size IS NOT NULL) AND (u.avatar_file_size > 0)) AS has_pic,
				0 AS am_follower, 
				0 AS is_following,
				c.following_state as following_state
			FROM	users u
				INNER JOIN connections c ON ((c.user_id = my_id) AND (c.connections_id = u.id) AND (c.following_state = 2))
		);
	ELSE
		-- people that (want to) follow me
		CREATE TEMP TABLE mytable
		ON COMMIT DROP
		AS (
			SELECT	u.id AS id, 
				u.username AS username, 
				((u.avatar_file_size IS NOT NULL) AND (u.avatar_file_size > 0)) AS has_pic,
				0 AS am_follower, 
				0 AS is_following,
				c.following_state as following_state
			FROM	users u
				INNER JOIN connections c ON ((c.user_id = u.id) AND (c.connections_id = my_id) AND (c.following_state > 0))
		);
	END IF;

	FOR r IN
		SELECT DISTINCT(m.id) FROM mytable m
	LOOP
		UPDATE	mytable SET am_follower = follow_state.i_follow, 
				   is_following = follow_state.they_follow
		FROM	checkfollowerstate(my_id, r.id) AS follow_state
		WHERE	mytable.id = r.id;

	END LOOP;

RETURN QUERY	
	SELECT m.id, m.username, m.has_pic, m.am_follower, m.is_following 
	FROM mytable m
	ORDER BY m.following_state ASC, m.username;
	
END;
$$ LANGUAGE plpgsql;
