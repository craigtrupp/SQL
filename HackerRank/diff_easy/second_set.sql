/*
Query the Name of any student in STUDENTS who scored higher than  Marks. Order your output by 
the last three characters of each name. If two or more students both have names ending in the same 
last three characters (i.e.: Bobby, Robby, etc.),
secondary sort them by ascending ID.
*/
SELECT
    Name
FROM STUDENTS
WHERE Marks > 75
ORDER BY RIGHT(Name, 3), ID;

/*
Write a query that prints a list of employee names (i.e.: the name attribute) for employees 
in Employee having a salary greater than  per month who have been employees for less than  months. 
Sort your result by ascending employee_id.
*/
SELECT
    name
FROM Employee
WHERE salary > 2000 AND months < 10
ORDER BY employee_id;

/*
Write a query identifying the type of each record in the TRIANGLES table using its three side lengths. Output one of the following statements for each record in the table:
 -- Side Note Challenge in MySQL which doesn't offer an array_agg type way of adding all sides of the triangel to one column data type

Equilateral: It's a triangle with  sides of equal length.
Isosceles: It's a triangle with  sides of equal length.
Scalene: It's a triangle with  sides of differing lengths.
Not A Triangle: The given values of A, B, and C don't form a triangle.
    - Values in the tuple (13,14,30) cannot form a triangle because the combined value of sides  A and B  is not larger than that of side C.
### Table Details
|A|B|C|
|20|20|23| - First Row

-- Output
|Isoceles| - They just want the 15 rows triangle type as the output
*/
WITH triangle_check AS (
SELECT
    *,
    CASE
        WHEN A + B > C THEN 'Triangle'
        ELSE 'Not A Triangle'
    END AS Tri_check
FROM TRIANGLES
)
SELECT
    CASE 
        WHEN a = b AND a = c AND Tri_check != 'Not A Triangle'
            THEN 'Equilateral'
        WHEN a = b AND a != c AND Tri_check != 'Not A Triangle'
            THEN 'Isosceles'
        WHEN a = c AND a != b AND Tri_check != 'Not A Triangle'
            THEN 'Isosceles'
        WHEN b = c AND b != a AND Tri_check != 'Not A Triangle'
            THEN 'Isosceles'
        WHEN Tri_check = 'Triangle' AND (a != b AND a != c AND c != b)
            THEN 'Scalene'
        ELSE Tri_check
    END AS triangle_type
FROM triangle_check;
