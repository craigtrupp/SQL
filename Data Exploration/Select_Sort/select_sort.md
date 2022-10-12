# Select & Sort Data Markdown

## Select All Columns 

In this first example we use **_*_** to inspect all the columns in a table.

This is usually the first query to run when you are not yet unfamiliar with a specific dataset.

> We usually say the words **“select star from …”** in a regular conversation about SQL tables!

#### Example Exercise:

1. Show all records from the language table from the dvd_rentals schema

```sql
SELECT * FROM dvd_rentals.language;
```
___

## Select Specific Columns

Instead of using **_*_** we can also manually specify which columns we want to return in a `SELECT` statement.

The only thing you need to be wary of is the commas used to separate each column name and getting the spelling of each column correct.

* Pro-tip: if you ever run into issues with your SQL queries in future - chances are you’ve made a typo or you are missing a comma or you have extra trailing commas in your query.

* Try to use control-f on Windows or command-f on MacOS to quickly highlight all of your commas so you can inspect them carefully.


#### Example Exercise:

1. Show only the language_id and name columns from the language table

```sql
SELECT
  language_id,
  name
FROM dvd_rentals.language;
```

___


## Limit Output Rows

We can use **LIMIT**  to restrict the output to just the first few rows from the query.

In practice, we almost always use this when we are first developing and testing initial exploratory queries, especially when we are not sure what sort of data we are dealing with.

For example, in my first ever data role we were instructed to 
> never **EVER** run `select * from some_big_sales_table` without a **limit** 

because there was over 1 trillion rows of data.

One time, a new starter joined our company and ran that query without thinking…and they instantly crashed the entire system causing a backlog in all production SQL jobs for that day - what a disaster!


#### Example Exercise:

1. Show the first 10 rows from the actor tables

```sql
SELECT *
FROM dvd_rentals.actor
LIMIT 10;
```

___

## Sorting Query Results

Ordering our results is quite a natural thing to do when trying to first explore any dataset.

We can use the **ORDER BY** clause at the end of our queries to sort the output.

> By default, the sorting will be done in ascending order and we can perform multi-level sorting by specifying more than one column.

* One more thing about NULL values also - by default PostgreSQL will put all null values last unless specified with a **NULLS FIRST** - see the appendix for more details on this specific piece!


___

## Sort By Text Column
* More detailed additional notes and scenarios in the appendix for the actual sorting order of various different types of text type data points.

#### Example Exercise:

1. What are the first 5 values in the country column from the country table by alphabetical order?

```sql
SELECT country
FROM dvd_rentals.country
ORDER BY country
LIMIT 5;
```

___

## Sort By Numeric/Date Column
* Sorting for any column with numbers, dates, timestamps is done from lowest to highest or latest to earliest for **date time** related columns.
    

#### Example Exercise:

1. What are the 5 lowest total_sales values in the sales_by_film_category table?
    + Note how we can alternatively refer to the **ORDER BY** column by it’s position (in this case it’s 1) in the final resulting output.

```sql
SELECT
  total_sales
FROM dvd_rentals.sales_by_film_category
ORDER BY 1
LIMIT 5;
```

___

## Sort By Descending
* We can also use the keyword **DESC** after the **ORDER BY** to reverse the sort order.

    + This is useful for text fields but is most common when trying to find the largest numeric value of a column or the latest date of a specific date time column.
    

#### Example Exercises:

1. What are the first 5 values in **reverse** alphabetical order in the country column from the country table?

```sql
SELECT country
FROM dvd_rentals.country
ORDER BY country DESC
LIMIT 5;
```

2. Which category had the **lowest** total_sales value according to the sales_by_film_category table? What was the total_sales value?
    + For this example, we demonstrate how you can select multiple columns and also specifically choose which column you want to use in the **ORDER BY** clause.

```sql
SELECT
  category,
  total_sales
FROM dvd_rentals.sales_by_film_category
ORDER BY total_sales
LIMIT 1;
```
3. What was the **latest** payment_date of all dvd rentals in the payment table??
    
```sql
SELECT
  payment_date
FROM dvd_rentals.payment
ORDER BY payment_date DESC
LIMIT 1;
```
___

## Sort By Multiple Columns
We can also perform a multi-level sort by specifying 2 or more columns with the **ORDER BY** clause.

> Honestly, this concept is super ***SUPER SUPER*** important so to make it really extra clear - I will use this following sample example dataset to explain further.

| ID | column_a | column_b | 
|:---|:-------|:--------|
|1|0|A|
|2|0|B|
|3|1|C|
|4|1|D|
|5|2|D|
|6|3|D|


