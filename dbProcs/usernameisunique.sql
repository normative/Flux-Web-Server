/*
DROP FUNCTION usernameisunique(uname text)
*/

/*
CREATE TYPE unique_suggestion AS (isunique boolean, suggested_name varchar);
*/

CREATE OR REPLACE FUNCTION usernameisunique(uname text)
RETURNS SETOF unique_suggestion
AS $$
DECLARE
	suggested varchar;
	c integer;
	suffix integer;
	isunique boolean;

BEGIN

	suggested := uname;

	SELECT COUNT(id) INTO c
	FROM users
	WHERE username = suggested;

	suffix := 0;
	isunique := (c = 0);

	WHILE c > 0 LOOP
		suffix := suffix + 1;
		
		suggested = uname || btrim(('' || suffix));
		
		SELECT COUNT(id) INTO c
		FROM users
		WHERE username = suggested;
		
	END LOOP;

RETURN QUERY
	SELECT isunique AS "isunique", suggested AS "suggested_name";
	
END;
$$ LANGUAGE plpgsql;
