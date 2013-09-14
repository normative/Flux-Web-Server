
-- return the set of tags found in local imagery and return ranked in order of highest count

/*
CREATE OR REPLACE FUNCTION purgeunreferencedtags()
*/

CREATE OR REPLACE FUNCTION purgeunreferencedtags()
RETURNS void
AS
$$
BEGIN
	DELETE FROM tags t
	WHERE t.id NOT IN 
		(SELECT DISTINCT(imt.tag_id) 
			FROM images_tags imt
		);
END;
$$ LANGUAGE plpgsql;
