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

-- 3 If we were to remove all interest_id values which are lower than the total_months 
-- value we found in the previous question - how many total data points would we be removing?
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
  -- Each value here is just one, interesting to see the total within window still available after the DISTINCT call 
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
WHERE interest_id_total_months <= 5 -- for question #3 
GROUP BY total_months
ORDER BY total_months DESC
),
rows_level_data_points_mock_remove AS (
SELECT 
  *,
  total_months * interest_id_counts AS data_rows_removed_from_level,
  SUM(total_months * interest_id_counts) OVER() AS total_rows_removed
FROM month_total_distinct_ids_count
)
SELECT * FROM rows_level_data_points_mock_remove;


-- 5 If we include all of our interests regardless of their counts - how many unique interests are there for each month?
WITH months_data_joined AS (
SELECT
  metrics.month_year AS metric_mth_year,
  map.interest_name AS map_name,
  map.id AS map_id,
  metrics.interest_id AS metrics_id
FROM fresh_segments.interest_metrics AS metrics 
INNER JOIN fresh_segments.interest_map AS map 
  ON metrics.interest_id = map.id
WHERE metrics.month_year IS NOT NULL
ORDER BY metric_mth_year
)
SELECT
  metric_mth_year,
  COUNT(DISTINCT map_name) AS month_unique_interests
FROM months_data_joined
GROUP BY metric_mth_year
ORDER BY month_unique_interests DESC;

---------------------- End of Section B ----------------------





---------------------- C. Segment Analysis -------------------
-- 1. Top 10 & Bottom 10 Composition Interest Ranked
WITH top_composition_interests AS (
SELECT
  interest_id,
  month_year,
  composition,
  'Highest' AS composition_segment
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL
ORDER BY composition DESC 
LIMIT 10
),
lowest_compositions AS (
SELECT
  interest_id,
  month_year,
  composition,
  'Lowest' AS composition_segment
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL
ORDER BY composition  
LIMIT 10
),
segments AS (
SELECT * FROM top_composition_interests
UNION
SELECT * FROM lowest_compositions
)
SELECT 
  *,
  CASE
    WHEN composition_segment = 'Highest'
      THEN 
      DENSE_RANK() OVER(
        PARTITION BY composition_segment
        ORDER BY composition DESC
      )
    WHEN composition_segment = 'Lowest'
      THEN
      DENSE_RANK() OVER(
        PARTITION BY composition_segment
        ORDER BY composition
      )
  END AS segment_ranking
FROM segments
ORDER BY composition_segment, segment_ranking

-- Secondary Query for distinct interest_id type top/bottom values for Question # 1 for Section C
WITH ranked_composition_values AS (
SELECT
  interest_id,
  month_year,
  composition,
  -- As we're only taking a top/bottom value per interest_id value 
  -- (don't want repeating interest_id values we need to give each composition a ranking regardless if they're tied)
  ROW_NUMBER() OVER(
    PARTITION BY interest_id
    ORDER BY composition DESC
  ) AS id_composition_rankings
FROM fresh_segments.interest_metrics
WHERE month_year IS NOT NULL
ORDER BY interest_id, id_composition_rankings 
),
top_bottom_intid_values AS (
SELECT
  interest_id,
  MIN(id_composition_rankings) AS top_join_value,
  MAX(id_composition_rankings) AS bottom_join_value
FROM ranked_composition_values
GROUP BY interest_id
),
joined_ctes AS (
SELECT
  cte_1.interest_id,
  cte_1.month_year,
  cte_1.composition,
  cte_1.id_composition_rankings
FROM top_bottom_intid_values AS cte_2
INNER JOIN ranked_composition_values AS cte_1
  ON cte_2.interest_id = cte_1.interest_id
  AND (cte_2.top_join_value = cte_1.id_composition_rankings OR cte_2.bottom_join_value = cte_1.id_composition_rankings)
ORDER BY cte_1.interest_id, cte_1.id_composition_rankings
),
unioned_top_bottom AS (
-- Each query below to be unioned (for top/bottom 10 w/limit must be passed in parentheses to be unioned)
(SELECT
  interest_id, month_year, composition, 
  'Higher Segment' AS composition_segment
FROM joined_ctes
ORDER BY composition DESC 
LIMIT 10)
UNION ALL
(SELECT
  interest_id, month_year, composition, 
  'Lower Segment' AS composition_segment
FROM joined_ctes
ORDER BY composition  
LIMIT 10)
)
SELECT 
  union_cte.interest_id, map.interest_name, union_cte.month_year,
  union_cte.composition, union_cte.composition_segment
FROM unioned_top_bottom AS union_cte
INNER JOIN fresh_segments.interest_map AS map 
  ON union_cte.interest_id = map.id
ORDER BY union_cte.composition_segment, union_cte.composition DESC;


-- 2 Which 5 interests had the lowest average ranking value?
SELECT
  metrics.interest_id, map.interest_name,
  ROUND(AVG(ranking), 2) AS interest_avg_ranking,
  COUNT(*) AS interest_record_count
FROM fresh_segments.interest_metrics AS metrics 
INNER JOIN fresh_segments.interest_map AS map 
  ON map.id = metrics.interest_id
GROUP BY interest_id, interest_name
ORDER BY interest_avg_ranking


