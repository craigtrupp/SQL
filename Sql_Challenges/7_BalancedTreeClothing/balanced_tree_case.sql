-------------------- `A. High Level Sales Analysis`---------------------

-- 1
SELECT
  s.prod_id AS prod_id, pd.product_name,
  SUM(s.qty) AS product_sales_counts
FROM balanced_tree.sales AS s 
INNER JOIN balanced_tree.product_details AS pd 
  ON s.prod_id = pd.product_id
GROUP BY prod_id, product_name
ORDER BY product_sales_counts DESC;

-- 2
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

-- (Also works for 2 ... lol)
SELECT
  -- Will multiply each row and simply take the sum of all rows quanity * price at the end
  SUM(qty * price) AS total_revenue,
  CAST(SUM(qty * price) AS money) AS str_total_revenue
FROM balanced_tree.sales;

-- 3
SELECT
  -- subtract base price by the discounted price of a product rounded to two decimals
  SUM(qty * ROUND(price - (price * discount/100::NUMERIC), 2)) AS total_amount_post_discount,
  CAST(SUM(qty * ROUND(price - (price * discount/100::NUMERIC), 2)) AS money) AS total_post_discount_$,
  -- and now we will simply take the total pre-discount and minus total-after discount for eact sale
  SUM(qty * price) - SUM(qty * ROUND(price - (price * discount/100::NUMERIC), 2)) AS total_discount_amount,
  CAST(SUM(qty * price) - SUM(qty * ROUND(price - (price * discount/100::NUMERIC), 2)) AS money) AS discount_amount_$
FROM balanced_tree.sales;


------------------------- END OF SECTION A -------------------------


-------------------- `B. Transaction Analysis`---------------------
-- 1
SELECT
  COUNT(DISTINCT txn_id) AS unique_transactions
FROM balanced_tree.sales;

-- 2
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

-- 3
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


-- 4 (See Progression of queries)
-- First Was simply looking at a transaction total sum with & w/o a discount applied to the sale logic
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

-- Next we do a individual sale discount query for one transaction to see the total discount pre/post discount for each sale in a txn
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


-- Final Query (See Markdown for details on progression)
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


-- 5 (Member Percentage Split Final Query -- See Markdown for further notes)
WITH txn_indv_sale_member_counts AS (
SELECT
  array_agg(member) AS member_txn_values,
  -- can check cardinality but just also eyeball here that these are the same (length wise so each txn has same member boolean status)
  SUM(CASE WHEN member IS TRUE THEN 1 ELSE 0 END) AS member_sale_rows_per_txn,
  SUM(CASE WHEN member IS NOT TRUE THEN 1 ELSE 0 END) AS non_member_sale_rows_per_txn
FROM balanced_tree.sales
GROUP BY txn_id
),
-- Now we can just target two scenarios here to get a total txn_value of 1 or 0 for the member status 
-- (cardinality checks length of array_agg against count of member rows value per grouped txn)
agg_txn_member_counts AS (
SELECT
  SUM(CASE WHEN CARDINALITY(member_txn_values) = member_sale_rows_per_txn THEN 1 ELSE 0 END) AS member_txn_total_events,
  SUM(CASE WHEN CARDINALITY(member_txn_values) = non_member_sale_rows_per_txn THEN 1 ELSE 0 END) AS non_member_txn_total_events
FROM txn_indv_sale_member_counts
)
-- percentage split
SELECT
  *,
  -- don't forget wonky floor division (will round to two decimal places)
  ROUND(100 * (member_txn_total_events / (member_txn_total_events + non_member_txn_total_events)::NUMERIC), 2) AS member_percentage,
  CONCAT(ROUND(100 * (member_txn_total_events / (member_txn_total_events + non_member_txn_total_events)::NUMERIC), 2), '%') AS member_perc_str,
  ROUND(100 * (non_member_txn_total_events / (member_txn_total_events + non_member_txn_total_events)::NUMERIC), 2) AS non_member_percentage,
  CONCAT(ROUND(100 * (non_member_txn_total_events / (member_txn_total_events + non_member_txn_total_events)::NUMERIC), 2), '%') AS non_member_perc_str
FROM agg_txn_member_counts;


