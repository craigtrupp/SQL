-- ** The PADS Advanced SELECT in Medium Difficulty ** 
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

--- Output ----
-- Aamina(D) 
-- Ashley(P) 
-- Belvet(P) 
-- Britney(P) 
-- Christeen(S) 
-- Eve(A) 
-- Jane(S) 
-- Jennifer(A) 
-- Jenny(S) 
-- Julia(D) 
-- Ketty(A) 
-- Kristeen(S) 
-- Maria(P) 
-- Meera(P) 
-- Naomi(P) 
-- Priya(D) 
-- Priyanka(P) 
-- Samantha(A) 
-- There are a total of 3 doctors. 
-- There are a total of 4 actors. 
-- There are a total of 4 singers. 
-- There are a total of 7 professors.

-- Quick Review
-- Name Profs : This is simply creating the first output above for the Name and the first letter of their Occupation
-- Profession count CTE is taking the group by counts for each profession and stacking vertically
-- before  using the stacked counts (Occupation - first column, count - second column) to Order (by least amount to most for profession and then by the Occupation alphabetically if a tie)
-- to create the profession_string CTE for a single column that we can then stack with the name of each individual's occupation



-- ** Occupations - Difficulty Medium - Advanced Select Subtopic ** --
-- Pivot the Occupation column in OCCUPATIONS so that each Name is sorted alphabetically and displayed 
-- underneath its corresponding Occupation. The output column headers should be Doctor, Professor, Singer, and Actor, respectively.

-- Note: Print NULL when there are no more names corresponding to an occupation.

-- Input Format

-- The OCCUPATIONS table is described as follows:

-- Same table as previous 
    -- Trick here is doing a UNION that has the same column lengths for Occupations that don't have the same count

-- Expected Output - Columns
-- |Doctor|Prof|Singer|Actor|
-- Aamina Ashley Christeen Eve 
-- Julia Belvet Jane Jennifer 
-- Priya Britney Jenny Ketty 
-- NULL Maria Kristeen Samantha 
-- NULL Meera NULL NULL 
-- NULL Naomi NULL NULL 
-- NULL Priyanka NULL NULL

-- Current Table Values
-- |Name|Occupation|
-- Ashley Professor
-- Samantha Actor
-- Julia Doctor
-- Britney Professor
-- Maria Professor
-- Meera Professor
-- Priya Doctor
-- Priyanka Professor
-- Jennifer Actor
-- Ketty Actor
-- Belvet Professor
-- Naomi Professor
-- Jane Singer
-- Jenny Singer
-- Kristeen Singer
-- Christeen Singer
-- Eve Actor
-- Aamina Doctor

WITH row_occupation_setting AS (
SELECT
    CASE WHEN Occupation = 'Doctor' THEN Name END AS Doctor,
    CASE WHEN Occupation = 'Professor' THEN Name END AS Professor,
    CASE WHEN Occupation = 'Singer' THEN Name END AS Singer,
    CASE WHEN Occupation = 'Actor' THEN Name END As Actor,
    ROW_NUMBER() OVER(
        PARTITION BY Occupation
        ORDER BY Name
    )
FROM Occupations
)
SELECT * FROM row_occupation_setting WHERE Doctor IS NOT NULL;

-- First Step here is Essentially ranking the Occupations by their name
-- Aamina NULL NULL NULL 1
-- Julia NULL NULL NULL 2
-- Priya NULL NULL NULL 3

--- Now we can use a GROUPBY but if we don't include an agg function (like min/max) - we can't avoid an error to group the columns by their ranking
-- Now using Coalesce can use the MIN/MAX on the Name value we pulled for each profession
SELECT MIN('Samantha'), MAX('Samantha'); -- Samantha Samantha (OUTPUT IS THE SAME)


-- Beacuse Without we get
-- ERROR 1055 (42000) at line 5: Expression #1 of SELECT list is not in GROUP BY clause 
-- and contains nonaggregated column 'row_occupation_setting.Doctor' which is not 
-- functionally dependent on columns in GROUP BY clause; this is incompatible with 
-- sql_mode=only_full_group_by

WITH row_occupation_setting AS (
SELECT
    CASE WHEN Occupation = 'Doctor' THEN Name END AS Doctor,
    CASE WHEN Occupation = 'Professor' THEN Name END AS Professor,
    CASE WHEN Occupation = 'Singer' THEN Name END AS Singer,
    CASE WHEN Occupation = 'Actor' THEN Name END As Actor,
    ROW_NUMBER() OVER(
        PARTITION BY Occupation
        ORDER BY Name
    ) AS occupation_name_srt_rank
FROM Occupations
)
SELECT
    COALESCE(Doctor, 'NULL') AS Doctor,
    COALESCE(Professor, 'NULL') AS Professor
FROM row_occupation_setting
GROUP BY occupation_name_srt_rank;


-- So no we can solve and use the Coalesce to set to null as needed
WITH occupation_name_rank_rows AS (
SELECT
    CASE WHEN Occupation = 'Doctor' THEN Name END AS Doctor,
    CASE WHEN Occupation = 'Professor' THEN Name END AS Professor,
    CASE WHEN Occupation = 'Singer' THEN Name END AS Singer,
    CASE WHEN Occupation = 'Actor' THEN Name END AS Actor,
    RANK() OVER(
        PARTITION BY Occupation
        ORDER BY Name
    ) AS occupation_name_rank
FROM Occupations
)
SELECT
    COALESCE(MIN(Doctor), NULL) AS Doctor,
    COALESCE(MIN(Professor), NULL) AS Professor,
    COALESCE(MIN(Singer), NULL) AS Singer,
    COALESCE(MIN(Actor), NULL) AS Actor
FROM occupation_name_rank_rows
GROUP BY occupation_name_rank;


---- Output ----
-- Aamina Ashley Christeen Eve
-- Julia Belvet Jane Jennifer
-- Priya Britney Jenny Ketty
-- NULL Maria Kristeen Samantha
-- NULL Meera NULL NULL
-- NULL Naomi NULL NULL
-- NULL Priyanka NULL NULL