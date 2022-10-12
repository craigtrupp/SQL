-- 1. Highest Duplicate: WWhich id value has the most number of duplicate records in the health.user_logs table?

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  id,
  SUM(frequency) AS total_user_duplicates
FROM groupby_counts
WHERE frequency > 1
GROUP BY id
ORDER BY total_user_duplicates DESC
LIMIT 1;

-- |id|total_user_duplicates|
-- |054250c692e07a9fa9e62e345231df4b54ff435d|17279|

-- Note that SUM() is needed when querying the CTE as the frequency value is greater than 1 what we're looking for, A COUNT() would just return the user with the most duplicate rows (not how many times they had been duplicated!)

-- 2. Which log_date value had the most duplicate records after removing the max duplicate id value from question 1? : Second Highest Duplicate

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  log_date,
  SUM(frequency) AS total_duplicate_logdates
FROM groupby_counts
WHERE frequency > 1
AND id <> '054250c692e07a9fa9e62e345231df4b54ff435d'
GROUP BY log_date
ORDER BY total_duplicate_logdates DESC
LIMIT 3;

-- |log_date|total_duplicate_logdates|
-- |:------|:------|
-- |2019-12-11|55|
-- |2019-12-10|22|
-- |2020-04-11|20|

-- Exclude ID value from max duplicate row returned from first challenge (line 60 of query from CTE provided dupes). GroupBy log_date and SUM(frequency) for total dupes for date


-- 3. Which measure_value had the most occurences in the health.user_logs value when measure = 'weight'? : Highest Occuring Value

SELECT
  ROUND(measure_value,2),
  COUNT(*) AS measure_value_occurences
FROM health.user_logs
WHERE measure = 'weight'
GROUP BY measure_value
ORDER BY measure_value_occurences DESC
LIMIT 3;

-- |round|measure_value_occurences|
-- |:------|:------|
-- |68.49|109|
-- |67.59|107|
-- |62.60|44|

-- Only querying the health.user_logs table directly, not looking for duplicates from the groupby expression

-- 4. How many single duplicated rows exist when measure = 'blood_pressure' in the health.user_logs? 
-- How about the total number of duplicate records in the same table?

-- First, we just need to perform a COUNT on a query to the CTE for the blood_pressure & frequency > 1 to see how many dupe rows
-- Next, we need to use SUM on the frequency of the same query to see for those single duplicate rows, how many times they were duplicated

WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT 
  COUNT(*) AS unique_single_dupe_rows_condition,
  SUM(frequency) AS sum_dupe_rows_frequency
FROM groupby_counts
WHERE measure = 'blood_pressure'
AND frequency > 1;


-- |unique_single_dupe_rows_condition|sum_dupe_rows_frequency|
-- |:------|:------|
-- |147|301|




-- 5. What percentage of records measure_value = 0 when measure = 'blood_pressure' in the health.user_logs table? 
-- How many records are there also for this same condition?

-- CTE is able to group by the different measure_values for the observed condition (measure = 'blood_pressure')
-- SUM(COUNT(*)) OVER() grabs the total count of all rows that equal the condition that have different measure_values but are blood_pressure
-- Can query CTE to then get the measure_value = 0 and get the percentage using aliases from the CTE

WITH all_measure_values AS (
  SELECT
    measure_value,
    COUNT(*) AS total_records,
    SUM(COUNT(*)) OVER () AS overall_total
  FROM health.user_logs
  WHERE measure = 'blood_pressure'
  GROUP BY measure_value
)

SELECT
  total_records AS condition_total_records,
  ROUND(100 * total_records::numeric / overall_total, 2) AS percent_condition,
  overall_total AS total_conditional_rows
FROM all_measure_values
WHERE measure_value = 0;

-- |condition_total_records|percent_condition| total_conditional_rows|
-- |:------|:------|:-----|
-- |562|23.25|2417


-- 6. What percentage of records are duplicates in the health.user_logs table?

-- My answer below (others below that!)
WITH unique_rows AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  COUNT(*) AS unique_rows,
  SUM(frequency) AS table_total_rows,
  ROUND(100 * (SUM(frequency) - COUNT(*))::numeric / SUM(frequency), 2) AS percent_dupes
FROM unique_rows 

-- |unique_rows|table_total_rows|percent_dupes|
-- |:------|:------|:-----|
-- |31004|43891|29.36



WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  -- Need to subtract 1 from the frequency to count actual duplicates!
  -- Also don't forget about the integer floor division!
  ROUND(
    100 * SUM(CASE
        WHEN frequency > 1 THEN frequency - 1
        ELSE 0 END
    )::NUMERIC / SUM(frequency),
    2
  ) AS duplicate_percentage
FROM groupby_counts;


-- More of my approach above for this subquery type and much easier way to get all distinct rows lol
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT
  ROUND(
    100 * (
      (SELECT COUNT(*) FROM health.user_logs) -
      (SELECT COUNT(*) FROM deduped_logs)
    )::NUMERIC /
    (SELECT COUNT(*) FROM health.user_logs),
    2
  ) AS duplicate_percentage;



