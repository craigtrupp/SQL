------------------------------ `A. Customer Nodes Exploration` ------------------------------
-- 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id)
FROM data_bank.customer_nodes;

-- either works
WITH combinations AS (
SELECT DISTINCT
  node_id
FROM data_bank.customer_nodes
)
SELECT COUNT(node_id) FROM combinations;

-- 2. What is the number of nodes per region?
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

-- 3. How many customers are allocated to each region?
SELECT
  cn.region_id,
  r.region_name,
  COUNT(DISTINCT cn.customer_id) AS unique_customer_region_allocation
FROM data_bank.customer_nodes AS cn
LEFT JOIN data_bank.regions AS r 
USING(region_id)
GROUP BY region_id, region_name
ORDER BY unique_customer_region_allocation DESC;

-- 4. How many days on average are customers reallocated to a different node?
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

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
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

------------------------------ `End Section A` ------------------------------




------------------------------ `B. Customer Transactions` ------------------------------
-- 1. What is the unique count and total amount for each transaction type?
SELECT
  txn_type,
  COUNT(*) AS txn_type_count,
  SUM(txn_amount) AS total_sum_txn_type
FROM data_bank.customer_transactions
GROUP BY txn_type
ORDER BY txn_type_count, total_sum_txn_type;


-- 2. What is the average total historical deposit counts and amounts for all customers?
WITH avg_deposit_details AS (
SELECT
  customer_id,
  COUNT(*) AS customer_total_deposits,
  ROUND(AVG(txn_amount), 2) AS customer_deposit_average
FROM data_bank.customer_transactions
WHERE txn_type = 'deposit'
GROUP BY customer_id
ORDER BY customer_id
)
SELECT
  ROUND(AVG(customer_total_deposits),1) AS Avg_Deposit_Counts,
  ROUND(AVG(customer_deposit_average),2) AS Avg_Deposit_Amount,
  ROUND(AVG(customer_deposit_average)) AS Avg_Rounded_Up
FROM avg_deposit_details;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and 
-- (either 1 purchase or 1 withdrawal) in a single month?
WITH customer_monthly_trax_counts AS (
SELECT 
  customer_id,
  DATE_TRUNC('MONTH', txn_date)::DATE AS month_trax_date,
  SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS monthly_deposits,
  SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS monthly_purchases,
  SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS monthly_withdrawals
FROM data_bank.customer_transactions
GROUP BY customer_id, month_trax_date
ORDER BY customer_id, month_trax_date
),
customer_months_criteria AS (
SELECT *
FROM customer_monthly_trax_counts
WHERE monthly_deposits >= 2 AND (monthly_purchases >= 1 OR monthly_withdrawals >= 1)
)
SELECT
  month_trax_date,
  COUNT(*) AS customer_condition_monthly_count
FROM customer_months_criteria
GROUP BY month_trax_date
ORDER BY month_trax_date;

