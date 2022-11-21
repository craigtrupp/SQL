# SQL Data Problem Solving

* Now that we’ve combined all of our different datasets together into a single base table which we can use for our insights - let’s revise our email template and that base table that we now use for many of our downstream components.
* This base table was a temporary table that performed the below type joins to link each table of interest with the data point of interest 

<br>


## Email Template
![Email Template 1_2](Images/Template1_2.png)
![Email Template 2_2](Images/Template2_2.png)

---

<br>


## SQL Base Table
* Recall the Left Style Join or Inner Join Produced the Same Table Results

```sql
DROP TABLE IF EXISTS complete_joint_dataset;
CREATE TEMP TABLE complete_joint_dataset AS
SELECT
  rental.customer_id,
  inventory.film_id,
  film.title,
  rental.rental_date,
  category.name AS category_name
FROM dvd_rentals.rental
INNER JOIN dvd_rentals.inventory
  ON rental.inventory_id = inventory.inventory_id
INNER JOIN dvd_rentals.film
  ON inventory.film_id = film.film_id
INNER JOIN dvd_rentals.film_category
  ON film.film_id = film_category.film_id
INNER JOIN dvd_rentals.category
  ON film_category.category_id = category.category_id;

SELECT * FROM complete_joint_dataset limit 10;
```
|customer_id|film_id|title|rental_date|category_name|
|-----|-----|-----|-----|------|
|130|80|BLANKET BEVERLY|2005-05-24 22:53:30.000|Family|
|459|333|FREAKY POCUS|2005-05-24 22:54:33.000|Music|
|408|373|GRADUATE LORD|2005-05-24 23:03:39.000|Children|
|333|535|LOVE SUICIDES|2005-05-24 23:04:41.000|Horror|
|222|450|IDOLS SNATCHERS|2005-05-24 23:05:21.000|Children|
|549|613|MYSTIC TRUMAN|2005-05-24 23:08:07.000|Comedy|
|269|870|SWARM GOLD|2005-05-24 23:11:53.000|Horror|
|239|510|LAWLESS VISION|2005-05-24 23:31:46.000|Animation|
|126|565|MATRIX SNOWMAN|2005-05-25 00:00:40.000|Foreign|
|399|396|HANGING DEEP|2005-05-25 00:02:21.000|Drama|

---

<br>

## Data Next Steps
We will use this base table as our starting point as we work towards the customer level insights and the film recommendations.

In this tutorial we will aim to cover those core calculated fields which we broke down in our first reverse engineering section of this case study.

Let’s also revisit some of these calculations we need to perform again to jog our memory:

<br>

## Core Calculated Fields
* **category_name**: The name of the top 2 ranking categories
* **rental_count**: How many total films have they watched in this category
* **average_comparison**: How many more films has the customer watched compared to the average DVD Rental Co customer
* **percentile**: How does the customer rank in terms of the top X% compared to all other customers in this film category?
* **category_percentage**: What proportion of total films watched does this category make up?

We will need these calculated fields to help us arrive at the various interim table outputs to reach our final required outputs for this case study.

![Calculated Fields](Images/CalculatedFields.png)

* We mentioned earlier in the Multiple Table Joining tutorial that we would need to keep all of the rental category counts for each customer - just like it’s shown in the sample output above - however we might run into issues if we only keep those top 2 ranking categories as we perform some of these calculations.

* When we look at these core calculated metrics - the final 3 metrics average_comparison, percentile and category_percentage are actually dependent on all of the category counts and not just the top 2 ranked categories.

We will definitely need those top 2 category_name and rental_count values for every customer - but how can we compute those 3 calculations if we only want to keep those top 2 values?

---

<br>

### Sample Illustrated Example
Let’s paint an imaginary scenario where we only have 3 customers in our entire database - we can do this using our existing data example and taking only customer_id values of 1, 2 and 3.

We can generate each customers’ aggregated rental_count values for every category_name value from our complete_joint_dataset temporary table also.

* Let’s also sort the output by `customer_id` and show the `rental_count` from largest to smallest for each customer: 

```sql
-- Let’s also sort the output by customer_id and show the rental_count from largest to smallest for each customer (1,2,3)
SELECT
  customer_id,
  category_name,
  COUNT(*) AS category_film_rent_count
  FROM complete_joint_dataset
  WHERE customer_id in (1, 2, 3)
  GROUP BY customer_id, category_name
  ORDER BY customer_id ASC, category_film_rent_count DESC;
```
![Customer 1](Images/Customer_1.png)

![Customer 2](Images/Customer_2.png)

