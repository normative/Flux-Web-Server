/*
DROP FUNCTION imagesaroundimage(image_id bigint, radius double precision);
*/

CREATE OR REPLACE FUNCTION imagesaroundimage(image_id bigint, radius double precision)
RETURNS TABLE(id bigint, filename varchar)
AS $$
DECLARE
	lat double precision;
	lon double precision;
BEGIN

	SELECT best_latitude, best_longitude INTO lat, lon
	FROM images i1
	WHERE i1.id = image_id;


RETURN QUERY
	

	SELECT	i.id, i.features_file_name
	FROM	(SELECT * 
		 FROM buildboundingbox(lat, lon, radius) 
		 FETCH FIRST 1 ROWS ONLY) as bb,
		images i
	WHERE	 ((i.best_latitude > bb.minlat) AND (i.best_latitude < bb.maxlat) AND
		 (i.best_longitude > bb.minlon) AND (i.best_longitude < bb.maxlon))
	   AND	i.id < image_id
	ORDER BY id ASC;
END;
$$ LANGUAGE plpgsql;
