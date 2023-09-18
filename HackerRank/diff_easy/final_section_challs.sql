-- Population Census : Basic Join
-- Given the CITY and COUNTRY tables, query the sum of the populations of all cities where the CONTINENT is 'Asia'.
-- Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
SELECT
    SUM(cty.population) AS asia_population
FROM CITY AS cty
INNER JOIN COUNTRY AS ctry
    on cty.countrycode = ctry.code
WHERE ctry.continent = 'Asia';

-- African Cities : Basic Join
-- Given the CITY and COUNTRY tables, query the names of all cities where the CONTINENT is 'Africa'.
-- Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
SELECT
    cty.name AS Africa_cities
FROM CITY AS cty
INNER JOIN COUNTRY AS ctry
    ON cty.countrycode = ctry.code
WHERE ctry.continent = 'Africa';


-- Average Population of Each Continent : Basic Join
-- Given the CITY and COUNTRY tables, query the names of all the continents (COUNTRY.Continent) and 
-- their respective average city populations (CITY.Population) rounded down to the nearest integer.
-- Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
SELECT
    ctry.continent,
    FLOOR(AVG(cty.population)) AS cont_avg_floor_pop
FROM COUNTRY AS ctry
INNER JOIN CITY AS cty
    ON ctry.code = cty.countrycode
GROUP BY ctry.continent;


-- 
-- Draw the Triangle 1 : 1 of 2 SQL (Advanced) Question within the Easy Difficulty 
-- P(R) represents a pattern drawn by Julia in R rows. The following pattern represents P(5):
-- * * * * * 
-- * * * * 
-- * * * 
-- * * 
-- *
-- Write a query to print the pattern P(20).
WITH RECURSIVE starCount(n) AS (
SELECT
    CAST('*' AS CHAR(25)) AS n
UNION ALL
SELECT
    CONCAT('*', n)
FROM starCount
WHERE LENGTH(n) <= 19
)
SELECT *
FROM starCount
ORDER BY LENGTH(n) DESC;

-- This isn't being excepted however despite creating 20 rows and having the descending star order
-- Oh god ... the star needed a space, procedure is easier though
DELIMITER //
CREATE PROCEDURE starCreator(stars INT)
    BEGIN
       WHILE stars >= 1 DO 
            SELECT REPEAT('* ', stars);
            SET stars = stars - 1;
        END WHILE;
    END//
DELIMITER ;
CALL starCreator(20);



-- Draw the Triangle 2 : 2 of 2 SQL (Advanced) Question with the Easy Difficulty category
-- P(R) represents a pattern drawn by Julia in R rows. The following pattern represents P(5):
-- * 
-- * * 
-- * * * 
-- * * * * 
-- * * * * *
-- so Essentially the inverse
DELIMITER //
CREATE PROCEDURE growingTriangle(stars INT)
    BEGIN
        DECLARE counter INT;
        SET counter = 1;
        WHILE counter <= stars DO
            SELECT REPEAT('* ', counter);
            SET counter = counter + 1;
        END WHILE;
    END//
DELIMITER ;
CALL growingTriangle(20);









