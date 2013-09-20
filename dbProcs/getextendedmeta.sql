-- Function: getextendedmeta(bigint[])
-- http://<host>/images/extendedmeta?idlist='%7b203%7d'

-- DROP FUNCTION getextendedmeta(bigint[]);

CREATE OR REPLACE FUNCTION getextendedmeta(IN idlist bigint[])
   RETURNS TABLE(
   id integer,
   description character varying, 
   categoryname character varying, 
   cameraname character varying, 
   username character varying, 
   hashtags text,
   category_id integer,
   camera_id integer
   ) 
AS
$$
DECLARE
	imageid bigint;

BEGIN
	-- spin through idlist to create idset
	CREATE TEMP TABLE imageids (id bigint, hashstr text)
	ON COMMIT DROP;

	FOREACH imageid IN ARRAY idlist
	LOOP
		INSERT INTO imageids (id, hashstr)
			VALUES (imageid, gethashtagstring(imageid));
	END LOOP;

	
RETURN QUERY
	SELECT	i.id, i.description, c.cat_text AS categoryname, cam.nickname AS cameraname, 
		u.nickname as username, imid.hashstr as hashtags, i.category_id, i.camera_id
	FROM	
		images i
		JOIN imageids imid ON i.id = imid.id
		JOIN categories c ON i.category_id = c.id
		JOIN users u ON i.user_id = u.id
		JOIN cameras cam on i.camera_id = cam.id
	ORDER by imid.id;

END;
$$ LANGUAGE plpgsql;
