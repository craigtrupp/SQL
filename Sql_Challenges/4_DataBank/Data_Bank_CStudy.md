## Data Bank
![Data Bank](images/case_4_intro.png)

### **Introduction**
There is a new innovation in the financial industry called `Neo-Banks`: new aged digital only banks without physical branches.

Danny thought that there should be some sort of intersection between these new age banks, cryptocurrency and the data world…so he decides to launch a new initiative - **Data Bank**!

Data Bank runs just like any other digital bank - but it isn’t only for banking activities, they also have the world’s most secure distributed data storage platform!

Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts. There are a few interesting caveats that go with this business model, and this is where the Data Bank team need your help!

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.

* This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

<br>

### `Available Data`
The Data Bank team have prepared a data model for this case study as well as a few example rows from the complete dataset below to get you familiar with their tables.

#### **ERD**
![ERD](images/erd_cs4.png)

`Table 1: Regions`

Just like popular cryptocurrency platforms - Data Bank is also run off a network of nodes where both money and data is stored across the globe. In a traditional banking sense - you can think of these nodes as bank branches or stores that exist around the world.

This **regions** table contains the `region_id` and their respective `region_name` values
```sql
SELECT *
FROM data_bank.regions
LIMIT 5;
```
|region_id|region_name|
|----|----|
|1|Australia|
|2|America|
|3|Africa|
|4|Asia|
|5|Europe|

<br>

`Table 2: Customer Nodes`

Customers are randomly distributed across the nodes according to their region - this also specifies exactly which node contains both their cash and data.

This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!

Below is a sample of the top 5 rows of the `data_bank.customer_nodes`
```sql
SELECT *
FROM data_bank.customer_nodes
LIMIT 5;
```
|customer_id|region_id|node_id|start_date|end_date|
|----|----|----|----|----|
|1|3|4|2020-01-02|2020-01-03|
|2|3|5|2020-01-03|2020-01-17|
|3|5|4|2020-01-27|2020-02-18|
|4|5|4|2020-01-07|2020-01-19|
|5|3|3|2020-01-15|2020-01-23|

<br>

`Table 3: Customer Transactions`

This table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card.
```sql
SELECT *
FROM data_bank.customer_transactions
LIMIT 5;
```
|customer_id|txn_date|txn_type|txn_amount|
|-----|-----|-----|-----|
|429|2020-01-21|deposit|82|
|155|2020-01-10|deposit|712|
|398|2020-01-01|deposit|196|
|255|2020-01-14|deposit|563|
|185|2020-01-29|deposit|626|

---

<br>

### **Case Study Questions** 
The following case study questions include some general data exploration analysis for the nodes and transactions before diving right into the core business questions and finishes with a challenging final request!

#### `A. Customer Nodes Exploration`
1. How many unique nodes are there on the Data Bank system?
```sql
SELECT COUNT(DISTINCT node_id)
FROM data_bank.customer_nodes;

-- either works
WITH combinations AS (
SELECT DISTINCT
  node_id
FROM data_bank.customer_nodes
)
SELECT COUNT(node_id) FROM combinations;
```
|count|
|----|
|5|

<br>

**2.** What is the number of nodes per region?
    * Taking an initial look at the region, region_id grouping
```sql
SELECT 
  COUNT(*) AS region_id_name_count,
  region_id,
  region_name
FROM data_bank.regions
GROUP BY region_id, region_name
ORDER BY region_id_name_count DESC;
```
|region_id_name_count|region_id|region_name|
|-----|-----|-----|
|1|1|Australia|
|1|2|America|
|1|5|Europe|
|1|4|Asia|
|1|3|Africa|

```sql
-- Nodes per region (all in customer_nodes - can left/inner join)
SELECT
  cn.region_id,
  r.region_name,
  COUNT(DISTINCT node_id) AS region_unique_nodes,
  COUNT(node_id) AS region_total_nodes
FROM data_bank.customer_nodes AS cn
LEFT JOIN data_bank.regions AS r 
USING(region_id)
GROUP BY region_id, region_name
ORDER BY region_total_nodes DESC;
```
|region_id|region_name|region_unique_nodes|region_total_nodes|
|------|-----|-----|------|
|1|Australia|5|770|
|2|America|5|735|
|3|Africa|5|714|
|4|Asia|5|665|
|5|Europe|5|616|

<br>

**3**. How many customers are allocated to each region?
```sql
-- How many customers are allocated to each region?
SELECT
  cn.region_id,
  r.region_name,
  COUNT(DISTINCT cn.customer_id) AS unique_customer_region_allocation
FROM data_bank.customer_nodes AS cn
LEFT JOIN data_bank.regions AS r 
USING(region_id)
GROUP BY region_id, region_name
ORDER BY unique_customer_region_allocation DESC;
```
|region_id|region_name|unique_customer_region_allocation|
|----|-----|----|
|1|Australia|110|
|2|America|105|
|3|Africa|102|
|4|Asia|95|
|5|Europe|88|

<br>

**4.** How many days on average are customers reallocated to a different node?
    * Let's take a look at how we can get a LEAD'ing value first
```sql
SELECT
  customer_id,
  region_id,
  node_id,
  start_date,
  end_date,
  LEAD(start_date, 1) OVER(
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS next_customer_node_start_date
FROM data_bank.customer_nodes
WHERE customer_id = 1
ORDER BY customer_id, start_date;
```
|customer_id|region_id|node_id|start_date|end_date|next_customer_node_start_date|
|-----|----|-----|-----|-----|-----|
|1|3|4|2020-01-02|2020-01-03|2020-01-04|
|1|3|4|2020-01-04|2020-01-14|2020-01-15|
|1|3|2|2020-01-15|2020-01-16|2020-01-17|
|1|3|5|2020-01-17|2020-01-28|2020-01-29|
|1|3|3|2020-01-29|2020-02-18|2020-02-19|
|1|3|2|2020-02-19|2020-03-16|2020-03-17|
|1|3|2|2020-03-17|9999-12-31|null|

