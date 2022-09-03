-- 1. Highest Duplicate: WWhich id value has the most number of duplicate records in the health.user_logs table??
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

-- 2. How many distinct **fid** values are there for the three most common price values in the dvd_rentals.nicer_but_slower_film_list table?
SELECT 
  price,
  COUNT(DISTINCT fid) AS film_counts
FROM dvd_rentals.nicer_but_slower_film_list
GROUP BY price
ORDER BY film_counts DESC
LIMIT 3;

-- |price|film_counts|
-- |:------|:------|
-- |0.99|340|
-- |4.99|334|
-- |2.99|323|


-- 3. How many unique country_id values exist in the dvd_rentals.city table?
SELECT
  COUNT(DISTINCT country_id) AS total_unique_countries
FROM dvd_rentals.city

-- |total_unique_countries|
-- |:------|
-- |109|


-- 4. What percentage of overall total_sales does the Sports category make up in the dvd_rentals.sales_by_film_category table?
-- My Solution - Only 1 row per category so the grouping not needed to get a total sales value
SELECT
  category,
  ROUND(
    100 * total_sales::NUMERIC / SUM(total_sales) OVER(),
    2
  ) AS percentage
FROM dvd_rentals.sales_by_film_category
GROUP BY category, total_sales
ORDER BY percentage DESC;

-- Course
SELECT
  category,
  ROUND(
    100 * total_sales::NUMERIC / SUM(total_sales) OVER (),
    2
  ) AS percentage
FROM dvd_rentals.sales_by_film_category

-- |category|percentage|
-- |:------|:------|
-- |Sports|7.88|
-- |Sci-Fi|7.06|



-- 5. What percentage of unique fid values are in the Children category in the dvd_rentals.film_list table?
SELECT
  category,
  ROUND(
    100 * COUNT(DISTINCT fid)::NUMERIC / SUM(COUNT(DISTINCT fid)) OVER(),
    2
  ) AS distinct_per_category_percentage
FROM dvd_rentals.film_list
GROUP BY category
ORDER BY distinct_per_category_percentage DESC

-- |category|distinct_per_category_percentage|
-- |:------|:------|
-- |Sports|7.32|
-- |Children|6.02|


