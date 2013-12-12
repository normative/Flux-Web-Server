
/*
DROP FUNCTION getprofileforuser(userid integer)
*/

CREATE OR REPLACE FUNCTION getprofileforuser(myauthtoken text, userid integer)

RETURNS table (id integer, follower_count integer, following_count integer, image_count integer, member_since timestamp, 
		bio character varying, friend boolean, amifollowing boolean, aretheyfollowing boolean 
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
	SELECT	DISTINCT(u.id), follower_count,  following_count, image_count, u.created_at AS member_since,
		u.bio AS bio, friend, amifollowing, aretheyfollowing
	FROM
		users u
		JOIN images i ON i.user_id = u.id
	WHERE	u.id = userid;

END;
$$ LANGUAGE plpgsql;
