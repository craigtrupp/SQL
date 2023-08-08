-- `A. High Level Sales Analysis`
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





-- `B. Transaction Analysis`
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