-- 6 Member Transaction Avg
WITH txn_distinct_mmb_status AS (
SELECT
  txn_id,
  -- get unique member value for each transaction
  array_agg(DISTINCT member) AS txn_member_flag
FROM balanced_tree.sales
GROUP BY txn_id
),
-- 
txn_total_join AS (
SELECT
  cte_txn_flg.txn_id AS id,
  cte_txn_flg.txn_member_flag[1] AS txn_flag,
  SUM(sales.qty * sales.price) AS txn_total
FROM txn_distinct_mmb_status AS cte_txn_flg
INNER JOIN balanced_tree.sales AS sales 
  ON cte_txn_flg.txn_id = sales.txn_id
GROUP BY id, txn_flag
),
-- now let's get a print out for the total sum of member transactions and aggregate the total transactions (similar to the last exercise)
-- price is a INT type AND not a decimal so only need to round in the next step when computing average
mbr_sales_txn_total AS (
SELECT 
  SUM(CASE WHEN txn_flag IS TRUE THEN 1 ELSE 0 END) AS mmbr_txn_count,
  SUM(CASE WHEN txn_flag IS TRUE THEN txn_total ELSE 0 END) mmbr_sale_total,
  SUM(CASE WHEN txn_flag IS NOT TRUE THEN 1 ELSE 0 END) AS na_mmbr_txn_count,
  SUM(CASE WHEN txn_flag IS NOT TRUE THEN txn_total ELSE 0 END) na_mmbr_sale_total
FROM txn_total_join
)
-- Let's try a UNION for a multiple row output
SELECT 
  'Member Avg' AS member_type,
  CAST(ROUND(mmbr_sale_total/mmbr_txn_count::NUMERIC, 2) AS MONEY) AS txn_avg
FROM mbr_sales_txn_total
UNION 
SELECT 
  'Non Member Avg' AS member_type,
  CAST(ROUND(na_mmbr_sale_total/na_mmbr_txn_count::NUMERIC, 2) AS MONEY) AS txn_avg
FROM mbr_sales_txn_total


-- Another Approach to Question 6 for Section B
WITH cte_member_revenue AS (
  SELECT
    member,
    txn_id,
    SUM(price * qty) AS revenue
  FROM balanced_tree.sales
  GROUP BY member, txn_id
)
SELECT
  member,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS median_avg_rev,
  CAST(AVG(revenue) AS MONEY) AS mean_avg_rev
FROM cte_member_revenue
GROUP BY member;


------------------------- END OF SECTION B -------------------------

-- 1 What are the top 3 products by total revenue before discount?
-- We'll take a peek at the first five
SELECT 
  pd.product_id, pd.product_name,
  SUM(sl.price * sl.qty) AS product_pre_disc_revenue,
  CAST(SUM(sl.price * sl.qty) AS MONEY) AS product_pre_disc_str
FROM balanced_tree.sales AS sl 
INNER JOIN balanced_tree.product_details AS pd 
  ON sl.prod_id = pd.product_id
GROUP BY product_id, product_name
ORDER BY product_pre_disc_revenue DESC
LIMIT 5;


--2 What is the total quantity, revenue and discount for each segment?
SELECT 
  pd.segment_id as seg_id, pd.segment_name AS seg_name,
  SUM(sl.qty) AS seg_total_qty, 
  SUM(sl.price * sl.qty) AS seg_no_disc_rev,
  CAST(SUM(sl.price * sl.qty) AS MONEY) AS seg_no_disc_rev_str,
  -- Explicit state for order of operations for revenue segment sale after discount applied recall discount needs to be turned to a decimal
  ROUND (
    SUM(sl.qty * (sl.price - ((sl.discount/100::NUMERIC) * sl.price)))
  , 2) AS seg_rev_w_disc,
  CAST( 
  ROUND (
    SUM(sl.qty * (sl.price - ((sl.discount/100::NUMERIC) * sl.price)))
  , 2) 
  AS MONEY)AS seg_rev_w_disc_str,
  -- Now we just want the discount amount for each segment 
  ROUND(
    SUM(
      ((sl.discount/100::NUMERIC) * sl.price) * sl.qty
    ) , 2)AS seg_disc_total,
  CAST(ROUND(
    SUM(
      ((sl.discount/100::NUMERIC) * sl.price) * sl.qty
    ) , 2) AS MONEY)AS seg_disc_total_str
FROM balanced_tree.sales AS sl 
INNER JOIN balanced_tree.product_details AS pd 
  ON sl.prod_id = pd.product_id
GROUP BY seg_id, seg_name
ORDER BY seg_name;


