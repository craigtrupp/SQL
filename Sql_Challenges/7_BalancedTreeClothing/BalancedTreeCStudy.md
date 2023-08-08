# Balanced Tree Clothing Company
![btree](images/Balanced_Tree.png)

<br>

### **Introduction**
Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

<br>

### **Available Data**
For this case study there is a total of 4 datasets for this case study - however you will only need to utilise 2 main tables to solve all of the regular questions, and the additional 2 tables are used only for the bonus challenge question!

<br>

`Product Details`
* `balanced_tree.product_details` includes all information about the entire range that Balanced Clothing sells in their store.

|product_id|price|product_name|category_id|segment_id|style_id|category_name|segment_name|style_name|
|----|----|----|-----|-----|-----|----|----|-----|
|c4a632|13|Navy Oversized Jeans - Womens|1|3|7|Womens|Jeans|Navy Oversized|
|e83aa3|32|Black Straight Jeans - Womens|1|3|8|Womens|Jeans|Black Straight|
|e31d39|10|Cream Relaxed Jeans - Womens|1|3|9|Womens|Jeans|Cream Relaxed|
|d5e9a6|23|Khaki Suit Jacket - Womens|1|4|10|Womens|Jacket|Khaki Suit|
|72f5d4|19|Indigo Rain Jacket - Womens|1|4|11|Womens|Jacket|Indigo Rain|

<br>

`Product Sales`
* `balanced_tree.sales` contains product level information for all the transactions made for Balanced Tree including **quantity, price, percentage discount, member status, a transaction ID** and also the **transaction timestamp**.

|prod_id|qty|price|discount|member|txn_id|start_txn_time|
|----|----|----|----|----|----|-----|
|c4a632|4|13|17|true|54f307|2021-02-13 01:59:43.296|
|5d267b|4|40|17|true|54f307|2021-02-13 01:59:43.296|
|b9a74d|4|17|17|true|54f307|2021-02-13 01:59:43.296|
|2feb6b|2|29|17|true|54f307|2021-02-13 01:59:43.296|
|c4a632|5|13|21|true|26cc98|2021-01-19 01:39:00.346|

<br>

`Product Hierarcy & Product Price`
Thes tables are used only for the bonus question where we will use them to recreate the **balanced_tree.product_details table**.


- balanced_tree.product_hierarchy

|id|parent_id|level_text|level_name|
|-----|-----|-----|-----|
|1|null|Womens|Category|
|2|null|Mens|Category|
|3|1|Jeans|Segment|
|4|1|Jacket|Segment|
|5|2|Shirt|Segment|

<br>

- balanced_tree.product_prices

|id|product_id|price|
|----|----|----|
|7|c4a632|13|
|8|e83aa3|32|
|9|e31d39|10|
|10|d5e9a6|23|
|11|72f5d4|19|

---

<br>

### **Case Study Questions**
The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

<br>

#### `A. High Level Sales Analysis`

**1.** What was the total quantity sold for all products?
```sql
SELECT
  s.prod_id AS prod_id, pd.product_name,
  SUM(s.qty) AS product_sales_counts
FROM balanced_tree.sales AS s 
INNER JOIN balanced_tree.product_details AS pd 
  ON s.prod_id = pd.product_id
GROUP BY prod_id, product_name
ORDER BY product_sales_counts DESC;
```
|prod_id|product_name|product_sales_counts|
|-----|-----|-----|
|9ec847|Grey Fashion Jacket - Womens|3876|
|c4a632|Navy Oversized Jeans - Womens|3856|
|2a2353|Blue Polo Shirt - Mens|3819|
|5d267b|White Tee Shirt - Mens|3800|
|f084eb|Navy Solid Socks - Mens|3792|
|e83aa3|Black Straight Jeans - Womens|3786|
|2feb6b|Pink Fluro Polkadot Socks - Mens|3770|
|72f5d4|Indigo Rain Jacket - Womens|3757|
|d5e9a6|Khaki Suit Jacket - Womens|3752|
|e31d39|Cream Relaxed Jeans - Womens|3707|
|b9a74d|White Striped Socks - Mens|3655|
|c8d436|Teal Button Up Shirt - Mens|3646|

