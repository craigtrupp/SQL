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


-- Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths 
-- (i.e.: number of characters in the name). If there is more than one smallest or largest city, choose the one that 
-- comes first when ordered alphabetically.
WITH longest_city_name_alpha AS (
SELECT 
    city, LENGTH(city) AS city_alpha_length,
    RANK() OVER(
        ORDER BY LENGTH(city) DESC, city
    ) AS longest_alpha_rankings
FROM STATION
),
shortest_city_name_alpha AS (
SELECT 
    city, LENGTH(city) AS city_alpha_length,
    RANK() OVER(
        ORDER BY LENGTH(city), city
    ) AS shortest_alpha_rankings
FROM STATION
)
SELECT city, city_alpha_length
FROM longest_city_name_alpha
WHERE longest_alpha_rankings = 1
UNION
SELECT city, city_alpha_length
FROM shortest_city_name_alpha
WHERE shortest_alpha_rankings = 1;