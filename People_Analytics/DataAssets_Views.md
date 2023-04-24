## Reusable Data Assets
When we are dealing with large datasets and with other team members in a work environment - there is often pressure to produce data analysis outputs faster and more efficiently, reducing the amount of new code that has to be written and also reducing the total raw amount of data computations and calculations.


<br>

### What is a `View`
Up until this point so far in the Serious SQL course - we’ve mostly focused on creating ``temporary tables` and making use of `CTEs` to help us structure our queries and generate interim inputs.

These aren’t the only tools we have in our SQL reproducibility toolkit to generate interim datasets that we can refer to later on in our SQL scripts and data analysis - we also have the humble `VIEW` and the versatile `MATERIALIZED VIEW` that we can use to spice up our SQL scripts to improve our efficiency and productivity.

Whilst our temporary tables and CTEs actually run the queries we specify and materialises the records inside our new temporary tables when we run our CREATE TEMP TABLE step - a `database view` does not actually run the queries but instead - 
* it saves the SQL query as a reference which only gets ran when the view is used in a downstream query.

So if we already have temporary tables and CTEs - why do we need something else?

---

<br>

### `Date Column Updates`
In our previous tutorial - we’ve identified a few tables where we will need to take action and make some changes to the date columns.

The following tables and their respective columns are listed below to adjust the date forward by 18 years except for the cases when any of the date columns has the arbitrary end date 9999-01-01.

To effectively handle these two date cases - we must avoid updating records where this value is present for certain columns, something we will demonstrate once we start diving into our SQL scripts to do this!

### `Target Tables`
We need to update the employee.employees table for both the birth_date and hire_date columns.

The following tables require the `from_date` and `to_date` to be updated:

* employees.department_employee
* employees.department_manager
* employees.salary
* employees.title

Let’s now carefully proceed to update these tables - but of course, there is a catch!

<br>

## `Updating Tables`
So let’s say our client, HR Analytica very specifically DO NOT want their source data to be modified for any reason.

This is actually quite common for many companies as they would like to keep data integrity of their “source” data as clear and raw as possible. This sometimes does mean that mistakes that happen are left as they are!

So if we are given this constraint: we must not make any changes at all to the tables within the employee schema - we need to think laterally to continue with our case study.

There are a few options we could take at this point - ranging from simple through to more involved, but potentially more scalable, reproducible and also efficient!

#### `Option 1 - Temporary Tables`
We could stick with what we know and simply create a few temporary tables with the updated datasets and make the fixes explicitly through our SQL scripts.

This is totally a valid option and would likely do the trick - but let’s throw an additional spanner into the works to mess things up further…

Let’s say that we do not want to always re-create our temporary tables everytime we want to simply query our updated datasets. As with many things in life - there is a cost involved!

* Everytime we run our `CREATE TEMP TABL`E steps from our SQL scripts - there is some computation going on in the background.

So if we wanted to create a few temp table versions of our tables by appending a temp_ in front of each table reference like so:

* `Note`: we also make a copy of the employees.department table just for completeness and uniformity in our approach!

```sql
-- employee
DROP TABLE IF EXISTS temp_employee;
CREATE TABLE temp_employee AS
SELECT * FROM employees.employee;

-- temp department employee
DROP TABLE IF EXISTS temp_department;
CREATE TEMP TABLE temp_department AS
SELECT * FROM employees.department;

-- temp department employee
DROP TABLE IF EXISTS temp_department_employee;
CREATE TEMP TABLE temp_department_employee AS
SELECT * FROM employees.department_employee;

-- department manager
DROP TABLE IF EXISTS temp_department_manager;
CREATE TEMP TABLE temp_department_manager AS
SELECT * FROM employees.department_manager;

-- salary
DROP TABLE IF EXISTS temp_salary;
CREATE TEMP TABLE temp_salary AS
SELECT * FROM employees.salary;

-- title
DROP TABLE IF EXISTS temp_title;
CREATE TEMP TABLE temp_title AS
SELECT * FROM employees.title;
```
* Now we’ll need to actually go in and update some of our table values - we’ve seen this in our previous marketing analytics case study, the only additional piece below is the extra WHERE filters to only update records where there is no 9999-01-01 values for the `to_date` column.

* Note how there are multiple `UPDATE` steps for each table - one statement for each column that needs to be changed. 
* We also need to use the + `INTERVAL '18 YEARS'` syntax to update our **date** values.

```sql
-- update temp_employee
-- ??? Why don't we need to check the date = '9999-01-01' for these columns
UPDATE temp_employee
SET hire_date = hire_date + INTERVAL '18 YEARS';

UPDATE temp_employee
SET birth_date = birth_date + INTERVAL '18 YEARS';

-- update temp_department_employee
-- ??? Why don't we need to check the date = '9999-01-01' for this column
UPDATE temp_department_employee SET
from_date = from_date + INTERVAL '18 YEARS';

