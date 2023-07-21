


-- Section B 
-- 1
SELECT COUNT(DISTINCT user_id) AS user_count
FROM clique_bait.users;

-- 2
WITH user_cookie_counts AS (
SELECT 
  user_id,
  COUNT(DISTINCT cookie_id) AS user_unique_counts
FROM clique_bait.users
GROUP BY user_id
)
SELECT
    ROUND(AVG(user_unique_counts), 2) AS average_user_cookie_amount,
    CONCAT('Users averaged ', ROUND(AVG(user_unique_counts), 2), ' cookies.') AS user_avg_str
FROM user_cookie_counts;

-- 3
SELECT
  DATE_PART('MONTH', start_date) AS Month,
  TO_CHAR(start_date, 'Month') AS Month_Name,
  COUNT(*) AS User_Counts_Per_Month,
  SUM(COUNT(*)) OVER() AS total_row_check
FROM clique_bait.users
GROUP BY Month, Month_Name
ORDER BY User_Counts_Per_Month DESC;