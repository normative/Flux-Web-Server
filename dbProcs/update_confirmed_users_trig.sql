
-- DROP TRIGGER update_confirmed_users_trigger ON users;
-- DROP FUNCTION update_confirmed_users_trig_fcn()

CREATE OR REPLACE FUNCTION update_confirmed_users_trig_fcn()
RETURNS trigger
AS $$
DECLARE 
	c integer;
BEGIN
	-- first, look for an existing matching email
	SELECT COUNT(a.user_id)
	INTO c
	FROM	aliases a
	WHERE	((a.alias_name = NEW.email) AND (a.service_id = 1));

	IF (c = 0) AND (NEW.confirmed_at IS NOT NULL) THEN
		-- not in the list yet - add it in...
		INSERT INTO aliases (user_id, alias_name, service_id, created_at, updated_at)
		VALUES (NEW.id, NEW.email, 1, NEW.confirmed_at, NEW.confirmed_at);
	END IF;
	RETURN NULL;


END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_confirmed_users_trigger AFTER UPDATE OF confirmed_at ON users
	FOR EACH ROW EXECUTE PROCEDURE update_confirmed_users_trig_fcn();
	