UPDATE temp_department_employee
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update temp_department_manager
UPDATE temp_department_manager
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE temp_department_manager
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update temp_salary
UPDATE temp_salary
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE temp_salary
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update temp_title
UPDATE temp_title
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE temp_title
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';
```
Take special notice of how many rows were updated during this step and how long it took to run each of the above update statements - especially the temp_salary table.

This example is still relatively small enough that it won’t really make a huge dent in productivity as the employees.salary table only has 2,844,047 rows - but can you imagine how long this sort of update step would take if you had 100’s of millions, billions or trillions of rows of data.

Then to add to this time cost - imagine we had to run these `CREATE TEMPORARY TABLE` steps every single time we wanted to just analyse our datasets with the updated datasets. 
* It’s just not really that efficient is it?!

<br>

### `Option 2 - New Schema`
So now let’s say that we’re going to pass on the temporary table method - and luckily we have the ability to create an entirely new schema in our database!

We can now run commands very similar to our` CREATE TEMP TABLE `statements previously - but this time we can remove the TEMP part and write the data directly into our newly created `adjusted_employees` schema.

Note how we can also drop the schema if it exists just like our tables - we just need to add the `CASCADE `option to the end of it so it will look for all of the different tables and dependent views inside the schema and help us drop them too - needless to say - don’t ever try this on a production schema at work unless you want to get hurt by your local DBA!

```sql
DROP SCHEMA IF EXISTS adjusted_employees CASCADE;
CREATE SCHEMA adjusted_employees;

-- employee - chain newly created schema (and all other create calls)
DROP TABLE IF EXISTS adjusted_employees.employee;
CREATE TABLE adjusted_employees.employee AS
SELECT * FROM employees.employee;

-- department employee
DROP TABLE IF EXISTS adjusted_employees.department;
CREATE TABLE adjusted_employees.department AS
SELECT * FROM employees.department;

-- department employee
DROP TABLE IF EXISTS adjusted_employees.department_employee;
CREATE TABLE adjusted_employees.department_employee AS
SELECT * FROM employees.department_employee;

-- department manager
DROP TABLE IF EXISTS adjusted_employees.department_manager;
CREATE TABLE adjusted_employees.department_manager AS
SELECT * FROM employees.department_manager;

-- salary
DROP TABLE IF EXISTS adjusted_employees.salary;
CREATE TABLE adjusted_employees.salary AS
SELECT * FROM employees.salary;

-- title
DROP TABLE IF EXISTS adjusted_employees.title;
CREATE TABLE adjusted_employees.title AS
SELECT * FROM employees.title;

-- update employee - set correct date using INTERVAL
UPDATE adjusted_employees.employee
SET hire_date = hire_date + INTERVAL '18 YEARS';

UPDATE adjusted_employees.employee
SET birth_date = birth_date + INTERVAL '18 YEARS';

-- update adjusted_employees.department_employee
UPDATE adjusted_employees.department_employee SET
from_date = from_date + INTERVAL '18 YEARS';

