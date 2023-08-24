------------------------- B. Data Analysis -------------------------
-- 1. How many customers has Foodie-Fi ever had?
SELECT 
COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - 
-- use the start of the month as the group by value
SELECT 
  DATE_TRUNC('month', start_date) AS month,
  COUNT(*) AS trial_plan_subscribers
FROM foodie_fi.subscriptions
WHERE plan_id = 0
GROUP BY month
ORDER BY month;

-- 3. What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name
SELECT 
  sub.plan_id AS plan_id,
  pl.plan_name AS plan,
  COUNT(*) AS post_2020_plan_start_dates
FROM foodie_fi.subscriptions sub 
INNER JOIN foodie_fi.plans pl 
  USING(plan_id)
WHERE EXTRACT(YEAR FROM sub.start_date) > 2020
-- WHERE sub.start_date > '2020-12-31'
GROUP BY plan_id, plan 
ORDER BY plan_id;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
WITH churn_total_subs AS (
SELECT 
  COUNT(DISTINCT customer_id) AS total_unq_custs,
  -- Need a Subquery for conditional plan check for churn count
  (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions WHERE plan_id = 4) AS total_unq_churn_custs
FROM foodie_fi.subscriptions
)
SELECT *, 
  ROUND(100 * (total_unq_churn_custs::NUMERIC/total_unq_custs), 1) AS churn_perc
FROM churn_total_subs;

-- Another Variety
SELECT
  SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churn_customers,
  ROUND(
    100 * SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) /
      COUNT(DISTINCT customer_id)::NUMERIC
  , 1) AS percentage -- Recall floor division (cast one value as numeric)
FROM foodie_fi.subscriptions;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH customer_event_ranking as (
SELECT
  pl.plan_id,
  pl.plan_name,
  sb.customer_id,
  sb.start_date,
  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY sb.start_date
  ) AS customer_plan_history
FROM foodie_fi.plans pl 
INNER JOIN foodie_fi.subscriptions sb 
  USING(plan_id)
),
customer_plan_history AS (
SELECT 
  customer_id,
  array_agg(plan_id) AS plan_id_values,
  array_agg(customer_plan_history) AS ranking_values
FROM customer_event_ranking
GROUP BY customer_id
ORDER BY customer_id, ranking_values
),
churned_customer_history AS (
SELECT
  customer_id,
  plan_id_values,
  ranking_values
FROM customer_plan_history
WHERE 4 = any(plan_id_values)
)
-- SELECT *, plan_id_values[1] AS first_plan, plan_id_values[2] AS second_plan FROM churned_customer_history
SELECT 
  COUNT(*) AS total_direct_churns_from_trial,
  ROUND(100 * (COUNT(*)::NUMERIC / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)), 1) AS direct_churn_percentage_all_customers,
  ROUND(100 * (COUNT(*)::NUMERIC / (SELECT COUNT(DISTINCT customer_id) FROM churned_customer_history)), 1) AS direct_churn_percentage_churn_customers
FROM churned_customer_history WHERE plan_id_values[2] = 4 AND plan_id_values[1] = 0; 

-- Another Way
WITH ranked_plans AS (
SELECT
  customer_id,
  plan_id,
  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY start_date 
  ) AS customer_event_rankings
FROM foodie_fi.subscriptions
)
SELECT
  SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churned_customers,
  ROUND(100 * (SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END)::NUMERIC / COUNT(DISTINCT customer_id)), 1) AS overall_perc
FROM ranked_plans
WHERE customer_event_rankings = 2

-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH customer_plan_rank AS (
SELECT
  customer_id,
  plan_id,
  RANK() OVER(
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS plan_history_rank
FROM foodie_fi.subscriptions
), 
customer_plan_history AS (
SELECT 
  customer_id,
  array_agg(plan_id) AS plan_id_values,
  array_agg(plan_history_rank) AS ranking_values
FROM customer_plan_rank
GROUP BY customer_id
ORDER BY customer_id, ranking_values
),
second_plan_counts AS (
SELECT 
  plan_id_values[2] AS second_customer_plan,
  COUNT(*) AS second_plan_counts
FROM customer_plan_history
WHERE plan_id_values[1] = 0 -- Validate initial plan was free trial
GROUP BY second_customer_plan
ORDER BY second_plan_counts DESC
)
-- Finally can use a left join to just get the plan_name associated to the plan_counts with the counts for the id generated above
SELECT 
  spc.second_customer_plan,
  spc.second_plan_counts,
  ROUND(100 * (spc.second_plan_counts::numeric / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions)), 2) AS second_plan_percentages, -- Now need the percentages
  pl.plan_name
