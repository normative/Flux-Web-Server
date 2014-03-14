/*
DROP FUNCTION checkfollowerstate(myid integer, theirid integer)
*/

/*
DROP TYPE follow_state;
CREATE TYPE follow_state AS (myid int, i_follow int, they_follow int);
*/


CREATE OR REPLACE FUNCTION checkfollowerstate(myid integer, theirid integer)
RETURNS follow_state
AS $$
DECLARE
	mystate integer;
	theirstate integer;
	state follow_state;

BEGIN
	SELECT c.following_state INTO state.i_follow 
	FROM connections AS c
	WHERE c.user_id = myid AND c.connections_id = theirid AND c.following_state = 2;

	SELECT c.following_state INTO state.they_follow
	FROM connections AS c
	WHERE c.user_id = theirid AND c.connections_id = myid AND c.following_state = 2;

	IF state.i_follow IS NULL THEN
		state.i_follow := 0;
	END IF;

	IF state.they_follow IS NULL THEN
		state.they_follow := 0;
	END IF;

	state.myid := myid;

RETURN  state;
END;
$$ LANGUAGE plpgsql;
