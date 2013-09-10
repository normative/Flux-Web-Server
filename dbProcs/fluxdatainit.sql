-- initialize the db with categories, a first user and a first camera

-- initialize categories
INSERT INTO categories (cat_description, cat_text, created_at, updated_at)
	VALUES ('Person', 'person', now(), now());
INSERT INTO categories (cat_description, cat_text, created_at, updated_at)
	VALUES ('Place', 'place', now(), now());
INSERT INTO categories (cat_description, cat_text, created_at, updated_at)
	VALUES ('Thing', 'thing', now(), now());
INSERT INTO categories (cat_description, cat_text, created_at, updated_at)
	VALUES ('Event', 'event', now(), now());

-- initialize user
INSERT INTO users (firstname, lastname, privacy, nickname, created_at, updated_at)
	VALUES('FLUX', 'User', false, 'flux_user', now(), now());


-- initialize camera
INSERT INTO cameras (user_id, model, deviceid, description, nickname, created_at, updated_at)
	VALUES(1, 'iPhone 5', '982739273940', 'Fluxs iPhone', 'fluxfone', now(), now());

-- SELECT * FROM categories;
-- SELECT * FROM users;
-- SELECT * FROM cameras;