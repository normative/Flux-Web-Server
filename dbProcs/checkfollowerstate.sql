/*
DROP FUNCTION checkfollowerstate(myid integer, otherid integer)
*/

CREATE OR REPLACE FUNCTION checkfollowerstate(myid integer, otherid integer)
RETURNS integer
AS $$
DECLARE
	state integer;
	mystate integer;
	otherstate integer;

BEGIN
	SELECT c.state INTO mystate 
	FROM connections AS c
	WHERE c.user_id = myid AND c.connections_id = otherid AND c.connection_type = 1;

	IF ((mystate IS NULL) OR (mystate = 0)) THEN
		state := 0;
	ELSE
		state := mystate;
	END IF;

	SELECT c.state INTO otherstate 
	FROM connections AS c
	WHERE c.user_id = otherid AND c.connections_id = myid AND c.connection_type = 1;

	IF ((otherstate IS NOT NULL) AND (otherstate <> 0)) THEN
		state := state + (16 * otherstate);
	END IF;

	
RETURN state;
END;
$$ LANGUAGE plpgsql;
