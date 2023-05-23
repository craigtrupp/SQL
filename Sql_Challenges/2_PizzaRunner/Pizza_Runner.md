![Pizza Runner](images/Pizza_Runner_2.png)

## Intro
Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

<br>

### **Available Data** 
Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

![PRunner ERD](images/erd_prunner.png)

--- 

<br>

## `Datasets` (Tables)

### **Table 1: Runners**
The `runners` table shows the `registration_date` for each new runner
```sql
SELECT *
FROM pizza_runner.runners
LIMIT 5;
```
|runner_id|registration_date|
|----|----|
|1|2021-01-01|
|2|2021-01-03|
|3|2021-01-08|
|4|2021-01-15|

<br>

### **Table 2: customer_orders**
Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order.

The `pizza_id` relates to the type of pizza which was ordered whilst the exclusions are the `ingredient_id` values which should be removed from the pizza and the extras are the ingredient_id values which need to be added to the pizza.

Note that customers can order multiple pizzas in a single order with varying exclusions and extras values even if the pizza is the same type!

The `exclusions` and `extras` columns will need to be cleaned up before using them in your queries.

|order_id|customer_id|pizza_id|exclusions|extras|order_time|
|----|----|----|----|-----|-----|
|1|101|1|||2021-01-01 18:05:02.000|
|2|101|1|||2021-01-01 19:00:52.000|
|3|102|1|||2021-01-02 23:51:23.000|
|3|102|2||null|2021-01-02 23:51:23.000|
|4|103|1|4||2021-01-04 13:23:46.000|

<br>

### **Table 3: runner_orders**
After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.

The `pickup_time` is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The distance and duration fields are related to how far and long the runner had to travel to deliver the order to the respective customer.

There are some known data issues with this table so be careful when using this in your queries - make sure to check the data types for each column in the ERD!

```sql
SELECT *
FROM pizza_runner.runner_orders
LIMIT 5;
```
|order_id|runner_id|pickup_time|distance|duration|cancellation|
|---|----|-----|-----|----|-----|
|1|1|2021-01-01 18:15:34|20km|32 minutes||
|2|1|2021-01-01 19:10:54|20km|27 minutes||
|3|1|2021-01-03 00:12:37|13.4km|20 mins|null|
|4|2|2021-01-04 13:53:03|23.4|40|null|
|5|3|2021-01-08 21:10:57|10|15|null|

<br>

### **Table 4: pizza_names**
At the moment - Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!
```sql
SELECT *
FROM pizza_runner.pizza_names
LIMIT 5;
```
|pizza_id|pizza_name|
|----|-----|
|1|Meatlovers|
|2|Vegetarian|

* Confirmed only two rows in this table 

<br>

### **Table 5: pizza_recipes**
Each `pizza_id` has a standard set of toppings which are used as part of the pizza recipe.
```sql
SELECT *
FROM pizza_runner.pizza_recipes
LIMIT 5;
```
|pizza_id|toppings|
|----|----|
|1|1, 2, 3, 4, 5, 6, 8, 10|
|2|4, 6, 7, 9, 11, 12|

<br>

## **Table 6: pizza_toppings**
This table contains all of the `topping_name` values with their corresponding `topping_id` value

```sql
SELECT
  COUNT(*)
FROM pizza_runner.pizza_toppings;
```
|count|
|----|
|12|


```sql
SELECT *
FROM pizza_runner.pizza_toppings
LIMIT 12;
```
|topping_id|topping_name|
|-----|-----|
|1|Bacon|
|2|BBQ Sauce|
|3|Beef|
|4|Cheese|
|5|Chicken|
|6|Mushrooms|
|7|Onions|
|8|Pepperoni|
|9|Peppers|
|10|Salami|
|11|Tomatoes|
|12|Tomato Sauce|

---

<br>

### `Case Study Questions`
This case study has LOTS of questions - they are broken up by area of focus including: 
* Pizza Metrics 
* Runner and Customer Experience 
* Ingredient Optimisation 
* Pricing and Ratings 
* **Bonus DML Challenges** 

Each of the following case study questions can be answered using a single SQL statement.

Again, there are many questions in this case study - please feel free to pick and choose which ones you’d like to try!

Before you start writing your SQL queries however - you might want to investigate the data, you may want to do something with some of those null values and data types in the `customer_orders` and `runner_orders` tables!

<br>

`A. Pizza Metrics` - My approaches

**1.** How many pizzas were ordered?
```sql
-- How many pizzas were ordered?
SELECT COUNT(pizza_id) AS total_pizza_count
FROM pizza_runner.customer_orders;
```
|total_pizza_count|
|----|
|14|

