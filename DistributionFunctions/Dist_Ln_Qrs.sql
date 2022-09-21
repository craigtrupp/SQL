-- Previous Lesson Final Agg Summary Stats Query
SELECT
  ROUND(MIN(measure_value), 2) AS minimum_value,
  ROUND(MAX(measure_value), 2) AS maximum_value,
  ROUND(AVG(measure_value), 2) AS mean_value,
  ROUND(
    -- this function actually returns a float which is incompatible with ROUND!
    -- we use this cast function to convert the output type to NUMERIC : (Quick Reminder that ORDER BY defaults to ASC order here for the GROUP)
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS NUMERIC),
    2
  ) AS median_value,
  ROUND(
    MODE() WITHIN GROUP (ORDER BY measure_value),
    2
  ) AS mode_value,
  -- Average squared distances between mean and square root for variance distribution deviations
  ROUND(STDDEV(measure_value), 2) AS standard_deviation,
  ROUND(VARIANCE(measure_value), 2) AS variance_value
FROM health.user_logs
WHERE measure = 'weight';

-- Top 10 Percents (see below percentiles CTE explanationfor further detail)
SELECT
  measure_value,
  NTILE(10) OVER (
    ORDER BY
      measure_value
  ) AS percentile
FROM health.user_logs
WHERE measure = 'weight'
ORDER BY measure_value DESC, percentile DESC;

-- CTE to get 1-100% percentile value added to respective measure value (Common to use deciles NTILE(10)) where measure = 'weight'
WITH percentiles as (
    SELECT
        measure_value,
        NTILE(100) OVER(
            ORDER BY measure_value
        ) AS percentile
    FROM health.user_logs
    WHERE measure = 'weight'
)
-- Create Agg func returns for grouped off results to each percentile in above CTE
SELECT 
    percentile,
    MIN(measure_value) AS floor_value,
    MAX(measure_value) AS ceiling_value,
    COUNT(percentile) AS percentile_counts
FROM percentiles
GROUP BY percentile
ORDER BY percentile;

-- How do we deal w/ties for Ranking (Ranking Function Difference) : Percentile available but ranking the measure_value and not any bucketing performed with NTILE
WITH percentile_values AS (
  SELECT
    measure_value,
    NTILE(100) OVER (
      ORDER BY
        measure_value
    ) AS percentile
  FROM health.user_logs
  WHERE measure = 'weight'
)
SELECT
  measure_value,
  -- these are examples of window functions below
  ROW_NUMBER() OVER (ORDER BY measure_value DESC) as row_number_order,
  RANK() OVER (ORDER BY measure_value DESC) as rank_order,
  DENSE_RANK() OVER (ORDER BY measure_value DESC) as dense_rank_order
FROM percentile_values
WHERE percentile = 100
ORDER BY measure_value DESC;


-- We have a few sizable looking outliers. Let's see how our percentiles look now
-- Temp Table First
DROP TABLE IF EXISTS clean_weight_logs;
CREATE TEMP table clean_weight_logs AS (
  SELECT * 
  FROM health.user_logs
  WHERE measure = 'weight'
    AND measure_value BETWEEN 1 AND 201
);

-- New CTE from temp table
WITH clean_weight_percentiles AS (
  SELECT
    measure_value,
    NTILE(100) OVER (
      ORDER BY measure_value
    ) AS clean_percentile
  FROM clean_weight_logs
)
-- Updated Distribution
SELECT
  clean_percentile,
  MIN(measure_value) AS floor_value,
  MAX(measure_value) AS ceil_value,
  COUNT(clean_percentile) AS clean_percent_counts
FROM clean_weight_percentiles
GROUP BY clean_percentile
ORDER BY clean_percentile DESC;