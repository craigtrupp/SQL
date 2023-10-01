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



