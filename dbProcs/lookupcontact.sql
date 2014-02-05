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

RETURNS TABLE(flux_id integer, flux_username varchar, alias_name varchar, friend_state integer, am_follower integer, is_following integer)
AS $$
DECLARE
	my_id integer;
	searchstr text;
	r RECORD;

BEGIN
	SELECT u.id INTO my_id 
	FROM users AS u 
	WHERE authentication_token = mytoken;

	searchstr := contact || '%';

	CREATE TEMP TABLE mytable
	ON COMMIT DROP
	AS (
		SELECT	u.id AS flux_id, 
			u.username AS flux_username, 
			u.name AS alias_name, 
			0 AS friend_state, 
			0 AS am_follower, 
			0 AS is_following
		FROM	users u
		WHERE	(u.username LIKE searchstr)
		
		LIMIT 20
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
	SELECT m.* FROM mytable m
	ORDER BY LENGTH(m.flux_username) ASC, m.flux_username;

END;
$$ LANGUAGE plpgsql;
