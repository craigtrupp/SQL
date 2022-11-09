# Back to the Marketing Case Study ... 

## Case Study Overview
![Case Study Overview](Images/CStudyOverview_jmt.png) 

<br>

### Requirements
* Requirements lecture slides in class notes for (Week 7 PDFs)

1. Top 2 Movie Categories for each customer
2. Film Recommendations for top 2 categories
    * Max 3 Films Per Category
    * Must not have watch recommended films before
3. Individual customer Top Category insights
    * Number of films watched
    * Comparison to DVD Rental Co average
    * Top X% ranking
4. Individual customer 2nd category insights
    * Number of films watched
    * Percentage of viewing history
5. Favorite actor insights & recommendations
    * Number of films watched
    * Max 3 film recommendations
    * Previously watched & top 2 category recommendations must not be included!

<br>

---

<br>

## Design a Plan of Attack!
I’m sure you realize that we’re going to have to do some serious table joining in order to generate our data outputs for this case study.

The first thing we need to do is to design a plan of attack by systematically breaking down our required SQL outputs and inspecting exactly which columns we need from the various tables in our ERD.

To keep things simple - let’s first start off with the required SQL outputs for our top categories information.

<br>

### Define The Final State
As seen in the previous data overview tutorial, the top categories insight aims to generate the raw data points required to fill in the title and headline insights for the email template.

The key columns that we will need to generate include the following data points at a customer_id level:

* **category_name**: The name of the top 2 ranking categories
* **rental_count**: How many total films have they watched in this category
* **average_comparison**: How many more films has the customer watched compared to the   average DVD Rental Co customer
* **percentile**: How does the customer rank in terms of the top X% compared to all other customers in this film category?
* **category_percentage**: What proportion of total films watched does this category make up?

![Sample Joins](Images/Final_Smpl_St_jmt.png)


<br>

### Reverse Engineering
In the final table output - we can see that the `category_name`, `average_comparison`, `percentile` and `category_percentage` are going to need some intense SQL calculations to generate these outputs.

You might also notice that the `rental_count` value is actually used in all of the calculations:

The top 2 `category_name` values are included for each customer ID because we only sure the category rankings of 1 and 2 for each customer.

Additionally - the `average_comparison` and percentile is calculated across all customers at a category level in order to find that DVD Rental Co averagte.

And finally the `category_percentage` relates to the proportion of each top 2 category to each individual customer’s total number of films watched.

Clearly we can see this `rental_count` is going to be the key for our analysis - so let’s focus on the columns we’ll need to generate this all important value!

If we now remove all the dependent calculated columns: category_ranking, average_comparison, percentile and category_percentage - we are left with the following table (below snippet)

|customer_id|category_name|rental_count|
|-------|----------|--------|
|1|Classics|6|
|1|Comedy|5|
|2|Sports|5|
|2|Classics|4|

<br>

#### However - there is one more catch!
* Since we only have the top 2 categories for each customer in this specific table - how can we calculate those above fields which need to be compared against all customer and categories?
* In short - we need to include all of the categories for each customer otherwise we can’t make those calculations!
* Let’s take a look at all the category rental counts by customer_id and category_name for just customer_id = 1

|customer_id|category_name|rental_count|
|-------|----------|--------|
|1|Classics|6|
|1|Comedy|5|
|1|Drama|4|
|1|Sports|2|
|1|Action|2|
|1|Music|2|
|1|Animation|2|
|1|New|2|
|1|Sci-Fi|2|

<br>

Now if we take it back even one step further - you should notice that this is going to be some sort of aggregated query to generate this table - something along the lines of:

```sql
SELECT
  customer_id,
  category_name,
  COUNT(*) AS rental_count
FROM the_next_level_down
GROUP BY
  customer_id,
  category_name
```

<br>

... And Now if we were to go one level down and dream up what that granular table might look like - we should have which films a customer has watched and the `category_name` for each rental record: (snippet)

