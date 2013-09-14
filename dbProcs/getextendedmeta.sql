-- Function: getextendedmeta(bigint[])

-- DROP FUNCTION getextendedmeta(bigint[]);

CREATE OR REPLACE FUNCTION getextendedmeta(IN idlist bigint[])
  RETURNS TABLE(imageid bigint, description character varying, category character varying, camera character varying, username character varying, hashtags text) 
AS
$$
DECLARE
	idstrset text[];
	-- idset bigint[];
	idarraylen integer;

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
	SELECT	imid.id, i.description, c.cat_text AS category, cam.nickname AS camera, u.nickname as user, imid.hashstr as hashtags
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
