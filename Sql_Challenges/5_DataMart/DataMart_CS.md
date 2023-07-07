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

* `Example Rows` : Uncleaned Provided Weekly_Sales Table
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
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year
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
|2020-08-31|3|1|2020|

* The Date string being mutated in the `TO_DATE` call takes the string **week_date** value (varchar as seen in the data columns) and a **format** to mutate from
* After setting the varchar to a date type, we can than use `DATE_PART` and a time value to extract to get the **week, month and calendar year** as requested
* **Note** : value for `TO_DATE` needed to be changed in order to get recognizable date value back
    - Good reference for next time when evaluating `DATE` type casting returns
    - **Previous : 'DD/M/YY'** value for string which was giving different dates (or standardized date in which the uncleaned orders table had )

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
  TO_DATE(week_date, 'DD/MM/YY') AS week_date,
  DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
  DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
  DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) AS calendar_year,
  region,
  platform,
  CASE
    WHEN segment = 'null' THEN 'Unknown'
    ELSE segment
    END AS segment,
  CASE
    WHEN LEFT(segment, 1) = '1' THEN 'Young Adults'
    WHEN LEFT(segment, 1) = '2' THEN 'Middle Aged'
    WHEN LEFT(segment, 1) IN ('3', '4') THEN 'Retirees'
    ELSE 'Unknown'
    END AS age_band,
  CASE
    WHEN RIGHT(segment, 1) = 'C' THEN 'Couples'
    WHEN RIGHT(segment, 1) = 'F' THEN 'Families'
    ELSE 'Unknown'
    END AS demographic,
  customer_type,
  transactions,
  sales,
  ROUND(
      sales / transactions,
      2
   ) AS avg_transaction
FROM data_mart.weekly_sales;


-- AFTER CREATION, LET'S QUERY A FEW ROWS
SELECT * FROM data_mart.clean_weekly_sales LIMIT 5;
```
* Arggghhh had messed up the date string for the `TO_DATE` function
    - 'DD/M/YY' - was the previous string value prior to correcting and getting results consistent with detailed desired result (see value in table creation for reference of change ... a month can be more than one digit kapuhhh)
    - https://www.commandprompt.com/education/postgresql-to_date-function-convert-string-to-date/
    - When in doubt, review the above for the string classification of different potential date representation you want to mutate from a string/varchar

* But now Here's a preview of our cleaned data

|week_date|week_number|month_number|calendar_year|region|platform|segment|age_band|demographic|customer_type|transactions|sales|avg_transaction|
|---|----|----|----|----|----|----|----|----|----|---|---|---|
|2020-08-31|36|8|2020|ASIA|Retail|C3|Retirees|Couples|New|120631|3656163|30.00|
|2020-08-31|36|8|2020|ASIA|Retail|F1|Young Adults|Families|New|31574|996575|31.00|
|2020-08-31|36|8|2020|USA|Retail|null|unknown|unknown|Guest|529151|16509610|31.00|
|2020-08-31|36|8|2020|EUROPE|Retail|C1|Young Adults|Couples|New|4517|141942|31.00|
|2020-08-31|36|8|2020|AFRICA|Retail|C2|Middle Aged|Couples|New|58046|1758388|30.00|

* Let's Before we move ensure we have the same count of rows in each table and haven't had any data leakage!
```sql
-- Make sure to do a union all as a union would return almost a join (equal values)
SELECT
    COUNT(*) AS total_rows
FROM data_mart.weekly_sales
UNION ALL
SELECT
    COUNT(*) AS total_rows
FROM data_mart.clean_weekly_sales;
```
|total_rows|
|----|
|17117|
|17117|

* **Alright!**, we can move along

<br>

--- 

### `B : Data Exploration`
**1.** What `day of the week` is used for each `week_date` value?
```sql
-- In theory this is what we can't do but return corrects for Each
SELECT 
  DISTINCT(TO_CHAR(week_date, 'Day')) AS Unique_Day_Name
FROM data_mart.clean_weekly_sales
UNION
SELECT
  DISTINCT(EXTRACT(dow FROM week_date)) AS Unique_Day_Value
FROM data_mart.clean_weekly_sales;
```
* `UNION` types text and double precision cannot be matched
    - One is an Int, one is a string
```sql
WITH unique_day_counts AS (
-- Each row will give us the day_name and the integer value associated to it 
SELECT
  (SELECT DISTINCT(TO_CHAR(week_date, 'Day'))) AS Unique_Day_Name,
  (SELECT DISTINCT(EXTRACT(dow FROM week_date))) AS Unique_Day_Value
FROM data_mart.clean_weekly_sales
)
-- Now just a generic count after grouping
SELECT
  Unique_Day_Name,
  Unique_Day_Value,
  COUNT(*) AS total_day_line_counts
