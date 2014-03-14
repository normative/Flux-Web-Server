
DROP FUNCTION checkcontacts(mytoken text, contactlist text, serviceid integer, maxcount integer);

/*
raw json call:
http://127.0.0.1:3101/aliases/checkcontacts?auth_token=AoSZmitKx7Mq8dkXd9QD&serviceid=2&maxcount=100 
*/

CREATE OR REPLACE FUNCTION checkcontacts(mytoken text, contactlist text, serviceid integer, maxcount integer)

RETURNS TABLE(user_id integer, username varchar, alias_name text, am_follower integer, is_following integer)
AS $$
DECLARE
	contactset text[];
	contactarraylen integer;

	flux_ids bigint[];

	my_id integer;

	r RECORD;


BEGIN
	SELECT u.id INTO my_id 
	FROM users AS u 
	WHERE authentication_token = mytoken;

	contactset := string_to_array(trim(both ' ' from contactlist), ',');
	contactarraylen := array_length(contactset, 1);

	CREATE TEMP TABLE mytable
	ON COMMIT DROP
	AS (
		SELECT	u.id AS user_id, 
			u.username AS username, 
			a.alias_name AS alias_name, 
			0 AS am_follower, 
			0 AS is_following
		FROM	users u
			INNER JOIN aliases a ON ((u.id = a.user_id) AND (a.service_id = serviceid))
		WHERE	(a.alias_name = ANY(contactset))
	);

	FOR r IN
		SELECT DISTINCT(m.user_id) FROM mytable m
	LOOP
		UPDATE mytable SET am_follower = fs.i_follow, is_following = fs.they_follow
		FROM checkfollowerstate(my_id, r.user_id) AS fs
		WHERE mytable.user_id = r.user_id;
	END LOOP;
	
RETURN QUERY	
	SELECT * FROM mytable m
	ORDER BY m.alias_name;


END;
$$ LANGUAGE plpgsql;
