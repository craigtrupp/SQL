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

## Common Table Expression
CTE stands for **Common Table Expression** - and when we compare it to something simple like Excel, we can think of CTEs as transformations applied to raw data inside an existing Excel sheet.

A CTE is a SQL query that manipulates existing data and stores the data outputs as a new reference, very similar to storing data in a new temporary Excel sheet (following the Excel analogy!)

Subsequent CTEs can refer to existing datasets, as well as previously generated CTEs. This allows for quite complex nested queries and operations to be performed, whilst keeping the code nice and readable!

We will be using CTEs a lot throughout this course - if you find yourself being overwhelmed by this, just remember that these are just like new Excel sheets generated with new data. You will definitely get used to this after we solve 100+ questions using them :)

```sql
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT COUNT(*)
from deduped_logs;
```
|count|
|:----|
|31004|

> CTE is a sequential way and instead of reading inside out (with a subquery), the expression can be read top to bottom. A fair bit easier to digest!

___

<br>

## Temporary Tables 
Whilst we could use **subqueries** and **CTEs** to capture the output directly in a single query - we can also create a temporary table with only the unique values of our dataset after we run the `DISTINCT` query.

This is a very common approach when you know that you will only be analyzing the deduplicated dataset, and you will ignore the original one with duplicates.

The main benefit of using temporary tables is removing the need to always run the same `DISTINCT` command everytime you want to run a query on the deduplicated records.

Temporary tables can also be used with **indexes** and **partitions** to speed up performance of our SQL queries - something which we will cover later!

There is a lengthier process to dealing with temporary tables, which is a multi-step ordeal!

First we run a `DROP TABLE IF EXISTS` statement to clear out any previously created tables
In practice - we like to make sure all the temporary tables we create are “clean” and often we will clear out any tables with the same target name as our new temporary table, just in case or better safe than to be sorry!

Be very super careful when running this following DROP TABLE statement as you can’t really undo things when you drop an actual table…

Well…I guess you can always restart your Docker environment and a fresh version of this database will be ready for you - but just know that you can really do some damage if you carelessly drop production tables in the workplace. You’ve been warned!!!

> `DROP TABLE IF EXISTS deduplicated_user_logs`;

<br>

* Next let’s create a new temporary table using the results of the query below

```sql
CREATE TEMP TABLE deduplicated_user_logs AS
SELECT DISTINCT *
FROM health.user_logs;
```
* Take note of the syntax for the first line in the above query, particularly the **AS** at the end of the line which tells SQL to use the output from the following query to populate the newly created table

<br>

> With the temporary table in place now holding all distinct records, the newly created table can be queried

```sql
SELECT COUNT(*)
from deduplicated_user_logs;
```
|count|
|:----|
|31004|



___

<br>

## Which to choose??

Generally a choice in which of the three options serves best can be guided by the following question

> Will I need to use the deduplicated data later?

<br>

If yes - opt for temporary tables.

If no - CTEs are your friend.

Usually we would not recommend subqueries as they are less readable than CTEs - making it more difficult for others to quickly understand your code!

CTE's are an elegant and easilier understood way to digest such operations. Also much easier to debug!

---

<br>

## Comparing Counts

OK so going back to our original purpose of detecting the presence of duplicate records in our dataset - can you figure out the logical conclusion to this exercise?

We now have the row counts of the original table **43,891** and of our deduplicated table **31,004**

It’s pretty safe to say that we have some deuplicate records!

By comparing the counts of the original and the deduplicated, we can prove the presence of duplicates.

But is that all we can do with these duplicate values…what if we wanted to know more?

Also what do you think of this labourious effort of having to calculate counts for both tables and manually comparing them?

What if there was another way to do this…

--- 

<br>

## Group By Counts On All Columns

> This technicque will allow you to gather a Count of each duplicated row (along with individual rows) but will `Have` a shot at that next :)

The trick is to use a `GROUP BY` clause which has every single column in the grouping element and a `COUNT` aggregate function - this is an elegant solution to quickly find the unique combinations of all the rows.

Hang on a second…isn’t that exactly what the `DISTINCT` keyword is supposed to do?

Yes - that’s correct! The only difference here is that we can also apply the aggregate function with the `GROUP BY` clause to find the counts for the unique combinations which we touched upon in the previous tutorial!

