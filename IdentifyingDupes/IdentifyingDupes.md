# Identifying Duplicate Data


Duplicate records are literally everywhere when you start dealing in the world of real-life messy datasets.

In this tutorial, we will learn how to deal with these situations by providing a real messy dataset that we will analyse together - and perhaps you might even broaden your thinking and philosophy about dealing with dirty data!

Sometimes we need to take a step back from this low level data work and inspect the problem from a 10,000 foot view so we can see the forest instead of always going from tree to tree.

One thing I would like to **stress** on you is the importance of dealing with duplicates in any dataset!

Supreme amounts of care is required to deal with these two before diving into any further analytics!

A word of warning also - this section will build off our previously covered topics but will also introduce new SQL techniques as we start combining techniques to round out our SQL skillset!

Make sure to read through all the various code chunks carefully and please run them in the SQL Docker environment!

___
<br>

## Introduction to Health Data
In this tutorial we will use a new database table to cover some of these concepts: `health.user_logs`

For context, this real world messy dataset captures data taken from individuals logging their measurements via an online portal throughout the day.

For example, multiple measurements can be taken on the same day at different times, but you may notice this information is missing as the log_date column does not show timestamp values!

Welcome to the real world of messy datasets :)

Build on our knowledge base from the previous tutorials - do you remember what was one of the first steps in analyzing a new dataset we’ve never seen before?

You can find this table under the health schema on the left part of the SQLPad GUI

**Let’s inspect a snapshot to view the first 10 rows from the `health.user_logs` table**

#### _Example Exercise_:

> Just initial row for output from query below

```sql
SELECT *
FROM health.user_logs
LIMIT 10;
```
| id | log_date | measure | measure_value | systolic | diastolic
|:---| :------ | :------ | :------ | :------ | :------ | 
|fa28f948a74032....|2020-11-15 | weight | 46.03959	| null | null|

___

<br>

## Record Counts 
Let’s also take a quick look at a few basic counts to get a good feel for our dataset
: `health.user_logs`


#### _Example Exercise_:

```sql
SELECT *
FROM health.user_logs
LIMIT 10;
```
| count |
|:---|
|43891|

___

<br>

## Unique Column Counts
Let’s use the `COUNT DISTINCT` to take a look at how many unique `id` values there are in this dataset.

This will give us a feel for how many unique users there are whilst we continue getting a better picture of what’s going on!

--- 
#### _Example Exercise_:
```sql
SELECT COUNT(DISTINCT id)
FROM health.user_logs;
```
| count |
|:---|
|554|

___

<br>

## Single Column Frequency Counts

Let’s also inspect that **measure** column and take a look at the most frequent values within this column using a `GROUP BY` and `ORDER BY DESC` combo from the last tutorial - let’s also throw in that percentage column that we went through also!

> Implement a Window Function for each individual measure's overall percentage frequency

#### Example Exercise:

```sql
SELECT
  measure,
  COUNT(*) AS measure_frequency,
  ROUND(
  100 * COUNT(*) / SUM(COUNT(*)) OVER()
  , 2) 
FROM health.user_logs
GROUP BY measure;
```

| measure | measure_frequency | round|
|:---| :-------| :---------------|
|blood_glucose| 38692 | 88.15 |
|blood_pressure| 2417 | 5.51 |
|weight| 2782 | 6.34 | 


>  `100 * COUNT(*)` multipies the count of the group frequencies values, `SUM(COUNT(*))` generates the sum of all generated frequencies for measure (ex : 38692 * 43894 = 0.881487... * 100 for percentage) 
> `OVER()` is our window function for the logic to Work over for the resulting window, 
> `ROUND()` is called on the result of the operation above and rounds to two decimal places


<br><br>

# How to Deal w/Duplicates
Duplication of data might occur due to many different reasons, often these are related to upstream issues with data collection, data processing or even manual data entry mistakes - think of all those times you made typos when filling in an Excel spreadsheet!

In SQL there are a few different ways to deal with these duplicate records:

