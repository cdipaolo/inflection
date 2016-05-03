.mode csv
.header on
.separator ~

-- "==> Generating reviews.csv dataset.";
-- "--   Contains date, business_id, name";
-- "--   longitude, latitude, and review_count";
-- "--   for each review and its associated";
-- "--   business.";

.output data/processed/reviews.csv

SELECT timestamp, business.business_id, name, longitude,
       latitude, review.stars, review_count
FROM review INNER JOIN business ON review.business_id = business.business_id;

.output stdout

SELECT "==> Done Generating reviews.csv";

-- "==> Generating vegas_stars.csv";
-- "--   Contains business_id, latitude,";
-- "--   longitude, and average stars";
-- "--   for each business in Las Vegas.";

.output data/processed/vegas_stars.csv

SELECT business_id, latitude, longitude, stars
FROM business
WHERE city = "Las Vegas";

.output stdout

SELECT "==> Done Generating vegas_stars.csv";
