
DROP FUNCTION filteredcontentquery(mytoken text, 
						lat double precision, lon double precision, radius double precision, 
						minalt double precision, maxalt double precision,
						mintime timestamp, maxtime timestamp,
						taglist text,
						userlist text,
						mypics integer,
						friendpics integer,
						followingpics integer,
						maxcount integer
						);

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
						mypics integer,
						followingpics integer,
						maxcount integer
						)
RETURNS TABLE(id bigint, content_type integer, latitude double precision, longitude double precision, altitude double precision)
AS $$
DECLARE
	tagset text[];
	tagarraylen integer;
	
	userset integer[];
	userarraylen integer;

	my_id integer;
	
	skiploc boolean;
	skipsocial boolean;

BEGIN

	skiploc = (radius <= 0);

	skipsocial = NOT ((mypics = 1) OR (followingpics = 1));

	SELECT u.id INTO my_id 
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
		
	CREATE TEMP TABLE imagesinbox
	ON COMMIT DROP
	AS
	(	
		SELECT	i.id, 
			i.privacy,
			i.user_id
		FROM	(SELECT * FROM buildboundingbox(lat, lon, radius) FETCH FIRST 1 ROWS ONLY) as bb,
			images i
			INNER JOIN users u ON (i.user_id = u.id)
		WHERE	((skiploc) OR
			 ((i.best_latitude > bb.minlat) AND (i.best_latitude < bb.maxlat) AND
			 (i.best_longitude > bb.minlon) AND (i.best_longitude < bb.maxlon))
			)
	);

	CREATE TEMP TABLE imageset
	ON COMMIT DROP
	AS 
	(
		SELECT	DISTINCT i.* 
		FROM	imagesinbox i
			INNER JOIN users u ON (i.user_id = u.id)
			LEFT OUTER JOIN connections c ON ((c.user_id = my_id) AND (c.connections_id = u.id))
		WHERE	-- my pics
  			(((mypics = 1) OR (skipsocial)) AND
  			 (i.user_id = my_id))
   		   OR	-- following pics
   			(((followingpics = 1) OR (skipsocial)) AND
   			 (c.following_state = 2))
  		   OR	-- everyone else
 			((skipsocial) AND (i.privacy = 0))
	);

RETURN QUERY
	SELECT	DISTINCT i.id AS id, 1::integer AS content_type, 
			i.best_latitude AS latitude, i.best_longitude AS longitude, i.best_altitude AS altitude
	FROM	imageset ims
		INNER JOIN images i ON (ims.id = i.id)
		LEFT OUTER JOIN images_tags imt ON i.id = imt.image_id
		LEFT OUTER JOIN tags t ON (imt.tag_id = t.id)
	WHERE	(   -- altitude
			(((minalt IS NULL) OR ((i.best_altitude + i.vert_accuracy) >= minalt))
		    AND	 ((maxalt IS NULL) OR ((i.best_altitude - i.vert_accuracy) <= maxalt))
			)
		AND -- time
			(((mintime IS NULL) OR (i.time_stamp >= mintime))
		    AND	 ((maxtime IS NULL) OR (i.time_stamp <= maxtime))
			)
		AND -- tags
			((tagarraylen IS NULL) OR (tagarraylen = 0) OR (t.tagtext = ANY (tagset)))
		AND -- users
			((userarraylen IS NULL) OR (userarraylen = 0) OR (ims.user_id = ANY (userset)))
		)
	ORDER by i.id DESC
	LIMIT maxcount;

END;
$$ LANGUAGE plpgsql;