-- 3  What is the top selling product for each segment?
-- Can't call Window function order by by the aliased column for each products sales total for every segment
WITH ranked_segment_product_counts AS (
 SELECT 
  pd.product_id, pd.product_name, pd.segment_id, pd.segment_name,
  SUM(sl.qty) AS prod_seg_total,
  RANK() OVER(
    PARTITION BY pd.segment_name
    ORDER BY SUM(sl.qty) DESC
  ) AS segment_rank
FROM balanced_tree.sales AS sl 
INNER JOIN balanced_tree.product_details AS pd
  ON sl.prod_id = pd.product_id
GROUP BY pd.product_id, pd.product_name, pd.segment_id, pd.segment_name
ORDER BY segment_name, prod_seg_total DESC
)
SELECT
* 
FROM ranked_segment_product_counts
WHERE segment_rank = 1
ORDER BY prod_seg_total DESC;



-- 4 What is the total quantity, revenue and discount for each category?
-- Quite Similar to #2 for this particular section but only categories are male/female
SELECT 
  pd.category_id as cat_id, pd.category_name AS cat_name,
  SUM(sl.qty) AS cat_total_qty, 
  SUM(sl.price * sl.qty) AS cat_no_disc_rev,
  CAST(SUM(sl.price * sl.qty) AS MONEY) AS cat_no_disc_rev_str,
  -- Explicit state for order of operations for revenue segment sale after discount applied recall discount needs to be turned to a decimal
  -- Recall here we are multiply the qty times the price after accounting for discount
  ROUND (
    SUM(sl.qty * (sl.price - ((sl.discount/100::NUMERIC) * sl.price)))
  , 2) AS cat_rev_w_disc,
  CAST( 
  ROUND (
    SUM(sl.qty * (sl.price - ((sl.discount/100::NUMERIC) * sl.price)))
  , 2) 
  AS MONEY)AS cat_rev_w_disc_str,
  -- Now we just want the discount amount for each segment so essientially the discount per purchased qty
  ROUND(
    SUM(
      ((sl.discount/100::NUMERIC) * sl.price) * sl.qty
    ) , 2)AS cat_disc_total,
  CAST(ROUND(
    SUM(
      ((sl.discount/100::NUMERIC) * sl.price) * sl.qty
    ) , 2) AS MONEY)AS cat_disc_total_str
FROM balanced_tree.sales AS sl 
INNER JOIN balanced_tree.product_details AS pd 
  ON sl.prod_id = pd.product_id
GROUP BY cat_id, cat_name


-- 5. What is the top selling product for each category?
WITH products_per_cat AS (
SELECT
  pd.product_id, pd.product_name, pd.category_name,
  SUM(sl.qty) AS prod_cat_total_qty,
  RANK() OVER (
    PARTITION BY pd.category_name
    ORDER BY SUM(sl.qty) DESC
  ) AS category_qty_rank
FROM balanced_tree.product_details AS pd 
INNER JOIN balanced_tree.sales AS sl 
  ON pd.product_id = sl.prod_id
GROUP BY pd.product_id, pd.product_name, pd.category_name
ORDER BY pd.category_name, category_qty_rank
)
SELECT * FROM products_per_cat WHERE category_qty_rank = 1;


-- 6. Percentage of Revnue Split by Product within Each Category
-- What is the percentage split of revenue by product for each segment?
WITH segment_prod_totals AS (
-- First an Idea of how the segments look
SELECT
  pd.product_name,
  pd.segment_name,
  SUM(sl.qty * sl.price) AS prod_seg_rev,
  CAST(SUM(sl.qty * sl.price) AS MONEY) AS prod_seg_rev_str,
  SUM(SUM(sl.qty * sl.price)) OVER (
    PARTITION BY pd.segment_name
  ) AS segment_total,
  CAST(
    SUM(SUM(sl.qty * sl.price)) OVER (
    PARTITION BY pd.segment_name
    ) 
  AS MONEY) AS seg_total_str,
  -- Now Can Rank to select the top segment and get percentages
  RANK() OVER(
    PARTITION BY pd.segment_name
    ORDER BY SUM(sl.qty * sl.price) DESC
  ) AS segment_rank
FROM balanced_tree.product_details AS pd
INNER JOIN balanced_tree.sales AS sl 
  ON pd.product_id = sl.prod_id
GROUP BY pd.product_name, pd.segment_name
ORDER BY segment_name, segment_rank
)
SELECT 
  *,
  -- take the sum of the product total for each segment with window function below (floor division)
  CONCAT(ROUND(100 * (prod_seg_rev / SUM(prod_seg_rev) OVER(PARTITION BY segment_name)::NUMERIC), 2), '%') AS seg_prod_proportion
