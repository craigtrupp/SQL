-------------------- `A. Data Exploration and Cleansing`---------------------
-- 1. Update Text Column to Date 
-- Check Types
SELECT
  column_name, data_type
FROM information_schema.columns
WHERE table_name = 'interest_metrics' AND table_schema = 'fresh_segments';

-- idea of the column mutation setting
SELECT
  TO_DATE(month_year, 'MM-YYYY'),
  month_year
FROM fresh_segments.interest_metrics
LIMIT 5;

-- Update 
UPDATE fresh_segments.interest_metrics
SET month_year = TO_DATE(month_year, 'MM-YYYY');

-- DML Required to update Schema
ALTER TABLE fresh_segments.interest_metrics
ALTER month_year TYPE DATE USING month_year::DATE;

-- Similarly call the information schema at the beginning of the question to validate 
-- the output and column being updated

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year 
-- value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT
  DATE_PART('Month', month_year) AS Month_Extract,
  month_year AS month_column,
  COUNT(*) AS monthly_record_count
FROM fresh_segments.interest_metrics
GROUP BY Month_Extract, month_column
-- Can use or month_extract to group by months of different years
-- for comparisson which a normal desc on the month_column wouldn't allow
ORDER BY Month_Extract DESC;


-- 3. (This was a null handling value without a query (unless you wanted to delete null which we can just filter out instead))

-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but 
-- not in the fresh_segments.interest_map table? What about the other way around?

-- Full Outer Join Approach
SELECT
  COUNT(interest_metrics.interest_id) AS all_interest_metric,
  COUNT(interest_map.id) AS all_interest_map,
  COUNT(CASE WHEN interest_map.id IS NULL THEN interest_metrics.interest_id ELSE NULL END) AS not_in_map,
  COUNT(CASE WHEN interest_metrics.interest_id IS NULL THEN interest_map.id ELSE NULL END)  AS not_in_metrics
FROM fresh_segments.interest_metrics
FULL OUTER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id;

-- Anti Join (A bit easier for my understanding)
SELECT 
(
  SELECT
    COUNT(id)
  FROM fresh_segments.interest_map AS i_map 
  WHERE NOT EXISTS (
    SELECT
      1
    FROM fresh_segments.interest_metrics AS i_metrics 
    WHERE i_metrics.interest_id = i_map.id
  ) 
) AS interest_map_id_count_unique,
(
  SELECT
    COUNT(interest_id)
  FROM fresh_segments.interest_metrics AS i_metrics
  WHERE NOT EXISTS (
    SELECT
      1
    FROM fresh_segments.interest_map AS i_map 
    WHERE i_map.id = i_metrics.interest_id
  ) 
) AS interest_metrics_id_count_unique

-- 5 Summarise the id values in the fresh_segments.interest_map by its total record count in this table
WITH interest_map_id_row_counts AS (
SELECT
  id,
  COUNT(*) AS id_rows
FROM fresh_segments.interest_map
GROUP BY id
),
record_counts AS (
SELECT
  -- group by the counts from previous query
  id_rows AS id_record_counts,
  COUNT(*) AS total_ids_w_shared_recourd_count
FROM interest_map_id_row_counts
GROUP BY id_record_counts
ORDER BY total_ids_w_shared_recourd_count DESC
)
SELECT * FROM record_counts;

-- 6 (Explanation on Join type) - Review Markdown for Question