![Customer 3](Images/Customer_3.png)

---

<br>

### Top 2 Category Per Customer
Let’s now imagine that we just go full speed ahead and trim our dataset keeping only the top 2 categories for each customer - we would get the following results below.

Let’s just say we visually inspected our customer records because we will need to cover some window function magic before we can implement this ranking and filtering:

![Top 2 Per Customer](Images/Top_2_PerCustomer.png)

* `Customer 3` is an edge case where it just so happens that both Sci-Fi and Animation categories have a `rental_count` value of 3 - let’s dive into this a bit more.

<br>

### Dealing With Ties
We refer to this matching occurence as `“ties”` in regular conversation, usually you’ll hear things said in meetings and such like - “How are we going to deal with ties?”

There are multiple ways you can deal with these `“equal”` ranking row ties:
* Sort the values further by an additional condition or criteria
* Randomly select a single row

<br>

####  Do Not Select Randomly
* In most cases - you do not want to randomly select single rows as this is not `reproducible` 
    * meaning that often the behaviour will change each time you run the SQL query.

* This is a really important concept when it comes to `data science` in practice as we will often need to prove that we can **repeatedly** generate the same data points, even if some script or process is ran at different times.

So that leaves us with only option 1 - we will need to figure out what we should be sorting by as an additional criterion for our example.

<br>

#### Additional Sorting Criteria
Often times when we think about these additional sorting or ranking conditions - we should aim to choose something which 
makes the most sense in terms of a business or customer perspective or something which is low cost and simple to execute.

For example - a super simple method to execute might be to just sort the `category_name` fields alphabetically - it might not be the “best” solution for our customer experience, but it might just work when we need to do something really quickly without needing to acquire additional data!

<br>

#### Customer 3 categories sorted by rental count descending and alphabetical order
|customer_id|category_name|rental_count|
|-----|------|-------|
|3	|Action|	4|
|3	|Animation|	3|
|3	|Sci-Fi|	3|

<br>

However, for our email example (and in general) we should consider how a customer might respond as a result of certain decisions like this.

* One really common sorting method is to look at the most recent purchase or rental and sort by some recency metric based on when the last purchase was made.

* We could propose that we investigate when the latest rental was completed for each category - if we had this `rental_date` value for each individual rental record, we could easily find the `MAX(rental_date)` value for each `customer_id` and `category_name` combination.

* If we wanted to do this `rental_date` tracking - we must acquire this data point in our base temporary table for use in our queries.

However, luckily for us - it is not difficult to incorporate this additional rental_date field for our new calculations. You can check the query in the section below if you want to see how to do it:

The query below adds an additional filter for only `customer_id = 3` instead of customer_id IN (1,2,3) as our 3rd customer is the one with the ranking issue!

```sql
-- Finally perform group by aggregations on category_name and customer_id
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM complete_joint_dataset
-- note the different filter here!
WHERE customer_id = 3
GROUP BY
  customer_id,
  category_name
ORDER BY
  customer_id,
  rental_count DESC,
  latest_rental_date DESC;
```
![Rental Date - Customer 3](Images/customer_3_rd.png)

* Great - now we can see that Customer 3 most recent rental was from the Sci-Fi category - so we can use this additional criteria to sort the output and select the 2nd ranking category!

<br>

#### Additional Thoughts on Sorting and Testing
Keep in mind that this specific criteria we’ve used to sort is all theoretical - we can’t quite understand real customer preferences with the data we currently have!

Usually in these scenarios - we would perform some sort of split testing or other customer experiments to see what works. We might also send out some customer surveys and ask customers about what type of recommendations they would like to receive.

In general - these types of tests are often referred to as A/B tests or “champion vs challenger” tests and are super common in digital marketing, marketing analytics and even through to more complicated experimentation design with machine learning models!

Experimentation is a very broad topic and this simple example of us simply sorting our customer categories is nowhere near enough to cover even a fraction of the challenges and thinking behind this!

<br>

### Calculate Averages on Top 2 Categories
So now that we have all of our customers top 2 categories - let’s see what happens when we try to calculate the average on only just the top 2 categories dataset:

* Top 2 categories for all 3 customers

|customer_id|	category_name|	rental_count|
|--------|-------|-------|
|1	|Classics|	6|
|1	|Comedy|	5|
|2	|Sports|	5|
|2	|Classics|	4|
|3	|Action|	4|
|3	|Sci-Fi|	3|

* To demonstrate what happens - let’s manually generate this dataset using our trusted `CTE` and `VALUES` method we’ve seen multiple time before 

