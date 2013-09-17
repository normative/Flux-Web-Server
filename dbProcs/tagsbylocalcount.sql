-- return the set of tags found in local imagery and return ranked in order of highest count

/*
DROP FUNCTION tagsbylocalcount(lat double precision, lon double precision, radius double precision, maxcount integer);
*/

CREATE OR REPLACE FUNCTION tagsbylocalcount(lat double precision, lon double precision, radius double precision, maxrows integer)
RETURNS TABLE (tagtext varchar, count bigint)
AS
$$
DECLARE
	tagset text[];
	tagarraylen integer;
	skiploc boolean;

BEGIN
	skiploc = ((radius <= 0) OR (radius IS NULL));

RETURN QUERY	
	SELECT	t.tagtext, count(imt.image_id) AS "count"
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
	ORDER BY "count" DESC, MAX(i.time_stamp), t.tagtext
	LIMIT maxrows;

END;
$$ LANGUAGE plpgsql;
