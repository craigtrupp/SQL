---------------------------- A. Pizza Metrics ------------------------------
-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) AS total_pizza_count
FROM pizza_runner.customer_orders;


-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM pizza_runner.customer_orders;


-- 3. How many successful orders were delivered by each runner?
DROP TABLE IF EXISTS successful_orders;
CREATE TEMP TABLE successful_orders AS 
SELECT * 
FROM pizza_runner.runner_orders
WHERE pickup_time NOT ILIKE '%null%';

-- UPDATE TABLE to set consistent cancellation value
UPDATE successful_orders
SET cancellation = NULL;

-- Now we can get the counts pretty straightforward
SELECT 
  runner_id,
  COUNT(DISTINCT order_id) AS successful_orders_per_runner
FROM successful_orders
GROUP BY runner_id
ORDER BY successful_orders_per_runner DESC;

-- This also works as a standalone 
SELECT
  runner_id,
  COUNT(DISTINCT order_id) AS successful_orders
FROM pizza_runner.runner_orders
WHERE cancellation IS NULL
  OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY runner_id
ORDER BY successful_orders DESC;


-- 4. How many of each type of pizza was delivered?
WITH successful_pizza_orders AS (
SELECT 
  so.order_id,
  co.pizza_id,
  pn.pizza_name
FROM successful_orders so 
-- get the pizza ids of successful orders (we want inner for all )
INNER JOIN pizza_runner.customer_orders co 
  USING(order_id)
INNER JOIN pizza_runner.pizza_names pn 
  ON co.pizza_id = pn.pizza_id
)
SELECT 
  pizza_name,
  COUNT(*) AS pizza_delivery_count
FROM successful_pizza_orders
GROUP BY pizza_name
ORDER BY pizza_delivery_count DESC

-- Quicker approcah w/o CTE
SELECT
  pn.pizza_name AS pizza,
  COUNT(*) AS delivered_pizzas_count
FROM pizza_runner.runner_orders ro 
INNER JOIN pizza_runner.customer_orders co 
  USING(order_id)
INNER JOIN pizza_runner.pizza_names pn 
  USING(pizza_id)
WHERE ro.cancellation IS NULL
  OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY pizza
ORDER BY delivered_pizzas_count DESC;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
  co.customer_id AS customer,
  pn.pizza_name AS pizza_type,
  COUNT(*) AS customer_pizza_counts
FROM pizza_runner.customer_orders co 
INNER JOIN pizza_runner.pizza_names pn 
  ON co.pizza_id = pn.pizza_id
GROUP BY customer, pizza_type
ORDER BY customer,  customer_pizza_counts DESC;