```sql
DROP TABLE IF EXISTS top_2_category_rental_count
CREATE TEMP TABLE top_2_category_rental_count AS
WITH input_data (customer_id, category_name, rental_count) AS (
    VALUES
    (1, 'Classics', 6),
    (1, 'Comedy', 5),
    (2, 'Sports', 5),
    (2, 'Classics', 4),
    (3, 'Action', 4),
    (3, 'Sci-Fi', 3)
)
SELECT * FROM input_data;

-- Check Output
SELECT * FROM top_2_category_rental_count;
```
* Produces same table as above

<br>

### CTE Average Rental Counts Customer Snippet
It should seem pretty clear that we have already experienced some sort of “data loss” - all of the Classics category films that customer 3 has watched are no longer in this existing dataset, and the same can be said about all of the other non top 2 category rental_count values for all of the other categories in the top_2_category_rental_count dataset.

If we were to calculate the average of all customer’s Classics films - there is actually no record for customer 3 and now the average is heavily skewed to only customers who have Classics as one of their top 2 categories - this is a bit of a no no!

So let’s back up a bit here and compare our averages with the original aggregated rental_count values for all of our categories - we’ll use that initial GROUP BY query as a CTE so we can keep everything in a single SQL statement:

```sql
WITH aggregated_rental_count AS (
  SELECT
    customer_id,
    category_name,
    COUNT(*) AS rental_count
  FROM complete_joint_dataset
  WHERE customer_id in (1, 2, 3)
  GROUP BY
    customer_id,
    category_name
  /* -- we remove this order by because we don't need it here!
     ORDER BY
     customer_id,
     rental_count DESC
  */
)
SELECT
  category_name,
  -- round out large decimals to just 1 decimal point
  ROUND(AVG(rental_count), 1) AS avg_rental_count
FROM aggregated_rental_count
GROUP BY
  category_name
-- this will sort our output in alphabetical order
ORDER BY
  category_name;
```
![Agg Rental Count](Images/Agg_CatRentalCount.png)

<br>

* Now let’s try calculating the same average rental count values for the top_2_category_rental_count dataset so we can compare them with the same values for the entire dataset.

```sql
SELECT
  category_name,
  -- round out large decimals to just 1 decimal point
  ROUND(AVG(rental_count), 1) AS avg_rental_count
FROM top_2_category_rental_count
GROUP BY
  category_name
-- this will sort our output in alphabetical order
ORDER BY
  category_name;
```

|category_name|avg_rental_count|
|------|-------|
|Action|	4.0|
|Classics|	5.0|
|Comedy|	5.0|
|Sci-Fi|	3.0|
|Sports|	5.0|

<br>

### Combined CTE For Top 2 Categorical Look
```sql
WITH aggregated_rental_count AS (
  SELECT
    customer_id,
    category_name,
    COUNT(*) AS rental_count
  FROM complete_joint_dataset
  WHERE customer_id in (1, 2, 3)
  GROUP BY
    customer_id,
    category_name
),
all_categories AS (
  SELECT
    category_name,
    -- round out large decimals to just 1 decimal point
    ROUND(AVG(rental_count), 1) AS all_category_average
  FROM aggregated_rental_count
  GROUP BY
    category_name
),
-- use a new CTE here with raw data entries just for completeness
top_2_category_rental_count (customer_id, category_name, rental_count) AS (
 VALUES
 (1, 'Classics', 6),
 (1, 'Comedy', 5),
 (2, 'Sports', 5),
 (2, 'Classics', 4),
 (3, 'Action', 4),
 (3, 'Sci-Fi', 3)
),
top_2_categories AS (
SELECT
  category_name,
  -- round out large decimals to just 1 decimal point
  ROUND(AVG(rental_count), 1) AS top_2_average
FROM top_2_category_rental_count
GROUP BY
  category_name
-- this will sort our output in alphabetical order
ORDER BY
  category_name
)
-- final select statement for output
SELECT
  top_2_categories.category_name,
  top_2_categories.top_2_average,
  all_categories.all_category_average
FROM top_2_categories
LEFT JOIN all_categories
  ON top_2_categories.category_name = all_categories.category_name
ORDER BY
  top_2_categories.category_name;
```

|category_name|top_2_average|all_category_average|
|-------|--------|-------|
|Action|4.0|3.0|
|Classics|5.0|3.7|
|Comedy|5.0|3.5|
|Sci-Fi|3.0|2.0|
|Sports|5.0|3.0|

<br>

