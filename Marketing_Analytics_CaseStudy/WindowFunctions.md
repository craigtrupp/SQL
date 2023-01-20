# Windows Functions

In this tutorial we will look into window functions which are an absolutely critical component of our marketing analytics case study.

This guide will aim to cover almost everything you’ll need to know about all the `window` functions and how to apply them in multiple different scenarios as you encounter various problems in your data journey.

Previously we have seen some ways to use window functions multiple times throughout Serious SQL so far. We just used the `PERCENT_RANK` and `ROW_NUMBER` window functions in our last SQL problem solving tutorial, however - we are yet to really dig into the details and understand what is actually going on under the hood!

Window functions or analytical functions are used practically everywhere in the data world and they are super useful! However they are not the most simple or intuitive to understand at first - this tutorial is here to help you gain that deep level of understanding.

---

<br>

## Introduction
After failing to truly understand window functions as a junior data analyst - I realised many years later that there was a better way to frame up the learning process.

Some of the main concepts we’ll cover in this section of the tutorial include:

* The different components that make up a window function
* How window functions are different to regular group by functions
* Basic operations we can perform using window functions
* Advanced applications of window functions


**Firstly** - let’s start with some basic definitions. 

<br>

## Basics Components
Window functions are operations or calculations performed on `“window frames”` or put simply, groups of rows in a dataset.

Just a warning that some of these things I’m going to describe in the following section might not instantly make sense, but bear with it - because after the next few following sections, hopefully things will become much clearer!

Window functions consist of the following components:

![Window Functions Components](images/wf_bcomponents.png)

<br>

---

<br>

## Understanding Partition By

One of the easiest ways to understand the how the `PARTITION BY` component of window functions worked was to compare it to a basic `GROUP BY` query.

Let’s start with this super simple example of an aggregate group by sum and its equivalent basic sum window function.

The key things to note are the similarity of the `sum_sales` column output for each example - they are exactly the same!

![Partition By](images/wf_partitionby.png)

<br>

#### Basic Group By Sum - SQL Exectuion Flow
![Group By SQL Exectuion](images/wf_basicgroupbyagg.png)

<br>

#### Basic Window Function 
![Basic Window Function](images/wf_basicwf.png)

* Main difference is you can see that the while the `Group By` collapses all rows that are grouped together whereas the `Window Function` includes the rows collapsed or grouped together as well as display the `sales` column that the aggregate function is run on 

<br>

#### SQL Code
```sql
DROP TABLE IF EXISTS customer_sales;
CREATE TEMP TABLE customer_sales AS
WITH input_data (customer_id, sales) AS (
 VALUES
 ('A', 300),
 ('A', 150),
 ('B', 100),
 ('B', 200)
)
SELECT * FROM input_data;

-- Group By Sum
-- Note that the ORDER BY is only for output sorting purposes!
SELECT
  customer_id,
  SUM(sales) AS sum_sales
FROM customer_sales
GROUP BY customer_id
ORDER BY customer_id;

-- Sum Window Function
SELECT
  customer_id,
  sales,
  SUM(sales) OVER (
    PARTITION BY customer_id
  ) AS sum_sales
FROM customer_sales;
```
#### Respective Outputs
* `GroupBy`

|customer_id|sum_sales|
|-----|-------|
|A|450|
|B|300|

* `PARTITION BY`

|customer_id|sales|sum_sales|
|-----|-------|----|
|A|300|450|
|A|150|450|
|B|100|300|
|B|200|300|

<br>

### Partition By 2 Columns
We’ve already seen how a single column can be used with the `PARTITION BY` clause - let’s now inspect what happens when we partition by 2 columns.

In the visual example below - you can think of the partitioning as splitting the dataset into smaller groups based on the unique combination of column values from each input to the `PARTITION BY`

![Partition 2 Columns](images/wf_prt_2cols.png)

* Also note that we are not restricted to only using columns as inputs, we can use other derived expressions also, just like you would use in a regular SELECT statement.

