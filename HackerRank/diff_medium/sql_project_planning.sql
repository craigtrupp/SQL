/*

You are given a table, Projects, containing three columns: Task_ID, Start_Date and End_Date. 
It is guaranteed that the difference between the `End_Date` and the `Start_Date` is equal to 1 day for each row in the table.

If the End_Date of the tasks are consecutive, then they are part of the same project. Samantha is interested in finding the total number of different projects completed.

Write a query to output the start and end dates of projects listed by the number of days it took to complete the project in ascending order. 
If there is more than one project that have the same number of completion days, then order by the start date of the project.

Sample Input
|TaskID|StartDate|EndDate|
|-----|------|------|
|1|2015-10-01|2015-10-02|
|2|2015-10-02|2015-10-03|
|3|2015-10-03|2015-10-04|
|4|2015-10-13|2015-10-14|
|5|2015-10-14|2015-10-15|
|6|2015-10-28|2015-10-29|
|7|2015-10-30|2015-10-31|

Sample Output
|StartDate|EndDate|
|------|--------|
|2015-10-28 |2015-10-29|
|2015-10-30 |2015-10-31|
|2015-10-13 |2015-10-15|
|2015-10-01 |2015-10-04|

*/

-- Initial Lag look for subsequent logic 
-- LAG we can spoof the first NULL lag here to be the opening of the window as such
WITH lag_end_dates AS (
SELECT
    Start_Date, End_Date, 
    LAG(End_Date, 1, Start_Date) OVER(ORDER BY Start_Date) AS most_recent_end_date
FROM Projects
ORDER BY Start_Date
)
SELECT * FROM lag_end_dates;

/* So instead of having an opening null lag, we can 
|StartDate| EndDate| RecentEndDate|
|-----------|-----------|----------|
|2015-10-01 |2015-10-02 |2015-10-01|
|2015-10-02 |2015-10-03 |2015-10-02|
|2015-10-03 |2015-10-04 |2015-10-03|
|2015-10-04 |2015-10-05 |2015-10-04|
|2015-10-11 |2015-10-12 |2015-10-05|
|2015-10-12 |2015-10-13 |2015-10-12|
|2015-10-15 |2015-10-16 |2015-10-13|
*/

/* .... So that about did my head in but we can use the unique of the idea of lag/trailing numbers to set unique start and end date rankings */
WITH unique_start_dates_ranked AS (
SELECT
    RANK() OVER (
        ORDER BY Start_date
    ) AS uniq_sd_rank,
    start_date AS new_sd_cmp -- date to use in comparison and case setting
FROM Projects
WHERE Start_Date NOT IN (SELECT End_date FROM projects)
ORDER BY Start_Date
),
unique_end_dates_ranked AS (
SELECT
    RANK() OVER(
        ORDER BY End_date
    ) AS uniq_ed_rank,
    End_date
FROM Projects
WHERE End_Date NOT IN (SELECT Start_Date FROM projects)
)
SELECT * FROM unique_start_dates_ranked
UNION ALL
SELECT * FROM unique_end_dates_ranked

/*
|Rank|Date|
|----|---|
|1 |2015-10-01|
|2 |2015-10-11|
|3 |2015-10-15|
|4 |2015-10-17|
|5 |2015-10-19|
|6 |2015-10-21|
|7 |2015-10-25|
|8 |2015-11-01|
|9 |2015-11-04|
|10 |2015-11-11|
|11 |2015-11-17|
|1 |2015-10-05|
|2 |2015-10-13|
|3 |2015-10-16|
|4 |2015-10-18|
|5 |2015-10-20|
|6 |2015-10-22|
|7 |2015-10-31|
|8 |2015-11-02|
|9 |2015-11-08|
|10 |2015-11-13|
|11 |2015-11-18|

Look at where the ranks reset now for a "head" and "tail" representation of unique start_dates ranked in order calendar wise 
and unique end_dates ranked in order calendar wise  
*/