|customer_id|title|category_name|
|-------|----------|--------|
|1	|MINDS TRUMAN|	Action|
|1	|WOMEN DORADO|	Action|
|1	|DOORS PRESIDENT|	Animation|
|1	|BIKINI BORROWERS|	Animation|
|1	|PATIENT SISTER|	Classics|
|1	|MUSKETEERS WAIT|	Classics|
|1	|DETECTIVE VISION|	Classics|
|1	|FROST HEAD|	Classics|
|1	|JEEPERS WEDDING|	Classics|
|1	|PATIENT SISTER|	Classics|
|1	|FIREBALL PHILADELPHIA|	Comedy|
|1	|CLOSER BANG|	Comedy|
|1	|FIREBALL PHILADELPHIA|	Comedy|

<br>

#### Reminder
* This is just for customer_id = 1 but if we generate this same dataset for each customer - we should be ok to generate all of the previously reverse engineered steps further up in this tutorial!

<br>

### Identify Key Columns and Start & End Points
So if we need to generate the reverse engineered datasets required to calculate this `rental_count` at a `customer_id` level - or simply put the number of films that a customer has watched in a specific category - we might need the following information for our analysis:

* `customer_id`
* `category_name`

The first mental leap we have to make is to realise that we will need to start at the `dvd_rentals.rental table`.

“Why is this the case?” you might be thinking…

The **dvd_rentals.rental** table is the only place where our `customer_id` field exists - it’s the only place where we can identify how many films a customer has watched.

However there is a catch - how can link the records in the **dvd_rentals.rental** table to get the `category_name` we need for our analysis?

Focusing in on that `category_name` field - the only table which we can get that data point is the **dvd_rentals.category** table.

With this information alone - we now have our start and end points of our data joining journey - now let’s figure out how to combine our data to get these two fields together in the same SQL table output!

<br>

### Map the Joining Journey
![Entity Diagram](Images/erd_jmt.png)
Starting with our `dvd_rentals.rental` table we can see that we do indeed have the `customer_id` as well as addition columns - but there is no `category_name` in sight, in fact we are very far away!

After inspecting the ERD - we need to get from `dvd_rentals.rental` labeled as number 1 all the way through to table number 5 - `dvd_rentals.category`

Note: you might have realised that the actor tables are not part of this current scenario - don’t worry! The actor tables labeled 6 and 7 will be used later in the case study!

When we travel through our `ERD` from tables 1 through to 5 though we can see that there is indeed a linear journey that we need to take and even further to this - we can use those blue lines to identify the foreign keys (or routes if we want to continue with our metaphor!) that we need to use for our table joining journey!

So here is the final version of our 4 part table joining journey itinerary:

|Join Journey Part|	Start|	End|	Foreign Key|
|-------|------|------|-----|
|Part 1|	rental|	inventory|	inventory_id|
|Part 2|	inventory|	film|	film_id|
|Part 3|	film|	film_category|	film_id|
|Part 4|	film_category|	category|	category_id|

### Join Journey Visualized
![First](Images/jn1_jmt.png)
![Second](Images/jn2_jmt.png)
![Third](Images/jn3_jmt.png)
![Four](Images/jn4_jmt.png)


* Let’s now start analyzing each start and end point in depth so we can proceed on our joining journey with confidence - but first onto the most important part of this tutorial!

<br>

---

<br>

## Deciding Which Type of Table Joins to Use
If you literally forgot every other thing from this entire tutorial and just remembered this section - I would be ok with it!

To answer this one question “What type of table join should we use?” we actually need to answer 3 additional questions! (crazy right…)

1. What is the purpose of joining these two tables?
2. What is the distribution of foreign keys within each table?
3. How many unique foreign key values exist in each table?

Failing to answer any of these 3 questions before you embark on a SQL table joining journey will harpoon your chances of actually getting the job done!

I found that jumping into joins too early without additional thought and context is THE MOST COMMON ERROR I’ve seen made by SQL developers throughout my career.

To make things even worse - these joining errors are almost always the most impactful error because getting your joining strategy wrong can cause all sorts of downstream problems when your data is all messed up!

To avoid these errors - we need to first focus on having a clear purpose.

<br>

### Joining Journey Considerations - Path

