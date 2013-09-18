-- Function: getextendedmeta(bigint[])
-- http://<host>/images/extendedmeta?idlist='%7b203%7d'

-- DROP FUNCTION getextendedmeta(bigint[]);

CREATE OR REPLACE FUNCTION getextendedmeta(IN idlist bigint[])
--  RETURNS TABLE(id integer, description character varying, categoryname character varying, cameraname character varying, username character varying, hashtags text,
--			best_latitude double precision, best_longitude double precision, best_altitude double precision, 
--			best_yaw double precision, best_pitch double precision, best_roll double precision,
--			best_qw double precision, best_qx double precision, best_qy double precision, best_qz double precision
--			)   
   RETURNS TABLE(
   id integer,
   description character varying, 
   categoryname character varying, 
   cameraname character varying, 
   username character varying, 
   hashtags text
   ) 
AS
$$
DECLARE
	idstrset text[];
	-- idset bigint[];
	idarraylen integer;
	imageid bigint;

BEGIN
--	idstrset = string_to_array(trim(both ' ' from idlist), ' ');
--	idarraylen = array_length(idstrset, 1);

	-- spin through idstrset to create idset (convert to numeric)
	CREATE TEMP TABLE imageids (id bigint, hashstr text)
	ON COMMIT DROP;

--	FOREACH imageid IN ARRAY idstrset
	FOREACH imageid IN ARRAY idlist
	LOOP
--		IF (ISNUMERIC(imageid)) THEN
			INSERT INTO imageids (id, hashstr)
--				VALUES (CAST(imageid as bigint), gethashtagstring(CAST(imageid as bigint)));
				VALUES (imageid, gethashtagstring(imageid));
--				VALUES (imageid, 'hash tag list');
--		END IF;
	END LOOP;

	
RETURN QUERY
--	SELECT	i.id, i.description, c.cat_text AS categoryname, cam.nickname AS cameraname, u.nickname as username, imid.hashstr as hashtags,
--		0.0::float8 as best_latitude, 0.0::float8 as best_longitude, 0.0::float8 as best_altitude, 
--		0.0::float8 as best_yaw, 0.0::float8 as best_pitch, 0.0::float8 as best_roll, 
--		0.0::float8 as best_qw, 0.0::float8 as best_qx, 0.0::float8 as best_qy, 0.0::float8 as best_qz
	SELECT	i.id, i.description, c.cat_text AS categoryname, cam.nickname AS cameraname, u.nickname as username, imid.hashstr as hashtags
	FROM	
		images i
		JOIN imageids imid ON i.id = imid.id
		JOIN categories c ON i.category_id = c.id
		JOIN users u ON i.user_id = u.id
		JOIN cameras cam on i.camera_id = cam.id
		
--	WHERE	( 
--		)
	ORDER by imid.id;

END;
$$ LANGUAGE plpgsql;