* Remove them in a SELECT statement
* Recreating a “clean” version of our dataset
* Identify exactly which rows are duplicated for further investigation or
* Simply ignore the duplicates and leave the dataset alone
* Wait…what? You want me to just ignore duplicate data?!?

Before we jump to any conclusions - let’s find out more as we start peeling the layers off our problem.

Firstly, we need to figure out if we even have duplicate records in our table!
___

<br>

## Detecting Duplicate Records
Before we think about removing duplicate records - we need a systematic way to check whether our table has any duplicate records first!

There are actually a few different ways to do this but I will show you first a simple method before jumping to the most efficient solution.

The first ingredient for this recipe is the basic record count for our table - plain and simple using the `COUNT(*)` just like we did above.
    
```sql
SELECT COUNT(*)
FROM health.user_logs;
```

The next step is to apply this same `COUNT(*)` method - but on a deduplicated version of the dataset.

So in the end - we actually need to remove duplicates first to even figure out if we have duplicates…talk about redundancy!

Although that previous roundabout notion of removing duplicates to find out if we have duplicates is slightly confusing - actually removing duplicates from a table is not confusing at all.

We can apply the same `DISTINCT` keyword we’ve used previously to do this like so:

```sql
SELECT DISTINCT *
FROM health.user_logs;
```

The next part of the duplicate identification recipe is to count the number of rows in this deduplicated dataset.

So, you’re probably thinking - no worries, all I need to do is something like this

```sql
SELECT COUNT(DISTINCT *)
FROM health.user_logs;
```

**Unfortunately** for us - PostgreSQL does not allow for this style of `COUNT(DISTINCT *)` syntax like we can use on a single column!

There are some other flavours of SQL that actually allow for this syntax namely Teradata, however it is not a standard operation which we can use everywhere.

However, it is relatively straightforward to get around this!

There are a few schools of thought on how exactly this COUNT DISTINCT should be done - I’ll show you a few different ways and then suggest you which one I recommend to use so you can gain exposure to more SQL techniques.

Take special note of the differences between the SQL syntax for each method.

___

<br>

## Hello, Subqueries!
A subquery is essentially a _query within a query_ - in this case we want to use our `DISTINCT *` output in the innermost nested query as a data source for the outer query.

Take note of the syntax - especially the AS component because **subqueries must always have an alias!**
    

#### _Example Exercise_:


```sql
SELECT COUNT(*)
FROM (
SELECT DISTINCT *
FROM health.user_logs
) AS distinct_health_sq;
```
|count|
|:----|
|31004|

> The innner (nested query pulls all the distinct rows) and the outer query counts the total rows from the pulled distinct nested query return

___

<br>

### Adding a Percentage Column - **BONUS**
This following section is an optional bonus component as it will touch on some SQL techniques which we have yet to cover so far in this course!

Sometimes the frequency is just not enough to really understand the frequency at a quick glance, so we like to create an additional **percentage** column to our dataset.

There are actually various ways to perform this operation but I will keep things simple and show you the most efficient way using a modified window function combining both `SUM` and `COUNT` functions with an `OVER()` clause.

Take note of that `::NUMERIC` right after the `COUNT(*)` - this is to avoid the dreaded integer floor division 

* We can also multiple this percentage value by 100 and round it to 1 decimal place using a `ROUND` function.
  + **COUNT(*)::NUMERIC** returns the grouped by column total count and multiplies by 100 for non fractional percentage w/round function below
  + **SUM(COUNT(*))** returns the total rows that is being divided against to see the percentage for the grouped column 
    + Ex : 223 * 100 / 997 =  22.37

```sql
SELECT
  rating, 
  COUNT(*) AS frequency,
  ROUND(
    100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER(),
    2
  ) AS percentage
FROM dvd_rentals.film_list
GROUP BY rating
ORDER BY frequency DESC
LIMIT 5;
```
|rating|frequency|percentage|
|:------|:------|:-------|
|PG-13|223|22.37|
|NC-17|210|21.06|
|PG|194|19.46|
|R|193|19.36|
|G|177|17.75|

<br>

