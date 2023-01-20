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