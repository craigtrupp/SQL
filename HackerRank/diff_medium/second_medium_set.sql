---- New Companies - Advanced Select - Medium Difficulty
-- Given the table schemas below, write a query to print the company_code, 
-- founder name, total number of lead managers, total number of senior managers, 
-- total number of managers, and total number of employees. Order your output by 
-- ascending company_code.

-- Note:

-- The tables may contain duplicate records.
-- The company_code is string, so the sorting should not be numeric. F
-- or example, if the company_codes are C_1, C_2, and C_10, then the ascending 
-- company_codes will be C_1, C_10, and C_2.
/*
Enter your query here.
*/
SELECT
    join_path.company_code, join_path.founder,
    COUNT(DISTINCT join_path.lead_manager) AS lead_managers,
    COUNT(DISTINCT join_path.senior_manager) AS senior_managers,
    COUNT(DISTINCT join_path.manager) AS managers,
    COUNT(DISTINCT join_path.employee) AS employees
FROM 
(
    SELECT
        cmp.company_code AS company_code, cmp.founder AS founder, lm.lead_manager_code AS lead_manager, 
        sm.senior_manager_code AS senior_manager, mng.manager_code AS manager, emp.employee_code AS employee
    FROM Company AS cmp
    INNER JOIN Lead_Manager AS lm
        USING(company_code)
    INNER JOIN Senior_Manager AS sm
        USING(company_code)
    INNER JOIN Manager AS mng
        USING(company_code)
    INNER JOIN Employee AS emp
        USING(company_code)
    ORDER BY cmp.company_code
) AS join_path
GROUP BY join_path.company_code, join_path.founder
ORDER BY join_path.company_code;




---- Weather Observation Station 18 - Medium - Aggregation ---
-- Consider P1(a,b)  and P2(c,d) to be two points on a 2D plane.

-- a happens to equal the minimum value in Northern Latitude (LAT_N in STATION).
-- b happens to equal the minimum value in Western Longitude (LONG_W in STATION).
-- c happens to equal the maximum value in Northern Latitude (LAT_N in STATION).
-- d happens to equal the maximum value in Western Longitude (LONG_W in STATION). 

-- Query the Manhattan Distance between points  and  and round it to a scale of  decimal places.
/*
Enter your query here.
In a plane with p1 at (x1, y1) and p2 at (x2, y2), it is |x1 - x2| + |y1 - y2|.
*/
SELECT
    ROUND(ABS(MIN(LAT_N) - MAX(LAT_N)) + ABS(MIN(LONG_W) - MAX(LONG_W)), 4)
FROM Station;




---- Weather Observation Station 19 - Medium - Aggregation ---
-- Consider P1(a,c) and P2(b,d)  to be two points on a 2D plane where (a,b) are the respective minimum and maximum values of Northern Latitude (LAT_N) 
-- and (c,d) are the respective minimum and maximum values of Western Longitude (LONG_W) in STATION.

-- Query the Euclidean Distance between points P1 and P2  and format your answer to display  decimal digits.
-- https://www.cuemath.com/euclidean-distance-formula/ 
SELECT
    ROUND(
        SQRT(
            POWER(MAX(LAT_N) - MIN(LAT_N), 2) + POWER(MAX(LONG_W) - MIN(LONG_W), 2)
        )
    , 4) AS EuclideanDistance
FROM Station;

-- Output
-- 184.1616



--- Weather Observation Station 20 - Medium - Aggregation ----
-- A median is defined as a number separating the higher half of a data set 
-- from the lower half. Query the median of the Northern Latitudes (LAT_N) 
-- from STATION and round your answer to 4 decimal places.
-- https://www.quora.com/How-do-you-find-the-median-from-a-set-of-even-numbers
-- Ex : 16,24,28,38,41,56 
    -- n = 6, n/2 = 3rd value, n/2 + 1 = 4th value
    -- median = 28 + 38 / 2 == 33 (66/2)