Elegant, right? Well - here is the SQL statement to do this:

```sql
SELECT
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic,
  COUNT(*) AS frequency
FROM health.user_logs
GROUP BY
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic
ORDER BY frequency DESC
```
| id | log_date | measure | measure_value | systolic | diastolic | frequency
|----|---------|---------|---------|--------|----|------|
|054250c|2019-12-06|blood_glucose|401|null|null|104
|054250c|2019-12-05|blood_glucose|401|null|null|77
|d696925d|2020-05-07|blood_glucose|224|0|0|1

Notice how the frequency for some of these values is 1 - whilst some are greater than 1?

This is exactly how we know which unique combinations of the columns have duplicates!

Now there is a final piece of the puzzle which will help us extract the duplicate records only.

---
<br>

## Having Clause For Unique Duplicates
Now the final step is to use the `HAVING` clause to further trim down our output by applying a condition on the same `COUNT(*)` expression we were using for the frequency column we created in our previous query.

Since we only want the duplicate records to be returned - we would like that `COUNT(*)` value to be greater than 1.

I will also show you an extra hack here for our SQL query where we can actually use the same * as we’ve used previously to replace all those columns that we specified in the `SELECT` expressions in our query.

This is totally optional and non-standard as it’s actually more difficult to read than listing out all the columns in the order that they appear in the dataset, but it does make for slightly neater looking code so I thought I might as well show you another option!

Note that we **cannot** use the same * within the `GROUP BY` grouping elements as it will throw a syntax error.

To drill our previous knowledge - let’s go ahead and create a new temporary table called `duplicate_record_counts` in our following query.

<br>

```sql
-- Don't forget to clean up any existing temp tables!
DROP TABLE IF EXISTS unique_duplicate_records;

CREATE TEMPORARY TABLE unique_duplicate_records AS
SELECT *
FROM health.user_logs
GROUP BY
  id,
  log_date,
  measure,
  measure_value,
  systolic,
  diastolic
HAVING COUNT(*) > 1;

-- Finally let's inspect the top 10 rows of our temp table
SELECT *
FROM unique_duplicate_records
LIMIT 10;
```

> Truncated Output

| id | log_date | measure | measure_value | systolic | diastolic | 
|----|---------|---------|---------|--------|----|
|054250c69|2020-10-04|blood_glucose|170|null|null|
|054250c69|22019-12-15|blood_glucose|79|0|0|
|054250c69|2020-10-05|blood_glucose|323|null|null|

---
<br>

## Retaining Duplicate Counts
Let’s say for example - we want to know which exact records are duplicated - but also how many times they appeared. The output would look exactly like our output from the Group By Counts On All Columns section - but just without the rows where the frequency count was equal to 1.

We can use our `CTE` approach with a `WHERE` filter condition to do this - note how the `CTE` component looks exactly same as the previous query - the only difference is the following `SELECT` statement.


<br>

```sql
WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT *
FROM groupby_counts
WHERE frequency > 1
ORDER BY frequency DESC
LIMIT 10;
```

> Truncated

| id | log_date | measure | measure_value | systolic | diastolic | 
|----|---------|---------|---------|--------|----|
|054250c69|2019-12-06|blood_glucose|104|null|null|
|054250c69|2019-12-05|blood_glucose|77|0|0|
|054250c69|2019-12-04|blood_glucose|72|null|null|


---
<br>

## Ignoring Duplicate Values
By now you are probably sick of this talk about duplicates and how to deal with them - why am I now telling you that maybe we should just ignore them?

Let’s think back to the context of our dataset here.

For context, this real world messy dataset captures data taken from individuals logging their health measurements via an online portal throughout the day.

For example, multiple measurements can be taken on the same day at different times, but you may notice this information is missing as the log_date column does not show timestamp values!

Welcome to the real world of messy datasets :)

That part about multiple measurements could be critical in the approach we wish to take with these duplicates.

Sometimes what we, as data analytics professionals or SQL developers, perceive as duplicates might actually not be duplicates after all - they could just be valid data points! I hope this example drills home the main point about duplicate data points - we must always think critically about the data that we have and what it really represents in terms of actual behaviour or processes that create them!

---

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

<br>

> Exercises in non lecture sql file in same root folder!


