----- ** The Report ** -----
-- You are given two tables: Students and Grades. Students contains three columns ID, Name and Marks.
-- Ketty gives Eve a task to generate a report containing three columns: Name, Grade and Mark. 
-- Ketty doesn't want the NAMES of those students who received a grade lower than 8. 
-- The report must be in descending order by grade -- i.e. higher grades are entered first. 
-- If there is more than one student with the same grade (8-10) assigned to them, order those particular 
-- students by their name alphabetically. Finally, if the grade is lower than 8, use "NULL" as their name 
-- and list them by their grades in descending order. If there is more than one student with the same grade (1-7)
-- assigned to them, order those particular students by their marks in ascending order.

-- Write a query to help Eve.
-- Students Table --
-- |ID|Name|Marks|
-- |1|Julia|88|
-- |2|Samantha|68|
-- |3|Maria|99|
-- |4|Scarlet|78|
-- |5|Ashley|63|
-- |6|Jane|81|

-- Grades Table --
-- |Grade|Min-Mark|Max-Mark|
-- |1|0|9|
-- |2|10|19|
-- |3|20|29|
-- |4|30|39|
-- |5|40|49|
-- |6|50|59|
-- |7|60|69|
-- |8|70|79|
-- |9|80|89|
-- |10|90|99|

-- Sample Output for Report Request
-- Maria 10 99
-- Jane 9 81
-- Julia 9 88 
-- Scarlet 8 78
-- NULL 7 63
-- NULL 7 68

/*
Enter your query here.
*/
WITH grade_classification AS (
SELECT
    s.Name, g.Grade, s.Marks
FROM Students AS s
INNER JOIN Grades AS g
WHERE s.Marks BETWEEN g.Min_Mark AND g.Max_Mark
ORDER BY g.Grade DESC, s.Name
)
SELECT
    CASE WHEN gc.Grade > 7 THEN gc.Name ELSE 'NULL' END AS Name,
    gc.Grade,
    gc.Marks
FROM grade_classification AS gc;



----- ** Top Competitors (Intmd - JOINs) ** -----
-- Julia just finished conducting a coding contest, and she needs your help assembling the leaderboard! 
-- Write a query to print the respective hacker_id and name of hackers who achieved full scores for 
-- more than one challenge. Order your output in descending order by the total number of challenges in 
-- which the hacker earned a full score. If more than one hacker received full scores in same number of 
-- challenges, then sort them by ascending hacker_id.

-- Note here the version allowed for this challenge is pretty low so we need to use a dervied subquery and can't use CTEs the works
/*
Enter your query here.
*/
-- 
SELECT
    hacker_id, name
FROM 
(
SELECT
    c.challenge_id, c.difficulty_level, d.score AS max_challenge_score, 
    s.hacker_id, h.name, s.score AS hacker_score
FROM Challenges AS c
INNER JOIN Difficulty AS d
    USING(difficulty_level)
INNER JOIN Submissions AS s
    ON s.challenge_id = c.challenge_id
INNER JOIN Hackers AS h
    ON s.hacker_id = h.hacker_id
WHERE d.score = s.score
ORDER BY c.difficulty_level, s.hacker_id
) hacker_max_scores
GROUP BY hacker_id, name
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, hacker_id;



----- ** Ollivander's Inventory (Intmd - JOINs) ** -----
-- Harry Potter and his friends are at Ollivander's with Ron, finally replacing Charlie's old broken wand.
-- Hermione decides the best way to choose is by determining the minimum number of gold galleons 
-- needed to buy each non-evil wand of high power and age. Write a query to print the id, age, coins_needed, 
-- and power of the wands that Ron's interested in, sorted in order of descending power. If more than one 
-- wand has same power, sort the result in order of descending age.
/*
Enter your query here.
*/
SELECT
    w.id AS wand_id, wp.age AS wand_age, w.coins_needed AS galleons_needed, 
    w.power AS wand_power, wp.code AS wp_code, wp.is_evil
FROM Wands AS w 
INNER JOIN Wands_Property AS wp
    USING(code)
WHERE wp.is_evil != 1
ORDER BY w.power DESC, wp.age DESC
LIMIT 15;

-- My output
-- |Wand|Age|Galleons|Power|code|is_evil|
-- 1303 496 6678 10 103 0 
-- 1038 496 4789 10 103 0 
-- 1130 494 9439 10 39 0 
-- 1315 492 4126 10 38 0 
-- 892 492 4345 10 38 0 
-- 9 491 7345 10 108 0 

-- Above isn't quite right, need to only pull one unique wand should the age & power be the same
-- for instance 1303 wand_id not in expected output like mine as it would appear we only want one unique age/power
-- And should there be multiple, we pick the one with the lowest galleons (See age and power for wands 1315 and 892)
-- (1315 - (power:10, age:492, galleons:4126) 892 - (power:10, age:492, galleons:4345))
 
-- Expected Chunk of Output
-- |wand|age|galleons|power|
-- 1038 496 4789 10 
-- 1130 494 9439 10 
-- 1315 492 4126 10 
-- 9 491 7345 10 


--- How'd I'd go about doing it if allowed with the provided sql version
-- SELECT VERSION(); -- 5.7.27-0ubuntu0.18.04.1 (No Ranking Function Allowed)
SELECT
    w.id, w.code, w.coins_needed, w.power, wp.age, wp.is_evil,
    RANK() OVER(
        PARTITION BY w.power, wp.age
        ORDER BY w.coins_needed ASC
    ) AS similar_wand_age_power_ranking
FROM Wands AS w
INNER JOIN Wands_Property AS wp 
    USING(code)
WHERE w.power = 10;


