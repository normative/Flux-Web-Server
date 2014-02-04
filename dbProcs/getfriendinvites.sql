
/*
DROP FUNCTION getfriendinvites(mytoken text)
*/
/*
raw json call:
http://127.0.0.1:3101/aliases/getfriendinvites?auth_token=AoSZmitKx7Mq8dkXd9QD */

CREATE OR REPLACE FUNCTION getfriendinvites(mytoken text)

RETURNS TABLE(id integer, flux_id integer, flux_username varchar, since timestamp)
AS $$
DECLARE
	my_id integer;

	r RECORD;
BEGIN
	SELECT u.id INTO my_id 
	FROM users AS u 
	WHERE authentication_token = mytoken;
	
RETURN QUERY
	SELECT	c.id AS id,
		u.id AS flux_id, 
		u.username AS flux_username,
		c.updated_at AS since
	FROM	users u
		INNER JOIN connections c ON ((c.user_id = u.id) AND (c.connections_id = my_id) AND (c.friend_state = 1));
END;
$$ LANGUAGE plpgsql;