<br>

**2.** How many unique customer orders were made?
```sql
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM pizza_runner.customer_orders;
```
|unique_customer_orders|
|----|
|10|

<br>

**3.** How many successful orders were delivered by each runner?
* Was seeing some odd returns with LIKE type character returns so need to either use a CTE or maybe a temp table for easier querying
```sql
SELECT
  order_id,
  pickup_time,
  LENGTH(pickup_time),
  cancellation,
  LENGTH(cancellation)
FROM pizza_runner.runner_orders
ORDER BY order_id;
```
|order_id|pickup_time|cancellation|length|
|-----|-----|-----|-----|
|1|2021-01-01 18:15:34||0|
|2|2021-01-01 19:10:54||0|
|3|2021-01-03 00:12:37|null|null|
|4|2021-01-04 13:53:03|null|null|
|5|2021-01-08 21:10:57|null|null|
|6|null|Restaurant Cancellation|23|
|7|2021-01-08 21:30:45|null|4|
|8|2021-01-10 00:15:02|null|4|
|9|null|Customer Cancellation|21|
|10|2021-01-11 18:50:20|null|4|

* Alright .. so we can see that the **LENGTH** readout exposes that the `cancellation` column has some unique vaues of actual **null** (or no length values) and strings that say **null** but actually are a string, in order to determine a successful order, need to standardize how we define cancellation.
* Seeing that the cancellation varies but is based on the pickup time existing, we can get the successful orders as so

```sql
-- Like the Idea of using the pickup time length (4 if null so still a value to standardize cancellation)
DROP TABLE IF EXISTS successful_orders;
CREATE TEMP TABLE successful_orders AS 
SELECT * 
FROM pizza_runner.runner_orders
WHERE pickup_time NOT ILIKE '%null%';

-- UPDATE TABLE to set consistent cancellation value
UPDATE successful_orders
SET cancellation = NULL;
```

* Now we can get the counts pretty straightforward
```sql
SELECT 
  runner_id,
  COUNT(DISTINCT order_id) AS successful_orders_per_runner
FROM successful_orders
GROUP BY runner_id
ORDER BY successful_orders_per_runner DESC;
```
|runner_id|successful_orders_per_runner|
|----|-----|
|1|4|
|2|3|
|3|1|

<br>

* ... Could also just do something like this for #3
```sql
SELECT
  runner_id,
  COUNT(DISTINCT order_id) AS successful_orders
FROM pizza_runner.runner_orders
WHERE cancellation IS NULL
  OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY runner_id
ORDER BY successful_orders DESC;
```

4. How many of each type of pizza was delivered?
* We'd still wanna use the `successful_orders` temp_table here as it holds all unique order_ids that were **delivered**
* A `LEFT SEMI JOIN` can only return columns from the left-hand table, and yields one of each record from the left-hand table where there is one or more matches in the right-hand table (regardless of the number of matches). It's equivalent to (in standard SQL):
```sql
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
```
|pizza_name|pizza_delivery_count|
|----|-----|
|Meatlovers|9|
|Vegetarian|3|

<br>

* Quicker approach w/o CTE
```sql
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
```
|pizza|delivered_pizzas_count|
|-----|-----|
|Meatlovers|9|
|Vegetarian|3|

* See alternative approach as well

<br>


**5.** How many Vegetarian and Meatlovers were ordered by each customer?
* Since this question doesn’t quite have the successful delivery criteria - we do not need to look at the cancellations!
```sql
SELECT 
  co.customer_id AS customer,
  pn.pizza_name AS pizza_type,
  COUNT(*) AS customer_pizza_counts
FROM pizza_runner.customer_orders co 
INNER JOIN pizza_runner.pizza_names pn 
  ON co.pizza_id = pn.pizza_id
GROUP BY customer, pizza_type
ORDER BY customer,  customer_pizza_counts DESC;
```
|customer|pizza_type|customer_pizza_counts|
|----|----|----|
|101|Meatlovers|2|
|101|Vegetarian|1|
|102|Meatlovers|2|
|102|Vegetarian|1|
|103|Meatlovers|3|
|103|Vegetarian|1|
|104|Meatlovers|3|
|105|Vegetarian|1|

<br>