<br>

**2.** What is the total generated revenue for all products before discounts?
* Recall that discount value is a **%** 
```sql
WITH product_counts AS (
SELECT
  s.prod_id AS prod_id, pd.product_name,
  SUM(s.qty) AS product_sales_counts
FROM balanced_tree.sales AS s 
INNER JOIN balanced_tree.product_details AS pd 
  ON s.prod_id = pd.product_id
GROUP BY prod_id, product_name
ORDER BY product_sales_counts 
)
SELECT 
  pc.prod_id, pc.product_name,
  ROUND(pc.product_sales_counts * pp.price, 2) AS product_rev_pre_disc,
  CONCAT('$', ROUND(pc.product_sales_counts * pp.price, 2)) as product_rev_pre_disc_str,
  -- Window SUM for the total product sales (as requested by the prompt) 
  CONCAT('$', SUM(pc.product_sales_counts * pp.price) OVER()) AS total_product_rev_pre_disc
FROM product_counts AS pc 
INNER JOIN balanced_tree.product_prices AS pp 
  ON pc.prod_id = pp.product_id
ORDER BY product_rev_pre_disc DESC;
```
|prod_id|product_name|product_rev_pre_disc|product_rev_pre_disc_str|total_product_rev_pre_disc|
|----|----|-----|-----|------|
|2a2353|Blue Polo Shirt - Mens|217683.00|$217683.00|$1289453|
|9ec847|Grey Fashion Jacket - Womens|209304.00|$209304.00|$1289453|
|5d267b|White Tee Shirt - Mens|152000.00|$152000.00|$1289453|
|f084eb|Navy Solid Socks - Mens|136512.00|$136512.00|$1289453|
|e83aa3|Black Straight Jeans - Womens|121152.00|$121152.00|$1289453|
|2feb6b|Pink Fluro Polkadot Socks - Mens|109330.00|$109330.00|$1289453|
|d5e9a6|Khaki Suit Jacket - Womens|86296.00|$86296.00|$1289453|
|72f5d4|Indigo Rain Jacket - Womens|71383.00|$71383.00|$1289453|
|b9a74d|White Striped Socks - Mens|62135.00|$62135.00|$1289453|
|c4a632|Navy Oversized Jeans - Womens|50128.00|$50128.00|$1289453|
|e31d39|Cream Relaxed Jeans - Womens|37070.00|$37070.00|$1289453|
|c8d436|Teal Button Up Shirt - Mens|36460.00|$36460.00|$1289453|

* Now we can do a better just `CAST`'ing as a **Money** type 
```sql
WITH product_counts AS (
SELECT
  s.prod_id AS prod_id, pd.product_name,
  SUM(s.qty) AS product_sales_counts
FROM balanced_tree.sales AS s 
INNER JOIN balanced_tree.product_details AS pd 
  ON s.prod_id = pd.product_id
GROUP BY prod_id, product_name
ORDER BY product_sales_counts 
)
SELECT 
  pc.prod_id, pc.product_name,
  ROUND(pc.product_sales_counts * pp.price, 2) AS product_rev_pre_disc,
  CAST(ROUND(pc.product_sales_counts * pp.price, 2) AS money) as product_rev_pre_disc_str,
  -- Window SUM for the total product sales (as requested by the prompt )
  CAST(SUM(pc.product_sales_counts * pp.price) OVER() AS money) AS total_product_rev_pre_disc
FROM product_counts AS pc 
INNER JOIN balanced_tree.product_prices AS pp 
  ON pc.prod_id = pp.product_id
ORDER BY product_rev_pre_disc DESC;
```
|prod_id|product_name|product_rev_pre_disc|product_rev_pre_disc_str|total_product_rev_pre_disc|
|----|-----|-----|------|------|
|2a2353|Blue Polo Shirt - Mens|217683.00|$217,683.00|$1,289,453.00|
|9ec847|Grey Fashion Jacket - Womens|209304.00|$209,304.00|$1,289,453.00|
|5d267b|White Tee Shirt - Mens|152000.00|$152,000.00|$1,289,453.00|
|f084eb|Navy Solid Socks - Mens|136512.00|$136,512.00|$1,289,453.00|
|e83aa3|Black Straight Jeans - Womens|121152.00|$121,152.00|$1,289,453.00|
|2feb6b|Pink Fluro Polkadot Socks - Mens|109330.00|$109,330.00|$1,289,453.00|
|d5e9a6|Khaki Suit Jacket - Womens|86296.00|$86,296.00|$1,289,453.00|
|72f5d4|Indigo Rain Jacket - Womens|71383.00|$71,383.00|$1,289,453.00|
|b9a74d|White Striped Socks - Mens|62135.00|$62,135.00|$1,289,453.00|
|c4a632|Navy Oversized Jeans - Womens|50128.00|$50,128.00|$1,289,453.00|
|e31d39|Cream Relaxed Jeans - Womens|37070.00|$37,070.00|$1,289,453.00|
|c8d436|Teal Button Up Shirt - Mens|36460.00|$36,460.00|$1,289,453.00|