-- 3 Which 5 interests had the largest standard deviation in their percentile_ranking 
WITH std_percranking_ranks AS (
SELECT
  map.id, map.interest_name,
  STDDEV(metrics.percentile_ranking)::NUMERIC(10, 2) AS interest_stddev,
  RANK() OVER(
  -- This resulting rank is the grouped by percentile ranking for each interest_id (essentiall just the above aggregate)
    ORDER BY STDDEV(metrics.percentile_ranking)::NUMERIC(10, 2) DESC
  ) AS interest_id_stddev_rankings,
  COUNT(*) AS interest_metrics_records,
  MAX(metrics.percentile_ranking) AS max_percentile,
  MIN(metrics.percentile_ranking) AS min_percentile,
  ROUND(AVG(metrics.percentile_ranking)::NUMERIC, 2) AS avg_percentile
FROM fresh_segments.interest_metrics AS metrics 
INNER JOIN fresh_segments.interest_map AS map 
  ON metrics.interest_id = map.id
WHERE metrics.month_year IS NOT NULL 
-- set condition to only rank interest_id with at least 5 readings in the metrics table
AND map.id IN 
  (
    SELECT interest_id 
    FROM fresh_segments.interest_metrics 
    GROUP BY interest_id 
    HAVING COUNT(interest_id) >= 5
  )
GROUP BY map.id, map.interest_name
)
SELECT * 
FROM std_percranking_ranks 
WHERE interest_id_stddev_rankings <= 5
ORDER BY interest_id_stddev_rankings;

-- 4 For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest 
-- and its corresponding year_month value? Can you describe what is happening for these 5 interests?
WITH percentile_rankings AS (
SELECT  
  map.id, map.interest_name, metrics.month_year, metrics.composition, metrics.ranking AS data_set_ranking, metrics.percentile_ranking,
  RANK() OVER (
    PARTITION BY map.id
    ORDER BY metrics.percentile_ranking DESC
  ) AS id_pr_rank,
  RANK() OVER (
    PARTITION BY map.id
    ORDER BY metrics.composition DESC
  ) AS id_comp_rank,
  MAX(metrics.percentile_ranking) OVER (
    PARTITION BY map.id
  ) AS id_max_prank,
  MIN(metrics.percentile_ranking) OVER (
    PARTITION BY map.id
  ) AS id_min_prank
FROM fresh_segments.interest_metrics AS metrics 
INNER JOIN fresh_segments.interest_map AS map 
  ON metrics.interest_id = map.id
WHERE metrics.month_year IS NOT NULL
AND metrics.interest_id IN (131,150,23,20764,38992)
ORDER BY map.id, id_pr_rank
)
SELECT 
  *, 
  -- https://www.calculatorsoup.com/calculators/algebra/percent-difference-calculator.php
  CONCAT(
    ROUND(CAST((ABS(percentile_ranking - id_max_prank) / ((percentile_ranking + id_max_prank) / 2)) * 100 AS NUMERIC), 2)
  , '%') AS prank_diff_perc_max,
  CONCAT(
    ROUND(CAST((ABS(percentile_ranking - id_min_prank) / ((percentile_ranking + id_min_prank) / 2)) * 100 AS NUMERIC), 2)
  , '%') AS prank_diff_perc_min
FROM percentile_rankings;


--------------------------- End of Section C  ---------------------------





--------------------------- D. Index Analysis ---------------------------

-- 1. What is the top 10 interests by the average composition for each month?
WITH month_avg_interest_composition_rankings AS (
SELECT
  map.id, map.interest_name, metrics.month_year,
  ROUND(CAST(metrics.composition / metrics.index_value AS NUMERIC), 2) AS int_idx_avgcomp,
  RANK() OVER (
    PARTITION BY metrics.month_year
    ORDER BY ROUND(CAST(metrics.composition / metrics.index_value AS NUMERIC), 2) DESC
  ) AS month_avg_comp_rank
FROM fresh_segments.interest_metrics AS metrics 
INNER JOIN fresh_segments.interest_map AS map 
  ON metrics.interest_id = map.id 
ORDER BY metrics.month_year, month_avg_comp_rank
)
SELECT 
  * 
FROM month_avg_interest_composition_rankings
WHERE month_avg_comp_rank <= 10;

-- 2. For all of these top 10 interests - which interest appears the most often?
WITH month_avg_interest_composition_rankings AS (
SELECT
  map.id, map.interest_name, metrics.month_year,
  ROUND(CAST(metrics.composition / metrics.index_value AS NUMERIC), 2) AS int_idx_avgcomp,
  RANK() OVER (
    PARTITION BY metrics.month_year
    ORDER BY ROUND(CAST(metrics.composition / metrics.index_value AS NUMERIC), 2) DESC
  ) AS month_avg_comp_rank
FROM fresh_segments.interest_metrics AS metrics
INNER JOIN fresh_segments.interest_map AS map 
  ON metrics.interest_id = map.id 
WHERE metrics.month_year IS NOT NULL
ORDER BY metrics.month_year, month_avg_comp_rank
),
top_10_monthly_interest AS (
SELECT * 
FROM month_avg_interest_composition_rankings
WHERE month_avg_comp_rank <= 10
),
top_10_total_interest_appearances AS (
SELECT 
  id, interest_name,
  COUNT(*) AS interest_id_top_10_apps,
  DENSE_RANK() OVER (
    ORDER BY COUNT(*) DESC
  ) AS interest_id_top_10_apps_rank
FROM top_10_monthly_interest
GROUP BY id, interest_name
ORDER BY interest_id_top_10_apps DESC
)
SELECT * FROM top_10_total_interest_appearances;