For part 1 of our table joining journey - we can see that we need to start with the rental table and end at the inventory table using the foreign key `inventory_id` - however does this really tell us anything about the purpose?

We need to fly higher and view our journey from a real bird’s eye view - what are we actually trying to achieve with these series of table joins?

Perhaps it’s been lost in all this talk about purpose and journeys - so let’s go over our first required output shall we?
* We need to generate the `rental_count` calculation
    * the number of films that a customer has watched in a specific category.

<br>

So now if we dive back down to our table joining journey again - we have the `rental` table which consists of the important `customer_id` data point BUT we also know that this rental table also has the actual number of films that each customer has watched.

However there is a catch with our **dvd_rentals.rental** table - all the table records are not yet tracked at the `film_id` level - they only have the `inventory_id` which is recorded for each customer’s rental record.

When we look through the other tables in the ERD - we can notice the **inventory** table which can be used to help us get the `film_id` column for each rental.

We can think of the deeper purpose of this join between the two tables in the following way:

* We need to keep **all** of the customer rental records from dvd_rentals.rental and match up each record with its equivalent film_id value from the dvd_rentals.inventory table.
    * Good idea what type of join may be needed by keyword like above which might be a `left` type join

<br>

### Left Join or Inner Join?
So once we are clear with the purpose of our join - we need to figure out how we want to implement it using SQL code.

For our first purpose - it looks like we will want to retain all of the data points in the rental table and make sure that there are valid film_id records for each row that is returned from the resulting table join.

Do you remember the various types of table joins we described in our last tutorial - which join do you think would best suit this scenario or purpose?

Straightaway - your mind should intuitively think about performing either a `LEFT` or an `INNER` join in this scenario. 

Whenever we need to retain all of the records and match on additional data from a `“right”` lookup table - these 2 joins should be front of mind.

However - there is one more question. Which join should we use? Should we use the `LEFT` or `INNER` join in our specific scenario?

<br>

### Key Analytical Questions
Now here is where things could get tricky, as there are a few unknowns that we need to address as we are matching the `inventory_id` foreign key between the `rental` and `inventory` tables.

* How many records exist per `inventory_id` value in `rental` or `inventory` tables?
* How many overlapping and missing unique foreign key values are there between the two tables?

The same questions can be used for all scenarios and is not just limited to this specific table join!
1. How many records exist per foreign key value in left and right tables?
2. How many overlapping and missing unique foreign key values are there between the two tables?

<br>

### The 2 Phase Approach
The best way to answer these follow up questions is usually in 2 separate phases.

Firstly you should think about the actual problem and datasets in terms of what they mean in real life.

Whilst thinking through the problem - we want to generate some hypotheses or assumptions about the data. (Yeah sorta like data science…)


#### Data Hypotheses
Since we know that the `rental` table contains every single rental for each customer - it makes sense logically that each valid rental record in the rental table should have a relevant `inventory_id` record as people need to physically hire some item in the store.

Additionally - it also makes sense that a specific item might be rented out by multiple customers at different times as customers return the DVD as shown by the return_date column in the dataset.

Now when we think about the inventory table - it should follow that every item should have a unique `inventory_id` but there may also be multiple copies of a specific film.

From these 2 key pieces of real life insight - we can generate some hypotheses about our 2 datasets.

1. The number of unique `inventory_id` records will be equal in both `dvd_rentals.rental` and `dvd_rentals.inventory` tables
2. There will be a multiple records per unique `inventory_id` in the `dvd_rentals.rental` table
3. There will be multiple `inventory_id` records per unique `film_id` value in the `dvd_rentals.inventory` table

<br>

### Validating Hypotheses with Data

#### Hypothesis 1
* The number of unique `inventory_id` records will be equal in both `dvd_rentals.rental` and `dvd_rentals.inventory` tables
```sql
SELECT COUNT(DISTINCT(inventory_id)) FROM dvd_rentals.rental; -- 4,580
SELECT COUNT(DISTINCT(inventory_id)) FROM dvd_rentals.inventory; --4,581
```
**Findings**: 
There seems to be 1 additional `inventory_id` value in the dvd_rentals.inventory table compared to the dvd_rentals.rental table