#### SQL Code
```sql
-- we remove that existing customer_sales table first!
DROP TABLE IF EXISTS customer_sales;
CREATE TEMP TABLE customer_sales AS
WITH input_data (customer_id, sale_id, sales) AS (
 VALUES
 ('A', 1, 300),
 ('A', 1, 150),
 ('A', 2, 100),
 ('B', 3, 200)
)
SELECT * FROM input_data;

-- Sum Window Function with 2 columns in PARTITION BY
SELECT
  customer_id,
  sales,
  SUM(sales) OVER (
    PARTITION BY
      customer_id,
      sale_id
  ) AS sum_sales
FROM customer_sales;
```

|customer_id|sales|sum_sales|
|-----|-------|----|
|A|300|450|
|A|150|450|
|A|100|100|
|B|200|300|

* The `sale_id` is the key take-away here, using it as a secondary **grouping** argument within our `PARTITION BY` only groups the `customer_id` together should it also share the `sale_id`

<br>

### Multiple Level Partition By
We can also use **different levels** for **multiple window functions** in a single query - there is one very specific reason why we usually prefer to use window functions to perform multiple level aggregations in this way compared to other methods.

We also demonstrate the `empty OVER clause` in the query below to calculate the `total_sales` column for our dataset.

![Multiple Level](images/wf_mlprtby.png)

#### SQL Code
```sql
SELECT
  customer_id,
  sale_id,
  sales,
  SUM(sales) OVER (
    PARTITION BY
      customer_id,
      sale_id
  ) AS sum_sales,
  SUM(SALES) OVER (
    PARTITION BY customer_id
  ) AS customer_sales,
  SUM(SALES) OVER () AS total_sales
FROM customer_sales;
```

|customer_id|sale_id|sales|sum_sales|customer_sales|total_sales|
|-----|-------|---------|-----|-------|----|
|A|1|300|450|550|750|
|A|1|150|450|550|750|
|A|2|100|100|550|750|
|B|3|200|200|200|750|

#### Three Window functions
* `sum_sales` is using the multiple `PARTITION` for the customer and specific sale_id
* `customer_sales` is using just the single level `PARTITION` to group customer sales totals even if purchased with a different sale_id
* `total_sales` is the SUM of the entire individual sales column irrespective of the customer or sale identifier
    * empty window frame or entire dataset 

<br>

### Multiple Calculations
We can also apply multiple different window function calculations instead of just using the `SUM` function like we’ve been using for all the previous examples.

In the following example, we demonstrate how to use `AVG` and `MAX` window functions.

![Multiple Calculations](images/wf_multilevelcalc.png)
* Below is an example of using multiple aggregations on partitioned groups or over empty window frames (aka entire dataset)

```sql
SELECT
  customer_id,
  sale_id,
  sales,
  SUM(sales) OVER (
    PARTITION BY
      customer_id,
      sale_id
  ) AS sum_sales,
  ROUND(
    AVG(sales) OVER (
        PARTITION BY
         customer_id,
         sale_id
    ),
    2
  ) AS avg_customer_saleid
  -- the average customer sales is rounded to 2 decimals!
  ROUND(
    AVG(sales) OVER (
      PARTITION BY customer_id
    ),
    2
  ) AS avg_cust_sales,
  MAX(sales) OVER () AS max_sales
FROM customer_sales;
```
|customer_id|sale_id|sales|sum_sales|avg_customer_saleid|avg_cust_sales|max_sales|
|-----|-------|---------|-----|-------|----|----|
|A|1|300|450|225.00|183.33|300|
|A|1|150|450|225.00|183.33|300|
|A|2|100|100|100.00|183.33|300|
|B|3|200|200|200.00|200.00|300|

* `sum_sales` get the sum of a parituclar customer and that unique sale_id
* `avg_customer_saleid` average purchase price for a particular customer and that unique sale_id
* `avg_cust_sales` another average purchase price but only partitioned by the unique customer (running average for a customer for each purchase purchase made)
    * Customer A has $550 in our example above and divided by total rows (3) == 183.33
* `max_sales` MAX aggregate function running over the entire dataset (hence the same return for each row)


<br>

### Empty or Missing Partition By
![Combine](images/wf_wf_grpby.png)
* Challenge from the above sample created sales table is to use both a `window` function and standard `GROUP BY` to achieve the following posed question above

