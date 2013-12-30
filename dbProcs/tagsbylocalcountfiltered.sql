-- return the set of tags found in local imagery and return ranked in order of highest count

/*
DROP FUNCTION tagsbylocalcountfiltered(lat double precision, lon double precision, radius double precision,
							minalt double precision, maxalt double precision,
							mintime timestamp, maxtime timestamp,
							taglist text,
							userlist text,
							catlist text,
							maxcount integer
						    )

*/

CREATE OR REPLACE FUNCTION tagsbylocalcountfiltered(mytoken text,
							lat double precision, lon double precision, radius double precision,
							minalt double precision, maxalt double precision,
							mintime timestamp, maxtime timestamp,
							taglist text,
							userlist text,
							catlist text,
							maxcount integer
						    )


RETURNS TABLE (tagtext varchar, count bigint)
AS
$$
DECLARE
	tagset text[];
	tagarraylen integer;
	
	userset text[];
	userarraylen integer;
	
	myid integer;
	
	skiploc boolean;

BEGIN

	skiploc = (radius <= 0);

	SELECT id INTO myid 
	FROM users 
	WHERE authentication_token = mytoken;

	tagset = string_to_array(trim(both ' ' from taglist), ' ');
	tagarraylen = array_length(tagset, 1);
	
	userset = string_to_array(trim(both ' ' from userlist), ' ');
	userarraylen = array_length(userset, 1);
	
	IF (mintime IS NULL) THEN
		mintime = '-infinity'::timestamp;
	END IF;
		
	IF (maxtime IS NULL) THEN
		maxtime = 'infinity'::timestamp;
	END IF;
		

RETURN QUERY	
	SELECT	t.tagtext, count(imt.image_id) AS "count"
	FROM	
		(SELECT * FROM buildboundingbox(lat, lon, radius) FETCH FIRST 1 ROWS ONLY) as bb,
		images i
		LEFT OUTER JOIN images_tags imt ON i.id = imt.image_id
		LEFT OUTER JOIN tags t ON (imt.tag_id = t.id)
		JOIN users u ON i.user_id = u.id
	WHERE	( 
		-- location
			((skiploc) OR
			 ((i.best_latitude > bb.minlat) AND (i.best_latitude < bb.maxlat) AND
			 (i.best_longitude > bb.minlon) AND (i.best_longitude < bb.maxlon))
			)
		-- altitude
		AND	(((minalt IS NULL) OR (i.best_altitude >= minalt))
		    AND	 ((maxalt IS NULL) OR (i.best_altitude <= maxalt))
			)
		-- time
--		AND	(i.time_stamp BETWEEN mintime AND maxtime)
		AND	(((mintime IS NULL) OR (i.time_stamp >= mintime))
		    AND	 ((maxtime IS NULL) OR (i.time_stamp <= maxtime))
			)
		-- tags
		 AND 	(((tagarraylen IS NULL) OR (tagarraylen = 0) OR (t.tagtext = ANY (tagset))) AND (t.tagtext IS NOT NULL))
		-- users
--		 AND 	((userarraylen IS NULL) OR (userarraylen = 0) OR (u.username = ANY (userset)))
		 )
	GROUP BY t.tagtext
	ORDER BY "count" DESC, MAX(i.time_stamp), t.tagtext
	LIMIT maxcount;

END;
$$ LANGUAGE plpgsql;