**6.** What was the maximum number of pizzas delivered in a single order?
* Note delivered included in the `WHERE` statement to limit how many rows to perform aggregate count on
```sql
-- What was the maximum number of pizzas "delivered" in a single order?
SELECT 
  co.order_id,
  COUNT(*) AS customer_order_pizza_count
FROM pizza_runner.customer_orders co 
INNER JOIN pizza_runner.runner_orders ro 
  ON co.order_id = ro.order_id
WHERE
-- clause to filter joined table where the order was cancelled (aka - not delivered )
  (ro.cancellation IS NULL OR ro.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation'))
GROUP BY co.order_id
ORDER BY customer_order_pizza_count DESC;
```
|order_id|customer_order_pizza_count|
|-----|-----|
|4|3|
|10|2|
|3|2|
|7|1|
|1|1|
|8|1|
|5|1|
|2|1|

* Maximum number would be three or just the first result of an included LIMIT in the above query

```sql
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
```
|unique_order|pizzas_delivered|
|-----|-----|
|4|3|
|10|2|
|3|2|
|7|1|
|1|1|
|8|1|
|5|1|
|2|1|

<br>

**7.** For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
* `Note`: a non-change for either extras or exclusions can either be a **blank string - length = 0**, a **null value**, or a **value of null with a length of 4**
```sql
-- SUM CASE WHEN type statement
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
```
|customer_id|customer_pizza_alterations|no_customer_pizza_alterations|
|-----|-----|-----|
|101|0|2|
|102|0|3|
|103|3|0|
|104|2|1|
|105|1|0|

<br>

8. How many pizzas were delivered that had both exclusions and extras?
* First part of CTE - simply take column value for exclusions or extra if not an empty string of the string of null
```sql
 SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE WHEN exclusions IN ('null', '') THEN NULL ELSE exclusions END AS exclusions,
    CASE WHEN extras IN ('null', '') THEN NULL ELSE extras END AS extras,
    order_time
  FROM pizza_runner.customer_orders
```
|order_id|customer_id|pizza_id|exclusions|extras|order_time|
|----|-----|----|-----|-----|-----|
|1|101|1|null|null|2021-01-01 18:05:02.000|
|2|101|1|null|null|2021-01-01 19:00:52.000|
|3|102|1|null|null|2021-01-02 23:51:23.000|
|3|102|2|null|null|2021-01-02 23:51:23.000|
|4|103|1|4|null|2021-01-04 13:23:46.000|

* Full CTE then with a Conditional `count`
```sql
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
```
|exclusions_extras_total_pizzas_count|
|-----|
|2|

<br>

**9.** What was the total volume of pizzas ordered for each hour of the day?
* Since orders do not necessarily mean delivered, can use the `order_time`
```sql
SELECT 
  DATE_PART('hour', order_time) AS order_hour,
  COUNT(order_id) AS hour_total_orders
FROM pizza_runner.customer_orders
GROUP BY order_hour
ORDER BY hour_total_orders DESC;
```
|order_hour|hour_total_orders|
|-----|-----|
|18|3|
|23|3|
|21|3|
|13|3|
|11|1|
|19|1|

<br>

10. What was the volume of orders for each day of the week?
```SQL
-- What was the volume of orders for each day of the week?
SELECT
-- TO_CHAR method very helpful here to group by
  INITCAP(TO_CHAR(order_time, 'day')) AS order_day,
  COUNT(order_id) AS DAY_total_orders
FROM pizza_runner.customer_orders
GROUP BY order_day
ORDER BY order_day DESC;
```
|order_day|day_total_orders|
|-----|----|
|Sunday|1|
|Saturday|3|
|Monday|5|
|Friday|5|

* Slightly different approach but does order a bit better
```sql
SELECT
  TO_CHAR(order_time, 'Day') AS day_of_week,
  COUNT(order_id) AS pizza_count
FROM pizza_runner.customer_orders
GROUP BY day_of_week, DATE_PART('dow', order_time)
ORDER BY DATE_PART('dow', order_time);
```
|day_of_week|pizza_count|
|---|----|
|Sunday|1|
|Monday|5|
|Friday|5|
|Saturday|3|

<br>

`A. Pizza Metrics` - Alternative approaches

**4.** How many of each type of pizza was delivered?
* WHERE EXISTS is filtering for the the orders not deemed as cancelled.
```sql
SELECT
  t2.pizza_name,
  COUNT(t1.*) AS delivered_pizza_count
FROM pizza_runner.customer_orders AS t1
INNER JOIN pizza_runner.pizza_names AS t2
  ON t1.pizza_id = t2.pizza_id
WHERE EXISTS (
  SELECT 1 FROM pizza_runner.runner_orders AS t3
  WHERE t1.order_id = t3.order_id
  AND (
    t3.cancellation IS NULL
    OR t3.cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation')
  )
)
GROUP BY t2.pizza_name
ORDER BY delivered_pizza_count DESC;
```
|pizza_name|delivered_pizza_count|
|---|----|
|Meatlovers|9|
|Vegetarian|3|