### Alterantive / Categorical Review
So now that we know that there are going to be some serious differences when we look at those average values across each of the categories - we need to figure out an alternative solution instead of just picking the top 2 catgories and naively applying those aggregate functions.

This same issue will definitely impact the percentile value - how can we compare a specific customer’s ranking percentage compared to other customers if we don’t have the rental count for other customers for a specific category?

And finally the `category_percentage` calculation is actually only relative to a single customer’s rental behaviour - but how can we count the total rentals if we only have the top 2 categories?

Luckily there is a simple solution - we can just use the entire dataset for some of these calculations BEFORE we isolate the first 2 categories for our final output.

Let’s now try this whole process using the entire dataset instead of just `customer_id` of 1, 2 and 3!

---

<br>

## Data Aggregation on Whole Dataset
Just like we did before with our simple illustrated example - we will need to aggregate the `rental_count` values for each of our customers and categoy values, however this time - we will do our aggregations on the whole `complete_joint_dataset` temporary table we created earlier.

For the following few sections - we will split up each part of our various aggregations and calculations into separate temporary tables. See if you can figure out exactly why I’m doing this by the time we reach the end of this tutorial!

I’m not going to let you in on the exact reason now - but I will say that this breaking up into multiple tables will help us a lot when we need to finally compile an entire SQL script to generate our case study solution!

<br>

### 1) Customer Rental Count
Let’s first aggregate that `rental_count` value first - however let’s also use the version of the `joint dataset` that also had the `rental_date `for each record too so we can generate an additional `latest_rental_date` field for use with our sorting and ordering step, just like in our simple illustrated example.

```sql
DROP TABLE IF EXISTS category_rental_counts;
CREATE TEMP TABLE category_rental_counts AS
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count,
  MAX(rental_date) AS latest_rental_date
FROM complete_joint_dataset
GROUP BY
  customer_id,
  category_name;

-- profile just customer_id = 1 values sorted by desc rental_count
SELECT *
FROM category_rental_counts
WHERE customer_id = 1
ORDER BY
  rental_count DESC;
```
* Using Joined Temp Table  for all Customer Data

![Customer Rental Counts](Images/3_1_CustRentalCount.png)

<br>

### 2) Total Customer Rentals
In order to generate the `category_percentage` calculation we will need to get the total rentals per customer. This is a piece of cake using a simple `GROUP BY` and `SUM`

    category_percentage: What proportion of each customer’s total films watched does this count make?

```sql
DROP TABLE IF EXISTS customer_total_rentals;
CREATE TEMP TABLE customer_total_rentals AS
SELECT
  customer_id,
  SUM(rental_count) AS total_rental_count
FROM category_rental_counts
GROUP BY customer_id;

-- show output for first 5 customer_id values
SELECT *
FROM customer_total_rentals
WHERE customer_id <= 5
ORDER BY customer_id;
```
* Using the created temp table `category_rental_counts` created in the first step, a temporary `total_rental` counts per customer can be performed by aggregating the sum of the rental counts after grouping by each `customer_id`

![Total Cust Rentals](Images/3_2_CustTotals.png)

<br>

### 3) Average Category Rental Counts 
* Finally we can also use the AVG function with all of our category records for all customers to calculate the true average rental count for each category.

```sql
DROP TABLE IF EXISTS average_category_rental_counts;
CREATE TEMP TABLE average_category_rental_counts AS
SELECT
  category_name,
  AVG(rental_count) AS avg_rental_count
FROM category_rental_counts
GROUP BY
  category_name;

-- output the entire table by desc avg_rental_count
SELECT *
FROM average_category_rental_counts
ORDER BY
  avg_rental_count DESC;
```
![Avg Cat Rentals](Images/3_3_CatAvgRent.png)

* For my sanity I did a spot check here to confirm the Averages (Spot Check `Animation`)

```sql
SELECT 
  SUM(rental_count) AS total_rentals,
  (SELECT SUM(rental_count) AS anime_sum FROM category_rental_counts WHERE category_name = 'Animation'),
  (SELECT COUNT(*) AS total_animation_cat_rows FROM category_rental_counts WHERE category_name = 'Animation'),
  (SELECT SUM(rental_count) AS anime_sum FROM category_rental_counts WHERE category_name = 'Animation') / (SELECT COUNT(*) AS total_animation_cat_rows FROM category_rental_counts WHERE category_name = 'Animation') AS anime_avg
  FROM category_rental_counts;
```
![Avg Anime](Images/Avg_Anime_Check.png)

|total_rentals|anime_sum|total_animation_cat_rows|anime_avg|
|-----|-------|-------|------|
|16044|1166|500|2.3320000000000000|