/*
Enter your query here.
First we can rank the lat_n if not null, then check if the outcome is even or odd for the 
calculation of the "median"
checked the even check is working by AND ID > 1 (our total count is 499 and each case was triggered)
*/
WITH lat_n_ordered AS (
SELECT
    LAT_N AS northern_latitude,
    RANK() OVER(
        ORDER BY LAT_N
    ) AS latitude_ranking
FROM Station
WHERE LAT_N IS NOT NULL
ORDER BY latitude_ranking
)
SELECT
    CASE 
        WHEN (SELECT COUNT(*) FROM lat_n_ordered) % 2 = 0
        THEN
        ROUND(
            (SELECT northern_latitude FROM lat_n_ordered
                WHERE latitude_ranking = (SELECT COUNT(*) FROM lat_n_ordered) / 2
            ) + 
            (SELECT northern_latitude FROM lat_n_ordered
                WHERE latitude_ranking = (SELECT COUNT(*) FROM lat_n_ordered) / 2 + 1
            ) / 2
        , 4)
        ELSE
        ROUND(
            (SELECT 
                northern_latitude
              FROM lat_n_ordered 
              WHERE latitude_ranking = 
                FLOOR(
                    ((SELECT COUNT(*) FROM lat_n_ordered) / 2) + 1
                ) -- 499 / 2 = 249.5 + 1 = 250.5 (FLOOR == 250)
            )
        , 4)
    END AS median;

--- Output ---
-- 83.8913


--- Now for me I just want to test each case if triggered would be correct, so here's a couple of 
-- concatenated statements for context 

--- Even amount of Numbers
/*
Enter your query here.
First we can rank the lat_n if not null, then check if the outcome is even or odd for the 
calculation of the "median"
checked the even check is working by AND ID > 1 (our total count is 499 and each case was triggered)
*/
WITH lat_n_ordered AS (
SELECT
    LAT_N AS northern_latitude,
    RANK() OVER(
        ORDER BY LAT_N
    ) AS latitude_ranking
FROM Station
WHERE LAT_N IS NOT NULL
AND ID > 1 -- This then turns 499 total to 498 which triggers even
ORDER BY latitude_ranking
)
SELECT
    CASE 
        WHEN (SELECT COUNT(*) FROM lat_n_ordered) % 2 = 0
        THEN
        CONCAT('N items was even with a median of : ' , ROUND(
            (SELECT northern_latitude FROM lat_n_ordered
                WHERE latitude_ranking = (SELECT COUNT(*) FROM lat_n_ordered) / 2
            ) + 
            (SELECT northern_latitude FROM lat_n_ordered
                WHERE latitude_ranking = (SELECT COUNT(*) FROM lat_n_ordered) / 2 + 1
            ) / 2
        , 4))
        ELSE
        CONCAT('N items was odd with a median of : ', ROUND(
            (SELECT 
                northern_latitude
              FROM lat_n_ordered 
              WHERE latitude_ranking = 
                FLOOR(
                    ((SELECT COUNT(*) FROM lat_n_ordered) / 2) + 1
                ) -- 499 / 2 = 249.5 + 1 = 250.5 (FLOOR == 250)
            )
        , 4))
    END AS median;

-- Output --
-- N items was even with a median of : 125.8519



-- Odd Amount of Numbers
/*
Enter your query here.
First we can rank the lat_n if not null, then check if the outcome is even or odd for the 
calculation of the "median"
checked the even check is working by AND ID > 1 (our total count is 499 and each case was triggered)
*/
WITH lat_n_ordered AS (
SELECT
    LAT_N AS northern_latitude,
    RANK() OVER(
        ORDER BY LAT_N
    ) AS latitude_ranking
FROM Station
WHERE LAT_N IS NOT NULL
ORDER BY latitude_ranking
)
SELECT
    CASE 
        WHEN (SELECT COUNT(*) FROM lat_n_ordered) % 2 = 0
        THEN
        CONCAT('N items was even with a median of : ' , ROUND(
            (SELECT northern_latitude FROM lat_n_ordered
                WHERE latitude_ranking = (SELECT COUNT(*) FROM lat_n_ordered) / 2
            ) + 
            (SELECT northern_latitude FROM lat_n_ordered
                WHERE latitude_ranking = (SELECT COUNT(*) FROM lat_n_ordered) / 2 + 1
            ) / 2
        , 4))
        ELSE
        CONCAT('N items was odd with a median of : ', ROUND(
            (SELECT 
                northern_latitude
              FROM lat_n_ordered 
              WHERE latitude_ranking = 
                FLOOR(
                    ((SELECT COUNT(*) FROM lat_n_ordered) / 2) + 1
                ) -- 499 / 2 = 249.5 + 1 = 250.5 (FLOOR == 250)
            )
        , 4))
    END AS median;

-- Output --
-- N items was odd with a median of : 83.8913












