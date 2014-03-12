/*
DROP FUNCTION checkcontacts(mytoken text, contactlist text, serviceid integer, maxcount integer)
*/
/*
raw json call:
http://127.0.0.1:3101/aliases/checkcontacts?auth_token=AoSZmitKx7Mq8dkXd9QD&serviceid=2&maxcount=100&contactlist=bob@twitter.com joedog2@twitter.com c*/

CREATE OR REPLACE FUNCTION checkcontacts(mytoken text, contactlist text, serviceid integer, maxcount integer)

RETURNS TABLE(user_id integer, username varchar, alias_name text, friend_state integer, am_follower integer, is_following integer)
AS $$
DECLARE
	contactset text[];
	contactarraylen integer;

	flux_ids bigint[];

	myid integer;

	r RECORD;


BEGIN
	SELECT u.id INTO myid 
	FROM users AS u 
	WHERE authentication_token = mytoken;

	contactset = string_to_array(trim(both ' ' from contactlist), ' ');
	contactarraylen = array_length(contactset, 1);


--RETURN QUERY
	
	CREATE TEMP TABLE mytable
	ON COMMIT DROP
	AS (
		SELECT	u.id AS id, 
			u.username AS username, 
			a.alias_name AS alias_name, 
			checkfriendstate(myid, u.id) AS friend_state,
			0 AS am_follower, 
			0 AS is_following
		FROM	users u
			INNER JOIN aliases a ON ((u.id = a.user_id) AND (a.service_id = serviceid))
--			INNER JOIN (SELECT * FROM checkfollowerstate(myid, u.id)) fs ON myid = fs.myid
			--checkfollowerstate(myid, u.id) as fs
		WHERE	(a.alias_name = ANY(contactset))
	);

	FOR r IN
		SELECT DISTINCT(m.id) FROM mytable m
	LOOP
		UPDATE mytable SET am_follower = fs.i_follow, is_following = fs.they_follow
		FROM checkfollowerstate(myid, r.id) AS fs
		WHERE mytable.id = r.id;
	END LOOP;
	
RETURN QUERY	
	SELECT * FROM mytable m
	ORDER BY m.username;


END;
$$ LANGUAGE plpgsql;
