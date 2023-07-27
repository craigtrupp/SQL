-- Section B 
-- 1
SELECT COUNT(DISTINCT user_id) AS user_count
FROM clique_bait.users;

-- 2
WITH user_cookie_counts AS (
SELECT 
  user_id,
  COUNT(DISTINCT cookie_id) AS user_unique_counts
FROM clique_bait.users
GROUP BY user_id
)
SELECT
    ROUND(AVG(user_unique_counts), 2) AS average_user_cookie_amount,
    CONCAT('Users averaged ', ROUND(AVG(user_unique_counts), 2), ' cookies.') AS user_avg_str
FROM user_cookie_counts;

-- 3
SELECT 
  DATE_PART('Month', event_time) AS Month,
  TO_CHAR(event_time, 'Month') AS Month_Name,
  COUNT(DISTINCT visit_id) AS monthly_unique_user_visits
FROM clique_bait.events
GROUP BY Month, Month_Name;


-- 4 
SELECT
  ev.event_type,
  evid.event_name,
  COUNT(*) AS event_type_count
FROM clique_bait.events AS ev
INNER JOIN clique_bait.event_identifier AS evid
  USING(event_type)
GROUP BY ev.event_type, evid.event_name
ORDER BY event_type_count DESC;

-- 5
SELECT
  e.event_type,
  ei.event_name,
  SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase_count,
  (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events) AS unique_user_visit,
  ROUND(
  SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END)::NUMERIC / (SELECT COUNT(DISTINCT visit_id) AS unique_visit FROM clique_bait.events)
  , 4) AS decimal_percentage,
  CONCAT(
    ROUND(
    100 * SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END)::NUMERIC / (SELECT COUNT(DISTINCT visit_id) AS unique_visit FROM clique_bait.events)
    , 2), '%') AS purchase_perc_per_unique_visits 
FROM clique_bait.events AS e 
INNER JOIN clique_bait.event_identifier AS ei 
  USING(event_type)
WHERE ei.event_name = 'Purchase'
GROUP BY e.event_type, ei.event_name;

-- Another Way with CTE for less subqueries
WITH cte_visits_with_purchase_flag AS (
  SELECT
    visit_id,
    SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase_flag
  FROM clique_bait.events
  GROUP BY visit_id
)
SELECT
  100 * SUM(purchase_flag) / (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events)::NUMERIC AS purchase_percentage,
  SUM(purchase_flag) AS total_purchases, 
  (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events) AS unique_events,
  CONCAT(ROUND(100 * SUM(purchase_flag) / (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events)::NUMERIC, 2), '%') AS purchase_perc_str
FROM cte_visits_with_purchase_flag;


-- 6 -- See Markdown progression for final query
WITH page_counts AS (
SELECT
  e.visit_id,
  SUM(CASE WHEN ph.page_name = 'Confirmation' THEN 1 ELSE 0 END) AS Purchase_unique_events,
  SUM(CASE WHEN ph.page_name = 'Checkout' THEN 1 ELSE 0 END) AS Checkout_unique_events
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  ON  e.page_id = ph.page_id
GROUP BY e.visit_id
)
SELECT
  SUM(Purchase_unique_events) AS total_unique_purchases,
  SUM(Checkout_unique_events) AS total_unique_checkoutpg_events,
  CONCAT(ROUND(SUM(Purchase_unique_events)::NUMERIC / SUM(Checkout_unique_events), 3) * 100, '%') AS check_out_to_purchase, 
  CONCAT(ROUND( 1 - SUM(Purchase_unique_events)::NUMERIC / SUM(Checkout_unique_events), 3) * 100, '%') AS check_out_and_no_purchase
FROM page_counts;


-- 7 
SELECT
  ph.page_id,
  ph.page_name,
  ei.event_name,
  COUNT(*) AS total_page_visits
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  USING(page_id)
INNER JOIN clique_bait.event_identifier AS ei 
  ON ei.event_type = e.event_type
GROUP BY ph.page_id, ph.page_name, ei.event_name
ORDER BY total_page_visits DESC
LIMIT 5


-- 8 (Good way to per row get the counts of a product/categorical feature and their subsquent sum for different events)
SELECT 
  ph.product_category,
  SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS product_page_views,
  SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS product_cart_adds
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  ON ph.page_id = e.page_id
INNER JOIN clique_bait.event_identifier AS ei 
  ON e.event_type = ei.event_type
WHERE ph.product_category IS NOT NULL
GROUP BY ph.product_category
ORDER BY ph.product_category;

-- 9 
SELECT
  ph.product_id, 
  ph.page_name AS product,
  ph.product_category AS category,
  COUNT(*) AS product_purchases
FROM clique_bait.events AS e 
INNER JOIN clique_bait.event_identifier AS ei 
  ON e.event_type = ei.event_type
INNER JOIN clique_bait.page_hierarchy AS ph 
  ON e.page_id = ph.page_id
