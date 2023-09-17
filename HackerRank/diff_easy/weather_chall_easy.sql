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


-- Challenge Name : Weather Observation Station 5
-- Difficulty (Easy) : SQL Skills (Intermediate)
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



-- Query the list of CITY names starting with vowels (i.e., a, e, i, o, or u) from STATION. 
-- Your result cannot contain duplicates.
WITH distinct_cities AS (
SELECT
    DISTINCT city AS unique_cities
FROM STATION
)
SELECT
    unique_cities
FROM distinct_cities
WHERE LEFT(LOWER(unique_cities), 1) in ('a', 'e', 'i', 'o', 'u');



-- Query the list of CITY names ending with vowels (a, e, i, o, u) from STATION. 
-- Your result cannot contain duplicates.
WITH unique_cities AS (
SELECT
    DISTINCT city AS city
FROM STATION
)
SELECT
    city
FROM unique_cities
WHERE LOWER(RIGHT(city, 1)) in ('a', 'e', 'i', 'o', 'u');


-- Query the list of CITY names from STATION which have vowels (i.e., a, e, i, o, and u) as both their first and last characters. 
-- Your result cannot contain duplicates.
WITH distinct_cities AS (
SELECT
    DISTINCT city AS city
FROM STATION
)
SELECT
    city
FROM distinct_cities
WHERE LEFT(LOWER(city), 1) in ('a', 'e', 'i', 'o', 'u')
    AND RIGHT(LOWER(city), 1) in ('a', 'e','i','o','u');


-- Query the list of CITY names from STATION that do not start with vowels. 
-- Your result cannot contain duplicates.
WITH distinct_cities AS (
SELECT
    DISTINCT city AS city
FROM STATION
)
SELECT
    city
FROM distinct_cities
WHERE LEFT(lower(city), 1) NOT IN ('a', 'e', 'i', 'o', 'u');


-- Query the list of CITY names from STATION that do not end with vowels. 
-- Your result cannot contain duplicates.
WITH distinct_cities AS (
SELECT
    DISTINCT city AS city
FROM STATION
)
SELECT
    city
FROM distinct_cities
WHERE RIGHT(lower(city), 1) NOT IN ('a', 'e', 'i', 'o', 'u');



-- Query the list of CITY names from STATION that **either** 
-- do not start with vowels or do not end with vowels. 
-- Your result cannot contain duplicates.
WITH distinct_cities AS (
SELECT
    DISTINCT city AS city
FROM STATION
)
SELECT
    city
FROM distinct_cities
WHERE 
    LEFT(LOWER(city), 1) NOT in ('a', 'e', 'i', 'o', 'u')
    OR RIGHT(LOWER(city), 1) NOT in ('a', 'e','i','o','u');



-- Query the list of CITY names from STATION that do not start with vowels 
-- **and** do not end with vowels. Your result cannot contain duplicates.
WITH distinct_cities AS (
SELECT
    DISTINCT city AS city
FROM STATION
)
SELECT
    city
FROM distinct_cities
WHERE 
    LEFT(LOWER(city), 1) NOT in ('a', 'e', 'i', 'o', 'u')
    AND RIGHT(LOWER(city), 1) NOT in ('a', 'e','i','o','u');


-- Weather Observation 2 : SQL Agg (Easy)
-- Query the following two values from the STATION table:
-- The sum of all values in LAT_N rounded to a scale of  decimal places.
-- The sum of all values in LONG_W rounded to a scale of  decimal places.
/*
Enter your query here.
*/
SELECT
    ROUND(SUM(lat_n), 2) AS lat_n_round_2,
    ROUND(SUM(long_w), 2) AS long_w_round_2
FROM STATION;


-- Weahter Observation 13 : SQL Agg (Easy)
-- Query the sum of Northern Latitudes (LAT_N) from STATION having values 
-- greater 38.7880 than and less than 137.2345. Truncate your answer to 4 decimal places.
/*
Enter your query here.
*/
SELECT
    ROUND(SUM(lat_n), 4) as lat_n_gt_38
FROM STATION
WHERE lat_n BETWEEN 38.7880 AND 137.2345;


-- Weather Observation 14 : SQL Agg (Easy)
-- Query the greatest value of the Northern Latitudes (LAT_N) from STATION 
-- that is less than 137.2345. Truncate your answer to 4 decimal places.
/*
Enter your query here.
*/
SELECT
    ROUND(MAX(lat_n), 4) AS max_lat_n_lt_137
FROM STATION
WHERE lat_n < 137.2345;


-- Weather Observation 15 : SQL Agg (Easy)
-- Query the Western Longitude (LONG_W) for the largest Northern Latitude (LAT_N) 
-- in STATION that is less than 137.2345. Round your answer to 4 decimal places.
/*
Enter your query here.
*/
SELECT
    ROUND(long_w, 4) AS cond_long_w
FROM (
    SELECT *
    FROM STATION
    WHERE lat_n < 137.2345
    ORDER BY lat_n DESC
    LIMIT 1
) AS derived_table;


-- Weather Observation 16 : SQL Agg (Easy)
-- Query the smallest Northern Latitude (LAT_N) from STATION that is greater than 38.7780.
-- Round your answer to 4 decimal places.
/*
Enter your query here.
*/
SELECT
    ROUND(MIN(lat_n), 4) AS min_lat_condition
FROM STATION
WHERE lat_n > 38.7780;


-- Weather Observation 17: SQL Agg (Easy)
-- Query the Western Longitude (LONG_W)where the smallest Northern Latitude (LAT_N) in 
-- STATION is greater than 38.7780. Round your answer to 4 decimal places.
/*
Enter your query here.
*/
SELECT
    * 
FROM
(
    SELECT
        ROUND(long_w, 4) AS long_w_condition
    FROM STATION
    WHERE lat_n > 38.7780
    ORDER BY lat_n
    LIMIT 1
) AS derived_output;
