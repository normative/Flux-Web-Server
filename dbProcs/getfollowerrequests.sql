
/*
DROP FUNCTION getfollowerrequests(mytoken text)
*/
/*
raw json call:
http://127.0.0.1:3101/aliases/getfollowerrequests?auth_token=AoSZmitKx7Mq8dkXd9QD */

CREATE OR REPLACE FUNCTION getfollowerrequests(mytoken text)

RETURNS TABLE(id integer, username varchar)
AS $$
DECLARE
	my_id integer;

	r RECORD;
BEGIN
	SELECT u.id INTO my_id
	FROM users AS u
	WHERE authentication_token = mytoken;

RETURN QUERY
	SELECT	u.id AS id,
		u.username AS username
	FROM	users u
		INNER JOIN connections c ON ((c.user_id = u.id) AND (c.connections_id = my_id) AND (c.following_state = 1));
END;
$$ LANGUAGE plpgsql;