WHERE ei.event_name = 'Add to Cart'
-- Now we want to validate if the visit ultimately resulted in a purchase with what was added to the cart
AND e.visit_id IN (
SELECT 
  e.visit_id
FROM clique_bait.events AS e 
WHERE e.event_type = 3 -- Purchase event_type 
)
-- now we should have a base table to group by and order by
GROUP BY ph.product_id, product, product_category
ORDER BY product_purchases DESC;




------ Section C -------
----- Temp Tables Syntax Shown in Markdown for storing CTE return into accessible table ---
------ Product Funnel Analysis ------
WITH product_views_cart_additions AS (
SELECT
  ph.page_name AS product, 
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS product_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS product_cart_adds
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  ON e.page_id = ph.page_id
WHERE ph.product_id IS NOT NULL
GROUP BY product
ORDER BY product
),
cart_additions_no_purchase AS (
SELECT
  ph.page_name AS product, 
  COUNT(*) AS abandoned_count
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  ON e.page_id = ph.page_id 
WHERE e.event_type = 2
AND e.visit_id NOT IN (
  SELECT
    e.visit_id
  FROM clique_bait.events AS e 
  WHERE e.event_type = 3
) 
AND ph.product_id IS NOT NULL
GROUP BY product
ORDER BY product
)
SELECT
  product,
  first_cte.product_views,
  first_cte.product_cart_adds,
  second_cte.abandoned_count
FROM product_views_cart_additions AS first_cte
INNER JOIN cart_additions_no_purchase AS second_cte
  USING(product)

-- So far to date for the views and cart abandonments for the product table analysis

-- Product Table Generation Entire CTE
WITH product_views_cart_additions AS (
SELECT
  ph.page_name AS product, 
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS product_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS product_cart_adds
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  ON e.page_id = ph.page_id
WHERE ph.product_id IS NOT NULL
GROUP BY product
ORDER BY product
),
cart_additions_no_purchase AS (
SELECT
  ph.page_name AS product, 
  COUNT(*) AS abandoned_count
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  ON e.page_id = ph.page_id 
WHERE e.event_type = 2
AND e.visit_id NOT IN (
  SELECT
    e.visit_id
  FROM clique_bait.events AS e 
  WHERE e.event_type = 3
) 
AND ph.product_id IS NOT NULL
GROUP BY product
ORDER BY product
),
product_joined_values AS (
-- Output includes the product id so we can do another quick join here to get the product id and match on the page_name which is our aliased product
SELECT
  ph.product_id,
  product,
  first_cte.product_views,
  first_cte.product_cart_adds,
  second_cte.abandoned_count
FROM product_views_cart_additions AS first_cte
INNER JOIN cart_additions_no_purchase AS second_cte
  USING(product)
INNER JOIN clique_bait.page_hierarchy AS ph 
  ON product = ph.page_name
ORDER BY ph.product_id
)
SELECT
  *,
  product_cart_adds - abandoned_count AS purchases
FROM product_joined_values;

-- Product Category CTE
-- Very Similar with just a few adjustments to aggregate by the product's category
WITH product_category_views_cart_adds AS (
SELECT
  ph.product_category AS product_category, 
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS category_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS category_cart_adds
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  ON e.page_id = ph.page_id
WHERE ph.product_id IS NOT NULL
GROUP BY product_category
),
cart_additions_no_purchase_categories AS (
SELECT
  ph.product_category AS product_category, 
  COUNT(*) AS abandoned_count
FROM clique_bait.page_hierarchy AS ph 
INNER JOIN clique_bait.events AS e 
  ON e.page_id = ph.page_id 
WHERE e.event_type = 2
AND e.visit_id NOT IN (
  SELECT
    e.visit_id
  FROM clique_bait.events AS e 
  WHERE e.event_type = 3
) 
AND ph.product_id IS NOT NULL
GROUP BY product_category
),
category_joined_values AS (
-- Output includes the product id so we can do another quick join here to get the product id and match on the page_name which is our aliased product
SELECT
  product_category,
  first_cte.category_views,
  first_cte.category_cart_adds,
  second_cte.abandoned_count
FROM product_category_views_cart_adds AS first_cte
INNER JOIN cart_additions_no_purchase_categories AS second_cte
  USING(product_category)
ORDER BY product_category
)
SELECT
  *,
  category_cart_adds - abandoned_count AS purchases
FROM category_joined_values;


----- Product Funnel Analysis ------

-- 1 - Max values for particular product event data (views, adds, purchases)
-- Max product views
SELECT
  product,
  product_views AS max_product_views
FROM pfa
WHERE product_views = (SELECT MAX(product_views) FROM pfa);

-- Most Cart Adds
SELECT
  product,
  product_cart_adds
FROM pfa
ORDER BY product_cart_adds DESC
LIMIT 1;

-- Most purchases
SELECT
  product,
  purchases
FROM pfa
ORDER BY purchases DESC
LIMIT 1;