FROM second_plan_counts spc
LEFT JOIN foodie_fi.plans pl
  ON second_customer_plan = pl.plan_id;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH customer_plan_history AS (
SELECT 
  customer_id,
  plan_id,
  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS customer_plan_rank,
  start_date
FROM foodie_fi.subscriptions
WHERE start_date::timestamp <= '2020-12-31'
),
customer_plan_order AS (
SELECT 
  customer_id,
  array_agg(plan_id ORDER BY customer_plan_rank) AS ordered_plan_history -- array_agg can be ordered by a subsequent field (rank here to get the right sequential order for each plan)
FROM customer_plan_history
GROUP BY customer_id
ORDER BY customer_id
),
last_plan_values AS (
SELECT 
  ordered_plan_history[array_upper(ordered_plan_history, 1)] AS last_plan_value, -- handy array_upper to pull the last value after ordering in chronological order using the rank alias customer_plan_rank
  COUNT(*) AS plan_counts_pre_2021
FROM customer_plan_order
GROUP BY last_plan_value
ORDER BY last_plan_value
)
SELECT 
  lpv.last_plan_value AS plan_id,
  pl.plan_name,
  lpv.plan_counts_pre_2021,
  ROUND(100 * (lpv.plan_counts_pre_2021::numeric / SUM(lpv.plan_counts_pre_2021) OVER()), 1) AS plan_percentage -- total value of unique customers SUM(plan_counts_pre_2021) OVER()
FROM last_plan_values lpv
LEFT JOIN foodie_fi.plans pl 
  ON last_plan_value = pl.plan_id
ORDER BY plan_id

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT
  plan_id,
  COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions
WHERE plan_id = 3 AND start_date <= '2020-12-31'
GROUP BY plan_id;

-- Another flavor (Same count for the plan)
SELECT
  COUNT(DISTINCT customer_id) AS annual_customers
FROM foodie_fi.subscriptions
WHERE plan_id = 3
  AND start_date BETWEEN '2020-12-31' AND '2020-01-01';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH annual_customer_history AS (
SELECT 
  *,
  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS customer_event_rank
FROM foodie_fi.subscriptions
WHERE customer_id in (
  -- Can isolate the customers who at some point have had an anuual plan w/subquery
  SELECT DISTINCT customer_id FROM foodie_fi.subscriptions WHERE plan_id = 3
) 
ORDER BY customer_id, start_date
),
start_annual_dates AS (
SELECT
  customer_id,
  array_agg(start_date ORDER BY customer_event_rank) AS initial_annual_dates
FROM annual_customer_history
WHERE customer_event_rank = 1 OR plan_id = 3 -- capture first event and date of annual plan 
GROUP BY customer_id
),
age_difference AS (
SELECT 
  *,
  initial_annual_dates[2]::date - initial_annual_dates[1]::date AS total_between_days
FROM start_annual_dates 
)
SELECT ROUND(AVG(total_between_days)) AS avg_days_initial_annual
FROM age_difference;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH annual_customer_history AS (
SELECT 
  *,
  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS customer_event_rank
FROM foodie_fi.subscriptions
WHERE customer_id in (
  -- Can isolate the customers who at some point have had an anuual plan w/subquery
  SELECT DISTINCT customer_id FROM foodie_fi.subscriptions WHERE plan_id = 3
) 
ORDER BY customer_id, start_date
),
start_annual_dates AS (
SELECT
  customer_id,
  array_agg(start_date ORDER BY customer_event_rank) AS initial_annual_dates
FROM annual_customer_history
WHERE customer_event_rank = 1 OR plan_id = 3 -- capture first event and date of annual plan 
GROUP BY customer_id
),
age_difference AS (
SELECT 
  *,
  initial_annual_dates[2]::date - initial_annual_dates[1]::date AS total_between_days
FROM start_annual_dates 
),
-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
bins AS (
SELECT
  *,
  -- WIDTH_BUCKET takes the values, the spread or range (were looking from 0 - 360) and number of buckets to 
  WIDTH_BUCKET(initial_annual_dates[2]::date - initial_annual_dates[1], 0, 360, 12) AS bin_number
FROM age_difference
)
-- Set lower threshold by simply subtracting one then multiplying by our total equaly days in each bin or 360/12 = 30
SELECT 
  (bin_number - 1) * 30 || ' - ' || bin_number * 30 || ' days' AS breakdown_period,
  COUNT(*) AS customers
