/*
DROP FUNCTION checkfriendstate(myid integer, theirid integer)
*/

CREATE OR REPLACE FUNCTION checkfriendstate(myid integer, theirid integer)
RETURNS integer
AS $$
DECLARE
	state integer;
	mystate integer;
	otherstate integer;

BEGIN
	SELECT (c.friend_state + 1) INTO mystate 
	FROM connections AS c
	WHERE c.user_id = myid AND c.connections_id = theirid AND friend_state > 0;

	IF ((mystate IS NULL) OR (mystate = 0)) THEN
		SELECT c.friend_state INTO mystate 
		FROM connections AS c
		WHERE c.user_id = theirid AND c.connections_id = myid AND friend_state > 0;
	END IF;

	IF (mystate IS NULL) THEN
		mystate := 0;
	END IF;

	
RETURN mystate;
END;
$$ LANGUAGE plpgsql;
