/*
DROP FUNCTION filteredcontentquery(lat double precision, lon double precision, radius double precision, 
						minalt double precision, maxalt double precision,
						mintime timestamp, maxtime timestamp,
						taglist text,
						userlist text,
						catlist text,
						maxcount integer
						)
*/
/*
raw json call:
http://54.221.254.230/images/filteredcontent.json?lat=43.32485&long=-79.81303&radius=500.0&altmin=-1000.0&altmax=1000.0&timemin=NULL&timemax=NULL&taglist=''&userlist=''&catlist=''&maxcount=10
*/
CREATE OR REPLACE FUNCTION filteredcontentquery(mytoken text,
						lat double precision, lon double precision, radius double precision, 
						minalt double precision, maxalt double precision,
						mintime timestamp, maxtime timestamp,
						taglist text,
						userlist text,
						maxcount integer
						)
--RETURNS TABLE(id bigint, content_type integer, best_latitude double precision, best_longitude double precision, best_altitude double precision)
RETURNS TABLE(id bigint, content_type integer, latitude double precision, longitude double precision, altitude double precision)
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
	SELECT	DISTINCT i.id AS id, 1::integer AS content_type, i.best_latitude AS latitude, i.best_longitude AS longitude, i.best_altitude AS altitude
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
		 AND 	((tagarraylen IS NULL) OR (tagarraylen = 0) OR (t.tagtext = ANY (tagset)))
		-- users
--		 AND 	((userarraylen IS NULL) OR (userarraylen = 0) OR (u.username = ANY (userset)))
		 )
	ORDER by i.id DESC
	LIMIT maxcount;

END;
$$ LANGUAGE plpgsql;
