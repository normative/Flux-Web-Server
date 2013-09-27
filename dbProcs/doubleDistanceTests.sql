select distancebetween(43.65339, -79.40659, 43.65338, -79.40661);

select distancebetween(43.65338, -79.40661, 43.65339, -79.40661);

select distancebetween(43.3248921158196, -79.8129805550722, ((43.3248921158196::float4)::float8), ((-79.8129805550722::float4)::float8)) 


select (-79.8129805550722::float4)

--SELECT i.id, i.best_longitude, round(i.best_longitude::numeric, 5) as chopped, 
--		distancebetween(i.best_latitude, i.best_longitude, (((i.best_latitude * 100000.0)::integer)::float8)/100000.0::float8, (((i.best_longitude * 100000.0)::integer)::float8)/100000.0::float8) as dubdistance,


SELECT i.id, i.best_longitude, round(i.best_longitude::numeric, 4) as chopped, 
		distancebetween(i.best_latitude, i.best_longitude, round(i.best_latitude::numeric, 4), round(i.best_longitude::numeric, 4)) as floatdistance
FROM images i
-- WHERE i.id >= 495
-- WHERE (i.id < 495) AND (i.best_longitude > -100.0)
-- WHERE best_longitude < -100.0
 WHERE (i.id >= 196) AND (i.id < 346) AND (i.best_longitude < -110.0)
-- WHERE (i.id < 495)
ORDER BY floatdistance DESC;


SELECT * from images i where i.id between 223 and 346 ORDER by i.id DESC;



select (((12.34567890 * 100000.0)::integer)::float8)/100000.0::float8

-- local, double
SELECT COUNT(i.id) as count, AVG(distancebetween(i.best_latitude, i.best_longitude, round(i.best_latitude::NUMERIC, 5), round(i.best_longitude::NUMERIC, 5))) as avgdist
FROM images i
WHERE (i.id >= 495) AND (i.id < 509)

-- west coast, float
SELECT COUNT(i.id) as count, AVG(distancebetween(i.best_latitude, i.best_longitude, round(i.best_latitude::NUMERIC, 4), round(i.best_longitude::NUMERIC, 4))) as avgdist
FROM images i
WHERE (i.id >= 196) AND (i.id < 346) AND (i.best_longitude < -110.0)

-- local, float
SELECT COUNT(i.id) as count, AVG(distancebetween(i.best_latitude, i.best_longitude, round(i.best_latitude::NUMERIC, 5), round(i.best_longitude::NUMERIC, 5))) as avgdist
FROM images i
WHERE i.id < 223

-- west coast, double
SELECT COUNT(i.id) as count, AVG(distancebetween(i.best_latitude, i.best_longitude, round(i.best_latitude::NUMERIC, 4), round(i.best_longitude::NUMERIC, 4))) as avgdist
FROM images i
WHERE (i.id >= 509) AND (i.id < 1000)

select id, best_longitude from images where best_longitude < -110.0 order by id


-- test database - first float/double image @ id=280, local
select * from images where id >= 280

-- local, mixed
SELECT COUNT(i.id) as count, AVG(distancebetween(i.best_latitude, i.best_longitude, i.raw_latitude, i.raw_longitude)) as avgdist
FROM images i
WHERE (i.id >= 280) AND (i.id < 292)

-- west coast, mixed
SELECT COUNT(i.id) as count, AVG(distancebetween(i.best_latitude, i.best_longitude, i.raw_latitude, i.raw_longitude)) as avgdist
FROM images i
WHERE (i.id >= 292)


select id, raw_latitude, best_latitude, raw_longitude, best_longitude, round(distancebetween(best_latitude, best_longitude, raw_latitude, raw_longitude)::numeric, 4) as distance
from images where id >= 280 
order by distance DESC;



