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

RETURNS TABLE(flux_id integer, flux_username varchar, alias_name varchar, friend_stat integer, follower_stat integer)
AS $$
DECLARE
	myid integer;
	searchstr text;

BEGIN
	SELECT u.id INTO myid 
	FROM users AS u 
	WHERE authentication_token = mytoken;

	searchstr := contact || '%';

RETURN QUERY
	SELECT	u.id AS flux_id, u.username AS flux_username, u.name AS alias_name, 
		check_friend_state(myid, u.id) AS friend_stat, 
		check_follower_state(myid, u.id) AS follower_stat
	FROM	users u
	WHERE	(u.username LIKE searchstr)
	ORDER BY LENGTH(u.username) ASC, u.username
	LIMIT 20;

END;
$$ LANGUAGE plpgsql;