-- Update all to_date unless fields has "future"/undefined date value
UPDATE adjusted_employees.department_employee
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update department_manager
UPDATE adjusted_employees.department_manager
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE adjusted_employees.department_manager
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update salary
UPDATE adjusted_employees.salary
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE adjusted_employees.salary
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- update title
UPDATE adjusted_employees.title
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE adjusted_employees.title
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';
```
All of the steps are exactly the same as before - just now the schema reference is changed and all tables will be **permanent table**s instead of temporary tables - this helps us achieve a few things:

1. We no longer need to re-run the temporary tables every time we fire up a new SQL session and
Everyone else who has access to our newly created adjusted_employees schema can query our new tables
    * This is going to save us huge amounts of time and resources when the datasets blow up to billions of rows - but there is still one glaring issue…

#### `New Data Adds - Wrong Schema`
What happens if we get new employees who join the company and their records enter into the database - or an employee gets a raise and subsequently new records are inserted into the original source employees.salary table?
* New data row considerations should new data try to be added to legacy "employees" schema

One simple solution is to drop our existing tables we created in the adjusted_employees schema on a regular basis and simply re-run our table creation statements from above - but I’m sure you can already see the issue with this approach already!

The cost would be enormous if the tables were substantially large!

There must be another way? Well…there are at least 3 more ways we can deal with this problem - let’s discuss the 1st and most inefficient way first before we make our way onto the main topic of this tutorial - views!

<br>

### `Delta Updates`
So when we think of reusable data assets and updating for new data points that might come in naturally over the course of a day or month - there is a concept known as “the delta” or the change in a dataset.

Simply put - instead of dropping the table and rerunning the entire table creation step each time new fresh data comes in, we can look for the records which changed in the source data - and only update the rows or records in our downstream derived tables.

Let’s just take a very simple example of our very first employee id = 10001 Georgi Facello - if we inspect Georgi’s salary records - here’s what the current status of the records would look like:

```sql
SELECT *
FROM adjusted_employees.salary
WHERE employee_id = 10001
ORDER BY FROM_DATE DESC
LIMIT 5;
```
|employee_id|amount|from_date|to_date|
|-----|----|----|----|
|10001|88958|2020-06-22|9999-01-01|
|10001|85097|2019-06-22|2020-06-22|
|10001|85112|2018-06-22|2019-06-22|
|10001|84917|2017-06-23|2018-06-22|
|10001|81097|2016-06-23|2017-06-23|

Now let’s say that on the 1st of January 2021 - Georgo was given a raise to $95,000, the dataset should be updated to the following - keep a close eye on the first 2 rows!

|employee_id|amount|from_date|to_date|
|-----|----|----|----|
|10001|95000|2021-01-01|9999-01-01|
|10001|88958|2020-06-22|2021-01-01|
|10001|85097|2019-06-22|2020-06-22|
|10001|85112|2018-06-22|2019-06-22|
|10001|84917|2017-06-23|2018-06-22|

* Previous salary value as the `to_date` value updated (second row)
* Newest row entry is the result of a `insert`

#### `SCD`
This is an example of what we would call a `“Slowly Changing Dimension”` or an **SCD** table for short in data engineering language - although it is slightly outside of our scope for this Serious SQL course - think of this as a brief primer on data engineering design!

When we look at each record in this salary table - we notice that there are from_date and to_date columns - these signify the periods of time when specific records are valid - hence this concept of “slowly changing” comes from.

Although our current datasets are just pure snapshots of a specific point in time - when we deal with real live datasets that are continuously updated with new data daily, hourly or even real-time - knowledge of these engineering designs are critical for effective and efficient SQL data processing.

When new data comes in - for example like our new $95,000 raise for Georgi - these SCD tables will often have what we call `“UPSERT”` statements - a combination of UPDATE and INSERT data manipulation statements.

In our example - we can see the UPDATE statement used for the second row where the to_date is being set to the latest date where the $88,958 salary is valid until, and an INSERT statement is used to add that first row with the $95,000 value and a new from_date for the date of the salary increase and to_date set to 9999-01-01.

So we can obviously see if there are any new records being inserted into our existing tables - however there is a catch (again…) - is it really efficient and scalable to do this with many many many new records? (spoiler alert - probably not!)

<br>

### `Updating Downstream Tables`
Warning: this section is slightly heavier on data engineering so just keep this in mind as you’re reading!

So say for example - we notice some changes in our source datasets where new data is arriving, what are the ways we can check that there are new values coming in? Here are some suggestions:

Check the GROUP BY counts by from_date to see if any data has been input for the latest date - this is easy enough
Keep a track of which records are being updated in all the tables so we can update our downstream derived tables - this is not so easy…
Entire projects can be created to develop complex extract-transform-load ETL pipelines to perform this same function - so keep in mind that these complex systems do exist - but it is often not where we want to spend our time focusing when we are starting off in the data world.

Depending on how complex the data processing systems are - we could actually implement these steps into our pipeline and use other SQL tools such as user defined functions (UDFs) and event-based processing (triggers) to run all of these steps automagically so our datasets in the `adjusted_employees` schema that we created can be updated accordingly - however this leads to an excessive amount of complex SQL development…

Important Note: many ETL processes in large organisations actually follow this SCD and upsert pattern as it is inefficient to perform some of the upcoming view based methods on seriously seriously huge datasets as it’s just not feasible to keep huge copies of datasets in production systems - so please keep this in mind!

Although this is technically not a data engineering focused course, these are some of the more complex data design situations or scenarios you might encounter as you start working on more advanced data projects in general!

Here is a light pseudo-code for what one such process might look like for this employees example where a new day’s worth of data is loaded into the system:

#### For the `UPDATE` records:

1. For each table with to_date records - check which ones have a to_date set to today’s date

2. Identify the relevant from_date records which need to have the update applied - usually most SCD style tables are optimised or partitioned (stored) on these date columns to reduce the amount of data required to be scanned during update steps

3. Update relevant records in the downstream tables via some type of join condition (usually inner join) on the subset of relevant partitions
Done!

#### For the `INSERT` records:

1. Check the count of records added for each table with the from_date equal to the current date of data processing
2. Insert these new records directly into the downstream tables

Done!

More often than not - the update steps are the most annoying and difficult parts. Some data engineering design patterns may also remove the need to UPDATE records and will only operate with an INSERT only paradigm. This helps to keep the data reproducible as well as immutable and idempotent - unchangeable and able to be rebuilt from scratch respectively - these are very common terms used in data engineering to design robust and high integrity data assets!

OK - so because these steps are a bit too involved for what we’re after - surely there is a simpler method to obtain a similar result without expending all this mental energy just to add some new data records?

This is exactly where our **database `views`** come into the picture!

---

<br>

## Database Views
As we’ve mentioned before - a database `VIEW` is essentially a reference which stores a query that can be ran and accessed just like any table - however the catch is that the data is not preprocessed and saved anywhere until the view is referenced in a query.

I can see the wheels turning in your mind as you figure out why this is a good solution for our updating data situation!

If we used views for our datasets instead of having permanent tables - we can effectively remove the need to create all those additional complex systems to check for changes and update all the downstream data sources accurately!

When we access our created views - the raw data will be requested only at that point in time - meaning that all of the newly updated and inserted records in our original source data will be available when we `SELECT FROM our view`. This is a very common approach for datasets which are constantly updated with new data - imagine a daily sales table which adds new transactions for example.

An additional benefit of using a VIEW instead of temporary tables is that the index information is retained from the base tables referenced in the view query. This sometimes leading to faster performance than storing datasets as permanent tables, and especially if you do not specify indexes for the new permanent tables (more on this later in the optimisation part of the Serious SQL course!)

#### `View Implementation`
So let’s dive into the SQL implementation of this view approach - we can store these views in another new schema called `v_employees` - this is actually quite common in terms of naming convention in large companies as many schemas may contain lots and lots of views only which will be reading off the source data which exists in a totally separate schema - in our case the v_ prepended to the employees helps us signal that this schema is full of views only!

Additionally - it’s really common to have entire datasets mapped across as a view to avoid hitting the raw source tables - for example: sometimes an end user analyst might only have access to the views that are created and they will not be able to access the raw source tables from a different schema due to user permissions in case they accidentally decide to update or delete some rows…

Note how the implementation of the views do not need the UPDATE steps we used previously - but instead we can use a simple CASE WHEN to setup an if-else style approach to updating our date columns below:

```sql
-- Recall Cascade from Above
DROP SCHEMA IF EXISTS v_employees CASCADE;
CREATE SCHEMA v_employees;

