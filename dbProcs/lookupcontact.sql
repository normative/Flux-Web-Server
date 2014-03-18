
DROP FUNCTION lookupcontact(mytoken text, contact text);

/*
raw json call:
GET  http://127.0.0.1:3101/users/lookupname?auth_token=Edfexs1ymWmHpTea5dhE&contact=joed
Headers: Content-Type: application/json
	 Accept: application/json
*/

CREATE OR REPLACE FUNCTION lookupcontact(mytoken text, contact text)

RETURNS TABLE(id integer, username varchar, am_follower integer, is_following integer)
AS $$
DECLARE
	my_id integer;
	searchstr text;
	r RECORD;

BEGIN
	SELECT u.id INTO my_id 
	FROM users AS u 
	WHERE authentication_token = mytoken;

	searchstr := '^' || contact || '.*';

	CREATE TEMP TABLE mytable
	ON COMMIT DROP
	AS (
		SELECT	u.id AS id, 
			u.username AS username, 
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
				   is_following = follow_state.they_follow
		FROM checkfollowerstate(my_id, r.id) AS follow_state
		WHERE mytable.id = r.id;
	END LOOP;

RETURN QUERY
	SELECT m.* FROM mytable m
	WHERE	m.am_follower < 2
	ORDER BY 	m.username ASC;

END;
$$ LANGUAGE plpgsql;