> Without Round function called on Window Function
```sql
SELECT 
  rating,
  COUNT(*) AS frequency,
  COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER() AS percentage
FROM dvd_rentals.film_list
GROUP BY rating
ORDER BY COUNT(*) DESC;
```
|rating|frequency|percentage|
|:------|:------|:-------|
|PG-13|223|0.22367101303911735206|
|NC-17|210|0.21063189568706118355|
|PG|194|0.19458375125376128385|
|R|193|0.19358074222668004012|
|G|177|0.17753259779338014042|



___

<br>

## Counts For Multiple Column Combinations
Previously we have been looking at the unique values for just 1 column. In this section we will demonstrate how best to analyse combinations of 2+ columns.

The simplest way to do this is to apply the same `GROUP BY` clause and just specify additional columns in the grouping element expressions at the bottom of the SQL statement.

When we use `GROUP BY` on 2+ columns, the subsequent `COUNT` function will aggregate the records based off the unique combination of values in these columns instead of just a single 1.

It is quite common to see queries to profile specific columns by descending frequency like the following example.

Note that the syntax is very similar to the previous GROUP BY example but with the addition of more columns in both the `SELECT` statement and the following `GROUP BY` clause.

<br>

#### Example Exercise:

1. What are the 5 most frequent rating and category combinations in the film_list table? - `Limit` 5

```sql
SELECT
  rating,
  category,
  COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY rating, category
ORDER BY frequency DESC
LIMIT 5;
```

|rating|category|frequency|
|:------|:------|:-------|
|PG-13|Drama|22|
|NC-17|Music|20|
|PG-13|Foreign|19|
|PG-13|Animation|19|
|NC-17|New|18|

___

<br>

## Using Positional Numbers Instead of Column Names

This is actually quite an important note because you will run into this sooner or later in any SQL situation!

Some SQL developers like to refer to target columns used in `GROUP BY` and `ORDER BY` clauses by the **positional** number that the columns appear in the `SELECT` statement.

Be mindful that this is usually just a stylistic choice made by different developers in different teams and there is no right or wrong when it comes to this!

For example using our previous code snippet with just a `GROUP BY` clause to demonstrate what we mean by this:

```sql
SELECT
  rating,
  category,
  COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY 1,2
```

>Although this may look quite clean - often times it could become actually harder to read and very prone to making mistakes when you are writing the code!

I would recommend sticking with complete column names where possible, sometimes you can use numbers in the `GROUP BY` clause for a huge amount of columns instead of listing them all out explicitly - but be sure to be very clear with your expression inputs for the `ORDER BY` clause to maximise readibility and comprehension for anyone reading your code!

* Tough to Interpret
```sql
SELECT
  rating,
  category,
  COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
```
* Better 
```sql
SELECT
  rating,
  category,
  COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY 1,2
ORDER BY frequency DESC
LIMIT 5;
``` 

* **Best!**
```sql
SELECT
  rating,
  category,
  COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY rating, category
ORDER BY frequency DESC
LIMIT 5;
```

---

<br>

## Exercises
These exercises will take a quick look at the other tables within the dvd_rentals schema.
> SQL Answers are in subsequent file in Folder

1. Which actor_id has the most number of unique film_id records in the dvd_rentals.film_actor table?
2. How many distinct **fid** values are there for the three most common price values in the dvd_rentals.nicer_but_slower_film_list table?
3. How many unique country_id values exist in the dvd_rentals.city table?
4. What percentage of overall total_sales does the Sports category make up in the dvd_rentals.sales_by_film_category table?
5. What percentage of unique fid values are in the Children category in the dvd_rentals.film_list table?


<br>

## Conclusion
The following concepts, methods were covered above 

* `COUNT` function
* `DISTINCT` keyword
* `GROUP BY` clauses and how they work under the hood
* Use `ORDER BY` with `GROUP BY` to selectively sort the output
* Column **aliases** to rename `SELECT` expressions in the final output
* Frequency/counts for a single column and multiple column combinations
* Efficiently calculate the counts percentage for groups using window functions

> Ensure that any numeric agg function applied should cast either the top or bottom term (column value ) to a `::NUMERIC` type to avoid Integere floor division scenarios!


