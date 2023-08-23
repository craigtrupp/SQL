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

-- 7 Are there any records in your joined table where the month_year value is before the 
-- created_at value from the fresh_segments.interest_map table? 
-- Do you think these values are valid and why? -- See Markdown file for further notest

-- Confirmation of CTE steps to validate the `interest_map.created_at` field is equal to the initial date of metrics pulled for interest_id
WITH cte_join AS (
SELECT
  -- Can grab all columns with the .* usage for a join table output 
  interest_metrics.*,
  interest_map.interest_name,
  interest_map.interest_summary,
  interest_map.created_at,
  interest_map.last_modified
FROM fresh_segments.interest_metrics
INNER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id
WHERE interest_metrics.month_year IS NOT NULL
),
month_year_before_created_at AS (
SELECT 
  interest_id,
  month_year,
  created_at
FROM cte_join
WHERE month_year < created_at
ORDER BY interest_id
),
created_at_trunc AS (
SELECT 
  *,
  DATE_TRUNC('month', created_at) AS created_at_month_trunc
FROM month_year_before_created_at
)
SELECT 
  COUNT(*) 
FROM created_at_trunc 
WHERE month_year < created_at_month_trunc



------------- Section B : Interest Analysis -----------------
-- 1. Which interests have been present in all month_year dates in our dataset?
WITH interest_month_records AS (
SELECT
  DISTINCT interest_id, month_year,
  COUNT(*) AS interest_month_val_present
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL AND interest_id IS NOT NULL
GROUP BY interest_id, month_year
ORDER BY month_year
),
-- We could just do a standard GROUP BY aggregate count here too
interest_id_total_months AS (
SELECT
  DISTINCT interest_id,
  -- Each value here is just one, interesting to see the total still available after the DISTINCT call 
  SUM(interest_month_val_present) OVER (
    PARTITION BY interest_id
  ) AS interest_id_total_months
FROM interest_month_records
)
-- Now we can look at how many unique interest_ids were seen over the 14 month period
SELECT 
  interest_id_total_months AS total_months,
  COUNT(interest_id) AS interest_id_counts
FROM interest_id_total_months
GROUP BY total_months
ORDER BY total_months DESC;

-- 2. Using this same total_months measure - calculate the cumulative percentage 
-- of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
WITH interest_month_records AS (
SELECT
  DISTINCT interest_id, month_year,
  COUNT(*) AS interest_month_val_present
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL AND interest_id IS NOT NULL
GROUP BY interest_id, month_year
ORDER BY month_year
),
-- We could just do a standard GROUP BY aggregate count here too
interest_id_total_months AS (
SELECT
  DISTINCT interest_id,
  -- Each value here is just one, interesting to see the total still available after the DISTINCT call 
  SUM(interest_month_val_present) OVER (
    PARTITION BY interest_id
  ) AS interest_id_total_months
FROM interest_month_records
),
-- 1 more level for cumulative percentages
month_total_distinct_ids_count AS (
SELECT 
  interest_id_total_months AS total_months,
  COUNT(interest_id) AS interest_id_counts
FROM interest_id_total_months
GROUP BY total_months
ORDER BY total_months DESC
)
SELECT
  *,
  -- Already ordered in total_months order
  SUM(interest_id_counts) OVER(
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total,
  -- calculate the running_total as a cumulative percentage
  ROUND(
  100 * SUM(interest_id_counts) OVER(
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )::NUMERIC / SUM(interest_id_counts) OVER()
    , 2) AS cumulative_percentage
FROM month_total_distinct_ids_count;