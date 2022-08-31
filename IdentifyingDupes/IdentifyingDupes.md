# Exploring Data with SQL

You may have heard people talk about how they would investigate, explore, profile or analyze a new dataset.

Did you also ask yourself “what does it really mean?” and “how can we use **SQL** to do this?”

This tutorial will cover a few useful ideas to keep in mind when taking a look at a new dataset in a SQL database.

Namely, we will be looking at how many records there are in a given table and also start to investigate what are the unique or distinct values in a specific column or table.

* For all the coding examples in this tutorial - we will investigate the range of DVDs that are available for hire in our sample dataset running in docker
  + dvd_rentals.film_list
  + schema.table

* Be sure to run a simple `SELECT * FROM dvd_rentals.film_list` to inspect the raw data before diving into the rest of this tutorial. Reading through some of the film descriptions should give you a good laugh!
  + **Don't** forget a `LIMIT`!

___

## How Many Records?
One of the first things we like to know about any dataset is **_how many rows there are_**!

It is really important to know just how many records there are in a table prior to running further analytical queries on the dataset.

The data size will have significant impacts on performance, as will indexes which we cover indepth later in this program!

In the following example, we use the `COUNT` function to take a look at a simple record count in a table.

Often you will see `COUNT(*)` out in the wild - we commonly refer to this as **“count star”** when talking about this in conversation!


#### Example Exercise:

1. How many rows are there in the film_list table?

```sql
SELECT COUNT(*) AS row_count
FROM dvd_rentals.film_list;
```
| row_count |
|:---|
|997|

___

## Column Aliases

Notice in the query above how there is an extra **AS** row_count after that `COUNT(*)`?

This is known as a **“column alias”** which is used to specify a name for an expression in the select statement. In this case, we are renaming our `COUNT(*)` expression to **“row_count"** instead of the default name “count”.

**Aliases** can also be used to name other SQL expressions such as 
* database tables 
* subqueries 
* common table expressions **(CTEs)**.

Aliases are really important when joining tables and performing other operations with CTEs as they vastly improve SQL code readability - reducing the time it takes for you to write and debug the code, as well as for others to quickly scan and understand your code!

> There is a saying - code is written once, read multiple times! This is exactly why we must strive to always write simple understandable code (that also looks nice!)

<br>

### Formatting Note:

One more additional note - sometimes you might see SQL record count queries written with `COUNT(1)` instead of `COUNT(*)` - in essence there is no difference, it is purely a stylistic choice!

My recommendation would be to use the same convention as whatever your team uses in the workplace - however my personal preference would be to use `COUNT(*)` where possible as it is the most clear for anyone else reading your code!

```sql
SELECT COUNT(1) AS row_count
FROM dvd_rentals.film_list;
```
```sql
SELECT COUNT(*) AS row_count
FROM dvd_rentals.film_list;
```

___

## `DISTINCT` For Unique Values

Often we will be interested in identifying just how many unique values there are in a specific column or table.

We can look at these values by themselves but more commonly we will try to look at the counts or frequencies, the number of times certain combinations occur within a dataset.

First let’s take a look at extracting the unique values only.

___

<br>

### Show Unique Column Values

We can use the `DISTINCT` keyword to obtain unique values from a deduplicated target column.

You might hear the terms dedupe, deduplicate, distinct or unique interchangeably in the workplace but just know that these all mean the same thing!

#### Example Exercise:

1. What are the unique values for the rating column in the film table?

```sql
SELECT DISTINCT rating
FROM dvd_rentals.film_list;
```

| rating |
|:---|
|NC-17|
|R|
|PG-13|
|PG|
|G|

___

<br>

### Count of Unique Values

Maybe you’re not interested in the actual unique values themselves but rather, you might want to know how many of them there are - in other words
>you want to know the count of `distinct` values within a column.

<br>

We can use the `COUNT` function with the `DISTINCT` keyword to find the number of unique values of a specific column.

#### Example Exercise:

1. How many unique category values are there in the film_list table?

```sql
SELECT DISTINCT rating
FROM dvd_rentals.film_list;
```

|count|
|:----|
|16|
___

## `Group By` Counts
Although the unique values or a `distinct` count of one column can be very useful when answering certain types of data questions - we can take this style of analysis further by using the `GROUP BY` clause with a `COUNT` aggregate function to help us generate a basic frequency value counts output.

One way to think of the `GROUP BY` is to imagine our dataset being divided into different groups based off the values of selected columns.

Say for example - we would like to answer the following question:

#### Example Exercise:

1. What is the frequency of values in the rating column in the film_list table?


```sql
SELECT 
  rating,
  COUNT(*)
FROM dvd_rentals.film_list
GROUP BY rating;
```

| rating | count|
|:---|:-----|
|NC-17| 210|
|R|193|
|PG-13|223|
|PG|194|
|G|177|

___

<br>

### Apply Aggregate Count Function
Once we have split the dataset into the groups specified for the `GROUP BY` we then apply the **aggregate** function within each of these grouped datasets to condense our output to a single row from each group.
*  Sample table result above in previous section
    
In future tutorials, we will use this exact same construct to apply different type of mathematical aggregate functions to `GROUP BY` example such as `SUM`, `MEAN`, `STDDEV`, `MAX` and `MIN` - more on this soon!

* The important thing to note for `GROUP BY` aggregate functions is this:
> Only **1** row is returned for each group

<br>

This is a super important concept - true mastery of SQL requires a really strong understanding of this `GROUP BY` usage. If you don’t retain anything else from this section - please remember that only 1 row will ever be returned for each individual group from a `GROUP BY` !

Only the expression that is used in the `GROUP BY` grouping elements will be returned along with a single column value for each aggregate function used in the column expressions for the `SELECT` statement.

___

<br>

### Single Column Value Counts
Now that we understand well what is going on under the hood with our simple but powerful `GROUP BY` clause - let’s apply it to the real complete dataset!

For the following code snippet - take special attention to the order of the syntax.

The `GROUP BY` must be used after the **FROM** statement otherwise you will get a syntax error and your SQL code will not run
    

#### Example Exercises:

1. What is the frequency of values in the category column in the film table? - `Limit` 2

```sql
SELECT 
  category,
  COUNT(*)
FROM dvd_rentals.film_list
GROUP BY category
LIMIT 2;
```
|category|count|
|:------|:------|
|Sports|73|
|Classics|57|

<br>

2. What is the frequency of values in the category column in **ASC** order? - `Limit` 2

```sql
SELECT 
  category,
  COUNT(*) as frequency
FROM dvd_rentals.film_list
GROUP BY category
ORDER BY frequency
LIMIT 2;
```

|category|frequency|
|:------|:------|
|Music|51|
|Travel|56|



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


