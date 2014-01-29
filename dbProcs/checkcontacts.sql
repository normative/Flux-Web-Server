/*
DROP FUNCTION checkcontacts(mytoken text, contactlist text, serviceid integer, maxcount integer)
*/
/*
raw json call:
http://127.0.0.1:3101/aliases/checkcontacts?auth_token=AoSZmitKx7Mq8dkXd9QD&serviceid=2&maxcount=100&contactlist=bob@twitter.com joedog2@twitter.com c*/

CREATE OR REPLACE FUNCTION checkcontacts(mytoken text, contactlist text, serviceid integer, maxcount integer)

RETURNS TABLE(flux_id integer, flux_username varchar, alias_name text, friend_stat integer, follower_stat integer)
AS $$
DECLARE
	contactset text[];
	contactarraylen integer;

	flux_ids bigint[];

	myid integer;

BEGIN
	SELECT u.id INTO myid 
	FROM users AS u 
	WHERE authentication_token = mytoken;

	contactset = string_to_array(trim(both ' ' from contactlist), ' ');
	contactarraylen = array_length(contactset, 1);

-- 	SELECT DISTINCT (u.id, a.alias_name)
-- 	FROM	users u,
-- 		INNER JOIN aliases a ON ((u.id = a.user_id) AND (a.service_id = serviceid))
-- 	WHERE	((a.alias_name = ANY(contactset));


RETURN QUERY
	SELECT	u.id AS flux_id, u.username AS flux_username, a.alias_name AS alias_name, 
		checkfriendstate(myid, u.id) AS friend_stat, 
		checkfollowerstate(myid, u.id) AS follower_stat
	FROM	users u
		INNER JOIN aliases a ON ((u.id = a.user_id) AND (a.service_id = serviceid))
	WHERE	(a.alias_name = ANY(contactset));

END;
$$ LANGUAGE plpgsql;
