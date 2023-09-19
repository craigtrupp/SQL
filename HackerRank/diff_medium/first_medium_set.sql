-- The PADS Advanced SELECT in Medium Difficulty
-- Generate the following two result sets:

-- Query an alphabetically ordered list of all names in OCCUPATIONS, immediately followed by the first 
-- letter of each profession as a parenthetical (i.e.: enclosed in parentheses). 
-- For example: AnActorName(A), ADoctorName(D), AProfessorName(P), and ASingerName(S).
-- Query the number of ocurrences of each occupation in OCCUPATIONS. Sort the occurrences in ascending order, 
-- and output them in the following format:
    -- There are a total of [occupation_count] [occupation]s.
-- where [occupation_count] is the number of occurrences of an occupation in OCCUPATIONS and [occupation] is the lowercase occupation name. 
-- If more than one Occupation has the same [occupation_count], they should be ordered alphabetically.
/*
Enter your query here.
*/
-- For some ... f'n reason this name_profs temp_table can't be a CTE and keep the ORDER BY when doing a Union All so made it as a temp table
-- Then was ... missing a case for the longest time ... J'f'n xst
CREATE TEMPORARY TABLE name_profs AS 
(SELECT
    CONCAT(Name, '(', LEFT(Occupation, 1), ')') AS name_profession
FROM Occupations
ORDER BY Name);

WITH doctors AS (
SELECT
    Occupation, COUNT(*) AS count
FROM Occupations
WHERE Occupation = 'Doctor'
GROUP BY Occupation
),
actors AS (
SELECT
    Occupation, COUNT(*) as count
FROM Occupations
WHERE Occupation = 'Actor'
GROUP BY Occupation
),
singers AS (
SELECT
    Occupation, COUNT(*) AS count
FROM Occupations
WHERE Occupation = 'Singer'
GROUP BY Occupation
),
professors AS (
SELECT
    Occupation, COUNT(*) AS count
FROM Occupations
WHERE Occupation = 'Professor'
GROUP BY Occupation
),
profession_counts AS (
SELECT * FROM doctors 
UNION ALL
SELECT * FROM actors
UNION ALL
SELECT * FROM singers
UNION ALL
SELECT * FROM professors
ORDER BY 2, 1
-- Order by Column Designations numeric (2, 1)
),
profession_string AS (
SELECT
    CONCAT('There are a total of ', count, ' ', LOWER(Occupation), 's.') AS prof_strings
FROM profession_counts
)
SELECT * FROM name_profs
UNION ALL
SELECT * FROM profession_string