-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT 
  co.order_id AS unique_order,
  -- Can use count as each order in co will be a single ordered pizza (multiple pizzas per unique order is its' own row)
  COUNT(*) AS pizzas_delivered,
  RANK() OVER (
    -- over pizzas_delivered (successfully)
    ORDER BY COUNT(*) DESC
  ) AS pizzas_delivered_rankings
FROM pizza_runner.runner_orders ro 
INNER JOIN pizza_runner.customer_orders co 
  USING(order_id)
WHERE ro.cancellation IS NULL
  OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY unique_order

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
  co.customer_id,
  -- Be careful here with the null values that actually have a length of 4 and aren't a null length (what would be expected for a null value)
  SUM(
    CASE 
      WHEN 
        (LENGTH(co.exclusions) >= 1 AND co.exclusions NOT LIKE '%null%')
      OR 
        (LENGTH(co.extras) >= 1 AND co.extras NOT LIKE '%null%')
      THEN 1
      ELSE 0
    END
  ) AS customer_pizza_alterations,
  SUM(
    CASE 
      WHEN 
        ((co.exclusions IS null OR LENGTH(co.exclusions) = 0) OR (LENGTH(co.exclusions) >= 1 AND co.exclusions LIKE '%null%'))
      AND 
        ((co.extras IS null OR LENGTH(co.extras) = 0) OR (LENGTH(co.extras) >= 1 AND co.extras LIKE '%null%'))
      THEN 1
      ELSE 0
    END
  ) AS no_customer_pizza_alterations
FROM pizza_runner.runner_orders ro 
INNER JOIN pizza_runner.customer_orders co 
  USING(order_id)
WHERE ro.cancellation IS NULL
  OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY co.customer_id
ORDER BY co.customer_id;


-- 8. How many pizzas were delivered that had both exclusions and extras?
WITH extras_exclusions_count AS (
   SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE WHEN exclusions IN ('null', '') THEN NULL ELSE exclusions END AS exclusions,
    CASE WHEN extras IN ('null', '') THEN NULL ELSE extras END AS extras,
    order_time
  FROM pizza_runner.customer_orders
)
SELECT
  COUNT(*) AS exclusions_extras_total_pizzas_count
FROM extras_exclusions_count
WHERE exclusions IS NOT NULL AND extras IS NOT NULL;


-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
  DATE_PART('hour', order_time) AS order_hour,
  COUNT(order_id) AS hour_total_orders
FROM pizza_runner.customer_orders
GROUP BY order_hour
ORDER BY hour_total_orders DESC;

-- 10. What was the volume of orders for each day of the week?
SELECT
-- TO_CHAR method very helpful here to group by
  INITCAP(TO_CHAR(order_time, 'day')) AS order_day,
  COUNT(order_id) AS DAY_total_orders
FROM pizza_runner.customer_orders
GROUP BY order_day
ORDER BY order_day DESC;

-- Another Way
SELECT
  TO_CHAR(order_time, 'Day') AS day_of_week,
  COUNT(order_id) AS pizza_count
FROM pizza_runner.customer_orders
GROUP BY day_of_week, DATE_PART('dow', order_time)
ORDER BY DATE_PART('dow', order_time);



-------------------------- End of Section A. Pizza Metrics ----------------------------



---------------------------- B. Runner and Customer Experience ------------------------------

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- Week Start 2021-01-01 (New Year)
SELECT 
  DATE_TRUNC('WEEK', registration_date::date) + INTERVAL '4 DAYS' AS runner_sign_up_wstart,
  COUNT(*)
FROM pizza_runner.runners
GROUP BY runner_sign_up_wstart
ORDER BY runner_sign_up_wstart;
-- EITHER HERE WORKS
SELECT
  DATE_TRUNC('week', registration_date)::DATE + 4 AS registration_week,
  COUNT(*) AS runners
FROM pizza_runner.runners
GROUP BY registration_week
ORDER BY registration_week;


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH runner_avg_pickup_times AS (
SELECT
  DISTINCT ro_1.order_id,
  ro_1.pickup_time,
  co_2.order_time,
  ro_1.pickup_time::timestamp - co_2.order_time AS pickup_time_diff,
  AGE(ro_1.pickup_time::timestamp, co_2.order_time) AS age_func_return,
  DATE_PART('minutes', AGE(ro_1.pickup_time::timestamp, co_2.order_time))::INTEGER AS minutes
FROM pizza_runner.runner_orders ro_1
INNER JOIN pizza_runner.customer_orders co_2
  USING(order_id)
WHERE 
  ro_1.pickup_time != 'null' OR ro_1.pickup_time IS NULL
)

SELECT 
  AVG(minutes)::FLOAT AS avg_minutes_pickup_for_runner_from_order
FROM runner_avg_pickup_times;


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT
  DISTINCT ro_1.order_id,
  DATE_PART('minutes', AGE(ro_1.pickup_time::timestamp, co_2.order_time))::INTEGER AS pickup_minutes,
  -- despite just getting 1 row for any orders with multiple rows we can still count the total orders from our joined customer orders table
  COUNT(co_2.order_id) AS pizza_count
FROM pizza_runner.runner_orders ro_1
INNER JOIN pizza_runner.customer_orders co_2
  USING(order_id)
WHERE 
  ro_1.pickup_time != 'null' OR ro_1.pickup_time IS NULL
GROUP BY order_id, pickup_minutes
ORDER BY pickup_minutes;


-- 4. What was the average distance travelled for each customer?
WITH pickup_details AS (
SELECT 
  DISTINCT ro.order_id,
  ro.runner_id,
  ro.pickup_time,
  co.customer_id,
  ro.distance,
  UNNEST(regexp_match(distance, '^\d+[.]*\d*'))::FLOAT AS numeric_distance,
  UNNEST(REGEXP_MATCH(ro.distance, '(^[0-9,.]+)'))::NUMERIC AS distance_rgp,
  ro.duration
FROM pizza_runner.runner_orders ro
INNER JOIN pizza_runner.customer_orders co 
  USING(order_id)
WHERE ro.pickup_time != 'null' OR ro.pickup_time IS NULL
ORDER BY order_id
)
SELECT
  customer_id,
  AVG(numeric_distance) as cust_avg_distance_travelled,
  ROUND(AVG(distance_rgp), 1) as cust_avg_rgxp_provided
FROM pickup_details
GROUP BY customer_id
ORDER BY customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH delivery_times_ranked AS (
SELECT 
  UNNEST(REGEXP_MATCH(duration, '^[0-9]+'))::INTEGER AS duration_num,
  duration,
  RANK() OVER (
    ORDER BY UNNEST(REGEXP_MATCH(duration, '^[0-9]+'))::INTEGER DESC
  ) AS deliverly_length_rankings
FROM pizza_runner.runner_orders
WHERE pickup_time != 'null' OR pickup_time IS null
)
SELECT 
  MAX(duration_num) - MIN(duration_num) AS max_delivery_difference
FROM delivery_times_ranked;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH pickup_details AS (
SELECT
  runner_id,
  order_id,
  EXTRACT('hour' FROM pickup_time::timestamp) AS hour_pickup,
  pickup_time,
  distance,
  UNNEST(REGEXP_MATCH(distance, '^[0-9, .]*'))::NUMERIC AS numeric_distance,
  duration,
  UNNEST(REGEXP_MATCH(duration, '^\d+'))::NUMERIC AS duration_mins
FROM pizza_runner.runner_orders
WHERE pickup_time != 'null'
)
SELECT
  runner_id,
  order_id,
  hour_pickup,
  numeric_distance,
  ROUND(60 / duration_mins::decimal, 1) AS distance_multiplier,
  -- Double precision type returned, must cast to a numeric after performing operation prior to round accepting
  ROUND((numeric_distance * (60 / duration_mins::DECIMAL))::NUMERIC, 1) AS avg_speed,
  CONCAT(ROUND((numeric_distance * (60 / duration_mins::DECIMAL))::NUMERIC, 1), ' km/hour') AS avg_speed_delivery
FROM pickup_details;


-- 7. What is the successful delivery percentage for each runner?
WITH runner_delivery_counts AS (
SELECT 
  runner_id,
  SUM(
  CASE 
    WHEN pickup_time != 'null'
    THEN 1 
    ELSE 0 
  END) AS successful_deliveries,
  COUNT(*) AS total_runner_orders
FROM pizza_runner.runner_orders
GROUP BY runner_id
)
-- Select all from CTE and perform successful percentage
SELECT 
  *,
  ROUND(100 * (successful_deliveries::NUMERIC / total_runner_orders), 1) AS success_percentage
FROM runner_delivery_counts;

-------------------------- End of Section B----------------------------


---------------------------- C. Ingredient Optimization ------------------------------

-- 1. What are the standard ingredients for each pizza?
WITH cte_split_pizza_names AS (
SELECT
  pizza_id,
  -- cast as integer in order to join on the pizza_toppings to get the topping_name
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes
)
SELECT
  pizza_id,
  STRING_AGG(pizza_text_toppings.topping_name::TEXT, ', ')
FROM cte_split_pizza_names AS pizza_numeric_toppings
INNER JOIN pizza_runner.pizza_toppings AS pizza_text_toppings 
  USING(topping_id)
GROUP BY pizza_id
ORDER BY pizza_id


-- 2. What was the most commonly added extra?
WITH order_extras AS (
SELECT 
  order_id,
  REGEXP_SPLIT_TO_TABLE(extras, '[, \s]+')::INTEGER AS order_extras
FROM pizza_runner.customer_orders
WHERE LENGTH(extras) >= 1 AND extras != 'null'
), 
extras_order_count AS (
SELECT
  order_extras,
  COUNT(*) AS extra_order_count
FROM order_extras
GROUP BY order_extras
)
SELECT 
  pt.topping_name,
  pt.topping_id,
  eoc.extra_order_count
FROM extras_order_count eoc 
INNER JOIN pizza_runner.pizza_toppings pt 
  ON eoc.order_extras = pt.topping_id
ORDER BY eoc.extra_order_count DESC


-- 3. What was the most common exclusion?
-- Most Common exclusions
WITH cte_exclusions AS (
SELECT
  REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.customer_orders
WHERE exclusions IS NOT NULL AND exclusions NOT IN ('null', '')
)
SELECT
  topping_name,
  COUNT(*) AS exclusions_count
FROM cte_exclusions
INNER JOIN pizza_runner.pizza_toppings
  ON cte_exclusions.topping_id = pizza_toppings.topping_id
GROUP BY topping_name
ORDER BY exclusions_count DESC;


-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following: 
-- + Meat Lovers + Meat Lovers - Exclude Beef + Meat Lovers - Extra Bacon + Meat Lovers 
-- Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH pizza_order_names AS (
SELECT
  co.order_id,
  co.customer_id,
  co.pizza_id,
  co.order_time AS order_time,
  pn.pizza_name,
  co.exclusions,
  co.extras
FROM pizza_runner.customer_orders AS co
INNER JOIN pizza_runner.pizza_names AS pn 
USING(pizza_id)
WHERE order_id = 9
ORDER BY order_id
), 
exclusions_extras AS (
SELECT *,
  CASE 
    WHEN LENGTH(exclusions) >= 1 AND exclusions != 'null'
      THEN (
      WITH exclusion_toppings AS (
        SELECT 
        REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS exclusions_int
      FROM pizza_order_names
      )
    SELECT 
      STRING_AGG(pt.topping_name, ', ') AS exclusions
    FROM exclusion_toppings et 
    INNER JOIN pizza_runner.pizza_toppings pt 
      ON et.exclusions_int = pt.topping_id
    )
    ELSE ''
  END AS exclusion_text,
  CASE 
    WHEN LENGTH(extras) >= 1 AND extras != 'null'
      THEN (
      WITH extras_toppings AS (
        SELECT 
        REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS extras_int
      FROM pizza_order_names
      )
    SELECT 
      STRING_AGG(pt.topping_name, ', ') AS extras_txt
    FROM extras_toppings et 
    INNER JOIN pizza_runner.pizza_toppings pt 
      ON et.extras_int = pt.topping_id
    )
    ELSE ''
  END AS extras_text
FROM pizza_order_names
)
SELECT * FROM exclusions_extras;

-- Another way
WITH cte_cleaned_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE
      WHEN exclusions IN ('', 'null') 
        THEN NULL
      ELSE exclusions
    END AS exclusions,
    CASE
      WHEN extras IN ('', 'null') 
        THEN NULL
      ELSE extras
    END AS extras,
    order_time,
    ROW_NUMBER() OVER () AS original_row_number
  FROM pizza_runner.customer_orders
),
-- when using the regexp_split_to_table function only records where there are
-- non-null records remain so we will need to union them back in!
cte_extras_exclusions AS (
    SELECT
      order_id,
      customer_id,
      pizza_id,
      REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS exclusions_topping_id,
      REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS extras_topping_id,
      order_time,
      original_row_number
    FROM cte_cleaned_customer_orders
  -- here we add back in the null extra/exclusion rows
  -- does it make any difference if we use UNION or UNION ALL?
  UNION
    SELECT
      order_id,
      customer_id,
      pizza_id,
      NULL AS exclusions_topping_id,
      NULL AS extras_topping_id,
      order_time,
      original_row_number
    FROM cte_cleaned_customer_orders
    WHERE exclusions IS NULL AND extras IS NULL
),
cte_complete_dataset AS (
  SELECT
    base.order_id,
    base.customer_id,
    base.pizza_id,
    names.pizza_name,
    base.order_time,
    base.original_row_number,
    STRING_AGG(exclusions.topping_name, ', ') AS exclusions,
    STRING_AGG(extras.topping_name, ', ') AS extras
  FROM cte_extras_exclusions AS base
  INNER JOIN pizza_runner.pizza_names AS names
    ON base.pizza_id = names.pizza_id
  LEFT JOIN pizza_runner.pizza_toppings AS exclusions
    ON base.exclusions_topping_id = exclusions.topping_id
  LEFT JOIN pizza_runner.pizza_toppings AS extras
    ON base.extras_topping_id = extras.topping_id
  GROUP BY
    base.order_id,
    base.customer_id,
    base.pizza_id,
    names.pizza_name,
    base.order_time,
    base.original_row_number
),
cte_parsed_string_outputs AS (
SELECT
  order_id,
  customer_id,
  pizza_id,
  order_time,
  original_row_number,
  pizza_name,
  CASE WHEN exclusions IS NULL THEN '' ELSE ' - Exclude ' || exclusions END AS exclusions,
  CASE WHEN extras IS NULL THEN '' ELSE ' - Extra ' || exclusions END AS extras
FROM cte_complete_dataset
),
final_output AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    pizza_name || exclusions || extras AS order_item
  FROM cte_parsed_string_outputs
)
SELECT
  order_id,
  customer_id,
  pizza_id,
  order_time,
  order_item
