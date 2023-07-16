-- Case Study Sql items for reference

-- A : Data Clensing (See Markdown File for Further Reference If Needed)
DROP TABLE IF EXISTS data_mart.clean_weekly_sales;
CREATE TABLE data_mart.clean_weekly_sales AS
SELECT
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
  region,
  platform,
  CASE
    WHEN segment = 'null' THEN 'Unknown'
    ELSE segment
    END AS segment,
  CASE
    WHEN LEFT(segment, 1) = '1' THEN 'Young Adults'
    WHEN LEFT(segment, 1) = '2' THEN 'Middle Aged'
    WHEN LEFT(segment, 1) IN ('3', '4') THEN 'Retirees'
    ELSE 'Unknown'
    END AS age_band,
  CASE
    WHEN RIGHT(segment, 1) = 'C' THEN 'Couples'
    WHEN RIGHT(segment, 1) = 'F' THEN 'Families'
    ELSE 'Unknown'
    END AS demographic,
  customer_type,
  transactions,
  sales,
  ROUND(
      sales / transactions,
      2
   ) AS avg_transaction
FROM data_mart.weekly_sales;

-- Data Matching UNION ALL to validate total new rows in old table match new cleaned table in schema
SELECT
    COUNT(*) AS total_rows
FROM data_mart.weekly_sales
UNION ALL
SELECT
    COUNT(*) AS total_rows
FROM data_mart.clean_weekly_sales;
-- |total_rows|
-- |----|
-- |17117|
-- |17117|


-- B : Data Exploration - See Markdown for further context on questions (table outputs), 
-- only queries here!!!

-- 1
-- In theory this is what we can't do but return corrects for Each
SELECT 
  DISTINCT(TO_CHAR(week_date, 'Day')) AS Unique_Day_Name
FROM data_mart.clean_weekly_sales
UNION
SELECT
  DISTINCT(EXTRACT(dow FROM week_date)) AS Unique_Day_Value
FROM data_mart.clean_weekly_sales;