```sql
-- lol, this also works
SELECT
  -- Will multiply each row and simply take the sum of all rows quanity * price at the end
  SUM(qty * price) AS total_revenue,
  CAST(SUM(qty * price) AS money) AS str_total_revenue
FROM balanced_tree.sales;
```
|total_revenue|str_total_revenue|
|----|---|
|1289453|$1,289,453.00|

<br>

**3.** What was the total discount amount for all products?
* Let's look at a row first for the price post discount against w/o discount
```sql
SELECT 
  qty, price, discount,
  -- qty * (price - (price * (discount/100)))
  price - (price * (ROUND(discount::NUMERIC/100, 2))) AS indiviual_price_w_disc,
  -- explicit here about which operations to do first
  qty * (price - (price * (ROUND(discount::NUMERIC/100, 2)))) AS total_after_disc,
  qty * price AS total_pre_disc
FROM balanced_tree.sales
LIMIT 1;
```
|qty|price|discount|indiviual_price_w_disc|total_after_disc|total_pre_disc|
|---|----|----|-----|----|-----|
|4|13|17|10.79|43.16|52|

```sql
SELECT
  -- subtract base price by the discounted price of a product rounded to two decimals
  SUM(qty * ROUND(price - (price * discount/100::NUMERIC), 2)) AS total_amount_post_discount,
  CAST(SUM(qty * ROUND(price - (price * discount/100::NUMERIC), 2)) AS money) AS total_post_discount_$,
  -- and now we will simply take the total pre-discount and minus total-after discount for eact sale
  SUM(qty * price) - SUM(qty * ROUND(price - (price * discount/100::NUMERIC), 2)) AS total_discount_amount,
  CAST(SUM(qty * price) - SUM(qty * ROUND(price - (price * discount/100::NUMERIC), 2)) AS money) AS discount_amount_$
FROM balanced_tree.sales;
```
|total_amount_post_discount|total_post_discount_$|total_discount_amount|discount_amount_$|
|-----|-----|------|-----|
|1133223.86|$1,133,223.86|156229.14|$156,229.14|

<br><br>

#### `B. Transaction Analysis`
**1.** How many unique transactions were there?
```sql
SELECT
  COUNT(DISTINCT txn_id) AS unique_transactions
FROM balanced_tree.sales;
```
|unique_transactions|
|-----|
|2500|

<br>

**2.** What is the average unique products purchased in each transaction?
* Let's look at two first here just to see how sales data looks per record in relation to an overall transaction
```sql
SELECT * FROM balanced_tree.sales WHERE txn_id IN ('54f307', '26cc98') LIMIT 10;
```
|prod_id|qty|price|discount|member|txn_id|start_txn_time|
|----|----|-----|----|----|----|----|
|c4a632|4|13|17|true|54f307|2021-02-13 01:59:43.296|
|5d267b|4|40|17|true|54f307|2021-02-13 01:59:43.296|
|b9a74d|4|17|17|true|54f307|2021-02-13 01:59:43.296|
|2feb6b|2|29|17|true|54f307|2021-02-13 01:59:43.296|
|c4a632|5|13|21|true|26cc98|2021-01-19 01:39:00.346|
|e31d39|2|10|21|true|26cc98|2021-01-19 01:39:00.346|
|72f5d4|3|19|21|true|26cc98|2021-01-19 01:39:00.346|
|2a2353|3|57|21|true|26cc98|2021-01-19 01:39:00.346|
|f084eb|3|36|21|true|26cc98|2021-01-19 01:39:00.346|

