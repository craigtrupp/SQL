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
