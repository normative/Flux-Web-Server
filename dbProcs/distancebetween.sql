
-- uses the Haversine formula to build a rectangular box of dimension (2 X radius) X (2 X radius) centered on the provided latitude and longitude

CREATE OR REPLACE FUNCTION distancebetween(lat1 double precision, lon1 double precision, lat2 double precision, lon2 double precision)
RETURNS double precision
AS $$
DECLARE
	lat0 double precision;
	a  double precision;
	f  double precision;
	e2  double precision;
	R1  double precision;
	R2  double precision;
	oneMeterLat  double precision;
	oneMeterLon  double precision;
	latdif double precision;
	londif double precision;

BEGIN

  lat0 = lat1 / 180.0 * pi();	-- convert to radians

  a = 6378137.0;
  e2 = 0.0066943799901413169964451404764132282816;

  R1 = a * (1.0 - e2) / power((1.0 - e2 * power(sin(lat0), 2.0)), (3.0 / 2.0));
  R2 = a / sqrt(1 - e2 * power(sin(lat0), 2.0));

  -- calc dlat and dlon (in degrees) for dN = dE = 1m
  oneMeterLat = (1.0 / R1) * (180.0 / pi());
  oneMeterLon = (1.0 / (R2 * cos(lat0))) * (180.0 / pi());

  latdif = (lat2 - lat1) / oneMeterLat;
  londif = (lon2 - lon1) / oneMeterLon;
  
RETURN 
	
	sqrt((latdif * latdif) + (londif * londif)) as distance;

END;
$$ LANGUAGE plpgsql;

