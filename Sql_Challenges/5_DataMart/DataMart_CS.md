## Data Mart
#### **Introduction**
Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

The key business question he wants you to help him answer are the following:

* What was the quantifiable impact of the changes introduced in June 2020?
* Which platform, region, segment and customer types were the most impacted by this change?
* What can we do about future introduction of similar sustainability updates to the business to minimise impact on sales?

<br>

#### **Available Data**
For this case study there is only a single table: `data_mart.weekly_sales`

The Entity Relationship Diagram is shown below with the data types made clear, please note that there is only this one table - hence why it looks a little bit lonely!

* Query for postgresql column evaluation
```sql
SELECT
    column_name,
    data_type
FROM
    information_schema.columns
WHERE
    table_name = 'weekly_sales';
```

|column|datatype|
|----|-----|
|week_date|varchar|
|region|varchar|
|platform|varchar|
|segment|varchar|
|customer_type|varchar|
|transactions|int|
|sales|int|

<br>

#### **Column Dictionary**
The columns are pretty self-explanatory based on the column names but here are some further details about the dataset:

1. Data Mart has international operations using a `multi-region` strategy
2. Data Mart has both, a **retail and online** `platform` in the form of a Shopify store front to serve their customers
3. Customer `segment` and `customer_type` data relates to personal age and demographics information that is shared with Data Mart
4. Transactions is the **count** of unique purchases made through Data Mart and sales is the actual dollar amount of purchases

Each record in the dataset is related to a specific aggregated slice of the underlying sales data rolled up into a week_date value which represents the start of the sales week.

* Example Rows
```sql
SELECT * 
FROM data_mart.weekly_sales
LIMIT 10;
```
|week_date|region|platform|segment|customer_type|transactions|sales|
|----|-----|-----|-----|-----|----|----|
|31/8/20|ASIA|Retail|C3|New|120631|3656163|
|31/8/20|ASIA|Retail|F1|New|31574|996575|
|31/8/20|USA|Retail|null|Guest|529151|16509610|
|31/8/20|EUROPE|Retail|C1|New|4517|141942|
|31/8/20|AFRICA|Retail|C2|New|58046|1758388|
|31/8/20|CANADA|Shopify|F2|Existing|1336|243878|
|31/8/20|AFRICA|Shopify|F3|Existing|2514|519502|
|31/8/20|ASIA|Shopify|F1|Existing|2158|71417|
|31/8/20|AFRICA|Shopify|F2|New|318|49557|
|31/8/20|AFRICA|Retail|C3|New|111032|3888162|

---

<br>

### Case Study Questions
The following case study questions require some data cleaning steps before we start to unpack Danny’s key business questions in more depth.

<br>

### `A : Data Cleansing Steps`
In a single query, perform the following operations and generate a new table in the `data_mart schema` named `clean_weekly_sales`:

* Convert the `week_date` to a DATE format

* Add a `week_number` as the second column for each `week_date` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

* Add a `month_number` with the calendar month for each `week_date` value as the 3rd column

* Add a `calendar_year` column as the 4th column containing either **2018, 2019 or 2020** values

* Add a new column called `age_band` after the original segment column using the following mapping on the number inside the segment value

|segment|age_band|
|----|----|
|1|Young Adults|
|2|Middle Aged|
|3 or 4|Retirees|

* Add a new demographic column using the following mapping for the first letter in the segment values:

|segment|demographic|
|----|----|
|C|Couples|
|F|Families|

* Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

* Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

<br>

#### **New Table Generation**
* So prior to getting the full table, let's see how we got there with some exploratory queries that will ultimately be compiled into our new table for the schema

<br>

##### **Date_Parts**
```sql
SELECT 
  TO_DATE(week_date, 'DD/M/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/M/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/M/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/M/YY')) AS calendar_year
FROM data_mart.weekly_sales
WHERE week_date < '20219-01-01'
ORDER BY week_date DESC
LIMIT 5;
```
|week_date|week_number|month_number|calendar_year|
|----|-----|----|-----|
|2020-01-18|3|1|2020|
|2020-01-18|3|1|2020|
|2020-01-18|3|1|2020|
|2020-01-18|3|1|2020|
|2020-01-18|3|1|2020|

* The Date string being mutated in the `TO_DATE` call takes the string **week_date** value (varchar as seen in the data columns) and a **format** to mutate from
* After setting the varchar to a date type, we can than use `DATE_PART` and a time value to extract to get the **week, month and calendar year** as requested

<br>

##### **Age_Band**
* Unique segments (We want the last digit it would appear)
```sql
SELECT 
  DISTINCT(segment) AS unique_segments
FROM data_mart.weekly_sales
```
|unique_segments|
|----|
|C3|
|C2|
|null|
|F2|
|C4|
|F1|
|F3|
|C1|

```sql
-- CTE to use a regexp_match for last digit
WITH segment_reg_ex AS (
SELECT 
  DISTINCT(segment) AS unique_segments
FROM data_mart.weekly_sales
),
regexp_matches AS (
SELECT
  unique_segments,
  regexp_matches(unique_segments, '\d{1}$') AS segment_last_digit
FROM segment_reg_ex
)
SELECT *,
  segment_last_digit[1]
FROM regexp_matches
```
|unique_segments|segment_last_digit|
|----|----|
|C3|3|
|C2|2|
|F2|2|
|C4|4|
|F1|1|
|F3|3|
|C1|1|

* It's likely a fair bit more than we need but just wanted to have a bit of fun here. You can't index the matches for the unique segments column until after being generated in the second cte above

<br>

`Last items`
* So we walso want the first value of the unique segments (C or F) as either couples or families for the demographic
    - We can just use the `LEFT/RIGHT` to perform a type substring for segment to get the values at the start and end of the string we're after 
```sql
SELECT
  LEFT(segment, 1) as left_1,
  LEFT(segment, 2) as left_2,
  RIGHT(segment, 1) AS reverse_left_1,
  segment
FROM data_mart.weekly_sales
LIMIT 5;
```
|left_1|left_2|reverse_left_1|segment|
|----|----|----|-----|
|C|C3|3|C3|
|F|F1|1|F1|
|n|nu|l|null|
|C|C1|1|C1|
|C|C2|2|C2|

* The avg_transaction just looks like a row type operation that we'll need to round.
* We'll also include the columns in the table that didn't require cleansing

So with a decent exploratory look at generating the new table for the schema, let's create!

#### **New Schema Table Creation**
```sql
DROP TABLE IF EXISTS data_mart.clean_weekly_sales;
CREATE TABLE data_mart.clean_weekly_sales AS 
SELECT
  TO_DATE(week_date, 'DD/M/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/M/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/M/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/M/YY')) AS calendar_year,
  region,
  platform,
  COALESCE(segment, 'unknown') AS segment,
  CASE
    WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment, 1) in ('3', '4') THEN 'Retirees'
    ELSE 'unknown'
  END AS age_band,
  CASE
    WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
    WHEN LEFT(segment, 1) = 'F' THEN 'Families'
    ELSE 'unknown'
  END AS demographic,
  customer_type,
  transactions,
  sales,
  ROUND(sales/transactions, 2) AS avg_transaction
FROM data_mart.weekly_sales


-- AFTER CREATION, LET'S QUERY A FEW ROWS
SELECT * FROM data_mart.clean_weekly_sales LIMIT 5;
```
-- So ... we'll put the table when we're not just on the labtop and can get a table readout a bit easier
- But it works!

<br>

--- 

