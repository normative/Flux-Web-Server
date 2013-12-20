
/*
DROP FUNCTION getprofileforuser(myauthtoken text, userid integer)
*/

CREATE OR REPLACE FUNCTION getprofileforuser(myauthtoken text, userid integer)

RETURNS table (id integer, username character varying, bio character varying, has_pic boolean,
		member_since timestamp, follower_count integer, following_count integer, 
		image_count integer, friend boolean, amifollowing boolean, aretheyfollowing boolean 
		)
AS $$
DECLARE
	follower_count integer;
	following_count integer;
	image_count integer;
	friend boolean;
	amifollowing boolean;
	aretheyfollowing boolean;

	myid integer;

BEGIN

	SELECT u.id INTO myid 
	FROM users u
	WHERE u.authentication_token = myauthtoken;

	follower_count := 0;
	following_count := 0;

 	SELECT COUNT(DISTINCT(i.id)) INTO image_count 
 	FROM images i
 	WHERE i.user_id = userid;
	
	friend := false;
	amifollowing := false;
	aretheyfollowing := false;

RETURN QUERY
	SELECT	DISTINCT(u.id), u.username AS username, u.bio AS bio, ((u.avatar_file_size IS NOT NULL) AND (u.avatar_file_size > 0)) AS has_pic, 
		u.created_at AS member_since, follower_count,  following_count, 
		image_count, friend, amifollowing, aretheyfollowing
	FROM
		users u
		LEFT OUTER JOIN images i ON i.user_id = u.id
	WHERE	u.id = userid;

END;
$$ LANGUAGE plpgsql;
