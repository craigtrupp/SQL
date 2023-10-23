/*
Two pairs (X1, Y1) and (X2, Y2) are said to be symmetric pairs if X1 = Y2 and X2 = Y1.

Write a query to output all such symmetric pairs in ascending order by the value of X. List the rows such that X1 ≤ Y1.

Symmetric Pairs
2 24 
4 22 
5 21 
6 20 
8 18 
9 17 
11 15
13 13

*/
-- First Chunk
WITH unioned AS (
SELECT
    f1.X AS X, f1.Y AS Y
FROM Functions AS f1
UNION ALL
SELECT
    f2.Y AS X, f2.X AS Y
FROM Functions AS f2
),
coordinate_unit_counts AS (
SELECT 
    X, Y, COUNT(*) AS coordinate_counts 
FROM unioned
GROUP BY 1, 2
ORDER BY coordinate_counts DESC
)
SELECT * 
FROM coordinate_unit_counts
WHERE coordinate_counts > 2 OR (X != Y AND coordinate_counts >= 2);

/*
The first Union Statement and subsequent group by statement is our way of weeding out simple pairs in a self-join
And getting unique pairs which from a self-join we'd want that (So think we are grouping from a unioned self-join in which we've just swapped the position of the X,y coordinates so we can group by column)


13 13 4
18 8 2
15 11 2
4 22 2
17 9 2
9 17 2
24 2 2
20 6 2
2 24 2
5 21 2
22 4 2
6 20 2
8 18 2
21 5 2
11 15 2
*/