-- department
DROP VIEW IF EXISTS v_employee.department;
CREATE VIEW v_employees.department AS
SELECT * FROM employees.department;

-- department employee - CASE for interval time setting
DROP VIEW IF EXISTS v_employees.department_employee;
CREATE VIEW v_employees.department_employee AS
SELECT
  employee_id,
  department_id,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.department_employee;

-- department manager
DROP VIEW IF EXISTS v_employees.department_manager;
CREATE VIEW v_employees.department_manager AS
SELECT
  employee_id,
  department_id,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.department_manager;

-- employee
DROP VIEW IF EXISTS v_employees.employee;
CREATE VIEW v_employees.employee AS
SELECT
  id,
  birth_date + interval '18 years' AS birth_date,
  first_name,
  last_name,
  gender,
  hire_date + interval '18 years' AS hire_date
FROM employees.employee;

-- salary
DROP VIEW IF EXISTS v_employees.salary;
CREATE VIEW v_employees.salary AS
SELECT
  employee_id,
  amount,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.salary;

-- title
DROP VIEW IF EXISTS v_employees.title;
CREATE VIEW v_employees.title AS
SELECT
  employee_id,
  title,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.title;
```

We can now select from any of the views in the `v_employees` schema just like we were hitting the raw tables directly in the original employees schema - let’s take a look again at Georgi’s salary!

```sql
SELECT *
FROM v_employees.salary
WHERE employee_id = 10001
ORDER BY FROM_DATE DESC
LIMIT 5;
```
|employee_id|amount|from_date|to_date|
|---|-----|----|----|
|10001|88958|2020-06-22|9999-01-01|
|10001|85097|2019-06-22|2020-06-22|
|10001|85112|2018-06-22|2019-06-22|
|10001|84917|2017-06-23|2018-06-22|
|10001|81097|2016-06-23|2017-06-23|

So we’ve covered how we can use views to simplify our queries and also obtain the most update version of the original source data by using database views to store our queries. Have you figured out what the catch is yet?

Everytime we hit a reference which is actually a view - we have to run the query. This has some cost implications - especially when some of these queries are massive (which they usually are!)

So there is one final thing we can look into to help solve our new issue - enter the materialized view!

### `Materialized Views`
We can think of a materialized view as a combination of a permanent table and a regular view - many SQL developers say it’s the best of both worlds as you get the flexibility of a view with the efficiency of persisted (or materialized) data!

The SQL implementation of a materialized view is literally by using `CREATE MATERIALIZED VIEW` instead of CREATE VIEW - simple right!

* The key difference is that materialized views are populated with data - in the same way that a CREATE TABLE or CREATE TEMP TABLE statement would also populate the table reference with data once they are ran.

There is also a catch with materialized views too - it seems like every single thing we learn in SQL always has edge cases or things to catch you out if you’re not careful!

When we run the CREATE MATERIALIZED VIEW to populate the new view reference with data - it can only use the existing data that is present in the source tables used in the view query - just like the CREATE TABLE steps.

If there is new data that comes in later - it will not be present in the materialized view! But luckily this is where the materialized view seriously shines - we just need to run `REFRESH MATERIALIZED VIEW`

We will demonstrate this with just our salary dataset and Georgi’s records in our test example - firstly let’s create a physical permanent table called georgi_salary since we want this to run quickly and don’t want to mess with our original source data (just like in a real life situation!)

Note that this cannot be a temporary table as materialized views can only be ran on permanent tables - it can’t even reference any views also which is noteworthy when you try using this in the workplace - make sure that all of the tables referenced in the view query are actual source tables and not views!

```sql
-- create a permanent table with Georgi's salary information
-- materialized views can only be ran on perm tables!
-- note that the CASCADE is needed here if you run some of the below steps!
DROP TABLE IF EXISTS georgi_salary CASCADE;
CREATE TABLE georgi_salary AS
SELECT *
FROM employees.salary
WHERE employee_id = 10001;
```
* After we create this table - we can now specify our materialized view:
    * Recall any materialized view requires a source/base table, not a view!


```sql
-- salary
DROP MATERIALIZED VIEW IF EXISTS v_employees.salary_georgi;
CREATE MATERIALIZED VIEW v_employees.salary_georgi AS
SELECT
  employee_id,
  amount,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM georgi_salary;
