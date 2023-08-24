--------------------- Case Study Questions ----------------------
-- 1. What is the total amount each customer spent at the restaurant?
-- Multiple Window Functions here to get an idea of daily/total value
SELECT
  s.customer_id,
  s.order_date,
  s.product_id,
  SUM(price) OVER (
    PARTITION BY s.customer_id, s.order_date
    ORDER BY s.order_date
  ) AS customer_order_date_sum,
  SUM(price) OVER(
    PARTITION BY s.customer_id
  ) AS customer_total_sum
FROM dannys_diner.sales AS s 
INNER JOIN dannys_diner.menu AS m
  USING(product_id)

-- Simple Aggregate
SELECT
  s.customer_id,
  SUM(m.price) AS customer_total_sum
FROM dannys_diner.sales AS s 
INNER JOIN dannys_diner.menu AS m
  USING(product_id)
GROUP BY s.customer_id
ORDER BY customer_total_sum DESC;


-- 2. How many days has each customer visited the restaurant?
SELECT
  s.customer_id,
  COUNT(DISTINCT order_date) AS customer_total_visits
FROM dannys_diner.sales AS s
GROUP BY s.customer_id
ORDER BY customer_total_visits DESC;


-- 3. What was the first item from the menu purchased by each customer?
-- DENSE RANK for any products purchased on same day (ranked the same)
WITH first_menu_item_customer_purchase AS (
SELECT
  s.customer_id,
  s.order_date,
  s.product_id,
  m.product_name,
  DENSE_RANK() OVER (
    PARTITION BY customer_id
    ORDER BY order_date
  ) AS item_purchase_rank_by_date
FROM dannys_diner.sales s 
INNER JOIN dannys_diner.menu m 
  USING(product_id)
)
SELECT *
FROM first_menu_item_customer_purchase
WHERE item_purchase_rank_by_date = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- per customer
WITH most_purchased_item AS (
SELECT 
  s.product_id,
  m.product_name,
  COUNT(*) AS menu_product_sales_count
FROM dannys_diner.sales AS s 
INNER JOIN dannys_diner.menu AS m
  USING(product_id)
GROUP BY s.product_id, m.product_name
ORDER BY menu_product_sales_count DESC
-- JUST WANT THE Top Item
LIMIT 1
)
SELECT
  s.customer_id,
  s.product_id,
  m.product_name,
  COUNT(*) AS customer_top_menu_item_purchases
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
  USING(product_id)
WHERE s.product_id = (SELECT product_id FROM most_purchased_item)
GROUP BY s.customer_id, s.product_id, m.product_name
ORDER BY customer_top_menu_item_purchases DESC;

-- aggregate of all customers
SELECT 
  m.product_name AS product,
  COUNT(*) AS total_product_purchases
FROM dannys_diner.sales s 
INNER JOIN dannys_diner.menu m
  USING(product_id)
GROUP BY product 
ORDER BY total_product_purchases DESC;


-- 5. Which item was the most popular for each customer?
WITH most_purchased_item_per_customer AS (
SELECT
  s.customer_id,
  s.product_id,
  m.product_name,
  DENSE_RANK() OVER (
    PARTITION BY customer_id
    ORDER BY COUNT(*) DESC
  ) AS customer_menu_item_rankings,
  COUNT(*) AS customer_item_purchase_count
FROM dannys_diner.sales s 
INNER JOIN dannys_diner.menu m 
  USING(product_id)
GROUP BY customer_id, product_id, product_name
ORDER BY customer_id
)
SELECT *
FROM most_purchased_item_per_customer
WHERE customer_menu_item_rankings = 1
ORDER BY customer_id;


-- 6. Which item was purchased first by the customer after they became a member?
WITH new_member_purchase_rankings AS (
SELECT
  s.customer_id,
  m.join_date AS member_join_date,
  s.order_date,
  s.product_id,
  mn.product_name,
  DENSE_RANK() OVER (
    PARTITION BY s.customer_id
    ORDER BY s.order_date
  ) AS new_member_purchase_rankings
FROM dannys_diner.members AS m
INNER JOIN dannys_diner.sales AS s 
  ON m.customer_id = s.customer_id
INNER JOIN dannys_diner.menu AS mn 
  USING(product_id)
WHERE m.join_date <= s.order_date
ORDER BY m.customer_id
)
SELECT * 
FROM new_member_purchase_rankings
WHERE new_member_purchase_rankings = 1;

-- Another Approach
WITH member_sales_cte AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    menu.product_name,
    RANK() OVER (
      PARTITION BY sales.customer_id
      ORDER BY sales.order_date
    ) AS order__rank
  FROM dannys_diner.sales
  INNER JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
  INNER JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id
  WHERE
    sales.order_date >= members.join_date::DATE
)
SELECT DISTINCT
  customer_id,
  order_date,
  product_name
FROM member_sales_cte
WHERE order__rank = 1


-- 7. Which item was purchased just before the customer became a member?
WITH pre_member_purchase_rankings AS (
SELECT
  s.customer_id,
  m.join_date AS member_join_date,
  s.order_date,
  s.product_id,
  mn.product_name,
  DENSE_RANK() OVER (
    PARTITION BY s.customer_id
    -- with where below we want to order by most recent leading up to the join date as a member
    ORDER BY s.order_date DESC
  ) AS pre_member_purchase_ranking
FROM dannys_diner.members AS m
INNER JOIN dannys_diner.sales AS s 
  ON m.customer_id = s.customer_id
INNER JOIN dannys_diner.menu AS mn 
  USING(product_id)
WHERE m.join_date > s.order_date
ORDER BY m.customer_id
)
SELECT * 
FROM pre_member_purchase_rankings
WHERE pre_member_purchase_ranking = 1;