FROM final_output
ORDER BY original_row_number;


-- 5. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH cte_cleaned_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE
      WHEN exclusions IN ('', 'null') THEN NULL
      ELSE exclusions
    END AS exclusions,
    CASE
      WHEN extras IN ('', 'null') THEN NULL
      ELSE extras
    END AS extras,
    order_time,
    ROW_NUMBER() OVER () AS original_row_number
  FROM pizza_runner.customer_orders
),
-- split the toppings using our previous solution
cte_regular_toppings AS (
SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes
),
-- now we can should left join our regular toppings with all pizzas orders
cte_base_toppings AS (
  SELECT
    cte_cleaned_customer_orders.order_id,
    cte_cleaned_customer_orders.customer_id,
    cte_cleaned_customer_orders.pizza_id,
    cte_cleaned_customer_orders.order_time,
    cte_cleaned_customer_orders.original_row_number,
    cte_regular_toppings.topping_id
  FROM cte_cleaned_customer_orders
  LEFT JOIN cte_regular_toppings
    ON cte_cleaned_customer_orders.pizza_id = cte_regular_toppings.pizza_id
),
-- now we can generate CTEs for exclusions and extras by the original row number
cte_exclusions AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE exclusions IS NOT NULL
),
-- check this one!
cte_extras AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    order_time,
    original_row_number,
    REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
  FROM cte_cleaned_customer_orders
  WHERE extras IS NOT NULL
),
-- now we can perform an except and a union all on the respective CTEs
-- also check this one!
cte_combined_orders AS (
  SELECT * FROM cte_base_toppings
  EXCEPT
  SELECT * FROM cte_exclusions
  UNION ALL
  SELECT * FROM cte_extras
)
-- perform aggregation on topping_id and join to get topping names
SELECT
  t2.topping_name,
  COUNT(*) AS topping_count