<br>

**5.** How many of each pizza type for each customer
```sql
SELECT
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS meatlovers,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS vegetarian
FROM pizza_runner.customer_orders
GROUP BY customer_id
ORDER BY customer_id;
```
|customer_id|meatlovers|vegetarian|
|-----|-----|-----|
|101|2|1|
|102|2|1|
|103|3|1|
|104|3|0|
|105|0|1|


<br>

**6.**  What was the maximum number of pizzas delivered in a single order? (back to order criteria - successfully ordered)
```sql
WITH cte_ranked_orders AS (
  SELECT
    order_id,
    COUNT(*) AS pizza_count,
    RANK() OVER (
      ORDER BY COUNT(*) DESC
    ) AS count_rank
  FROM pizza_runner.customer_orders AS t1
  WHERE EXISTS (
    SELECT 1 FROM pizza_runner.runner_orders AS t2
    WHERE t1.order_id = t2.order_id
    AND (
      t2.cancellation IS NULL
      OR t2.cancellation NOT IN ('Restaurant Cancellation', 'Cstomer Cancellation')
    )
  )
  GROUP BY order_id
)
SELECT pizza_count FROM cte_ranked_orders WHERE count_rank = 1;
```
|pizza_count|
|----|
|3|

<br>

---

<br>

`B Runner and Customer Experience`

**1.** How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```sql
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
```
|registration_week|runners|
|-----|-----|
|2021-01-01|2|
|2021-01-08|1|
|2021-01-15|1|

<br>

**2.** What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
* One more thing to be aware of is how we will be joining our customer and runner order tables - how will we deal with the duplicates from the customer table?
```sql
SELECT
  DISTINCT ro_1.order_id,
  ro_1.pickup_time,
  co_2.order_time,
  ro_1.pickup_time::timestamp - co_2.order_time AS pickup_time_diff,
  AGE(ro_1.pickup_time::timestamp, co_2.order_time) AS age_func_return,
  DATE_PART('minutes', AGE(ro_1.pickup_time::timestamp, co_2.order_time))::INTEGER
FROM pizza_runner.runner_orders ro_1
INNER JOIN pizza_runner.customer_orders co_2
  USING(order_id)
WHERE 
  ro_1.pickup_time != 'null' OR ro_1.pickup_time IS NULL
ORDER BY order_id;
```
|order_id|pickup_time|order_time|pickup_time_diff|age_func_return|date_part|
|----|-----|-----|------|-----|-----|
|1|2021-01-01 18:15:34|2021-01-01 18:05:02.000|{ "minutes": 10, "seconds": 32 }|{ "minutes": 10, "seconds": 32 }|10|
|2|2021-01-01 19:10:54|2021-01-01 19:00:52.000|{ "minutes": 10, "seconds": 2 }|{ "minutes": 10, "seconds": 2 }||10|
|3|2021-01-03 00:12:37|2021-01-02 23:51:23.000|{ "minutes": 21, "seconds": 14 }|{ "minutes": 21, "seconds": 14 }|21|
|4|2021-01-04 13:53:03|2021-01-04 13:23:46.000|{ "minutes": 29, "seconds": 17 }|{ "minutes": 29, "seconds": 17 }|29|
|5|2021-01-08 21:10:57|2021-01-08 21:00:29.000|{ "minutes": 10, "seconds": 28 }|{ "minutes": 10, "seconds": 28 }|10|
|7|2021-01-08 21:30:45|2021-01-08 21:20:29.000|{ "minutes": 10, "seconds": 16 }|{ "minutes": 10, "seconds": 16 }|10|
|8|2021-01-10 00:15:02|2021-01-09 23:54:33.000|{ "minutes": 20, "seconds": 29 }|{ "minutes": 20, "seconds": 29 }|20|
|10|2021-01-11 18:50:20|2021-01-11 18:34:49.000|{ "minutes": 15, "seconds": 31 }|{ "minutes": 15, "seconds": 31 }|15|

* We can see that the string `pickup_time` needs to be cast to a timestamp as the value is a string with the WHERE condition
* Next we'll need to use the `DATE_PART` function with the return from either the `AGE` function or direct interval returned from the subtraction

```sql
-- What was the average time in "minutes" it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
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
```
|avg_minutes_pickup_for_runner_from_order|
|----|
|15.625|

<br>