```

Now let’s say Georgi gets the raise on the 1st of January 2003 (which is actually 2021 - remember the intern’s mistakes?) and the source dataset is updated and inserted into with Georgi’s new records:

```sql
-- UPSERT georgi's salary
UPDATE georgi_salary
SET to_date = '2003-01-01'
WHERE to_date = '9999-01-01';

INSERT INTO georgi_salary(employee_id, amount, from_date, to_date)
VALUES (10001, 95000, '2003-01-01', '9999-01-01');
```

* If we were to query the materialized view - these changes will not be present.

```sql
SELECT *
FROM v_employees.salary_georgi
WHERE employee_id = 10001
ORDER BY FROM_DATE DESC
LIMIT 5;
```
|employee_id|amount|from_date|to_date|
|-----|-----|------|-----|
|10001|88958|2020-06-22 00:00:00|9999-01-01 00:00:00|
|10001|85097|2019-06-22 00:00:00|2020-06-22 00:00:00|
|10001|85112|2018-06-22 00:00:00|2019-06-22 00:00:00|
|10001|84917|2017-06-23 00:00:00|2018-06-22 00:00:00|
|10001|81097|2016-06-23 00:00:00|2017-06-23 00:00:00|

* So we will need to `refresh the materialized view` as below before trying again - the following query won’t generate any output!

```sql
REFRESH MATERIALIZED VIEW v_employees.salary_georgi;
-- Look for most recent salary date data
SELECT *
FROM v_employees.salary_georgi
WHERE employee_id = 10001
ORDER BY FROM_DATE DESC
LIMIT 5;
```
|employee_id|amount|from_date|to_date|
|-----|-----|------|-----|
|10001|95000|2021-01-01|9999-01-01|
|10001|88958|2020-06-22 00:00:00|2021-01-01 00:00:00|
|10001|85097|2019-06-22 00:00:00|2020-06-22 00:00:00|
|10001|85112|2018-06-22 00:00:00|2019-06-22 00:00:00|
|10001|84917|2017-06-23 00:00:00|2018-06-22 00:00:00|

<br>


Let’s now implement the entire workflow for our datasets - we’ll create a separate schema for these materialized views mv_employees:

```sql
DROP SCHEMA IF EXISTS mv_employees CASCADE;
CREATE SCHEMA mv_employees;

-- department
DROP MATERIALIZED VIEW IF EXISTS v_employee.department;
CREATE MATERIALIZED VIEW mv_employees.department AS
SELECT * FROM employees.department;

-- department employee
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department_employee;
CREATE MATERIALIZED VIEW mv_employees.department_employee AS
SELECT
  employee_id,
  department_id,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.department_employee;

-- department manager
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department_manager;
CREATE MATERIALIZED VIEW mv_employees.department_manager AS
SELECT
  employee_id,
  department_id,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.department_manager;

-- employee
DROP MATERIALIZED VIEW IF EXISTS mv_employees.employee;
CREATE MATERIALIZED VIEW mv_employees.employee AS
SELECT
  id,
  birth_date + interval '18 years' AS birth_date,
  first_name,
  last_name,
  gender,
  hire_date + interval '18 years' AS hire_date