This warrants further investigation but it seems to invalidate our first hypothesis - which is exactly what we are after!

<br>

#### Hypothesis 2
* There will be a multiple records per unique `inventory_id` in the `dvd_rentals.rental` table
```sql
SELECT
  inventory_id,
  COUNT(*) as inventory_rentals
  FROM dvd_rentals.rental
  GROUP BY inventory_id;
```
|inventory_id|inventory_rentals|
|------|------|
|1489|5|
|273|5|
|3936|4|
|2574|5|
|951|3|
|4326|4|
|2614|3|
* Expand and get counts of ids with x amount of rentals
* Whilst this above table is somewhat useful when inspecting the top ranking inventory_id values or the max number of rows that an inventory_id might appear - we can’t really glean much more insight from this cut of the data.
    * Another way to view this information would be to further aggregate this output by counting the unique `inventory_id` values whilst performing a a group by on that newly generated `row_counts` column. Row counts in this context in our hypotheses translates to unique rentals seen for that inventory item
```sql
-- first generate group by counts on the target_column_values column
WITH counts_base AS (
SELECT
  inventory_id AS target_column_values,
  COUNT(*) AS row_counts
FROM dvd_rentals.rental
GROUP BY target_column_values
)
-- summarize the group by counts above by grouping again on the row_counts from counts_base CTE part (group by is on numeric value - all inventory_id (target_column) == the same count will be counted)
-- output is total counts of inventory_ids' rental rows/instances (so 1489 (inv_id) has 5 row counts in the rental table) - x amount of inventory_ids also have that many rentals)
SELECT
  row_counts,
  COUNT(target_column_values) as count_of_target_values
FROM counts_base
GROUP BY row_counts
ORDER BY row_counts;
```
|row_counts|count_of_target_values|
|------|------|
|1|4|
|2|1126|
|3|1151|
|4|1160|
|5|1139|

**Findings**: We can indeed confirm that there are multiple rows per `inventory_id` value in our `dvd_rentals.rental` table.

<br>

#### Hypothesis 3
* There will be multiple `inventory_id` records per unique `film_id` value in the `dvd_rentals.inventory` table

```sql
-- Quick check of distinct counts for film_ids versus total row counts for table for startest
SELECT
  COUNT(DISTINCT(film_id))
  FROM dvd_rentals.inventory; -- 958

SELECT COUNT(*)
FROM dvd_rentals.inventory; -- 4581
```

* We can use this same approach as hypothesis 2 but instead of groupinng on the `inventory_id` - we will instead group on the `film_id` column and perform a count distinct on the inventory_id before summarizing the outputs

```sql
-- first generate group by counts on the target_column_values column
WITH counts_base AS (
SELECT
  film_id AS target_column_values,
  COUNT(DISTINCT inventory_id) AS unique_record_counts
FROM dvd_rentals.inventory
GROUP BY target_column_values
)
-- summarize the group by counts above by grouping again on the row_counts from counts_base CTE part
SELECT
  unique_record_counts,
  COUNT(target_column_values) as count_of_target_values
FROM counts_base
GROUP BY unique_record_counts
ORDER BY unique_record_counts;
```
|unique_record_counts|count_of_target_values|
|------|------|
|2|133|
|3|131|
|4|183|
|5|136|
|6|187|
|7|116|
|8|72|

**Findings**: We can confirm that there are indeed multiple unique `inventory_id` per `film_id` value in the `dvd_rentals.inventory` table.

<br>

### Returning to the 2 Key Questions
As we inspect the two tables in question to validate our hunches or hypotheses about the data - we can also cover those 2 key questions that we need answers to for every table join.

Do you remember the 2 questions that we need to answer when we are joining tables together?
1. How many records exist per inventory_id value in rental or inventory tables?
2. How many overlapping and missing unique foreign key values are there between the two tables?

One of the first places to start inspecting our datasets is to look at the distribution of foreign key values in each `rental` and `inventory` table used for our join.

The distribution and relationship within the table by the foreign keys is super important because it helps us inspect what our table joining inputs consist of and also determines what sort of outputs we should expect after joining.
