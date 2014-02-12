-- FUNCTION to clean up (delete) connections when am_following = 0 AND friend_state = 0

CREATE OR REPLACE FUNCTION cleanconnections_trig()
RETURNS trigger
AS $$
DECLARE 

BEGIN
	IF (NEW.am_following = 0) AND (NEW.friend_state = 0) THEN
		DELETE FROM connections c WHERE c.id = NEW.id;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- DROP TRIGGER cleanconnections_trig ON connections;

CREATE TRIGGER cleanconnections_trig AFTER UPDATE OF am_following, friend_state
	ON connections
	FOR EACH ROW EXECUTE PROCEDURE cleanconnections_trig();