FROM cte_combined_orders AS t1
INNER JOIN pizza_runner.pizza_toppings AS t2
  ON t1.topping_id = t2.topping_id
GROUP BY t2.topping_name
ORDER BY topping_count DESC;

-------------------------- End of Section C ----------------------------



-------------------------- D. Pricing and Ratings ----------------------------
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
-- how much money has Pizza Runner made so far if there are no delivery fees?
WITH pizza_names AS (
SELECT 
  co.order_id,
  pn.pizza_id,
  pn.pizza_name
FROM pizza_runner.customer_orders co 
INNER JOIN pizza_runner.pizza_names pn 
  USING(pizza_id)
ORDER BY order_id
)
SELECT 
  pizza_name,
  SUM(
    CASE 
      WHEN pizza_name = 'Meatlovers'
        THEN 12
      ELSE 10
    END 
  ) AS pizza_total_revenue
FROM pizza_names
GROUP BY pizza_name
ORDER BY pizza_total_revenue DESC;


-- 2. What if there was an additional $1 charge for any pizza extras? + Add cheese is $1 extra
WITH pizza_n_extras AS (
SELECT 
  order_id,
  runner_id,
  pizza_id,
  extras,
  REGEXP_SPLIT_TO_ARRAY(extras, '[,\s]+') AS extras_lst
FROM pizza_runner.runner_orders ro
-- remove cancelled orders
INNER JOIN pizza_runner.customer_orders co 
  USING(order_id)
WHERE ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation') OR  ro.cancellation IS NULL
),
extras_count AS (
SELECT *,
  CASE 
  -- index starts at 1 for conditional checks we don't want to count
    WHEN extras_lst[1] = '' OR extras_lst[1] = 'null' OR extras_lst IS NULL
      THEN 0
    ELSE
    -- cardinality allows you to count everything in the list 
      cardinality(extras_lst)
  END AS total_order_extras
FROM pizza_n_extras
)
SELECT * FROM extras_count

