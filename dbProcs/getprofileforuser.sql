
/*
DROP FUNCTION getprofileforuser(myauthtoken text, userid integer)
*/

CREATE OR REPLACE FUNCTION getprofileforuser(myauthtoken text, userid integer)

RETURNS table (id integer, username character varying, bio character varying, has_pic boolean,
		member_since timestamp, follower_count integer, following_count integer, 
		image_count integer, friend_state integer, am_follower integer, is_following integer 
		)
AS $$
DECLARE
	follower_count integer;
	following_count integer;
	image_count integer;

	my_id integer;

BEGIN

	SELECT u.id INTO my_id 
	FROM users u
	WHERE u.authentication_token = myauthtoken;

	SELECT COUNT(DISTINCT(c.user_id)) INTO follower_count
	FROM connections c
	WHERE c.connections_id = userid AND c.am_following = 1;

	SELECT COUNT(DISTINCT(c.connections_id)) INTO following_count
	FROM connections c
	WHERE c.user_id = userid AND c.am_following = 1;

 	SELECT COUNT(DISTINCT(i.id)) INTO image_count 
 	FROM images i
 	WHERE i.user_id = userid;


RETURN QUERY	
	SELECT	DISTINCT(u.id), 
		u.username AS username, 
		u.bio AS bio, 
		((u.avatar_file_size IS NOT NULL) AND (u.avatar_file_size > 0)) AS has_pic, 
		u.created_at AS member_since, 
		follower_count,  
		following_count, 
		image_count, 
		checkfriendstate(my_id, userid) AS friend_state,
		follow_state.i_follow AS am_follower, 
		follow_state.they_follow AS is_following
	FROM
		users u
		LEFT OUTER JOIN images i ON i.user_id = u.id,
		checkfollowerstate(my_id, userid) AS follow_state
	WHERE	u.id = userid;
	
END;
$$ LANGUAGE plpgsql;