* So her we can see for two transaction ids over 9 rows is each product is given its own line in the sales table so we can look to group by the unique prod_id per `txn_id`

```sql
SELECT
  txn_id,
  COUNT(DISTINCT prod_id) AS unique_prod_count_per_txn
FROM balanced_tree.sales
WHERE txn_id IN ('54f307', '26cc98')
GROUP BY txn_id
```
|txn_id|unique_prod_count_per_txn|
|----|----|
|26cc98|5|
|54f307|4|

```sql
WITH unique_prod_per_txn AS (
SELECT
  txn_id,
  COUNT(DISTINCT prod_id) AS unique_prod_count_per_txn
FROM balanced_tree.sales
GROUP BY txn_id
)
SELECT 
  ROUND(AVG(unique_prod_count_per_txn), 2) AS avg_unq_prod_per_txn
FROM unique_prod_per_txn;
```
|avg_unq_prod_per_txn|
|-----|
|6.04|

* If rounded to a **full** product would just be 6 here

<br>

**3.** What are the 25th, 50th and 75th percentile values for the revenue per transaction?

* So just some first thoughts here. How is our pricing from sales against the product details.
* ... Also, this diverges a bit into percentile discussion and how to calculate in **sql** and **python**
```sql
-- Let's confirm that sales price and product_price is the same 
SELECT
  pd.product_id AS id, pd.product_name AS product,
  pd.price AS product_price, sal.price AS sale_price,
  COUNT(*) AS product_sale_prices_count
FROM balanced_tree.product_details AS pd 
INNER JOIN balanced_tree.sales AS sal
  ON sal.prod_id = pd.product_id
GROUP BY id, product, product_price, sale_price;
```
|id|product|product_price|sale_price|product_sale_prices_count|
|---|----|----|-----|-----|
|f084eb|Navy Solid Socks - Mens|36|36|1281|
|e31d39|Cream Relaxed Jeans - Womens|10|10|1243|
|b9a74d|White Striped Socks - Mens|17|17|1243|
|5d267b|White Tee Shirt - Mens|40|40|1268|
|2a2353|Blue Polo Shirt - Mens|57|57|1268|
|9ec847|Grey Fashion Jacket - Womens|54|54|1275|
|e83aa3|Black Straight Jeans - Womens|32|32|1246|
|72f5d4|Indigo Rain Jacket - Womens|19|19|1250|
|c8d436|Teal Button Up Shirt - Mens|10|10|1242|
|d5e9a6|Khaki Suit Jacket - Womens|23|23|1247|
|c4a632|Navy Oversized Jeans - Womens|13|13|1274|
|2feb6b|Pink Fluro Polkadot Socks - Mens|29|29|1258|

* First observations is the product price and sale price is matched, a little uncertain how **profit** is measured but still getting familiar with the data set. Now since we're just looking for **revenue** we can get the total of each transaction prior to getting our `%` type figures for revenue

* Also, `percentile_disc` and `percentile_cont` are discussed in the provided solution and I wanted to better understand the difference
    - https://www.mssqltips.com/sqlservertutorial/9128/sql-server-statistical-window-functions-percentile-disc-and-percentile-cont/
    - https://www.youtube.com/watch?v=4Gr93tPMXeo
    - Later in this video is helpful how the `percentile_disc` interprets the set of pulling a **percentile** from commonly aggregated values (think like a department average for salary). 
![sql_percentile_disc](images/percentilecont_percentiledisc_diff.png)
    - Here we can see how the Finance department return a median of 4100 for `percentile_disc` which details the even set of values  picking the **lower** band of an even set of values when looking for the median

