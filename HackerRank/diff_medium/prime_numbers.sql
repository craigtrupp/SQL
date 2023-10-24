/*
Write a query to print all prime numbers less than or equal to 1000. 
Print your result on a single line, and use the ampersand (&) character as your separator (instead of a space).

For example, the output for all prime numbers <= 10 would be:
    * 2&3&5&7
*/

-- Start with Recrusive sequence as MySQL doesn't have a like generate_series
CREATE TABLE int_sequence
WITH RECURSIVE sequence (n) AS (
    SELECT 0
    UNION ALL
    SELECT n + 1 FROM sequence WHERE n + 1 <= 10
)
SELECT n FROM sequence;

SELECT * FROM int_sequence;

/*
-- Output 
0
1
2
3
4
5
6
7
8
9
10
*/