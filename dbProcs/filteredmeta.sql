
/*
DROP FUNCTION filteredmeta(mytoken text,
					lat double precision, lon double precision, radius double precision, 
					minalt double precision, maxalt double precision,
					mintime timestamp, maxtime timestamp,
					taglist text,
					userlist text,
					maxcount integer
					)
*/

CREATE OR REPLACE FUNCTION filteredmeta(mytoken text,
					lat double precision, lon double precision, radius double precision, 
					minalt double precision, maxalt double precision,
					mintime timestamp, maxtime timestamp,
					taglist text,
					userlist text,
					maxcount integer
					)
RETURNS table (id bigint, time_stamp timestamp, user_id integer, description character varying, 
			username character varying, camera_model character varying,
			latitude double precision, longitude double precision, altitude double precision, 
			heading double precision, yaw double precision, pitch double precision, roll double precision,
			qw double precision, qx double precision, qy double precision, qz double precision)
AS $$
DECLARE
	tagset text[];
	tagarraylen integer;

	userset text[];
	userarraylen integer;

	myid integer;

	skiploc boolean;

BEGIN

	skiploc = (radius <= 0);

	SELECT u.id INTO myid 
	FROM users AS u 
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
	SELECT	DISTINCT(i.id), i.time_stamp, i.user_id, i.description, u.username as username, c.model as camera_model,
				i.best_latitude as latitude, i.best_longitude as longitude, i.best_altitude as altitude,
				i.heading, i.best_yaw as yaw, i.best_pitch as pitch, i.best_roll as roll, 
				i.best_qw as qw, i.best_qx as qx, i.best_qy as qy, i.best_qz as qz
	FROM	
		(SELECT * FROM buildboundingbox(lat, lon, radius) FETCH FIRST 1 ROWS ONLY) as bb,
		images i
		LEFT OUTER JOIN images_tags imt ON i.id = imt.image_id
		LEFT OUTER JOIN tags t ON (imt.tag_id = t.id)
		LEFT OUTER JOIN cameras c ON (i.camera_id = c.id)
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
		AND	(((mintime IS NULL) OR (i.time_stamp >= mintime))
		    AND	 ((maxtime IS NULL) OR (i.time_stamp <= maxtime))
			)
		-- tags
		 AND 	((tagarraylen IS NULL) OR (tagarraylen = 0) OR (t.tagtext = ANY (tagset)))
		-- users
--		 AND 	((userarraylen IS NULL) OR (userarraylen = 0) OR (u.username = ANY (userset)))
		 )
	ORDER by i.time_stamp desc
	LIMIT maxcount;

END;
$$ LANGUAGE plpgsql;