```sql
DROP TABLE IF EXISTS sample_table;
CREATE TEMP TABLE sample_table AS
WITH raw_data (id, column_a, column_b) AS (
 VALUES
 (1, 0, 'A'),
 (2, 0, 'B'),
 (3, 1, 'C'),
 (4, 1, 'D'),
 (5, 2, 'D'),
 (6, 3, 'D')
)
SELECT * FROM raw_data;
```

> The most important thing here to note is that id column - notice how those numbers change from the straight 1 to 6 as we run the following ORDER BY clauses in the following sections.

<br>

### Both Ascending

```sql
SELECT * FROM sample_table
ORDER BY column_a, column_b
```
| ID | column_a | column_b | 
|:---|:-------|:--------|
|1|0|A|
|2|0|B|
|3|1|C|
|4|1|D|
|5|2|D|
|6|3|D|

**Note** : See how shared value in column_a (1) is ordered in **ASC** type order and using the value in column_b to order the results when column_a has the same value

<br>

### Ascending & Descending

```sql
SELECT * FROM sample_table
ORDER BY column_a DESC, column_b
```
| ID | column_a | column_b | 
|:---|:-------|:--------|
|6|3|D|
|5|2|D|
|3|1|C|
|4|1|D|
|1|0|A|
|2|0|B|

**Note** : Column_A values are ordered in **DESC** order and when a shared value _(rows w/ID 3 & 4)_ is found, the secondary **ORDER BY** column will place _row w/ID 3_ above _row w/ID 4_ as the values in column_b are then ordered in **ASC** order

<br>

### Both Descending

```sql
SELECT * FROM sample_table
ORDER BY column_a DESC, column_b DESC
```

| ID | column_a | column_b | 
|:---|:-------|:--------|
|6|3|D|
|5|2|D|
|4|1|D|
|3|1|C|
|2|0|B|
|1|0|A|

<br>

### Different Column Order
* What happens if we were to order by colum_b **DESC** first instead of column_a?

```sql
SELECT * FROM sample_table
ORDER BY column_b DESC, column_a;
```

| ID | column_a | column_b | 
|:---|:-------|:--------|
|4|1|D|
|5|2|D|
|6|3|D|
|3|1|C|
|2|0|B|
|1|0|A|

**Note** : All values starting with D in column B are grouped and then ordered by their differing values in **ASC** order from column_a

<br>

* Let's try it with column_b and column_a **DESC** now to see if it changes things 

```sql
SELECT * FROM sample_table
ORDER BY column_b, column_a DESC;
```

| ID | column_a | column_b | 
|:---|:-------|:--------|
|1|0|A|
|2|0|B|
|3|1|C|
|6|3|D|
|5|2|D|
|4|1|D|

**Note** : See how _row w/ID 6_ is now the first row for column_b shared values as it's column_a value is higher than the other two rows

<br><br>


## ORDER BY Addtional Notes 
Text fields will be sorted in alphabetical order, but be careful when some of these text fields start with numbers or non-alphabetical characters.

Try running the below example and updating some of these raw values to see if your assumptions about the ordering is true!

```sql
WITH test_data (sample_values) AS (
VALUES
(null),
('0123'),
('_123'),
(' 123'),
('(abc'),
('  abc'),
('bca')
)
SELECT * FROM test_data
ORDER BY 1;
```

|sample_values|
|:-----------|
|0123|
|123|
|_123|
|abc|
|(abc|
|bca|
|null|

<br>

> When we put the NULLS FIRST expression at the end of the ORDER BY clause we will see a different output:

```sql
WITH test_data (sample_values) AS (
VALUES
(null),
('0123'),
('_123'),
(' 123'),
('(abc'),
('  abc'),
('bca')
)
SELECT * FROM test_data
ORDER BY 1 NULLS FIRST;
```

|sample_values|
|:-----------|
|null|
|0123|
|123|
|_123|
|abc|
|(abc|
|bca|

<br>

* Does this also stay true when we use an ORDER BY DESC ?
```sql
WITH test_data (sample_values) AS (
VALUES
(null),
('0123'),
('_123'),
(' 123'),
('(abc'),
('  abc'),
('bca')
)
SELECT * FROM test_data
ORDER BY 1 DESC NULLS FIRST;
```

|sample_values|
|:-----------|
|null|
|0123|
|123|
|_123|
|abc|
|(abc|
|bca|

> ORDER BY DESC orders Null the same




