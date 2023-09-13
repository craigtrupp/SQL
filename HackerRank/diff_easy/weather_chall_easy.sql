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