FROM employees.employee;

-- salary
DROP MATERIALIZED VIEW IF EXISTS mv_employees.salary;
CREATE MATERIALIZED VIEW mv_employees.salary AS
SELECT
  employee_id,
  amount,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.salary;

-- title
DROP MATERIALIZED VIEW IF EXISTS mv_employees.title;
CREATE MATERIALIZED VIEW mv_employees.title AS
SELECT
  employee_id,
  title,
  from_date + interval '18 years' AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN to_date + interval '18 years'
    ELSE to_date
    END AS to_date
FROM employees.title;
```

<br>

Let’s now take a look at the differences between each of our 3 separate methods in terms of how long it takes to access our data - for the next section we will start touching on the `EXPLAIN` and `EXPLAIN ANALYZE` statements, the entrypoint to SQL optimization!

---

<br>

### **Comparing Methods**
So let’s only inspect the different salary tables that we have created since it is the largest dataset that we have at our disposal for this example.

Up until now we have been running mostly basic SELECT statements to create tables and views - now we will start to build our knowledge on the `EXPLAIN` plan - something which we will need to get acquainted with thoroughly to take our SQL skills from the beginner/intermediate level to advanced levels!


#### `Explain Plan`
If we put `EXPLAIN` in front of any query that we’d like to run - it will actually profile the execution plan of the SQL query and return us information about how the SQL optimizer will run the query. Naturally this is how we make important decisions to help speed up our queries to get around slow running or bottlenecked SQL code!

To demonstrate this - let’s try running the EXPLAIN on a basic query from the original source employees.salary table:

```sql
EXPLAIN SELECT * FROM employees.salary;
```
|QUERY PLAN|
|----|
|Seq Scan on salary (cost=0.00..46555.47 rows=2844047 width=24)|

This returns us only a single row in this example since we are just requesting a basic select from the employees.salary table. More complex queries will have multiple steps, which we will soon encounter! For now we will now break down this single query plan step going from left to right:

This first part of the query plan tells us what sort of operation is being performed and which table is being used.

In this example - we are performing a `sequential` scan on the salary table, meaning that we will sequentially look at the records in the salary table from the first row to the last row in order (sequence)


* Cost = (lots of numbers!)

The next section provides us information about the estimated `“cost”` for this step of the query plan - note that the first 2 numbers related to the cost are arbitrary units of time (they are not seconds!) which are generated by the underlying SQL planner 
- in short, large numbers = bad, small numbers = good!

The first number provided in this part of the plan: 0.00 refers to the initial estimated “start-up” cost required before any outputs are generated - note that this is usually 0.00 unless there is some explicit sorting through an ORDER BY clause somewhere in the SQL query for a specific step.

- The next number `46555.47` is the estimated total cost of this specific operation (also called step or plan-node) in the query plan.

- The next output `rows=2844047` is the estimated number of rows that will show up in the output for this plan node.

- And finally the `width=24` relates to the estimated average width of all the rows in the output specified in bytes. 
    * A rough rule of thumb is - each individual character is roughly 1 byte but can vary depending on the data types.

#### `Check Data Types`
Let’s just confirm this is the case when we look at our table’s data types - do you remember how to check the data types again? This time we also include the table_schema column to specify the employees schema properly since we have multiple tables in different schemas with the name salary:

```sql
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'employees'
    AND table_name = 'salary';