-- Above causes and error but in reality what were kinda looking for (can't union different data types!!!)

WITH unique_day_counts AS (
-- Each row will give us the day_name and the integer value associated to it 
SELECT
  (SELECT DISTINCT(TO_CHAR(week_date, 'Day'))) AS Unique_Day_Name,
  (SELECT DISTINCT(EXTRACT(dow FROM week_date))) AS Unique_Day_Value
FROM data_mart.clean_weekly_sales
)
-- Now just a generic count after grouping
SELECT
  Unique_Day_Name,
  Unique_Day_Value,
  COUNT(*) AS total_day_line_counts
FROM unique_day_counts
GROUP BY Unique_Day_Name, Unique_Day_Value
ORDER BY total_day_line_counts DESC;



-- 2
WITH total_weeks AS (
SELECT
  GENERATE_SERIES(1,52) AS week_number
)
SELECT
  week_number AS unique_week_numbers_not_included
FROM total_weeks
WHERE week_number NOT IN (SELECT DISTINCT(week_number) FROM data_mart.clean_weekly_sales)
ORDER BY unique_week_numbers_not_included;

-- Another fashion
WITH all_week_numbers AS ( 
  SELECT GENERATE_SERIES(1, 52) AS week_number
)
SELECT
  week_number
FROM all_week_numbers AS t1
WHERE NOT EXISTS (
  SELECT 1
  FROM data_mart.clean_weekly_sales AS t2
  WHERE t1.week_number = t2.week_number 
);

-- 3
SELECT
  calendar_year,
  SUM(transactions) AS year_total_transactions,
  SUM(SUM(transactions)) OVER() AS total_years_summed_transactions_window
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year
ORDER BY year_total_transactions DESC;



-- 4 
-- Using TO_CHAR to get the month name for easier association
SELECT
  month_number,
  TO_CHAR(week_date, 'Month') AS month_name,
  region,
  SUM(sales) AS month_total_sales_over_years
FROM data_mart.clean_weekly_sales
GROUP BY month_number, month_name, region
ORDER BY region, month_number;


-- 5
-- Fairly Straight Forward
SELECT
  platform,
  SUM(transactions) AS platform_total_transactions
FROM data_mart.clean_weekly_sales
GROUP BY platform
ORDER BY platform_total_transactions DESC;


-- 6
-- A few queries here - most notably how to establish a sum row for 
-- two group by features you want to compare

-- First for 6 
WITH monthly_platform_sales AS (
SELECT
  month_number,
  TO_CHAR(week_date, 'MONTH') AS month_label,
  platform,
  SUM(sales)
FROM data_mart.clean_weekly_sales
GROUP BY month_number, month_label, platform
ORDER BY month_number, month_label
)
SELECT * FROM monthly_platform_sales LIMIT 5;

-- Second for 6 
WITH monthly_platform_sales AS (
SELECT
  month_number,
  TO_CHAR(week_date, 'MONTH') AS month_name,
  calendar_year,
  SUM(CASE WHEN platform = 'Retail' THEN sales END) AS retail_monthly_sum,
  SUM(CASE WHEN platform = 'Shopify' THEN sales END) AS shopify_monthly_sum
FROM data_mart.clean_weekly_sales
GROUP BY month_number, month_name, calendar_year
-- Order by calendar year oldest, to newest in sequential month order
ORDER BY calendar_year, month_number
)
SELECT
  *,
  ROUND(100 * (retail_monthly_sum / (retail_monthly_sum + shopify_monthly_sum)::NUMERIC), 2) AS retail_monthly_percentage,
  ROUND(100 * (shopify_monthly_sum / (retail_monthly_sum + shopify_monthly_sum)::NUMERIC), 2) AS shopify_monthly_percentage
FROM monthly_platform_sales;


-- 7
-- Good way to use a window function to get a sum of a grouped by value we want to use as the base 
-- sum to create percentages off with the general sum of the grouped by features
SELECT
  calendar_year,
  demographic,
  SUM(sales) AS yearly_sales,
  -- We want to take the our summed sale value for the demo and divide by the sum of all the sum(sales) over a particular year
  ROUND(
  100 * (SUM(sales)::NUMERIC / SUM(SUM(sales)) OVER (
    PARTITION BY calendar_year
  )), 2) AS demo_sales_percentage_for_year
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year, demographic
ORDER BY calendar_year, demographic;


-- 8 
-- A bit going on with this one
-- Essentially we rank by our first grouped by sum values
-- Then we use the sum of all the grouped by sum in a window function to get their percentage
WITH age_demographic_retail_sales AS (
SELECT
  age_band,
  demographic,
  SUM(sales) AS age_demo_sales
FROM data_mart.clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
),
age_band_sales_rankings AS (
SELECT 
  *,
  RANK() OVER(
    ORDER BY age_demo_sales DESC
  ) AS demo_ageband_retail_sales_rankings
FROM age_demographic_retail_sales
)
SELECT 
  *,
  ROUND(
    100 * (age_demo_sales::NUMERIC / SUM(age_demo_sales) OVER())
  , 1) AS age_demo_percentage_ofsale
FROM age_band_sales_rankings 
ORDER BY demo_ageband_retail_sales_rankings;





-- C : Before & After Analysis - See Markdown for further context on questions (table outputs), 
-- only queries here!!!

-- Here we are looking for sales period difference/totals over a weekly interval period with a provided cutoff week for before/after analysis
WITH cutoff_week AS (
SELECT DISTINCT week_number AS cutoff_week
FROM data_mart.clean_weekly_sales 
WHERE week_date = '2020-06-15'
),
-- let's look at generated series to get the 4 preceding and subsequent week_number int values
preceding_subsequent_weeks AS (
SELECT
  cutoff_week,
  GENERATE_SERIES(cutoff_week::INT - 4, cutoff_week::INT - 1) AS preceding_weeks,
  GENERATE_SERIES(cutoff_week::INT + 1,  cutoff_week::INT + 4) AS subsequent_weeks
FROM cutoff_week
),
-- total_sales
total_pre_post_sales AS (
SELECT
-- Now we need to do a conditional summing based on the week values .. a little tricky but doable
  SUM(CASE WHEN week_number in (SELECT preceding_weeks FROM preceding_subsequent_weeks) THEN sales END) AS preceding_weeks_sum,
  SUM(CASE WHEN week_number in (SELECT subsequent_weeks FROM preceding_subsequent_weeks) THEN sales END) AS subsequent_weeks_sum
FROM data_mart.clean_weekly_sales
)
SELECT 
  *,
  CASE
    WHEN preceding_weeks_sum > subsequent_weeks_sum THEN 'Higher Sales in Preceding Period'
    WHEN subsequent_weeks_sum > preceding_weeks_sum THEN 'Higher Sales in Subsequent Weeks'
    ELSE 'Wow! Somehow the sales are the same'
  END AS greater_sales_period,
  CASE 
    WHEN preceding_weeks_sum > subsequent_weeks_sum THEN preceding_weeks_sum - subsequent_weeks_sum
    WHEN subsequent_weeks_sum > preceding_weeks_sum THEN subsequent_weeks_sum - preceding_weeks_sum
    ELSE 0
  END AS greater_sales_period_diff,
  -- All branches of a CASE expression need to have the same type.
  CASE
    WHEN preceding_weeks_sum > subsequent_weeks_sum THEN TO_CHAR(ROUND(100 * (preceding_weeks_sum - subsequent_weeks_sum) / subsequent_weeks_sum::NUMERIC, 3), 'fm0D000%')
    WHEN subsequent_weeks_sum > preceding_weeks_sum THEN TO_CHAR(ROUND(100 * (subsequent_weeks_sum - preceding_weeks_sum) / preceding_weeks_sum::NUMERIC, 3), 'fm0D000%')
    ELSE TO_CHAR(0, 'fm0D000%') 
  END as greater_sales_percentage
FROM total_pre_post_sales;




-- D : Creating series for 12 week interval (and then subsequent group by stats for different dimensions)

-- Create Preceding/Subsequent Weeks
WITH cutoff_week AS (
SELECT DISTINCT week_number FROM data_mart.clean_weekly_sales WHERE week_date = '2020-06-15'
),
preceding_subsequent_weeks AS (
SELECT
  ARRAY(
    SELECT GENERATE_SERIES((SELECT * FROM cutoff_week)::INT - 12, (SELECT * FROM cutoff_week)::INT - 1)
  ) AS preceding_weeks,
    ARRAY(
    SELECT GENERATE_SERIES((SELECT * FROM cutoff_week)::INT + 1, (SELECT * FROM cutoff_week)::INT + 12)
  ) AS subsequent_weeks
)
SELECT * FROM preceding_subsequent_weeks;