```sql
-- Combine OVER and GROUPBY logic 
SELECT 
  customer_id,
  SUM(sales) AS customer_total_sales,
  ROUND(
    SUM(sales) / SUM(SUM(sales)) 
      OVER(), 
      2) * 100 
      AS customer_percentage_total_sales,
  SUM(SUM(sales)) OVER() AS total_windowf_sales
  FROM customer_sales
  GROUP BY customer_id;
```
|customer_id|customer_total_sales|customer_percentage_total_sales|total_windowf_sales|
|-------|-------|-------|-----|
|A|550|73.00|750|
|B|200|27.00|750|

* The `ROUND` function above quicky summed up
    * the initial `SUM(sales)` is essentialy the alias above (customer_total_sales). This column alias can't be referenced
    * next the `SUM(SUM(sales))` value is our grouped by aggregate  divided by the total SUM value of the subsequent `OVER()` window function
        * Ex : 550 customer A total sales divided by 750 for 73%
* The `OVER()` function runs after the `GROUP BY` to get the total window sales column data 

<br>

We mentioned that the default behaviour for `PARTITION BY` when the window function has an empty `OVER` clause is to perform calculations across all the rows of the dataset - in fact, we’ve also used this exact strategy before for parts of our data exploration section earlier!

This is directly copied from the Dealing with Duplicates tutorial earlier when we were inspecting the `health.user_logs` table to calculate the percentage of values of the various measures available in the dataset.

* Let’s also inspect that measure column and take a look at the most frequent values within this column using a `GROUP BY` and `ORDER BY DESC` combo from the last tutorial - let’s also throw in that percentage column that we went through also!


![OVER & GROUPBY](images/wf_emprt_health.png)

* Like above with our created temp tables, we can use a similar logic to leverage a `GROUPBY` and `OVER` query to pull a different aggregate percentage
* Similar in that the window function includes the aggregate function on the column being grouped by 
    * COUNT(*) gets total frequency counts for each measurement
    * This value is then used and divided by the SUM of all total measurements to give us the respective percentage (38692/43890 == 0.88156)

---

<br>

## SQL Logical Execution Order

In a nutshell - all SQL queries are “ran” in the following order:

1) FROM
    * WHERE filters
    * ON table join conditions
2) GROUP BY
3) SELECT aggregate function calculations
4) HAVING
5) Window functions
6) ORDER BY
7) LIMIT

Note: that the actual execution order might differ slightly from the below due to the SQL optimizer making its own decisions for performance reasons!

We can use our previous query to break this down and understand how it works - can you identify which SQL components we have below?

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*) / SUM(COUNT(*)) OVER (),
    2
  ) AS percentage
FROM health.user_logs
GROUP BY measure
ORDER BY frequency DESC;
```

* In the following parts of this tutorial - we will reconstruct our above query from the ground up to see how each component interacts with eachother to build up our understanding of the logical execution order.

<br>

### Basic SELECT statement

First let’s select the `measure` and `value` values from the `health.user_logs` table as our starting point - we’ll also limit this output to the first 10 rows:

```sql
SELECT
  measure,
  measure_value
FROM health.user_logs
LIMIT 10;
```
|measure|measure_value|
|------|-----|
|weight|46.03959|
|blood_glucose|97|
|blood_glucose|120|
|blood_glucose|232|
|blood_pressure|140|
|blood_glucose|166|
|blood_glucose|142|
|weight|129.060012817|
|blood_glucose|138|
|blood_glucose|210|

<br>

### Group By and Aggregate Count

Next let’s add the `COUNT(*)` value and the `GROUP BY` measure into our query - let’s also we’ll remove that LIMIT 10 as we will only have 3 rows in our query output:

```sql
SELECT
  measure,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY measure;
```

|measure|frequency|
|-----|------|
|blood_glucose|38692|
|blood_pressure|2417|
|weight|2782|

<br>

### Window Function
Let’s add onto our query by implementing our denominator value for percentage column from our query as a new total column.

We combine our frequency `COUNT(*)` metric with the `SUM` window function and an empty window frame () used with the `OVER` clause.

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM health.user_logs
GROUP BY measure;
```

