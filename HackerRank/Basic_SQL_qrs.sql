-- Find the difference between the total number of CITY entries 
-- in the table and the number of distinct CITY entries in the table.
WITH diff_values AS (
SELECT
    (SELECT COUNT(*) FROM STATION) AS total_cities,
    (SELECT COUNT(DISTINCT city) FROM STATION) AS unique_cities
)
SELECT 
    total_cities - unique_cities
FROM diff_values;