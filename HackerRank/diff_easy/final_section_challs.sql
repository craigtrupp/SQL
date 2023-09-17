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