* `Python` percentile for scores in a mocked test for reference on getting a percentile of a value in a set of ordered numbers
```python
# So here is a quick look at grabbing the percentile value that the person was in who scorred an 88 on the test 
>>> scores
[95, 93, 90, 89, 88, 87, 85, 83, 80, 78, 77, 76, 75, 70, 67]
>>> scores_sorted
[67, 70, 75, 76, 77, 78, 80, 83, 85, 87, 88, 89, 90, 93, 95]
>>> percentile_88_score = len(scores_sorted[:scores_])
KeyboardInterrupt
>>> values_below_88 = scores_sorted[:scores_sorted.index(88)]
>>> values_below_88
[67, 70, 75, 76, 77, 78, 80, 83, 85, 87]
>>> len(values_below_88)
10
>>> score_88_percentile = ROUND((len(values_below_88) / len(scores)) * 100, 2)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
NameError: name 'ROUND' is not defined
>>> score_88_percentile = (len(values_below_88) / len(scores)) * 100
>>> score_88_percentile
66.66666666666666
>>> import math
>>> math.round(score_88_percentile, 2)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: module 'math' has no attribute 'round'
>>> round(score_88_percentile, 2)
66.67
>>> f'{round(score_88_percentile, 2)}%'
'66.67%'
>>> scores_sorted
[67, 70, 75, 76, 77, 78, 80, 83, 85, 87, 88, 89, 90, 93, 95]
>>> np.percentile(scores,25)
76.5
```
![percentile_eq](images/percentile_eq.png)

```sql
WITH transaction_avgs AS (
SELECT
  txn_id,
  ROUND(SUM(qty * price), 2) AS txn_avg
FROM balanced_tree.sales
GROUP BY txn_id
)
SELECT
  CAST(PERCENTILE_CONT(.25) WITHIN GROUP(ORDER BY txn_avg)::NUMERIC AS MONEY) AS twenty_fifth_percentile,
  CAST(PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY txn_avg)::NUMERIC AS MONEY) AS fiftieth_percentile,
  CAST(ROUND(AVG(txn_avg), 2) AS MONEY) AS mean_txn_avg,
  -- cannot cast type double precision to money if not converting the percentile return to numeric
  CAST(PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY txn_avg)::NUMERIC AS MONEY) AS seventh_fifth_percentile
FROM transaction_avgs;
```
|twenty_fifth_percentile|fiftieth_percentile|mean_txn_avg|seventh_fifth_percentile|
|------|-----|-----|-----|
|$375.75|$509.50|$515.78|$647.00|

<br>

**4.** What is the average discount value per transaction?
* We'll look at one row first here for how I take it. We would want to find the sum of all sales in a transaction prior to the discount and after to get a **total discount value** for the entire transaction which is a series of sales.
    - We can look at one order first **note** the shared : `txn_id` 

|prod_id|qty|price|discount|member|txn_id|start_txn_time|
|----|----|---|----|----|-----|----|
|c4a632|4|13|17|true|54f307|2021-02-13 01:59:43.296|
|5d267b|4|40|17|true|54f307|2021-02-13 01:59:43.296|
|b9a74d|4|17|17|true|54f307|2021-02-13 01:59:43.296|
|2feb6b|2|29|17|true|54f307|2021-02-13 01:59:43.296|

```sql
SELECT
  txn_id,
  -- Sum of Each sale in all sales for a transaction w a discount applied to the price and qty for each sale in an order 
  -- Recall discount applied as discount (which is integer) / 100 * price, then the price minus that to subtract discount amount from price before multiply by the quantity purchased 
  ROUND(SUM(qty * (price - ( price * (discount/100::NUMERIC) ) ) ), 2) AS txn_total_w_discount,
  -- Sum of Each sale in all sales for a transaction w/o a discount applied to the price and qty for each sale in an order
  SUM(qty * price) AS txn_total_wo_discount
FROM balanced_tree.sales
WHERE txn_id = '54f307'
GROUP BY txn_id
```
|txn_id|txn_total_w_discount|txn_total_wo_discount|
|----|----|----|
|54f307|280.54|338|

* As we can see here for the transaction that the sum total after applied the price discount is substantial!
    - Let's dig a bit deeper and use a `WINDOW FUNCTION` to look at an individual transaction sale discount applied at each level and validate the sum values from above on the entire total 

