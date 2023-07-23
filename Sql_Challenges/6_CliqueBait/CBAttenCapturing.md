## **Clique Bait**
![clickque bait](images/clique_bait_6.png)

### **Introduction**
Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

### `Available Data`
For this case study there is a total of 5 datasets which you will need to combine to solve all of the questions.

<br>

#### **Clique Bait Tables**

`Users`
* Customers who visit the Clique Bait website are tagged via their `cookie_id`

|user_id|cookie_id|start_date|
|---|-----|----|
|397|	3759ff|	2020-03-30 00:00:00|
|215|	863329|	2020-01-26 00:00:00|
|191|	eefca9|	2020-03-15 00:00:00|
|89	|764796|	2020-01-07 00:00:00|
|127|	17ccc5|	2020-01-22 00:00:00|
|81	|b0b666|	2020-03-01 00:00:00|
|260|	a4f236|	2020-01-08 00:00:00|
|203|	d1182f|	2020-04-18 00:00:00|
|23	|12dbc8|	2020-01-18 00:00:00|
|375|	f61d69|	2020-01-03 00:00:00|

`Events`
* Customer visits are logged in this events table at a `cookie_id` level and the `event_type` and `page_id` values can be used to **join** onto relevant satellite tables to obtain further information about each event.

The sequence_number is used to order the events within each visit.

|visit_id	|cookie_id	|page_id	|event_type	|sequence_number	|event_time|
|-----|-----|-----|-----|----|-----|
|719fd3	|3d83d3|	5	|1	|4	|2020-03-02 00:29:09.975502|
|fb1eb1	|c5ff25|	5	|2	|8	|2020-01-22 07:59:16.761931|
|23fe81	|1e8c2d|	10	|1	|9	|2020-03-21 13:14:11.745667|
|ad91aa	|648115|	6	|1	|3	|2020-04-27 16:28:09.824606|
|5576d7	|ac418c|	6	|1	|4	|2020-01-18 04:55:10.149236|
|48308b	|c686c1|	8	|1	|5	|2020-01-29 06:10:38.702163|
|46b17d	|78f9b3|	7	|1	|12	|2020-02-16 09:45:31.926407|
|9fd196	|ccf057|	4	|1	|5	|2020-02-14 08:29:12.922164|
|edf853	|f85454|	1	|1	|1	|2020-02-22 12:59:07.652207|
|3c6716	|02e74f|	3	|2	|5	|2020-01-31 17:56:20.777383|


`Event Identifier`
* The event_identifier table shows the types of events which are captured by Clique Bait’s digital data systems.

|event_type	|event_name|
|-----|-----|
|1	|Page View|
|2	|Add to Cart|
|3	|Purchase|
|4	|Ad Impression|
|5	|Ad Click|

`Campaign Identifier`
* This table shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020.

|campaign_id|products|campaign_name|start_date|end_date|
|-----|----|-----|-----|-----|
|1	|1-3|	BOGOF - Fishing For Compliments	    |2020-01-01 00:00:00	|2020-01-14 00:00:00|
|2	|4-5|	25% Off - Living The Lux Life	    |2020-01-15 00:00:00	|2020-01-28 00:00:00|
|3	|6-8|	Half Off - Treat Your Shellf(ish)	|2020-02-01 00:00:00	|2020-03-31 00:00:00|


`Page Hierarchy`
* This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

|page_id|page_name|product_category|product_id|
|----|----|-----|-----|
|1	|Home Page	    |null	    |null|
|2	|All Products	|null	    |null|
|3	|Salmon	    |Fish	    |1|
|4	|Kingfish	    |Fish	    |2|
|5	|Tuna	       |Fish	    |3|
|6	|Russian Caviar|Luxury	    |4|
|7	|Black Truffle|	Luxury	    |5|
|8	|Abalone|	    Shellfish	|6|
|9	|Lobster|	    Shellfish	|7|
|10	|Crab|          Shellfish	|8|
|11	|Oyster|	    Shellfish	|9|
|12	|Checkout|	    null	    |null|
|13	|Confirmation|	null	    |null|


---

<br>

### **Case Study Questions**

#### `A. Enterprise Relationship Diagram`
* Using the following DDL schema details to create an ERD for all the Clique Bait datasets.
    - ... aight I'm gonna get here but using MySQLWorkBench as well for familiarity with that tool and likely reverse engineering
    - More to come here but let's get to querying to kick the project off

