/*
Query a count of the number of cities in CITY having a Population larger than 100,000
*/
SELECT
    COUNT(*) AS city_count_gt_100000
FROM CITY
WHERE population > 100000;

/*
Query the total population of all cities in CITY where District is California.
-- Output only wants population 
*/
WITH cal_district_pop AS (
SELECT
    district,
    SUM(population) AS district_population
FROM CITY
GROUP BY district
HAVING district = 'California'
)
SELECT district_population FROM cal_district_pop;

-- This works too (no need for a CTE .. I just like them lol)
SELECT
    SUM(population) AS district_population
FROM CITY
GROUP BY district
HAVING district = 'California';



/*
Query the average population of all cities in CITY where District is California.
*/
-- Seems they expected the output rounded to 3 decimals
SELECT
    ROUND(AVG(population),3) AS dist_avg_pop_3
FROM CITY
GROUP BY district
HAVING district = 'California';



/*
Query the average population for all cities in CITY, rounded down to the nearest integer.
*/
-- No postgres numeric or case type concerns with the division performed for avg
SELECT
    ROUND(
        SUM(population) / (SELECT COUNT(*) FROM CITY)
    ) AS total_avg_population
FROM CITY;
--      Output
-- |total_avg_population|
-- |454250|

/*
Query the sum of the populations for all Japanese cities in CITY. 
The COUNTRYCODE for Japan is JPN.
*/
SELECT
    SUM(population) AS japan_total_pop
FROM CITY
WHERE countrycode = 'JPN';


/*
Query the difference between the maximum and minimum populations in CITY.
*/
WITH max_min_vals AS (
SELECT
    MIN(population) AS min_pop,
    MAX(population) AS max_pop
FROM CITY
)
SELECT
    max_pop - min_pop AS max_pop_diff
FROM max_min_vals;


/*
"The Blunder" - Challenge Name - Aggregation
Samantha was tasked with calculating the average monthly salaries for all employees in 
the EMPLOYEES table, but did not realize her keyboard's "0" key was broken until after 
completing the calculation. She wants your help finding the difference between her 
miscalculation (using salaries with any zeros removed), and the actual average salary.

Write a query calculating the amount of error (i.e. : actual - miscalculated average monthly salaries), 
and round it up to the next integer.

Constraints : 1000 < Salary < 10^5 == 100,000
*/
-- Will cast Integer to CHAR(str), then remove the '0', THEN CAST back to Int
WITH zeros_removed_and_edited_salaries AS (
SELECT 
    CAST(REPLACE(CAST(SALARY AS CHAR), '0', '') AS DECIMAL) AS zeros_removed_sals,
    SALARY AS salaries_with_zeros
FROM EMPLOYEES
),
averages AS (
SELECT
    AVG(zeros_removed_sals) AS zeros_removed_avg,
    AVG(salaries_with_zeros) AS w_zeros_avg
FROM zeros_removed_and_edited_salaries
)
SELECT
CEIL(w_zeros_avg - zeros_removed_avg) AS corrected_ceil_sal_avgs
FROM averages;


/*
"Top Earners" - Challenge Name - Aggregation
We define an employee's total earnings to be their monthly salary * months  worked, 
and the maximum total earnings to be the maximum total earnings for any employee in 
the Employee table. 
Write a query to find the maximum total earnings for all employees as well as the 
total number of employees who have maximum total earnings. 
Then print these values as  2 space-separated integers.

** Notes - MYSQL Version only 5.7 (Not 8+ - which supports CTEs, Ranking Functions)
** Dervied or Subquery Required
*/
SELECT 
CONCAT(CAST(emp_total_earnings AS CHAR), ' ', grouped_total_earnings_emps)
FROM 
(
    SELECT 
        months * salary AS emp_total_earnings,
        COUNT(*) AS grouped_total_earnings_emps
    FROM Employee
    GROUP BY emp_total_earnings
    ORDER BY emp_total_earnings DESC
) total_earnings
LIMIT 1; -- Just take the top row that was already ordered for the highest total salary potential

