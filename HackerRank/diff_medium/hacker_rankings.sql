-- **** Challenges - Joins **** 
/*
Julia asked her students to create some coding challenges. Write a query to print the hacker_id, name, and the total number of challenges created by each student. 
Sort your results by the total number of challenges in descending order. If more than one student created the same number of challenges, then sort the result by hacker_id. 
If more than one student created the same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.
*/

/*Sample Output
|HackerID|  Name    |   ChallengesCreated|
|12299 |    Rose     |   6      |
|34856 |    Angela   |   6      |
|79345 |    Frank    |   4      |
|80491 |    Patrick  |   3      |
|81041 |    Lisa     |   1      |
*/

-- Initial Query to Start Challenge
SELECT
    c.hacker_id, h.name, COUNT(*) AS challenges_created,
    DENSE_RANK() OVER(
        ORDER BY COUNT(*) DESC
    ) AS challenges_created_rankings
FROM Challenges AS c
LEFT JOIN Hackers AS h
    USING(hacker_id)
GROUP BY c.hacker_id, h.name
ORDER BY COUNT(*) DESC, c.hacker_id;

/*
|Hacker|name|challenge_count|rank|
|5120 |Julia        |50 |1|
|18425| Anna        |50 |1|
|20023| Brian       |50 |1|
|33625| Jason       |50 |1|
|41805| Benjamin    |50 |1|
|52462| Nicholas    |50 |1|
|64036| Craig       |50 |1|
|69471| Michelle    |50 |1|
|77173| Mildred     |50 |1|
|94278| Dennis      |50 |1|
|96009| Russell     |50 |1|
|96716| Emily       |50 |1|
|72866| Eugene      |42 |2|
|37068| Patrick     |41 |3|
*/

-- Alright so .. finally get it, essentially any value that isn't a top rank and has a student total of more than 1 for the challenges created wouldn't be in the final output 
-- So for below (any) of the sudents that completed 12 chalenges (so rank of 28) would be excluded as there's more than 1 student that's not a top rank - they only want unique rankings after the top ranking
/*
|Hacker|name|challenge_count|rank|
31426 Carlos 15 26
95010 Victor 14 27
5734 James 12 28
21813 Gerald 12 28
27277 Sandra 12 28
29542 Janet 12 28
31465 Ryan 12 28
38035 Doris 12 28
52050 Steve 12 28
55727 Randy 12 28
58209 Nicole 12 28
59455 Virginia 12 28
27071 Gerald 10 29
90267 Edward 9 30
*/

-- A little deeper
WITH hacker_CTE AS (
SELECT
    c.hacker_id, h.name, COUNT(*) AS challenges_created,
    DENSE_RANK() OVER(
        ORDER BY COUNT(*) DESC
    ) AS challenges_created_rankings
FROM Challenges AS c
LEFT JOIN Hackers AS h
    USING(hacker_id)
GROUP BY c.hacker_id, h.name
ORDER BY COUNT(*) DESC, c.hacker_id
),
rankings_grouped AS (
SELECT 
    challenges_created_rankings, COUNT(*) AS rank_count
FROM hacker_CTE
GROUP BY challenges_created_rankings
ORDER BY challenges_created_rankings
)
SELECT 
    hcte.hacker_id, hcte.name, rnk_grpd.challenges_created_rankings, rnk_grpd.rank_count
FROM hacker_CTE AS hcte
INNER JOIN rankings_grouped AS rnk_grpd
    ON hcte.challenges_created_rankings = rnk_grpd.challenges_created_rankings
ORDER BY rnk_grpd.challenges_created_rankings, hcte.hacker_id;

/* - All users (same subset as above with the rank of 28 would be eliminated as that rank has a non unique != 1 number of users who created that many challenges)
|HackerId|Name|Rank|Rank_Count|
|31426| Carlos  |26 |1|
|95010| Victor  |27 |1|
|5734 |James    |28 |10|
|21813| Gerald  |28 |10|
|27277| Sandra  |28 |10|
|29542| Janet   |28 |10|
|31465| Ryan    |28 |10|
|38035| Doris   |28 |10|
|52050| Steve   |28 |10|
|55727| Randy   |28 |10|
|58209| Nicole  |28 |10|
|59455| Virginia|28 |10|
|27071| Gerald  |29 |1|
|90267| Edward  |30 |1|
*/