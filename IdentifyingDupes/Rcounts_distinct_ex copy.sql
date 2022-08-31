-- 1. Which actor_id has the most number of unique film_id records in the dvd_rentals.film_actor table?
SELECT
  actor_id,
  COUNT(DISTINCT film_id) AS films_acted_in
FROM dvd_rentals.film_actor
GROUP BY actor_id
ORDER BY films_acted_in DESC
LIMIT 1;

-- |actor_id|films_acted_in|
-- |:------|:------|
-- |107|42|

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


