/*
You did such a great job helping Julia with her last coding contest challenge that she wants you to work on this one, too!

The total score of a hacker is the sum of their maximum scores for all of the challenges. 
Write a query to print the hacker_id, name, and total score of the hackers ordered by the descending score. 
If more than one hacker achieved the same total score, then sort the result by ascending hacker_id. Exclude all hackers with a total score of 0 from your result.
*/
-- SELECT VERSION(); -- 5.7.27-0ubuntu0.18.04.1  ... no CTE's or ranking so I guess dervied/subquery the only way
SELECT 
    hacker_id, name, SUM(max_challenge_score) AS total_max_challenge_scores
FROM (
    SELECT
        s.hacker_id, h.name, s.challenge_id, MAX(s.score) AS max_challenge_score
    FROM Submissions AS s
    LEFT JOIN Hackers AS h
        USING(hacker_id)
    GROUP BY s.hacker_id, h.name, s.challenge_id
    HAVING MAX(s.score) > 0
    ORDER BY max_challenge_score DESC
) AS max_hacker_challenge_score
GROUP BY hacker_id, name
ORDER BY total_max_challenge_scores DESC, hacker_id;