-- 8. A) What is the total items and amount spent for each member before they became a member?
SELECT
  customer_id,
  COUNT(*) AS total_items_pre_member_join_date,
  SUM(mn.price) AS sales_total_pre_member_join_date
FROM dannys_diner.sales AS s 
INNER JOIN dannys_diner.members AS m 
  USING(customer_id)
INNER JOIN dannys_diner.menu AS mn 
  USING(product_id)
WHERE m.join_date < s.order_date
GROUP BY customer_id
ORDER BY sales_total_pre_member_join_date DESC;

-- 8. B)  What is the number of unique menu items and total amount spent for each member before they became a member?
SELECT 
  customer_id,
  COUNT(DISTINCT product_name),
  SUM(price)
FROM dannys_diner.sales sl 
  INNER JOIN dannys_diner.menu mn 
  USING(product_id)
  INNER JOIN dannys_diner.members mb 
  USING(customer_id)
WHERE sl.order_date < mb.join_date
GROUP BY customer_id
ORDER BY customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
  sales.customer_id,
  -- Captrue SUM of points grouped by customer with different product types
  SUM(
    CASE
      WHEN menu.product_name = 'sushi' 
        THEN 2 * (10 * menu.price)
      ELSE 10 * menu.price
    END
  )
  AS points
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY points DESC;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?
WITH member_join_date_diff AS (
SELECT 
  s.customer_id AS customer_id,
  s.order_date AS order_date,
  mn.product_name,
  mn.price,
  m.join_date,
  s.order_date - m.join_date AS date_diff
FROM dannys_diner.sales AS s 
INNER JOIN dannys_diner.members AS m 
  USING(customer_id)
INNER JOIN dannys_diner.menu AS mn 
  USING(product_id)
WHERE order_date <= '2021-01-31'
ORDER BY s.customer_id, s.order_date
),
-- BETWEEN is inclusive for each end of the provided range
member_end_jan_points AS (
SELECT 
  customer_id,
  order_date,
  join_date,
  product_name,
  price,
  CASE
    WHEN date_diff BETWEEN 0 AND 7
      THEN (price * 10) * 2
    WHEN date_diff > 7
      AND product_name != 'sushi'
      THEN price * 10
    WHEN date_diff > 7
      AND product_name = 'sushi'
      THEN (price * 10) * 2
    ELSE 0
    END AS member_purchase_points
FROM member_join_date_diff 
)
SELECT 
  customer_id,
  SUM(member_purchase_points) AS member_points_end_jan
FROM member_end_jan_points
GROUP BY customer_id
ORDER BY member_points_end_jan DESC;

-------------------------- End of Case Study Non Bonus -----------------------



------------------------- Bonus Section --------------------
-- The following questions are related creating basic data tables that Danny and his team can use to quickly 
-- derive insights without needing to join the underlying tables using SQL.

-- 1. Recreate the following table output using the available data:
WITH customer_sales_member_join AS (
SELECT 
  sl.customer_id AS customer_id,
  sl.order_date AS order_date,
  mn.product_name AS product_name,
  mn.price AS price,
  memb.join_date AS join_date
FROM dannys_diner.sales AS sl 
INNER JOIN dannys_diner.menu AS mn
  USING(product_id)
LEFT JOIN dannys_diner.members AS memb 
  ON sl.customer_id = memb.customer_id
ORDER BY customer_id, order_date
)
SELECT
  customer_id,
  order_date,
  product_name,
  price,
  CASE 
    WHEN join_date IS NULL
      THEN 'N'
    WHEN join_date > order_date
      THEN 'N'
    WHEN join_date <= order_date
      THEN 'Y'
  END AS member 
FROM customer_sales_member_join
ORDER BY customer_id, order_date, product_name;

-- 2. Danny also requires further information about the `ranking` of customer products, but he purposely does not 
-- need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
WITH customer_sales_member_join AS (
SELECT 
  sl.customer_id AS customer_id,
  sl.order_date AS order_date,
  mn.product_name AS product_name,
  mn.price AS price,
  memb.join_date AS join_date
FROM dannys_diner.sales AS sl 
INNER JOIN dannys_diner.menu AS mn
  USING(product_id)
LEFT JOIN dannys_diner.members AS memb 
  ON sl.customer_id = memb.customer_id
ORDER BY customer_id, order_date
),
member_date AS (
SELECT
  customer_id,
  order_date,
  product_name,
  price,
  CASE 
    WHEN join_date IS NULL
      THEN 'N'
    WHEN join_date > order_date
      THEN 'N'
    WHEN join_date <= order_date
      THEN 'Y'
  END AS member 
FROM customer_sales_member_join
ORDER BY customer_id, order_date, product_name
)
SELECT
  customer_id,
  order_date,
  product_name,
  price,
  member,
  CASE
    WHEN member = 'N'
      THEN null
    WHEN member = 'Y'
      THEN 
      DENSE_RANK() OVER(
        PARTITION BY customer_id, member
        ORDER BY order_date
      )
  END AS ranking
FROM member_date
ORDER BY customer_id, order_date, product_name;


-------------------------- End of Bonus Section --------------------------