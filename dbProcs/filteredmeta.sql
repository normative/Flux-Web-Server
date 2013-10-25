
/*
DROP FUNCTION filteredmeta(lat double precision, lon double precision, radius double precision, 
						minalt double precision, maxalt double precision,
						mintime timestamp, maxtime timestamp,
						taglist text,
						userlist text,
						catlist text,
						maxcount integer
						)
*/

CREATE OR REPLACE FUNCTION filteredmeta(lat double precision, lon double precision, radius double precision, 
						minalt double precision, maxalt double precision,
						mintime timestamp, maxtime timestamp,
						taglist text,
						userlist text,
						catlist text,
						maxcount integer
						)
--RETURNS table (id integer, time_stamp timestamp, latitude double precision, longitude double precision, altitude double precision, 
--			heading double precision, yaw double precision, pitch double precision, roll double precision,
--			qw double precision, qx double precision, qy double precision, qz double precision)
RETURNS table (id integer, time_stamp timestamp, latitude double precision, longitude double precision, altitude double precision, 
			heading double precision, yaw double precision, pitch double precision, roll double precision,
			qw double precision, qx double precision, qy double precision, qz double precision)
AS $$
DECLARE
	tagset text[];
	tagarraylen integer;
	userset text[];
	userarraylen integer;
	catset text[];
	catarraylen integer;

	skiploc boolean;

BEGIN

	skiploc = (radius <= 0);

	tagset = string_to_array(trim(both ' ' from taglist), ' ');
	tagarraylen = array_length(tagset, 1);
	
	userset = string_to_array(trim(both ' ' from userlist), ' ');
	userarraylen = array_length(userset, 1);
	
	catset = string_to_array(trim(both ' ' from catlist), ' ');
	catarraylen = array_length(catset, 1);

	IF (mintime IS NULL) THEN
		mintime = '-infinity'::timestamp;
	END IF;
		
	IF (maxtime IS NULL) THEN
		maxtime = 'infinity'::timestamp;
	END IF;
		

RETURN QUERY
	SELECT	DISTINCT(i.id), i.time_stamp, i.best_latitude as latitude, i.best_longitude as longitude, i.best_altitude as altitude,
				i.heading, i.best_yaw as yaw, i.best_pitch as pitch, i.best_roll as roll, 
				i.best_qw as qw, i.best_qx as qx, i.best_qy as qy, i.best_qz as qz
--	SELECT	DISTINCT(i.id), i.time_stamp, i.best_latitude, i.best_longitude, i.best_altitude,
--				i.heading, i.best_yaw, i.best_pitch, i.best_roll, 
--				i.best_qw, i.best_qx, i.best_qy, i.best_qz
	FROM	
		(SELECT * FROM buildboundingbox(lat, lon, radius) FETCH FIRST 1 ROWS ONLY) as bb,
		images i
		LEFT OUTER JOIN images_tags imt ON i.id = imt.image_id
		LEFT OUTER JOIN tags t ON (imt.tag_id = t.id)
		JOIN categories c ON i.category_id = c.id
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
		 AND 	((tagarraylen IS NULL) OR (tagarraylen = 0) OR (t.tagtext = ANY (tagset)))
		-- users
		 AND 	((userarraylen IS NULL) OR (userarraylen = 0) OR (u.nickname = ANY (userset)))
		-- categories
		 AND 	((catarraylen IS NULL) OR (catarraylen = 0) OR (c.cat_text = ANY (catset)))
		 )
	ORDER by i.time_stamp
	LIMIT maxcount;

END;
$$ LANGUAGE plpgsql;