<br>

#### `B. Digital Analysis`
Using the available datasets - answer the following questions using a single query for each one:

**1.** How many users are there?
```sql
-- How many users are there?
SELECT COUNT(DISTINCT user_id) AS user_count
FROM clique_bait.users;
```
|user_count|
|----|
|500|

<br>

**2.** How many cookies does each user have on average?
```sql
-- Get user unique cookies
WITH user_cookie_counts AS (
SELECT 
  user_id,
  COUNT(DISTINCT cookie_id) AS user_unique_counts
FROM clique_bait.users
GROUP BY user_id
)
SELECT * FROM user_cookie_counts LIMIT 5;
```
|user_id|user_unique_counts|
|----|----|
|1|4|
|2|4|
|3|5|
|4|2|
|5|3|

* Now average them
```sql
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
```
|average_user_cookie_amount|user_avg_str|
|----|----|
|3.56|Users averaged 3.56 cookies.|

<br>

**3.** What is the unique number of visits by all users per month?
```sql
-- Quick look at total row count to validate our return on subsequent query
SELECT COUNT(*) from clique_bait.users;
```
|count|
|--|
|1782|

```sql
-- This is just the counts of user events (we want event details)
SELECT
  DATE_PART('MONTH', start_date) AS Month,
  TO_CHAR(start_date, 'Month') AS Month_Name,
  COUNT(*) AS User_Counts_Per_Month,
  SUM(COUNT(*)) OVER() AS total_row_check
FROM clique_bait.users
GROUP BY Month, Month_Name
ORDER BY User_Counts_Per_Month DESC;
```
|month|month_name|user_counts_per_month|total_row_check|
|-----|-----|-----|-----|
|2|February|744|1782|
|3|March|458|1782|
|1|January|438|1782|
|4|April|124|1782|
|5|May|18|1782|

<br>

* Unique Number of visits by all users per month will look at data from the `Event` table
```sql
-- UNION ALL (Same Counts)
SELECT COUNT(DISTINCT cookie_id) FROM clique_bait.events
UNION ALL
SELECT COUNT(DISTINCT cookie_id) FROM clique_bait.users;
```
|count|
|----|
|1782|
|1782|

* We can see here that the events and users appear to share the same distinct cookie_id but the counts of rows in events is a lot higher as it appears to be a `many-many` type relationship
```sql
SELECT visit_id, cookie_id, sequence_number
FROM clique_bait.events
ORDER BY visit_id
LIMIT 5
```
|visit_id|cookie_id|sequence_number|
|---|----|----|
|242220|001652|1|
|c4120b|001652|1|
|c4120b|001652|2|
|c4120b|001652|3|
|c4120b|001652|4|

```sql
SELECT 
  DATE_PART('Month', event_time) AS Month,
  TO_CHAR(event_time, 'Month') AS Month_Name,
  COUNT(DISTINCT visit_id) AS monthly_unique_user_visits
FROM clique_bait.events
GROUP BY Month, Month_Name;
```
|month|month_name|monthly_unique_user_visits|
|-----|----|----|
|1|January|876|
|2|February|1488|
|3|March|916|
|4|April|248|
|5|May|36|

<br>

**4.** What is the number of events for each event type? 
* Looking outside of Users now for some Event Detail
```sql
SELECT
  ev.event_type,
  evid.event_name,
  COUNT(*) AS event_type_count
FROM clique_bait.events AS ev
INNER JOIN clique_bait.event_identifier AS evid
  USING(event_type)
GROUP BY ev.event_type, evid.event_name
ORDER BY event_type_count DESC;
```
|event_type|event_name|event_type_count
|----|----|----|
|1|Page View|20928|
|2|Add to Cart|8451|
|3|Purchase|1777|
|4|Ad Impression|876|
|5|Ad Click|702|

<br>