FROM bins 
GROUP BY bin_number
ORDER BY bin_number;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020
WITH customer_history_lag AS (
SELECT
  customer_id,
  plan_id,
  start_date,
  LAG(plan_id) OVER (
    PARTITION BY customer_id
    ORDER BY start_date 
  ) AS prev_plan
FROM foodie_fi.subscriptions
WHERE EXTRACT(year FROM start_date) = 2020
ORDER BY customer_id, start_date
)
-- We can then simply look for the plan id for the basic monthly 1 and if that row item has a previous value of the monthly_annual of 2
-- Only item here to maybe also consider if a "downgrade" is not a sequential event and happened for the customer but not as a direct next action which LAG would only look back 1 for
SELECT 
  COUNT(*) AS customer_count
FROM customer_history_lag
WHERE plan_id = 1 AND prev_plan = 2;

------------------------- End of Section B. Data Analysis -------------------------



------------------------- Section C. Payment Table -------------------------
CREATE TABLE payments_2020 AS
WITH RECURSIVE cutoff_date AS (
SELECT 
  sb.customer_id AS customer_id, 
  pl.plan_id AS plan_id, 
  pl.plan_name AS plan_name , 
  sb.start_date AS start_date, 
  pl.price AS price,
  LEAD(start_date, 1) OVER (
    PARTITION BY sb.customer_id 
    ORDER BY sb.start_date, sb.plan_id
  ) AS cutoff_date,
  pl.price AS amount
FROM foodie_fi.subscriptions AS sb
JOIN foodie_fi.plans AS pl
USING (plan_id)
WHERE plan_name NOT IN('trial', 'churn') AND 
  start_date BETWEEN '2020-01-01' AND '2020-12-31'
),
-- coalesce (set null value)
end_of_year AS (
SELECT
  customer_id,
  plan_id, 
  plan_name,
  start_date,
  COALESCE(cutoff_date, '2020-12-31') AS cutoff_date,
  amount
FROM cutoff_date
),
recursive_date_cte AS (
SELECT
  customer_id, plan_id, plan_name, start_date, cutoff_date, amount
FROM end_of_year
UNION ALL
SELECT
  customer_id, plan_id, plan_name,
  DATE((start_date + INTERVAL '1 month')) AS start_date,
  cutoff_date,
  amount
FROM recursive_date_cte
-- create table to union based on cutoff_date
WHERE cutoff_date > DATE((start_date + INTERVAL '1 month'))
  AND plan_name != 'pro annual'
),
-- however, need to look at the price value and adjust the "yearly value" if monthly plans already existed
annual_pay_adjustments AS (
SELECT 
  *,
  LAG(plan_id, 1) OVER (
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS last_payment_plan,
  LAG(amount, 1) OVER (
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS last_amount_paid,
  RANK() OVER (
    PARTITION BY customer_id
    ORDER BY start_date
  ) AS payment_order
  FROM recursive_date_cte
  ORDER BY customer_id, start_date
)
SELECT
  customer_id, plan_id, plan_name, start_date AS payment_date,
  CASE
    WHEN plan_id in (2, 3) AND last_payment_plan = 1
      THEN amount - last_amount_paid
    ELSE amount
  END AS amount,
  payment_order
FROM annual_pay_adjustments;

SELECT * FROM payments_2020;



------------------------- End of Section C. Payment Table -------------------------