```
|table_schema|table_name|column_name|data_type|
|----|-----|-----|-----|
|employees|salary|employee_id|bigint|
|employees|salary|amount|bigint|
|employees|salary|from_date|date|
|employees|salary|to_date|date|

You can find the byte size of each data type via the PostgreSQL documentation but to save you from searching yourself - `bigint` data types are **8 bytes** each and `date` data types are **4 bytes** each which means we will indeed have **24 bytes** as our average size of each `row`!
* 2 date (8 * 2) = 16 & 2 bigint (4 * 2) = 8 == 16+8 == 24

<br>

So this is all good - however, what if we wanted to know how long the query actually took to run and we also don’t want the estimates - but we wanted the actual counts of data?

Enter the `EXPLAIN ANALYZE`

#### `EXPLAIN ANALYZE`
We can add an extra ANALYZE keyword to our SQL query to actually run the queries and return not just the query plan but we can also generate some runtime statistics about our query.

The only thing to be wary of the EXPLAIN ANALYZE is that it will actually run your query - so avoid using the EXPLAIN ANALYZE with table creation steps - instead just use the actual SQL query that is inside the CREATE TABLE step for the EXPLAIN ANALYZE.

```SQL
EXPLAIN ANALYZE SELECT * FROM employees.salary;
```
|QUERY PLAN|
|----|
|Seq Scan on salary (cost=0.00..46555.47 rows=2844047 width=24) (actual time=0.017..19524.776 rows=2844047 loops=1)|
|Planning Time: 0.121 ms|
|Execution Time: 38507.179 ms|

Breaking this down - we can already see the same EXPLAIN outputs in the first row, but now we also have the actual times in the following paranthesis as well as 2 additional rows with the Planning time and actual execution time in milliseconds - you can divide the value by 1,000 to get the execution time in seconds.

The order of the numbers inside the additional output for the EXPLAIN ANALYZE is exactly the same as the regular EXPLAIN query plan - however note how there is a loops=1 instead of the width=24

In this trivial example - this particular plan node is only ran a single time to generate the output because there is only need for a single sequential scan to generate the outputs for the query. In more complex queries where indexes, nested joins and other recursive components are used - the loops number can be more than 1. This is not covered in this specific tutorial but there is a real wealth of information in the PostgreSQL documentation for this topic!

Now let’s use these 2 new tools to compare our various methodologies used to apply the data manipulation steps for our case study.

<br>

### `Select Comparison`
Let’s just inspect the EXPLAIN ANALYZE outputs for each version of the salary tables to see if there are actual differences in the execution times between the different options:

- Baseline: Original table
```sql
EXPLAIN ANALYZE SELECT * FROM employees.salary;
```
- Adjusted permanent tables:
```sql
EXPLAIN ANALYZE SELECT * FROM adjusted_employees.salary;
```
- Basic View
```sql
EXPLAIN ANALYZE SELECT * FROM v_employees.salary;
```
- Materialized View
```sql
EXPLAIN ANALYZE SELECT * FROM mv_employees.salary;
```

### `Where Filter Comparison`
Let’s say that we want to perform the same comparisons but this time we will apply a filter to extract only Georgi’s data:

- Baseline: Original table
```sql
EXPLAIN ANALYZE SELECT * FROM employees.salary
WHERE employee_id = 10001;
```
- Adjusted permanent tables
```sql
EXPLAIN ANALYZE SELECT * FROM adjusted_employees.salary
WHERE employee_id = 10001;
```
- Basic View
```sql
EXPLAIN ANALYZE SELECT * FROM v_employees.salary
WHERE employee_id = 10001;
```
- Materialized View
```sql
EXPLAIN ANALYZE SELECT * FROM mv_employees.salary
WHERE employee_id = 10001;
```

<br>

### Filter Summary Results
|Method Type|Execution Time|Operation Type|
|-----|----|----|
|1. Original Source Data|0.498 ms|Index Scan|
|2. Adjusted Permanent Tables|105.985 ms|Parallel Sequential Scan|
|3. Basic View|0.461 ms|Index Scan|
|4. Materialized View|83.200 ms|Parallel Sequential Scan|

We can see that the performance on the original baseline dataset and option 2 using a basic view are much much faster than the other 2 options.

We have yet to touch deeper on the concept of table indexes - but you can think of this section as a brief primer before we tackle raw SQL optimisation in a future tutorial!

In a nutshell - an index is a data structure that contains information about the dataset to allow for faster scanning. A good analogy is like the table of contents of a document or the glossary of a large book. Both the table of contents and the glossary can help the reader quickly move to the part of the document or book which is related to their interests!

When we analyse the `EXPLAIN ANALYZE` outputs we can see an operation called an **Index Scan** being performed as the initial plan node for these query plans as opposed to the **Parallel Sequential Scan** for the other 2 options - based off the actual execution times, we can also see that the `Index Scan` is indeed much more performant than the `sequential scan` operations in this instance.

This leads us to a very profound conclusion about permanent tables, views and materialized views!

Views can make use of the underlying indexes present in the source data table references in the view SQL query - however both tables and materialized views do not have indexes present!

What happens when we create an index? Does this change anything for our permanent tables and materialized view options?

<br>

### **With Table Indexes**
We can simply create indexes on our table and materialized view as shown:

```sql
CREATE INDEX ON adjusted_employees.salary (employee_id);
CREATE INDEX ON mv_employees.salary (employee_id);
```
Now let’s run the same EXPLAIN ANALYZE step on these two references now to see if our indexes made any difference to execution times:

- Option 1: Adjusted permanent tables
```sql
EXPLAIN ANALYZE SELECT * FROM adjusted_employees.salary
WHERE employee_id = 10001;
```

|QUERY PLAN|
|-----|
|Index Scan using salary_employee_id_idx on salary (cost=0.43..27.97 rows=18 width=24) (actual time=0.029..0.193 rows=17 loops=1)|
|Index Cond: (employee_id = 10001)|
|Planning Time: 0.264 ms|
|Execution Time: 0.384 ms|

- Materialized View
```sql
EXPLAIN ANALYZE SELECT * FROM mv_employees.salary
WHERE employee_id = 10001;
```

|QUERY PLAN|
|-----|
|Index Scan using salary_employee_id_idx on salary (cost=0.43..8.62 rows=11 width=32) (actual time=0.029..0.210 rows=17 loops=1)|
|Index Cond: (employee_id = 10001)|
|Planning Time: 0.351 ms|
|Execution Time: 0.453 ms|

Now we can see the expected speedups and `Index Scan` action we would expect from having an index present!

What happens if permanent table was updated or if the materialized view was refreshed? What would happen to our indexes that we just created?

<br>

### **What Happens To The Index**
#### `Table Recreate`
Let’s just try recreating our adjusted_employees.salary table to see what happens to our EXPLAIN ANALYZE output
```sql
DROP TABLE IF EXISTS adjusted_employees.salary;
CREATE TABLE adjusted_employees.salary AS
SELECT * FROM employees.salary;