* They match!
* Using a subquery and the `category_rental_counts` temp table, the average generated for each category is generated through the sum of each categorical count against the total rows for each category
    * Each found row for the categorical search (Animation example above) would have varying numbers for the grouped by total for that category per customer

<br>

### 4) Update Table Values
Since it might seem a bit weird to be telling customers that they watched 1.346 more films than the average customer - let’s make an executive decision and just take the `FLOOR` value of the decimal to give our customers a bit of a feel-good boost that they watch more films (as opposed to if we rounded the number to the nearest integer!)

We can do this directly with that temp table we created by running an `UPDATE` command.

If you need to update multiple columns at one time, you can use a comma to separate each set of column and new value pairs.

We can also set a `WHERE` clause to only update specific rows that meet some condition we want.

Additionally - we can return the rows which were adjusted by specifying a `RETURNING * at the end of the query.

Just to demonstrate all of this functionality - let’s create an exact copy of our `average_category_rental_counts` temporary table and call it `testing_average_category_rental_counts` and we will try to update a few things for films that start with the letter 'C'

Let’s try adding 100 to our average rental count value and also adding an extra string ‘Category’ to the end of our `category_name` field:

```sql
-- first create a copy of average_category_rental_counts
DROP TABLE IF EXISTS testing_average_category_rental_counts;
CREATE TEMP TABLE testing_average_category_rental_counts AS
  TABLE average_category_rental_counts;

-- now update all the things!
UPDATE testing_average_category_rental_counts
SET
  avg_rental_count = avg_rental_count + 10,
  category_name = category_name || ' Category'
WHERE
  -- first character of category_name is 'C'
  LEFT(category_name, 1) = 'C'
-- show all updated rows as the query output
RETURNING *;
```

The above query returns the following output:

|category_name|	avg_rental_count|
|------|-------|
|Classics Category|	12.0064102564102564|
|Comedy Category|	11.9010101010101010|
|Children Category|	11.9605809128630705|

And we can finally check that the underlying values in the `testing_average_category_rental_counts` table has indeed changed:

```sql
SELECT *
FROM testing_average_category_rental_counts
ORDER BY category_name;
```
![Cat Update](Images/cat_update.png)

* Ok - now that we’ve tested out all the different bits for the `UPDATE` statement - let’s now update our table for real. We will still use the `RETURNING *` to show what has changed in the process:

```sql
UPDATE average_category_rental_counts
SET avg_rental_count = FLOOR(avg_rental_count)
RETURNING *;
```
![Cat Update 2 of 2](Images/cat_updates_2.png)

<br>

### 5) Percentile Values
After that quick whirlwind tour of using `UPDATE` let’s continue with our final calculated field we’ll need to tackle - the percentile field:

* `percentile`: How does the customer rank in terms of the top X% compared to all other customers in this film category?

![Perc Values](Images/perc_value_3_5.png)

<br>

### 6) Percent Rank Window Function
We can use the `PERCENT_RANK` window function to easily generate our percentile calculated field - however it only generates decimal percentages from 0 to 1!

All window functions must have an `OVER` clause - and in the case of `PERCENT_RANK` which is actually an ordered analytical function - it must also have an `ORDER BY` clause at the minimum - but a `PARTITION BY` clause can also be used with this window function - which we will demonstrate how to use for our current problem!

For now - you can think of the `PARTITION BY` as a similar version of `GROUP BY` which helps split our dataset into specific “groups” or “window frames” to perform further calculations. For this `percentile` field - we actually need to partition on the `category_name` values as we will be trying to get all of the percentile metrics within each unique category

The `ORDER BY` clause is very similar to how it’s used when we want to sort SQL outputs in a specific order - however the ordering is not only required for our `PERCENT_RANK` window function - it is critical!

For our example - we will want to order by the `rental_count` in descending order in order to return us the expected top N% result that we need for our case study.

Don’t worry if all these terms seem a bit confusing - we will cover them in much more depth in the very next tutorial.

We can use our aggregated `rental_count` values at a `customer_id` and `category_level` in the `category_rental_counts` temp table we created earlier to generate the required output like so - let’s first inspect the results for customer_id = 1 for all of their records:

```sql
SELECT
  customer_id,
  category_name,
  rental_count,
  PERCENT_RANK() OVER (
    PARTITION BY category_name
    ORDER BY rental_count DESC
  ) AS percentile
FROM category_rental_counts
ORDER BY customer_id, rental_count DESC
LIMIT 14;
```
![Percent Rank](Images/prcnt_rank.png)