* Next need to get an `Age : Difference` for days in between nodes
```sql
-- How many days on average are customers reallocated to a different node?
-- I'm thinking a LEAD here for a window function with 
WITH subsequent_customer_node_date AS (
SELECT
  customer_id,
  region_id,
  node_id,
  start_date,
  end_date,
  LEAD(start_date, 1) OVER(
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS next_customer_node_start_date
FROM data_bank.customer_nodes
WHERE customer_id in (1, 2)
ORDER BY customer_id, start_date
),
total_days_between_nodes AS (
SELECT *,
EXTRACT('days' FROM AGE(next_customer_node_start_date, start_date)) as age_difference
FROM subsequent_customer_node_date
-- exclude current plan with end date set to future 9999-12-31 value
WHERE end_date <= NOW()
)
SELECT 
  *,
  ROUND(AVG(age_difference) OVER(
    PARTITION BY customer_id
  )::NUMERIC, 2) AS customer_avg_days_node_reallocation,
  ROUND(AVG(age_difference) OVER()::NUMERIC, 2) AS total_customer_avg_days_node_reallocation
FROM total_days_between_nodes;
```
|customer_id|region_id|node_id|start_date|end_date|next_customer_node_start_date|age_difference|customer_avg_days_node_reallocation|total_customer_avg_days_node_reallocation|
|----|-----|-----|-----|-----|-----|-----|----|-----|
|1|3|4|2020-01-02|2020-01-03|2020-01-04|2|12.5|12.17|
|1|3|4|2020-01-04|2020-01-14|2020-01-15|11|12.5|12.17|
|1|3|2|2020-01-15|2020-01-16|2020-01-17|2|12.5|12.17|
|1|3|5|2020-01-17|2020-01-28|2020-01-29|12|12.5|12.17|
|1|3|3|2020-01-29|2020-02-18|2020-02-19|21|12.5|12.17|
|1|3|2|2020-02-19|2020-03-16|2020-03-17|27|12.5|12.17|
|2|3|5|2020-01-03|2020-01-17|2020-01-18|15|11.83|12.17|
|2|3|3|2020-01-18|2020-02-09|2020-02-10|23|11.83|12.17|
|2|3|3|2020-02-10|2020-02-21|2020-02-22|12|11.83|12.17|
|2|3|5|2020-02-22|2020-03-07|2020-03-08|15|11.83|12.17|
|2|3|2|2020-03-08|2020-03-12|2020-03-13|5|11.83|12.17|
|2|3|4|2020-03-13|2020-03-13|2020-03-14|1|11.83|12.17|

* Here we have a good idea with our two window function (`make sure to cast as NUMERIC` to avoid ROUND return error) for the customer_avg and overall average. Now just need to include all customers 

```sql
WITH subsequent_customer_node_date AS (
SELECT
  customer_id,
  region_id,
  node_id,
  start_date,
  end_date,
  LEAD(start_date, 1) OVER(
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS next_customer_node_start_date
FROM data_bank.customer_nodes
ORDER BY customer_id, start_date
),
total_days_between_nodes AS (
SELECT *,
EXTRACT('days' FROM AGE(next_customer_node_start_date, start_date)) as age_difference
FROM subsequent_customer_node_date
-- exclude current plan with end date set to future 9999-12-31 value
WHERE end_date <= NOW()
),
customer_overall_window_averages AS (
SELECT 
  *,
  ROUND(AVG(age_difference) OVER(
    PARTITION BY customer_id
  )::NUMERIC, 2) AS customer_avg_days_node_reallocation,
  ROUND(AVG(age_difference) OVER()::NUMERIC, 2) AS total_customer_avg_days_node_reallocation
FROM total_days_between_nodes
)
-- now can just get the whole window avg in the over return from the window above, cte holds customer avg details too, only need 1 as window value is same across all customer rows
SELECT 
  total_customer_avg_days_node_reallocation
FROM customer_overall_window_averages
LIMIT 1;
```
|total_customer_avg_days_node_reallocation|
|---|
|14.84|

<br>

**5.** What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
```sql
-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH subsequent_customer_node_date AS (
SELECT
  customer_id,
  region_id,
  node_id,
  start_date,
  end_date,
  LEAD(start_date, 1) OVER(
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS next_customer_node_start_date
FROM data_bank.customer_nodes
ORDER BY customer_id, start_date
),
total_days_between_nodes AS (
SELECT *,
EXTRACT('days' FROM AGE(next_customer_node_start_date, start_date)) as age_difference
FROM subsequent_customer_node_date
-- exclude current plan with end date set to future 9999-12-31 value
WHERE end_date <= NOW()
)
SELECT 
  tdbn.region_id,
  rgn.region_name,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age_difference)) AS median_region_metric,
  ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY age_difference)) AS pct80_region_metric,
  ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY age_difference)) AS pct95_region_metric
FROM total_days_between_nodes AS tdbn
INNER JOIN data_bank.regions AS rgn
  ON tdbn.region_id = rgn.region_id
GROUP BY tdbn.region_id, rgn.region_name
ORDER BY tdbn.region_id;
```
|region_id|region_name|median_region_metric|pct80_region_metric|pct95_region_metric|
|-----|-----|-----|------|------|
|1|Australia|15|23|28|
|2|America|15|24|28|
|3|Africa|15|24|28|
|4|Asia|15|23|28|
|5|Europe|15|24|29|