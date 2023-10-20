/*
You are given three tables: Students, Friends and Packages. 
Students contains two columns: ID and Name. 
Friends contains two columns: ID and Friend_ID (ID of the ONLY best friend). 
Packages contains two columns: ID and Salary (offered salary in $ thousands per month).

Write a query to output the names of those students whose best friends got offered a higher salary than them. 
Names must be ordered by the salary amount offered to the best friends. 
    It is guaranteed that no two students got same salary offer.
*/

-- Start 
WITH friend_lookup AS (
SELECT
    f.id AS student_lookup, f.Friend_ID as friend_lookup, s.Name AS friend_name
FROM Friends AS f
LEFT JOIN Students AS s
    ON f.Friend_id = s.ID
)
SELECT 
    st.name AS student_name, st.id AS studenId, fl.friend_name, 
    fl.friend_lookup AS friendId
FROM friend_lookup AS fl
LEFT JOIN Students AS st
    ON fl.student_lookup = st.id
ORDER BY st.id

/*
|Student|StudentId|Friend|FriendId|
|-----|----|----|----|
|Samantha| 1 |Scarlet |14|
|Julia   | 2 |Salma   |15|
|Britney | 3 |Stuart  |18|
|Kristeen| 4 |Aamina  |19|
|Dyana   | 5 |Amina   |20|

-- Here we did a quick series of joins to get the student and friend, easire conceptually in a chain of joins 
*/

-- Now we can join on the same table twice (alias twice) for the different student/friend id on the same row to get the 
-- salary of each on the same row similar to above but just in one query
WITH friend_lookup AS (
SELECT
    f.id AS student_lookup, f.Friend_ID as friend_lookup, s.Name AS friend_name
FROM Friends AS f
LEFT JOIN Students AS s
    ON f.Friend_id = s.ID
), 
student_re_join AS (
SELECT 
    st.name AS student_name, st.id AS studentId, fl.friend_name AS friend_name, 
    fl.friend_lookup AS friendId
FROM friend_lookup AS fl
LEFT JOIN Students AS st
    ON fl.student_lookup = st.id
ORDER BY st.id
),
SELECT 
    srj.student_name, srj.studentId, pck_1.Salary AS student_salary,
    srj.friend_name, srj.friendId, pck_2.Salary AS friend_salary
FROM student_re_join AS srj
LEFT JOIN Packages AS pck_1
    ON srj.studentId = pck_1.id
LEFT JOIN Packages AS pck_2
    ON srj.friendId = pck_2.id
ORDER BY studentId;

/*
|Student|StudentId|student_salary|Friend|FriendId|friend_salary|
|-------|---------|--------------|------|--------|-------------|
|Samantha| 1      |     15.5     |Scarlet |14|      15.1|
|Julia   | 2      |     15.6     |Salma   |15|      17.1|
|Britney | 3      |     16.7     |Stuart  |18|      13.15|
|Kristeen| 4      |     18.8     |Aamina  |19|      33.33|
|Dyana   | 5      |     31.5     |Amina   |20|      221.6|
*/

-- Final Output - We just need the name of student's who best friend have a higher salary sorted by the friend salary in ASC order
WITH friend_lookup AS (
SELECT
    f.id AS student_lookup, f.Friend_ID as friend_lookup, s.Name AS friend_name
FROM Friends AS f
LEFT JOIN Students AS s
    ON f.Friend_id = s.ID
), 
student_re_join AS (
SELECT 
    st.name AS student_name, st.id AS studentId, fl.friend_name AS friend_name, 
    fl.friend_lookup AS friendId
FROM friend_lookup AS fl
LEFT JOIN Students AS st
    ON fl.student_lookup = st.id
ORDER BY st.id
),
full_join_row_detail AS (
SELECT 
    srj.student_name, srj.studentId, pck_1.Salary AS student_salary,
    srj.friend_name, srj.friendId, pck_2.Salary AS friend_salary
FROM student_re_join AS srj
LEFT JOIN Packages AS pck_1
    ON srj.studentId = pck_1.id
LEFT JOIN Packages AS pck_2
    ON srj.friendId = pck_2.id
ORDER BY studentId
)
SELECT 
    student_name
FROM full_join_row_detail
WHERE friend_salary > student_salary
ORDER BY friend_salary;



