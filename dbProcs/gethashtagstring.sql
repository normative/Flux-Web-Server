-- Function: gethashtagstring(imageid bigint)

-- DROP FUNCTION gethashtagstring(bigint);

CREATE OR REPLACE FUNCTION gethashtagstring(imageid bigint)
  RETURNS TABLE(hashtags text) 
AS
$$
DECLARE
	hashset text[];
	tagset text;
	hashtag text;

BEGIN

	-- loop through tags for the image
	FOR hashtag IN 	(SELECT t.tagtext
			 FROM	images_tags imt
				JOIN tags t ON (imt.tag_id = t.id)
			 WHERE imt.image_id = imageid
	
			)
	LOOP
		-- add to array
		hashset = hashset || hashtag;
	END LOOP;

RETURN QUERY 
	-- return array converted to string
	SELECT array_to_string(hashset, ' ');

END;
$$ LANGUAGE plpgsql;


