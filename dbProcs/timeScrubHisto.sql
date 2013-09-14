-- proc to bucket-ize (filtered) images based on timestamp
-- bucket size is based on total time span / num buckets and rounded up to convienient size
-- bucket sizes: 1s, 1m, 5m, 10m, 15m, 30m, 1h, 6h, 12h, 1d, 1w, 2w, 1m, 3m, 4m, 6m, 1y
-- to get bucket size, calc <(maxtime - mintime) in seconds> / <max bucket count>
--	yields min number of seconds per bucket
--	compare to set of constants for above buckets to find the min fixed bucket that is larger than calc'd
-- build array of bucket min/max times (start from query max/now and work down)
-- query for bucket max, <count(imageid)> based on min/max buckets and <group by> bucket max
-- return list ordered by bucketmax.



/*
DROP FUNCTION timeScrubHisto(lat double precision, lon double precision, radius double precision, 
						minalt double precision, maxalt double precision,
						mintime timestamp, maxtime timestamp,
						taglist text,
						userlist text,
						catlist text,
						maxbucketcount int
						)
*/

CREATE OR REPLACE FUNCTION timeScrubHisto(lat double precision, lon double precision, radius double precision, 
						minalt double precision, maxalt double precision,
						mintime timestamp, maxtime timestamp,
						taglist text,
						userlist text,
						catlist text,
						maxbucketcount int
						)
-- RETURNS TABLE (time_stamp timestamp, imageid bigint)
RETURNS TABLE (time_stamp timestamp, imageid integer)
AS
$$
DECLARE
	tagset text[];
	tagarraylen integer;
	userset text[];
	userarraylen integer;
	catset text[];
	catarraylen integer;

	skiploc boolean;

	maxbucketsize double precision;
	maxbucketsizeseconds double precision;

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
		
	CREATE TABLE filtimages (time_stamp, id)
--	CREATE TEMP TABLE filtimages (time_stamp, id)
--		ON COMMIT DROP
	AS 	
		SELECT	i.time_stamp, i.id
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
		
		ORDER by i.time_stamp;
	
	SELECT EXTRACT(EPOCH FROM (MAX(fi.time_stamp) - MIN(fi.time_stamp)) / maxbucketcount), MIN(fi.time_stamp)
		INTO maxbucketsize, mintime
		FROM filtimages fi;
		
-- -- bucket sizes: 1s, 1m, 5m, 10m, 15m, 30m, 1h, 6h, 12h, 1d, 1w, 2w, 1m, 3m, 4m, 6m, 1y

	IF (maxbucketsize <= 1.0) THEN
		-- use a 1s bucket
	ELSIF (maxbucketsize <= 30.0) THEN
		-- use a 30s bucket
	ELSIF (maxbucketsize <= 60.0) THEN
		-- use a 1m bucket
	ELSIF (maxbucketsize <= 300.0) THEN
		-- use a 5m bucket
	ELSIF (maxbucketsize <= 600.0) THEN
		-- use a 10m bucket
	ELSIF (maxbucketsize <= 900.0) THEN
		-- use a 15m bucket
	ELSIF (maxbucketsize <= 1800.0) THEN
		-- use a 30m bucket
	ELSIF (maxbucketsize <= 3600.0) THEN
		-- use a 1h bucket
	ELSIF (maxbucketsize <= 21600.0) THEN
		-- use a 6h bucket
	ELSIF (maxbucketsize <= 43200.0) THEN
		-- use a 12h bucket
	ELSIF (maxbucketsize <= 86400.0) THEN
		-- use a 1d bucket
	ELSIF (maxbucketsize <= 604800.0) THEN
		-- use a 1w bucket
	END IF;

RETURN QUERY
	SELECT * from filtimages;


END;
$$ LANGUAGE plpgsql;



