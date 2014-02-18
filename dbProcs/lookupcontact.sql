/*
DROP FUNCTION lookupcontact(mytoken text, contact text)
*/
/*
raw json call:
GET  http://127.0.0.1:3101/users/lookupname?auth_token=Edfexs1ymWmHpTea5dhE&contact=joed
Headers: Content-Type: application/json
	 Accept: application/json
*/

CREATE OR REPLACE FUNCTION lookupcontact(mytoken text, contact text)

--RETURNS TABLE(id integer, username varchar, alias_name varchar, friend_state integer, am_follower integer, is_following integer)
RETURNS TABLE(id integer, username varchar, friend_state integer, am_follower integer, is_following integer)
AS $$
DECLARE
	my_id integer;
	searchstr text;
	r RECORD;

BEGIN
	SELECT u.id INTO my_id 
	FROM users AS u 
	WHERE authentication_token = mytoken;

	searchstr := contact || '.*';

	CREATE TEMP TABLE mytable
	ON COMMIT DROP
	AS (
		SELECT	u.id AS id, 
			u.username AS username, 
--			u.name AS alias_name, 
			0 AS friend_state, 
			0 AS am_follower, 
			0 AS is_following
		FROM	users u
		WHERE	(u.username ~* searchstr)	-- case insensitive regex
		  AND	u.id != my_id
		
		LIMIT 20
	);

	FOR r IN
		SELECT DISTINCT(m.id) FROM mytable m
	LOOP
		UPDATE mytable SET am_follower = follow_state.i_follow, 
				   is_following = follow_state.they_follow,
				   friend_state = checkfriendstate(my_id, mytable.id)
		FROM checkfollowerstate(my_id, r.id) AS follow_state
		WHERE mytable.id = r.id;
	END LOOP;

RETURN QUERY
	SELECT m.* FROM mytable m
	ORDER BY 	m.friend_state, am_follower, is_following, 
			LENGTH(m.username) ASC, m.username;

END;
$$ LANGUAGE plpgsql;