FROM segment_prod_totals;

-- If to get the over proportions of segment totals for revenue (using the ranking we have for each product wihtin segment)
WITH segment_totals AS (
-- First an Idea of how the segments look
SELECT
  pd.product_name,
  pd.segment_name,
  SUM(sl.qty * sl.price) AS prod_seg_rev,
  CAST(SUM(sl.qty * sl.price) AS MONEY) AS prod_seg_rev_str,
  SUM(SUM(sl.qty * sl.price)) OVER (
    PARTITION BY pd.segment_name
  ) AS segment_total,
  CAST(
    SUM(SUM(sl.qty * sl.price)) OVER (
    PARTITION BY pd.segment_name
    ) 
  AS MONEY) AS seg_total_str,
  -- Now Can Rank to select the top segment and get percentages
  RANK() OVER(
    PARTITION BY pd.segment_name
    ORDER BY SUM(sl.qty * sl.price) DESC
  ) AS segment_rank
FROM balanced_tree.product_details AS pd
INNER JOIN balanced_tree.sales AS sl 
  ON pd.product_id = sl.prod_id
GROUP BY pd.product_name, pd.segment_name
ORDER BY segment_name, segment_rank
)
SELECT 
  segment_name,
  segment_total,
  seg_total_str,
  -- Now we can get the proportion for the whole segment 
  CONCAT(ROUND(100 * (segment_total / SUM(segment_total) OVER())::NUMERIC, 2), '%') AS seg_proportion,
  CAST(SUM(segment_total) OVER() AS MONEY) AS total_revenue
FROM segment_totals
WHERE segment_rank = 1;


-- 7 What is the percentage split of revenue by segment for each category?
WITH seg_cat_rev_totals AS (
SELECT
  pd.segment_id, pd.segment_name, pd.category_id, pd.category_name,
  SUM(sl.qty * sl.price) as segment_category_sale_totals,
  CAST(SUM(sl.qty * sl.price) AS MONEY) AS seg_cat_stotals_str
FROM balanced_tree.product_details AS pd 
INNER JOIN balanced_tree.sales AS sl 
  ON pd.product_id = sl.prod_id
GROUP BY segment_id, segment_name, category_id, category_name
ORDER BY segment_name, category_name
)
SELECT
  *,
  CONCAT( ROUND(
    100 * ( segment_category_sale_totals / SUM(segment_category_sale_totals) OVER (
      PARTITION BY category_name ) )
  , 2), '%') AS seg_cat_perc
FROM seg_cat_rev_totals;


-- 8. What is the percentage split of total revenue by category?
SELECT
  pd.category_id, pd.category_name,
  SUM(sl.qty * sl.price) AS category_revenue,
  CAST(SUM(sl.qty * sl.price) AS MONEY) AS cat_rev_str,
  SUM(SUM(sl.qty * sl.price)) OVER() AS total_revenue,
  CAST(SUM(SUM(sl.qty * sl.price)) OVER() AS MONEY) AS total_revenue_str,
  CONCAT(
    ROUND( 100 * (SUM(sl.qty * sl.price) / SUM(SUM(sl.qty * sl.price)) OVER()::NUMERIC) -- takes category revnue / window revenue
    , 2)
  , '%') AS total_category_rev_percentage
FROM balanced_tree.product_details AS pd 
INNER JOIN balanced_tree.sales AS sl 
  ON pd.product_id = sl.prod_id
GROUP BY category_id, category_name;


-- 9. What is the total transaction “penetration” for each product? 
-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased 
-- divided by total number of transactions)
WITH unique_prod_per_txns AS (
SELECT
  pd.product_id, pd.product_name, sl.txn_id,
  COUNT(DISTINCT pd.product_id) AS product_sale_txns -- would eliminate any duplicate products in one txn
FROM balanced_tree.product_details AS pd 
INNER JOIN balanced_tree.sales AS sl 
  ON pd.product_id = sl.prod_id
GROUP BY product_id, product_name, sl.txn_id
)
SELECT
  product_id, 
  product_name,
  COUNT(*) AS product_txns,
  -- Subquery for unique transaction count against the count of all products total txn count
  CONCAT(ROUND(100 * (COUNT(*) / (SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales)::NUMERIC), 2), '%') AS penetration_percentage,
  (SELECT COUNT(DISTINCT txn_id) FROM balanced_tree.sales) AS unique_transactions
FROM unique_prod_per_txns
GROUP BY product_id, product_name
ORDER BY penetration_percentage DESC;