|measure|frequency|total|
|-----|------|----|
|blood_glucose|38692|43891|
|blood_pressure|2417|43891|
|weight|2782|43891|

* **Reminder** : We can't use the alias of the `COUNT(*)` **frequency** unles we used a CTE or subquery

```sql
-- CTE method
WITH summarised_data AS (
SELECT
  measure,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY measure
)
SELECT
  measure,
  frequency,
  SUM(frequency) OVER () AS total
FROM summarised_data;

-- Alternative Subquery style
SELECT
  measure,
  frequency,
  SUM(frequency) OVER () AS total
FROM (
  SELECT
    measure,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY measure
) AS summarised_data;
```

* Produces same table output as above SUM and WINDOW function 

<br>

### HAVING Clause
`HAVING` is used to filter out records based off the `GROUP BY` results - in this example the measure values. It is similar to a WHERE filter but can only be applied to the GROUP BY columns.

Let’s use HAVING measure != 'weight' to see what happens to our query output. Try answering the following question before you take a look at the result “what do you expect to happen to that total value to change?”

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM health.user_logs
GROUP BY measure
HAVING measure != 'weight';
```

|measure|frequency|total|
|-----|------|-----|
|blood_glucose|38692|41109|
|blood_pressure|2417|41109|

* No surprises here (reviewing the order above the  `HAVING` clause excludes the measure not needed before then performing the WINDOW sum count for the resulting return made by `HAVING`

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM health.user_logs
GROUP BY measure
HAVING frequency > 2800;
```

* **ERROR**:  column "frequency" does not exist
LINE 7: HAVING frequency > 2800;
    * Alias not available


```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM health.user_logs
GROUP BY measure
HAVING COUNT(*) > 2800;
```

|measure|frequency|total|
|----|-----|-----|
|blood_glucose|38692|38692|

* We ca use the frequency aggregate `COUNT` called on the grouped measure to limit any fequency not over the threshold above

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM health.user_logs
GROUP BY measure
HAVING total > 2800;
```
* column `"total"` does not exist
LINE 7: HAVING frequency > 2800;
    * similar when we tried to alias frequency using the resulting `WINDOW` function the HAVING clause doesn't know what to reference as it occurs first in the sequence (see order above)

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM health.user_logs
GROUP BY measure
HAVING SUM(COUNT(*)) OVER () > 2800;
```
* ``ERROR``:  window functions are not allowed in HAVING LINE 7: HAVING SUM(COUNT(*)) OVER () > 2800;
* Similary when applying the same window function in the `HAVING` clause, we see the above error

<br>

So it looks like we can use all of our non-window function outputs given that they exist already in the table OR if we can perform an aggregate function inside the `GROUP BY` query!

* So after trying all of these different variations - we can see that we can only use the outputs from the `GROUP BY` query in the `HAVING` clause.

<br>

### WHERE Filters

Let’s say that we want apply that `measure_value >= 100` inside a `WHERE` filter instead of the `HAVING` clause - what do you notice about the frequency and the total values compared to before?

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM health.user_logs
WHERE measure_value >= 100
GROUP BY measure;
```

|measure|frequency|total|
|----|-----|----|
|blood_glucose|34068|36399|
|blood_pressure|1725|36399|
|weight|606|36399|

Both the frequency and total values dropped - because we used that `WHERE` filter to get rid of the values - so it seems like that `WHERE` definitely occurs before the `GROUP BY`

<br>

Let’s also apply that `HAVING` clause we used to remove all weight values - HAVING measure != 'weight'. What do you notice about the new total value this time?

```sql
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM health.user_logs
WHERE measure_value >= 100
GROUP BY measure
HAVING measure != 'weight';
```

|measure|frequency|total|
|-----|------|-----|
|blood_glucose|34068|35793|
|blood_pressure|1725|35793|

The total reduces by exactly the 606 records we saw from the previous query after applying the `WHERE` filter only. Here we can demonstrate that the window function definitely applies only after the `HAVING` step in our query execution order.

Here we can demonstrate how the window function only ever gets calculated after both the `WHERE` and `HAVING` clauses - something which we really need to keep in mind when we are implementing our window function calculations!

<br>

### ORDER BY and LIMIT
The `ORDER BY` and `LIMIT` are our final pieces to inspect for the execution order.

There isn’t much to mention about the `ORDER BY` apart from the fact that you should avoid using it within subqueries, CTEs or even temporary tables, unless you really need to (some ordered join examples are the only exception) - and usually it is when it’s used in conjunction with a `LIMIT` clause to only keep the top 10 records sorted by a specific column, for example.

The `LIMIT` however has some implications depending on where you want to use it within the different components.

For temporary tables - `LIMIT` acts just like it would for our regular SQL outputs, it will only keep the rows specified in the `LIMIT` clause inside the final temporary table.

However for `CTEs` and `subqueries` - the `LIMIT` step will actually be applied directly inside to reduce the number of records which will be used in the subsequent stages of the SQL query. This clearly has a huge impact on what your expected results will be!

```sql
-- CTE method
WITH summarised_data AS (
SELECT
  measure
FROM health.user_logs
LIMIT 1000
)
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM summarised_data
GROUP BY measure;


