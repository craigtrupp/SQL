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

-- Still just kinda playing with recursive ideas here
    -- The best way for OP to tell if n is prime is just to try to divide it by all numbers up to the ceiling of its square root

-- Below is a three table column that has (n, index, ceil_sq_root for n)
CREATE TABLE int_sequence
WITH RECURSIVE sequence (n, x, sq_c) AS (
    SELECT 2, 1, CEIL(SQRT(2)) -- offset of 0, 1 for prime numbers
    UNION ALL
    SELECT n + 1, x + 1, CEIL(SQRT(n + 1)) FROM sequence WHERE n + 1 <= 10
)
SELECT n, x, sq_c FROM sequence;

SELECT * FROM int_sequence;

/*
|N|idx|s q_c(n)|
|2 | 1 | 2|
|3 | 2 | 2|
|4 | 3 | 2|
|5 | 4 | 3|
|6 | 5 | 3|
|7 | 6 | 3|
|8 | 7 | 3|
|9 | 8 | 3|
|10| 9 | 4|
*/


-- Another Route
with recursive all_numbers(n) AS  
(
    SELECT 1 
    UNION ALL 
    SELECT n+1 
    FROM all_numbers 
    WHERE n < 1000
)

SELECT GROUP_CONCAT(all_numbers.n SEPARATOR '&') 
FROM all_numbers 
WHERE NOT EXISTS
    (
        SELECT n 
        FROM all_numbers AS factor 
        WHERE factor.n > 1 AND factor.n < all_numbers.n AND 
            all_numbers.n % factor.n = 0
    ) 
    AND all_numbers.n > 1
;