-- Now with a derived/sub-query we can maybe look to use the output from the first query and group by the age and power 
-- and take the min galleons needed (we probably need a few then to group by then take the id from our first subquery)

-- SELECT VERSION(); -- 5.7.27-0ubuntu0.18.04.1 (No Ranking Function Allowed)
SELECT
    mgws.wand_age, mgws.wand_power, mgws.min_galleons
FROM 
    (
    SELECT
        wand_age, wand_power, MIN(galleons_needed) AS min_galleons
    FROM
        (
        SELECT
            w.id AS wand_id, wp.age AS wand_age, w.coins_needed AS galleons_needed, 
            w.power AS wand_power, wp.code AS wp_code, wp.is_evil
        FROM Wands AS w 
        INNER JOIN Wands_Property AS wp
            USING(code)
        WHERE wp.is_evil != 1
        ORDER BY w.power DESC, wp.age DESC
        ) AS jwa
    GROUP BY wand_age, wand_power
    ORDER BY wand_power DESC, wand_age DESC
    ) AS mgws
LIMIT 5

--- Output 
-- 496 10 4789 
-- 494 10 9439 
-- 492 10 4126 
-- 491 10 7345 
-- 483 10 4352 

-- So if we check this against the expected output, we can now see that a join would need to be done
-- from the output of the derived query to get the final features from the two tables to create the expected output
/*
Enter your query here.
*/
-- SELECT VERSION(); -- 5.7.27-0ubuntu0.18.04.1 (No Ranking Function Allowed)
SELECT
    wds.id AS wand_id, mgws.wand_age AS wand_age, 
    mgws.min_galleons AS min_galleons, mgws.wand_power AS wand_power
FROM 
    (
    SELECT
        wand_age, wand_power, MIN(galleons_needed) AS min_galleons
    FROM
        (
        SELECT
            w.id AS wand_id, wp.age AS wand_age, w.coins_needed AS galleons_needed, 
            w.power AS wand_power, wp.code AS wp_code, wp.is_evil
        FROM Wands AS w 
        INNER JOIN Wands_Property AS wp
            USING(code)
        WHERE wp.is_evil != 1
        ORDER BY w.power DESC, wp.age DESC
        ) AS jwa
    GROUP BY wand_age, wand_power
    ORDER BY wand_power DESC, wand_age DESC
    ) AS mgws
INNER JOIN Wands AS wds
    ON mgws.wand_power = wds.power AND mgws.min_galleons = wds.coins_needed
ORDER BY wand_power DESC, wand_age DESC;


    

-- Output
-- 1038 496 4789 10 
-- 774 494 9439 10 
-- 1130 494 9439 10 
-- 1315 492 4126 10 
-- 9 491 7345 10 
-- 858 483 4352 10 
-- 1164 481 9831 10 
-- 1288 464 4952 10 
-- 861 462 8302 10 
-- 412 455 5625 10 

-- Expected
-- 1038 496 4789 10 
-- 1130 494 9439 10 
-- 1315 492 4126 10 
-- 9 491 7345 10 
-- 858 483 4352 10 
-- 1164 481 9831 10 
-- 1288 464 4952 10 
-- 861 462 8302 10 
-- 412 455 5625 10 
-- 996 451 8884 10 

--- ** Well ... now we have a wand with the same age, power, and shared low galleon_price so we're not quite getting the expected output
-- In the criteria I'm not seeing a described tie-breaker for this scenario but the output is expecting the higher id
-- There's about ... 700+ rows of wands, how many tie-breaker scenarios are there (wands of same age, power, and minimum galleon score?)
SELECT 
wand_age, min_galleons, wand_power, COUNT(*) AS unique_f_wnd_output_criteria
FROM (
    SELECT
        wds.id AS wand_id, mgws.wand_age AS wand_age, 
        mgws.min_galleons AS min_galleons, mgws.wand_power AS wand_power
    FROM 
        (
        SELECT
            wand_age, wand_power, MIN(galleons_needed) AS min_galleons
        FROM
            (
            SELECT
                w.id AS wand_id, wp.age AS wand_age, w.coins_needed AS galleons_needed, 
                w.power AS wand_power, wp.code AS wp_code, wp.is_evil
            FROM Wands AS w 
            INNER JOIN Wands_Property AS wp
                USING(code)
            WHERE wp.is_evil != 1
            ORDER BY w.power DESC, wp.age DESC
            ) AS jwa
        GROUP BY wand_age, wand_power
        ORDER BY wand_power DESC, wand_age DESC
        ) AS mgws
    INNER JOIN Wands AS wds
        ON mgws.wand_power = wds.power AND mgws.min_galleons = wds.coins_needed
    ORDER BY wand_power DESC, wand_age DESC
) AS final_wand_query_distinct_check
GROUP BY wand_age, min_galleons, wand_power
ORDER BY unique_f_wnd_output_criteria DESC;

-- Duplicate Rows for Current Criteria (wand_search)
-- 290 7761 7 2 
-- 208 5422 6 2 
-- 438 3185 2 2 
-- 494 9439 10 2 
-- 481 615 9 2 
-- 292 6740 7 2 
-- 381 6740 7 2 
-- 240 9556 9 2 
-- 211 2060 7 2 
-- 443 5967 1 2 
-- 464 9556 9 2 
-- 164 3480 2 2 
-- 483 556 2 2 
-- 414 5869 9 2 
-- 492 2782 2 2 
-- 335 4263 6 2 
-- 292 9241 1 2 
-- 318 520 10 2 
-- 176 653 1 2 
-- 301 3754 6 2 
-- 344 3185 2 2 
-- 343 653 1 2 