-- Alternative subquery method
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM (
  SELECT
    measure
  FROM health.user_logs
  LIMIT 1000
) AS summarised_data
GROUP BY measure;
```

|measure|frequency|total|
|------|------|-----|
|blood_glucose|853|1000|
|blood_pressure|68|1000|
|weight|79|1000|

* Both queries above would return the same result in which the `LIMIT` ran prio to the subsequent execution only ever showing 1000 total results from our `WINDOW` summary

<br>

#### LIMIT Implications & Random Numbers
Limiting examples from `CTEs` are actually a really great way to quickly test and debug queries without needing to run queries on large datasets entirely. However there is one super large caveat!

There is no real guarantee that the records returned after a `LIMIT` are truly representative of the true dataset that you are actually running the queries on - can you identify the reason why?

There is a more advanced method which we can use to randomly sample rows from the dataset without requiring us to use an `ORDER BY` clause on a specific column or SQL expression.

This is actually a really common technique we apply in many many data science applications as we usually down sample or take random splits of datasets to better understand behaviour of large datasets without needing to perform calculations on every single row in a 1 trillion row dataset!

We can use the `RANDOM()` function to generate us a random number and use it with a `WHERE` filter to only keep a 10% random sample for example:

```sql
-- CTE method
WITH summarised_data AS (
SELECT
  measure
FROM health.user_logs
-- RANDOM() returns 0 <= value < 1 when there are no argument inputs!
WHERE RANDOM() <= 0.1
)
SELECT
  measure,
  COUNT(*) AS frequency,
  SUM(COUNT(*)) OVER () AS total
FROM summarised_data
GROUP BY measure;
```

|measure|frequency|total|
|-----|-----|-----|
|blood_pressure|249|4318|
|blood_glucose|3809|4318|
|weight|260|4318|

<br>

### Summary of SQL Logical Order
Finally we’ve reached to the end of this logical execution order section after a few interesting detours!

1) FROM
    * WHERE filters
    * ON table join conditions
2) GROUP BY
3) SELECT statements
    * Derived column expressions
    * Aggregate functions
4) HAVING
5) Window functions
6) ORDER BY
7) LIMIT

The most important thing we need to take out of this previous section is exactly where the window functions take place - all of the joins, group by and where filters take place before. 

<br>

---

<br>

## Ordered Window Functions
In the previous window function examples - we have always been dealing with records which did not need to be ordered, we only applied the `PARTITION BY` clause to define the window frame.

In the following section we will start looking into that `ORDER BY` component of window functions and start to understand what it is doing - in a nutshell, the `ORDER BY` acts in exactly the same way as a regular `ORDER BY` clause would act in a standard SQL query.

Logically - we can think of the `ORDER BY` happening after the `PARTITION BY` clause as the sorting of records will happen within each partition or group that is separated as part of the window function.

![Rnk Window 1](images/wk_rnkwdf_prt_ord.png)

![Rnk Window 2](images/wk_rnkwdf_prt_ord_desc.png)

* A handy way to think of the two calls working for our resulting 