-- Another Path
WITH pizza_n_extras AS (
SELECT 
  order_id,
  runner_id,
  pizza_id,
  extras,
  REGEXP_SPLIT_TO_ARRAY(extras, '[,\s]+') AS extras_lst
FROM pizza_runner.runner_orders ro
-- remove cancelled orders
INNER JOIN pizza_runner.customer_orders co 
  USING(order_id)
WHERE ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation') OR  ro.cancellation IS NULL
),
extras_count AS (
SELECT *,
  CASE 
  -- index starts at 1 for conditional checks we don't want to count
    WHEN extras_lst[1] = '' OR extras_lst[1] = 'null' OR extras_lst IS NULL
      THEN 0
    ELSE
    -- cardinality allows you to count everything in the list 
      cardinality(extras_lst)
  END AS total_order_extras
FROM pizza_n_extras
),
pizza_totals AS (
SELECT
  order_id,
  pizza_id,
  extras,
  extras_lst,
  CASE 
    WHEN pizza_id = 1 AND total_order_extras >= 1
      THEN 12 + (total_order_extras * 1)
    WHEN pizza_id = 1 AND total_order_extras = 0
      THEN 12
    WHEN pizza_id = 2 AND total_order_extras >= 1
      THEN 10 + (total_order_extras * 1)
    WHEN pizza_id = 2 AND total_order_extras = 0
      THEN 10
  END AS pizza_total
FROM extras_count
)
SELECT *, SUM(pizza_total) OVER() AS total_order_sum FROM pizza_totals

