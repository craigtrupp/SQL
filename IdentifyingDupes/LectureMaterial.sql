-- Measure counts
SELECT 
  measure,
  COUNT(*) AS customer_visits
FROM health.user_logs
GROUP BY measure
ORDER BY COUNT(*) DESC;

-- find the top 10 customers by record count
SELECT 
  id,
  COUNT(*) AS customer_visits
FROM health.user_logs
GROUP BY id
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Inspecting the data where measure_value = 0
SELECT COUNT(*)
FROM health.user_logs
WHERE measure_value = 0;

-- More meausre value digging
SELECT COUNT(DISTINCT measure_value)
FROM health.user_logs
WHERE measure_value <= 1;


SELECT DISTINCT measure_value FROM health.user_logs WHERE measure_value <= 1;

-- Inclue IS NULL type detail
SELECT 
  measure,
  COUNT(*)
FROM health.user_logs
WHERE measure_value = 0 OR measure_value IS NULL
GROUP BY measure
ORDER BY COUNT(*) ASC;

-- All records
SELECT COUNT(*) FROM health.user_logs;

-- SELECT DISTINCT * (This simple query will pull all distinct records from a log and ignore duplicates) - Use in CTE/Subquery (Generally for count purposes)!
-- Only way to get duplicate rows is through either CTE or Subquery as SELECT COUNT(DISTINCT *) FROM table; // is not allowed/accepted by SQL 

-- CTE for COUNT of distinct row entries in health.user_logs
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT COUNT(*)
FROM deduped_logs;

-- Subquery for COUNT of distinct row entries in health.user_logs
SELECT COUNT(*)
FROM (
  SELECT DISTINCT *
  FROM health.user_logs
) AS subquery;

-- PERFORMING A LIKE DISTINCT (UNIQUE GROUP BY columns) This is the exact same row return as the COUNT(distinct * ) type subquery or cte count return - 31,004 rows
-- SUM not COUNT as COUNT is just grabbing rows as opposed to the record_count as the sum is more than 1 on a count your doing in a summation
WITH duplicate_data AS (
SELECT 
  id, log_date, measure, measure_value, systolic, diastolic, COUNT(*) AS record_count
FROM health.user_logs
GROUP BY id, log_date, measure, measure_value, systolic, diastolic) -- Then look per id in user_logs for a count with a sum on the record_count
SELECT 
  id,
  SUM(record_count) as total_id_records
FROM duplicate_data
WHERE record_count > 1
GROUP BY id
ORDER BY total_id_records DESC;

-- Only find Duplicates
SELECT id, log_date, measure, measure_value, systolic, diastolic, COUNT(*) AS record_counts
FROM health.user_logs
GROUP BY id, log_date, measure, measure_value, systolic, diastolic
HAVING COUNT(*) > 1;