**5.** What is the percentage of visits which have a purchase event?
```sql
SELECT
  ev.event_type,
  evid.event_name,
  ROUND(
  COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM clique_bait.events)
  , 2) AS purchase_percentage_decimal,
  CONCAT(
  100 * ROUND(
  COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM clique_bait.events)
  , 2), '%') AS purchase_percentage
FROM clique_bait.events AS ev
INNER JOIN clique_bait.event_identifier AS evid
  USING(event_type)
WHERE evid.event_name = 'Purchase'
GROUP BY ev.event_type, evid.event_name;
```
|event_type|event_name|purchase_percentage_decimal|purchase_percentage|
|-----|-----|------|-----|
|3|Purchase|0.05|5.00%|

<br>

- So the above is unfortunately ... not right but a good idea of what I was first thinking when assessing the tables without an ERD diagram and know relationship between `events` and `users`. Now to more of the purchase events items
```sql
-- Now the way this looks is we would be looking at the distinct count of unique `visit_ids` against how many actually turned into a event_type of purchase
SELECT
  e.event_type,
  ei.event_name,
  SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase_count,
  (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events) AS unique_user_visit,
  ROUND(
  SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END)::NUMERIC / (SELECT COUNT(DISTINCT visit_id) AS unique_visit FROM clique_bait.events)
  , 4) AS decimal_percentage,
  CONCAT(
    ROUND(
    100 * SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END)::NUMERIC / (SELECT COUNT(DISTINCT visit_id) AS unique_visit FROM clique_bait.events)
    , 2), '%') AS purchase_perc_per_unique_visits 
FROM clique_bait.events AS e 
INNER JOIN clique_bait.event_identifier AS ei 
  USING(event_type)
WHERE ei.event_name = 'Purchase'
GROUP BY e.event_type, ei.event_name;
```
|event_type|event_name|purchase_count|unique_user_visit|decimal_percentage|purchase_perc_per_unique_visits|
|----|----|-----|-----|------|---|
|3|Purchase|1777|3564|0.4986|49.86%|

<br>

* Here's another way 
```sql
WITH cte_visits_with_purchase_flag AS (
  SELECT
    visit_id,
    MAX(CASE WHEN event_type = 3 THEN 3 ELSE 0 END) AS purchase_flag
  FROM clique_bait.events
  GROUP BY visit_id
)
SELECT
  ROUND(100 * SUM(purchase_flag) / COUNT(*), 2) AS purchase_percentage
FROM cte_visits_with_purchase_flag;
```
|visit_id|purchase_flag|
|----|----|
|fbfdcb|0|
|d27c65|0|
|79553d|0|
|aded2b|0|
|dc8de5|0|
|c91b3c|1|
|2be4dc|0|

* So now we have each visited grouped by (visit_id can have many events (`one-visit to many-events`)) so we would want to SUM the purchase flag and divide by our total unique visits
```sql
WITH cte_visits_with_purchase_flag AS (
  SELECT
    visit_id,
    SUM(CASE WHEN event_type = 3 THEN 1 ELSE 0 END) AS purchase_flag
  FROM clique_bait.events
  GROUP BY visit_id
)
SELECT
  100 * SUM(purchase_flag) / (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events)::NUMERIC AS purchase_percentage,
  SUM(purchase_flag) AS total_purchases, 
  (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events) AS unique_events,
  CONCAT(ROUND(100 * SUM(purchase_flag) / (SELECT COUNT(DISTINCT visit_id) FROM clique_bait.events)::NUMERIC, 2), '%') AS purchase_perc_str
FROM cte_visits_with_purchase_flag;
```
|purchase_percentage|total_purchases|unique_events|purchase_perc_str|
|-----|----|-----|-----|
|49.8597081930415264|1777|3564|49.86%|

<br>

**6.** What is the percentage of visits which view the checkout page but do not have a purchase event?
```sql
SELECT
  ev.event_type,
  evid.event_name,
  COUNT(*) AS event_type_count,
  ROUND(
    COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER() 
  , 2) AS event_percetange_decimal,
  CONCAT(
  100 * ROUND(
  COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER() 
  , 2), '%') AS event_percetange
FROM clique_bait.events AS ev
INNER JOIN clique_bait.event_identifier AS evid
  USING(event_type)
WHERE evid.event_name IN ('Purchase', 'Add to Cart')
GROUP BY ev.event_type, evid.event_name;
```
|event_type|event_name|event_type_count|event_percetange_decimal|event_percetange|
|-----|-----|-----|----|----|
|3|Purchase|1777|0.17|17.00%|
|2|Add to Cart|8451|0.83|83.00%|