-- Using Where Exists
WITH cte_cleaned_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE
      WHEN exclusions IN ('', 'null') THEN NULL
      ELSE exclusions
    END AS exclusions,
    CASE
      WHEN extras IN ('', 'null') THEN NULL
      ELSE extras
    END AS extras,
    order_time,
    ROW_NUMBER() OVER () AS original_row_number
  FROM pizza_runner.customer_orders
  WHERE EXISTS (
    SELECT 1 FROM pizza_runner.runner_orders
    WHERE customer_orders.order_id = runner_orders.order_id
      AND runner_orders.pickup_time != 'null'
  )
)
SELECT
  SUM(
    CASE
      WHEN pizza_id = 1 THEN 12
      WHEN pizza_id = 2 THEN 10
      END +
    -- we can use CARDINALITY to find the length of array of extras
    COALESCE(
      CARDINALITY(REGEXP_SPLIT_TO_ARRAY(extras, '[,\s]+')),
      0
    )
  ) AS cost
FROM cte_cleaned_customer_orders;


-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
SELECT SETSEED(1);

-- Drop table if in pizza_runner.schema
DROP TABLE IF EXISTS pizza_runner.ratings;
CREATE TABLE pizza_runner.ratings (
  "order_id" INTEGER,
  "rating" INTEGER
);

INSERT INTO pizza_runner.ratings
SELECT
  order_id,
  FLOOR(1 + 5 * RANDOM()) AS rating
FROM pizza_runner.runner_orders
WHERE pickup_time != 'null';

SELECT * FROM pizza_runner.ratings;


