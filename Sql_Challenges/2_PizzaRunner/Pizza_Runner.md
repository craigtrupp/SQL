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

`A. Pizza Metrics`
1. How many pizzas were ordered?
```sql
-- How many pizzas were ordered?
SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM pizza_runner.customer_orders;
```
|unique_customer_orders|
|----|
|10|
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?