-- update salary
UPDATE adjusted_employees.salary
SET from_date = from_date + INTERVAL '18 YEARS';

UPDATE adjusted_employees.salary
SET to_date = to_date + INTERVAL '18 YEARS'
WHERE to_date <> '9999-01-01';

-- analyze query
EXPLAIN ANALYZE SELECT * FROM adjusted_employees.salary
WHERE employee_id = 10001;
```
|QUERY PLAN|
|----|
|Gather (cost=1000.00..101150.18 rows=41461 width=24) (actual time=40.277..245.801 rows=17 loops=1)|
|Workers Planned: 2|
|Workers Launched: 2|
|-> Parallel Seq Scan on salary (cost=0.00..96004.08 rows=17275 width=24) (actual time=81.568..213.689 rows=6 loops=3)|
|Filter: (employee_id = 10001)|
|Rows Removed by Filter: 948010|
|Planning Time: 0.038 ms|

* Whoops - it looks like we’ve lost our index!

#### `Refresh Materialized View`
```sql
REFRESH MATERIALIZED VIEW mv_employees.salary;

EXPLAIN ANALYZE SELECT * FROM mv_employees.salary
WHERE employee_id = 10001;
```
|QUERY PLAN|
|----|
|Index Scan using salary_employee_id_idx on salary (cost=0.43..8.62 rows=11 width=32) (actual time=0.047..0.267 rows=17 loops=1)|
|Index Cond: (employee_id = 10001)|
|Planning Time: 0.178 ms|
|Execution Time: 0.476 ms|

Great - our index was retained! So it seems like our materialized view might be one of the best candidate solutions since we only ever need to specify our indexes once and the system will just know exactly how to update the index from scratch everytime the view is refreshed and the table is regenerated!

---

<br>

### **Summary**
So after analysing our different options for creating reproducible data assets - which one should we go with for our specific case study example?

The right answer is - it depends!

#### **Option 1 - Perm Tables**
For our first option of creating new permanent tables - we saw that creating adjusted permanent tables is not so ideal when there is new data coming in on a regular basis.

We would need to perform one of the following to regularly maintain these datasets:
- Drop the previous created table and replace it with a new table when new data is updated or
- Design a complex update and insert strategy whenever there are changes in the upstream source data
- We would also need to manually recreate our indexes to replicate the underlying source data table indexes if we were to create these tables ourselves.

Indexes are relatively cheap to create and maintain - but they still incur both an upfront cost and need to be regenerated everytime the table is recreated as indexes will be dropped with the permanent tables.

<br>

#### **Option 2 - Views**
Our next option was to use a `view`, retaining all the underlying index information from our source data references and also giving us access to any updates in the upstream data too - however there was the issue of excessive computation.

Since each time a view is referenced in a downstream query - it will be recalculated only when the query is ran, leading to potentially lots and lots of queries being ran if the views are frequently referred to by a large team of data analysts for example!

For views which are not quite so popular - we could stop here and call it a day as the all-important index information is kept and we are also able to access latest changes to the data, however we have one more option!

<br>

#### **Option 3 - Materialized Views**
For views which might be accessed multiple times frequently - it makes a lot of sense to create a materialized view as there is only a single `REFRESH MATERIALIZED VIEW` statement to pull in the new data if there are any changes in the upstream source data.

Additionally - we can create indexes on materialized views which will also get updated whenever we refresh the materialized view. In fact - these indexes are recreated from scratch each time the view is refreshed without any further intervention - it is like a fixed recipe for each materialized view that we just need to set and forget!

As long as we are happy to refresh our materialized views as new data comes in - and we are happy to take the cost of creating indexes once, this makes the perfect solution for our use case!

Additional note: there are actually ways to generate triggers to only update and refresh parts of the materialized view instead of replacing the entire table - you can read more about it this blog post I found here - just be aware that this is definitely in the realm of the DBA or the data engineer so don’t worry if it’s a bit too complex to consume right now!

For our next tutorial about historic and snapshot analysis - we will refer to our newly created mv_employees schema!