-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
WITH ratings_pickups_stats AS (
SELECT
  rt.order_id,
  ro.runner_id,
  rt.rating,
  co.order_time,
  ro.pickup_time::timestamp,
  -- must cast pickup_time varchar to timestamp
  ro.pickup_time::timestamp - co.order_time AS order_pickup_duration,
  DATE_PART('minutes', AGE(ro.pickup_time::timestamp, co.order_time))::INTEGER AS order_pickup_minutes,
  UNNEST(REGEXP_MATCH(ro.distance, '^[0-9, .]*'))::NUMERIC AS numeric_distance_km,
  UNNEST(REGEXP_MATCH(ro.duration, '^\d+'))::NUMERIC AS duration_mins
FROM pizza_runner.ratings rt 
INNER JOIN pizza_runner.customer_orders co 
  ON rt.order_id = co.order_id
INNER JOIN pizza_runner.runner_orders ro 
  ON co.order_id = ro.order_id
),
ratings_avg_duration AS (
SELECT *,
  ROUND((numeric_distance_km * (60 / duration_mins::DECIMAL))::NUMERIC, 1) AS avg_speed,
  CONCAT(ROUND((numeric_distance_km * (60 / duration_mins::DECIMAL))::NUMERIC, 1), ' km/hour') AS avg_speed_delivery
FROM ratings_pickups_stats
)
SELECT 
  order_id,
  runner_id,
  rating,
  order_time,
  pickup_time,
  -- using DATE_PART to get the minutes between the pickup and order time, most recent time first similar to how the subtraction returns the object for minutes/seconds
  order_pickup_minutes,
  avg_speed,
  avg_speed_delivery,
  COUNT(order_id) AS pizza_count
FROM ratings_avg_duration
GROUP BY order_id, runner_id, rating, order_time, pickup_time, order_pickup_minutes, avg_speed, avg_speed_delivery
ORDER BY order_id;

-- One more way
WITH cte_adjusted_runner_orders AS (
  SELECT
    t1.order_id,
    t1.runner_id,
    t2.order_time,
    t3.rating,
    t1.pickup_time::TIMESTAMP AS pickup_time,
    UNNEST(REGEXP_MATCH(duration, '(^[0-9]+)'))::NUMERIC AS duration,
    UNNEST(REGEXP_MATCH(distance, '(^[0-9,.]+)'))::NUMERIC AS distance,
    COUNT(t2.*) AS pizza_count
  FROM pizza_runner.runner_orders AS t1
  INNER JOIN pizza_runner.customer_orders AS t2
    ON t1.order_id = t1.order_id
  LEFT JOIN pizza_runner.ratings AS t3
    ON t3.order_id = t3.order_id
  -- WHERE t1.pickup_time != 'null'
  GROUP BY
    t1.order_id,
    t1.runner_id,
    t3.rating,
    t2.order_time,
    t1.pickup_time,
    t1.duration,
    t1.distance
)
SELECT
  order_id,
  runner_id,
  rating,
  order_time,
  pickup_time,
  DATE_PART('min', AGE(pickup_time::TIMESTAMP, order_time))::INTEGER AS pickup_minutes,
  ROUND(distance / (duration / 60), 1) AS avg_speed,
  pizza_count
FROM cte_adjusted_runner_orders;


-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
-- - how much money does Pizza Runner have left over after these deliveries?
WITH pizza_runner_profit AS (
SELECT 
  ro.order_id,
  co.pizza_id, 
  ro.pickup_time,
  UNNEST(REGEXP_MATCH(ro.distance, '^[0-9, .]*'))::NUMERIC AS numeric_distance_km
FROM pizza_runner.runner_orders ro
INNER JOIN pizza_runner.customer_orders co 
  USING(order_id)
WHERE ro.pickup_time != 'null'
),
order_pizza_sum AS (
SELECT
  order_id,
  numeric_distance_km,
  SUM (
    CASE 
      WHEN pizza_id = 1 THEN 12
      WHEN pizza_id = 2 THEN 10
    END
  ) AS order_pizza_store_total
FROM pizza_runner_profit
GROUP BY order_id, numeric_distance_km
ORDER BY order_id
),
delivery_driver_cost AS (
SELECT 
  order_id,
  order_pizza_store_total,
  numeric_distance_km::NUMERIC * 0.3 AS driver_expense,
  order_pizza_store_total - (numeric_distance_km * 0.3) AS store_order_takehome
FROM order_pizza_sum
)
-- USING LIMIT here doesn't impact the window that needs to be summed for each order_takehome, just limits the same value repeating for all rows from each order_delivery below
SELECT 
  SUM(store_order_takehome) OVER() AS take_home_revenue
FROM delivery_driver_cost
LIMIT 1;


-------------------------- End of Section D ----------------------------