FROM unique_day_counts
GROUP BY Unique_Day_Name, Unique_Day_Value
ORDER BY total_day_line_counts DESC;
```
|unique_day_name|unique_day_value|total_day_line_counts|
|-----|-----|-----|
|Monday|1|17117|

* See the match in total rows (**total_day_line_counts**) as the rows for the table validates that indeed it is only ever `Monday` in which the base/parent table has ever had data inserted

<br>

**2.** What range of week numbers are missing from the dataset?
```sql
WITH total_weeks AS (
SELECT
  GENERATE_SERIES(1,52) AS week_number
)
SELECT
  week_number AS unique_week_numbers_not_included
FROM total_weeks
WHERE week_number NOT IN (SELECT DISTINCT(week_number) FROM data_mart.clean_weekly_sales)
ORDER BY unique_week_numbers_not_included;
```
|unique_week_numbers_not_included|
|---|
|1|
|2|
|3|
|4|
|5|
|6|
|7|
|8|
|9|
|10|
|11|
|12|
|37|
|38|
|39|
|40|
|41|
|42|
|43|
|44|
|45|
|46|
|47|
|48|
|49|
|50|
|51|
|52|

* 28 Rows for Week Numbers not included
    - `GENERATE_SERIES` Used to create a number to compare against
* Keyboard hot cut of : https://stackoverflow.com/questions/30037808/multiline-editing-in-visual-studio-code
    - Option + Command and either up or down arrow
* Another approach
```sql
WITH all_week_numbers AS ( 
  SELECT GENERATE_SERIES(1, 52) AS week_number
)
SELECT
  week_number
FROM all_week_numbers AS t1
WHERE NOT EXISTS (
  SELECT 1
  FROM data_mart.clean_weekly_sales AS t2
  WHERE t1.week_number = t2.week_number 
);
-- Can use the aliased week_number from CTE w/Generate Series to match against found week numbers and WHERE NOT EXISTS to get the missing week_numbers
```

<br>

**3.** How many total transactions were there for each year in the dataset?
```sql
SELECT
  calendar_year,
  SUM(transactions) AS year_total_transactions,
  SUM(SUM(transactions)) OVER() AS total_years_summed_transactions_window
FROM data_mart.clean_weekly_sales
GROUP BY calendar_year
ORDER BY year_total_transactions DESC;
```
|calendar_year|year_total_transactions|total_years_summed_transactions_window|
|----|-----|-----|
|2020|375813651|1087859396|
|2019|365639285|1087859396|
|2018|346406460|1087859396|

* `SUM(SUM(column))` Can provide the window sum after getting an aggregate for different grouped/partitioned groups

<br>

**4.** What is the total sales for each region for each month?
```sql
-- Using TO_CHAR to get the month name for easier association
SELECT
  month_number,
  TO_CHAR(week_date, 'Month') AS month_name,
  region,
  SUM(sales) AS month_total_sales_over_years
FROM data_mart.clean_weekly_sales
GROUP BY month_number, month_name, region
ORDER BY region, month_number;
```
|month_number|month_name|region|month_total_sales_over_years|
|----|-----|-----|------|
|3|March|AFRICA|567767480|
|4|April|AFRICA|1911783504|
|5|May|AFRICA|1647244738|
|6|June|AFRICA|1767559760|
|7|July|AFRICA|1960219710|
|8|August|AFRICA|1809596890|
|9|September|AFRICA|276320987|
|3|March|ASIA|529770793|
|4|April|ASIA|1804628707|
|5|May|ASIA|1526285399|
|6|June|ASIA|1619482889|
|7|July|ASIA|1768844756|
|8|August|ASIA|1663320609|
|9|September|ASIA|252836807|
|3|March|CANADA|144634329|
|4|April|CANADA|484552594|
|5|May|CANADA|412378365|
|6|June|CANADA|443846698|
|7|July|CANADA|477134947|
|8|August|CANADA|447073019|
|9|September|CANADA|69067959|
|3|March|EUROPE|35337093|
|4|April|EUROPE|127334255|
|5|May|EUROPE|109338389|
|6|June|EUROPE|122813826|
|7|July|EUROPE|136757466|
|8|August|EUROPE|122102995|
|9|September|EUROPE|18877433|
|3|March|OCEANIA|783282888|
|4|April|OCEANIA|2599767620|
|5|May|OCEANIA|2215657304|
|6|June|OCEANIA|2371884744|
|7|July|OCEANIA|2563459400|
|8|August|OCEANIA|2432313652|
|9|September|OCEANIA|372465518|
|3|March|SOUTH AMERICA|71023109|
|4|April|SOUTH AMERICA|238451531|
|5|May|SOUTH AMERICA|201391809|
|6|June|SOUTH AMERICA|218247455|
|7|July|SOUTH AMERICA|235582776|
|8|August|SOUTH AMERICA|221166052|
|9|September|SOUTH AMERICA|34175583|
|3|March|USA|225353043|
|4|April|USA|759786323|
|5|May|USA|655967121|
|6|June|USA|703878990|
|7|July|USA|760331754|
|8|August|USA|712002790|
|9|September|USA|110532368|