```sql
-- Just for fun can we do an example order for the discount applied at each sale in a transaction???
WITH individual_txn_sale_details AS (
SELECT
  prod_id, txn_id, qty, price, discount,
  ROUND (
  -- Remember you want to perform the window operation on each row prior to rounding the value returned from it 
    SUM(qty * (price - ( price * (discount/100::NUMERIC) ) ) )
      OVER (
        PARTITION BY prod_id, txn_id
    )
  , 2 ) AS sale_discount,
  ROUND (
    SUM(qty * price ) OVER (
      PARTITION BY prod_id, txn_id
    )
  , 2) AS sale_pre_discount
FROM balanced_tree.sales
WHERE txn_id = '54f307'
)
SELECT 
  *,
  SUM(sale_discount) OVER() AS txn_total_discount_sum,
  SUM(sale_pre_discount) OVER() AS txn_total_sum_no_discount
FROM individual_txn_sale_details
```
|prod_id|txn_id|qty|price|discount|sale_discount|sale_pre_discount|txn_total_discount_sum|txn_total_sum_no_discount|
|----|----|---|----|----|-----|-----|-----|-----|
|2feb6b|54f307|2|29|17|48.14|58.00|280.54|338.00|
|5d267b|54f307|4|40|17|132.80|160.00|280.54|338.00|
|b9a74d|54f307|4|17|17|56.44|68.00|280.54|338.00|
|c4a632|54f307|4|13|17|43.16|52.00|280.54|338.00|

- And ... back to the original question
```sql
-- Recall each SUM value in CTE below is performing the operation on each sale line before aggregating by the transaction
WITH txn_total AS (
SELECT
  txn_id,
  -- Sum of Each sale in all sales for a transaction w a discount applied to the price and qty for each sale in an order 
  -- Recall discount applied as discount (which is integer) / 100 * price, then the price minus that to subtract discount amount from price before multiply by the quantity purchased 
  ROUND(SUM(qty * (price - ( price * (discount/100::NUMERIC) ) ) ), 2) AS txn_total_w_discount,
  -- Sum of Each sale in all sales for a transaction w/o a discount applied to the price and qty for each sale in an order
  SUM(qty * price) AS txn_total_wo_discount
FROM balanced_tree.sales
GROUP BY txn_id
),
txn_disc_differences AS (
SELECT
  *,
  txn_total_wo_discount - txn_total_w_discount AS txn_discount_savings
FROM txn_total
)
SELECT * FROM txn_disc_differences WHERE txn_id = '54f307';
```
|txn_id|txn_total_w_discount|txn_total_wo_discount|txn_discount_savings|
|-----|-----|-----|-----|
|54f307|280.54|338|57.46|

* Looking good for one transaction getting the difference, now to all of them
```sql
WITH txn_total AS (
SELECT
  txn_id,
  -- Sum of Each sale in all sales for a transaction w a discount applied to the price and qty for each sale in an order 
  -- Recall discount applied as discount (which is integer) / 100 * price, then the price minus that to subtract discount amount from price before multiply by the quantity purchased 
  ROUND(SUM(qty * (price - ( price * (discount/100::NUMERIC) ) ) ), 2) AS txn_total_w_discount,
  -- Sum of Each sale in all sales for a transaction w/o a discount applied to the price and qty for each sale in an order
  SUM(qty * price) AS txn_total_wo_discount
FROM balanced_tree.sales
GROUP BY txn_id
),
txn_disc_differences AS (
SELECT
  *,
  txn_total_wo_discount - txn_total_w_discount AS txn_discount_savings
FROM txn_total
)
SELECT 
  ROUND(AVG(txn_discount_savings), 2) AS avg_disc_per_txn,
  CAST(ROUND(AVG(txn_discount_savings), 2) AS MONEY) AS avg_disc_per_txn_string
FROM txn_disc_differences;
```
|avg_disc_per_txn|avg_disc_per_txn_string|
|-----|-----|
|62.49|$62.49|

**5.** What is the percentage split of all transactions for members vs non-members?

**6.** What is the average revenue for member transactions and non-member transactions?