﻿-- return the set of tags found in local imagery and return ranked in order of highest count

/*
DROP FUNCTION tagsbylocalrank(lat double precision, lon double precision, radius double precision, maxcount integer);
*/

CREATE OR REPLACE FUNCTION tagsbylocalrank(lat double precision, lon double precision, radius double precision, maxcount integer)
RETURNS TABLE (tagtext varchar, rank bigint)
AS
$$
DECLARE
	tagset text[];
	tagarraylen integer;
	skiploc boolean;

BEGIN
	skiploc = ((radius <= 0) OR (radius IS NULL));

	IF (maxcount IS NULL) THEN
		maxcount = 20;
	END IF;

RETURN QUERY	
	SELECT	t.tagtext, count(imt.image_id) AS rank
	FROM	
		(SELECT * FROM buildboundingbox(lat, lon, radius) FETCH FIRST 1 ROWS ONLY) AS bb,
		images i
		JOIN images_tags imt ON i.id = imt.image_id
		JOIN tags t ON (imt.tag_id = t.id)
	WHERE	( 
		-- location
			((skiploc) OR
			 ((i.best_latitude > bb.minlat) AND (i.best_latitude < bb.maxlat) AND
			 (i.best_longitude > bb.minlon) AND (i.best_longitude < bb.maxlon))
			)
		-- altitude
--		AND	(((minalt IS NULL) OR (i.best_altitude >= minalt))
--		    AND	 ((maxalt IS NULL) OR (i.best_altitude <= maxalt))
--			)
		 )

	GROUP BY t.tagtext
	ORDER BY rank DESC, MAX(i.time_stamp), t.tagtext
	LIMIT maxcount;

END;
$$ LANGUAGE plpgsql;