-- 4. What is the closing balance for each customer at the end of the month?
WITH customer_monthly_balance AS (
SELECT 
  customer_id,
  DATE_TRUNC('MONTH', txn_date)::DATE AS transaction_month,
  SUM(
    CASE WHEN txn_type = 'deposit' THEN txn_amount
    -- Invert the txn amount to negative for withdrawal or purchase
    ELSE (-txn_amount)
    END
  ) AS balance
FROM data_bank.customer_transactions
GROUP BY customer_id, transaction_month
ORDER BY customer_id, transaction_month
),
quarter_data_period_per_customer AS (
SELECT
  DISTINCT(customer_id),
  ('2020-01-01'::DATE + GENERATE_SERIES(0, 3) * INTERVAL '1 MONTH')::DATE AS generated_month
  FROM data_bank.customer_transactions
)
SELECT
  qdppc.customer_id customer_id,
  qdppc.generated_month AS month,
  -- Either take found value or if not exists (no customer account transaction activity for month) set to 0
  COALESCE(cmb.balance, 0) AS balance_monthly_activity,
  SUM(cmb.balance) OVER (
    PARTITION BY qdppc.customer_id
    ORDER BY qdppc.generated_month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS ending_month_balance
FROM quarter_data_period_per_customer AS qdppc
LEFT JOIN customer_monthly_balance as cmb 
  ON qdppc.customer_id = cmb.customer_id
  AND qdppc.generated_month = cmb.transaction_month
-- We'll only get the first three customers
WHERE qdppc.customer_id <= 3;

-- 5. Comparing the closing balance of a customer’s first month and the closing balance from their second nth, 
-- what percentage of customers:
        -- Have a negative first month balance?
        -- Have a positive first month balance?
        -- Increase their opening month’s positive closing balance by more than 5% in the following month?
        -- Reduce their opening month’s positive closing balance by more than 5% in the following month?
        -- Move from a positive balance in the first month to a negative balance in the second month?

WITH cte_monthly_balances AS (
SELECT
  customer_id,
  DATE_TRUNC('Month', txn_date)::DATE as month,
  SUM(
    CASE 
      WHEN txn_type = 'deposit' THEN txn_amount
      ELSE (-txn_amount)
      END
  ) AS monthly_activity
FROM data_bank.customer_transactions
GROUP BY customer_id, month
ORDER BY customer_id, month
),
cte_generated_months AS (
  SELECT
    DISTINCT customer_id,
    (
      DATE_TRUNC('mon', MIN(txn_date))::DATE +
      GENERATE_SERIES(0, 1) * INTERVAL '1 MONTH'
    )::DATE AS month,
    GENERATE_SERIES(1, 2) AS month_number
  FROM data_bank.customer_transactions
  GROUP BY customer_id
  ORDER BY customer_id
),
cte_monthly_transactions AS (
  SELECT
    cte_generated_months.customer_id,
    cte_generated_months.month,
    cte_generated_months.month_number,
    COALESCE(cte_monthly_balances.monthly_activity, 0) AS transaction_amount
  FROM cte_generated_months
  LEFT JOIN cte_monthly_balances
    ON cte_generated_months.month = cte_monthly_balances.month
    AND cte_generated_months.customer_id = cte_monthly_balances.customer_id
  ORDER BY customer_id, month, month_number
),
cte_monthly_aggregates AS (
SELECT
  customer_id,
  month_number,
  LAG(transaction_amount) OVER (
    PARTITION BY customer_id
    ORDER BY month
  ) AS prev_month_transaction_amount,
  transaction_amount as monthly_activity
FROM cte_monthly_transactions
),
cte_calcs AS (
SELECT 
  -- we'll use this value for our percentages in the last query for total numbers
  COUNT(DISTINCT customer_id) AS customer_count,
  -- Calculate 5 different metrics
  SUM(CASE WHEN prev_month_transaction_amount > 0 THEN 1 ELSE 0 END) AS total_positive_first_month_balances,
  SUM(CASE WHEN prev_month_transaction_amount < 0 THEN 1 ELSE 0 END) AS total_negative_first_month_balances,
  -- Increase their opening month’s positive closing balance by more than 5% in the following month?, positive past_month, posivite activity and previous + .05% < new activity
  SUM(
    CASE 
      WHEN prev_month_transaction_amount > 0
        AND monthly_activity > 0
        AND (prev_month_transaction_amount * 0.05) + prev_month_transaction_amount < monthly_activity 
        THEN 1
      ELSE 0
    END
  ) AS increase_count_greater_5_percent,
  -- Reduce their opening month’s positive closing balance by more than 5% in the following month, activity must be negative and previous month must be positive
  SUM(
    CASE 
      WHEN prev_month_transaction_amount > 0
        AND monthly_activity < 0
        -- we want to now see if the 5% inversed is still less than the monthly_activity which will determine if the drop was more than 5%
        AND (-(prev_month_transaction_amount * .05) < monthly_activity)
        THEN 1
      ELSE 0
    END
  ) AS decrease_count_greater_5_percent,
  -- Move from a positive balance in the first month to a negative balance in the second month, most importantly is the monthly value being less than the inverse of the posivie month value for a deficit or negative count
  SUM(
    CASE 
      WHEN prev_month_transaction_amount > 0 
        AND monthly_activity < 0 
        AND monthly_activity < (-prev_month_transaction_amount) -- Must validate that the negative monthly activity is also less than what the inverse of the positive amount
        THEN 1 
      ELSE 0
    END
  ) AS negative_balance_counts_after_positive_first
FROM cte_monthly_aggregates
-- Essentially we just want to look at the last row for each customer which holds the previous month value and the activity for the 2nd month we use for our metrics
WHERE prev_month_transaction_amount IS NOT NULL
)
SELECT
  -- we'll round each 
  ROUND(100 * (total_positive_first_month_balances/customer_count::NUMERIC)) AS positive_first_month_balance_percentage,
  ROUND(100 * (total_negative_first_month_balances/customer_count::NUMERIC)) AS negative_first_month_balance_percentage,
  ROUND(100 * (increase_count_greater_5_percent/customer_count::NUMERIC)) AS increase_greater_than_5_percentage,
  ROUND(100 * (decrease_count_greater_5_percent/customer_count::NUMERIC)) AS decrease_greater_than_5_percentage,
  ROUND(100 * (negative_balance_counts_after_positive_first/customer_count::NUMERIC)) AS positive_to_negative_percentage
FROM cte_calcs

------------------------------ `End Section B` ------------------------------




