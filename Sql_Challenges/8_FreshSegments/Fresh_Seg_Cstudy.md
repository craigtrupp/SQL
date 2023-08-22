# Fresh Segments (Extract Max Value!)
![Fresh Segment Cover](images/Fresh_Seg_Cover.png)

### **Introduction** 🍊
Danny created `Fresh Segments`, a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.

Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.

In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.

#### `Objective` 📔
Danny has asked for your assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.


#### `Available Data / Tables` 🗄️
For this case study there is a total of 2 datasets which you will need to use to solve the questions.

**Interest Metrics**
* This table contains information about aggregated interest metrics for a specific major client of Fresh Segments which makes up a large proportion of their customer base.
* Each record in this table represents the performance of a specific `interest_id` based on the client’s customer base interest measured through clicks and interactions with specific targeted advertising content.


|_month|_year|month_year|interest_id|composition|index_value|ranking|percentile_ranking|
|----|----|-----|-----|-----|-----|-----|----|
|7	|2018	|07-2018	|32486	|11.89	|6.19	|1	|99.86|
|7	|2018	|07-2018	|6106	|9.93	|5.31	|2	|99.73|
|7	|2018	|07-2018	|18923	|10.85	|5.29	|3	|99.59|
|7	|2018	|07-2018	|6344	|10.32	|5.1	|4	|99.45|
|7	|2018	|07-2018	|100	|10.77	|5.04	|5	|99.31|
|7	|2018	|07-2018	|69	    |10.82	|5.03	|6	|99.18|
|7	|2018	|07-2018	|79	    |11.21	|4.97	|7	|99.04|
|7	|2018	|07-2018	|6111	|10.71	|4.83	|8	|98.9|
|7	|2018	|07-2018	|6214	|9.71	|4.83	|8	|98.9|
|7	|2018	|07-2018	|19422	|10.11	|4.81	|10	|98.63|

For example - let’s interpret the first row of the interest_metrics table together:
* In July 2018, the composition metric is 11.89, meaning that 11.89% of the client’s customer list interacted with the interest interest_id = 32486 - we can link interest_id to a separate mapping table to find the segment name called “Vacation Rental Accommodation Researchers”

The index_value is 6.19, means that the composition value is 6.19x the average composition value for all Fresh Segments clients’ customer for this particular interest in the month of July 2018.

The ranking and percentage_ranking relates to the order of index_value records in each month year.

**Interest Map**
* This mapping table links the interest_id with their relevant interest information. 
* You will need to join this table onto the previous interest_details table to obtain the interest_name as well as any details about the summary information.

|id|interest_name|interest_summary|created_at|last_modified|
|---|----|-----|----|-----|
1|Fitness Enthusiasts|Consumers using fitness tracking apps and websites.|2016-05-26 14:57:59	|2018-05-23 11:30:12|
|2|Gamers|Consumers researching game reviews and cheat codes.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|3|Car Enthusiasts|Readers of automotive news and car reviews.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|4|Luxury Retail Researchers|Consumers researching luxury product reviews and gift ideas|2016-05-26 14:57:59|2018-05-23 11:30:12|
|5|Brides & Wedding Planners|People researching wedding ideas and vendors.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|6|Vacation Planners|Consumers reading reviews of vacation destinations and accommodations.|2016-05-26 14:57:59|2018-05-23 11:30:13|
|7|Motorcycle Enthusiasts|Readers of motorcycle news and reviews.|2016-05-26 14:57:59|2018-05-23 11:30:13|
|8|Business News Readers|Readers of online business news content.|2016-05-26 14:57:59|2018-05-23 11:30:12|
|12|Thrift Store Shoppers|Consumers shopping online for clothing at thrift stores and researching locations.|2016-05-26 14:57:59|2018-03-16 13:14:00|
|13|Advertising Professionals|People who read advertising industry news.|2016-05-26|14:57:59|2018-05-23 11:30:12|

---

<br>

### **Case Study Questions** :books:
The following questions can be considered key business questions that are required to be answered for the Fresh Segments team.

Most questions can be answered using a single query however some questions are more open ended and require additional thought and not just a coded solution!

<br>

#### `A. Data Exploration and Cleansing` 🥾 :broom:
**1.** Update the **fresh_segments.interest_metrics** table by modifying the **month_year** column to be a date data type with the start of the month
```sql
-- Check Types
SELECT
  column_name, data_type
FROM information_schema.columns
WHERE table_name = 'interest_metrics' AND table_schema = 'fresh_segments';
```
|column_name|data_type|
|----|-----|
|_month|text|
|_year|text|
|month_year|text|
|interest_id|integer|
|composition|double precision|
|index_value|double precision|
|ranking|integer|
|percentile_ranking|double precision|

```sql
-- idea of the column mutation setting
SELECT
  TO_DATE(month_year, 'MM-YYYY'),
  month_year
FROM fresh_segments.interest_metrics
LIMIT 5;

-- Update 
UPDATE fresh_segments.interest_metrics
SET month_year = TO_DATE(month_year, 'MM-YYYY');

-- DML Required to update Schema
ALTER TABLE fresh_segments.interest_metrics
ALTER month_year TYPE DATE USING month_year::DATE;

-- Similarly call the information schema at the beginning of the question to validate the output and column being updated
```
|column_name|data_type|
|-----|-----|
|_month|text|
|_year|text|
|month_year|date|
|interest_id|integer|
|composition|double precision|
|index_value|double precision|
|ranking|integer|
|percentile_ranking|double precision|


<br>

**2.** What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
```sql
SELECT
  DATE_PART('Month', month_year) AS Month_Extract,
  month_year AS month_column,
  COUNT(*) AS monthly_record_count
FROM fresh_segments.interest_metrics
GROUP BY Month_Extract, month_column
-- Can use or month_extract to group by months of different years
-- for comparisson which a normal desc on the month_column wouldn't allow
ORDER BY Month_Extract DESC;
```
|month_extract|month_column|monthly_record_count|
|-----|------|------|
|null|null|1194|
|12|2018-12-01|995|
|11|2018-11-01|928|
|10|2018-10-01|857|
|9|2018-09-01|780|
|8|2018-08-01|767|
|8|2019-08-01|1149|
|7|2019-07-01|864|
|7|2018-07-01|729|
|6|2019-06-01|824|
|5|2019-05-01|857|
|4|2019-04-01|1099|
|3|2019-03-01|1136|
|2|2019-02-01|1121|
|1|2019-01-01|973|

<br>

**3.** What do you think we should do with these null values in the fresh_segments.interest_metrics
* As our metrics look heavily involved in regards to time (see counts above), we can likely remove the null values from our data as there is not contextual or referential ways to impute the values.
* Looking at this in the context of the overall dataset and the business problem - it does not make too much sense to include these erroneous records into the analysis because we are going to be interested in the records only with a date specified!

**4.** How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
```sql
SELECT
  COUNT(interest_metrics.interest_id) AS all_interest_metric,
  COUNT(interest_map.id) AS all_interest_map,
  COUNT(CASE WHEN interest_map.id IS NULL THEN interest_metrics.interest_id ELSE NULL END) AS not_in_map,
  COUNT(CASE WHEN interest_metrics.interest_id IS NULL THEN interest_map.id ELSE NULL END)  AS not_in_metrics
FROM fresh_segments.interest_metrics
FULL OUTER JOIN fresh_segments.interest_map
  ON interest_metrics.interest_id = interest_map.id;
```
|all_interest_metric|all_interest_map|not_in_map|not_in_metrics|
|----|----|----|----|
|1202|1209|0|7|

`Note`: We can also use an **anti-join** which is conceptually a little easier to understand here in terms of checking where there isn't any intersection on the shared id values 

```sql
-- Anti Join
SELECT 
(
  SELECT
    COUNT(id)
  FROM fresh_segments.interest_map AS i_map 
  WHERE NOT EXISTS (
    SELECT
      1
    FROM fresh_segments.interest_metrics AS i_metrics 
    WHERE i_metrics.interest_id = i_map.id
  ) 
) AS interest_map_id_count_unique,
(
  SELECT
    COUNT(interest_id)
  FROM fresh_segments.interest_metrics AS i_metrics
  WHERE NOT EXISTS (
    SELECT
      1
    FROM fresh_segments.interest_map AS i_map 
    WHERE i_map.id = i_metrics.interest_id
  ) 
) AS interest_metrics_id_count_unique
```
|interest_map_id_count_unique|interest_metrics_id_count_unique|
|----|----|
|7|0|

* What about the unique ID values though?
```sql
SELECT 
(
  SELECT
    ARRAY_AGG(DISTINCT i_map.id)
  FROM fresh_segments.interest_map AS i_map 
  WHERE NOT EXISTS (
    SELECT
      1
    FROM fresh_segments.interest_metrics AS i_metrics 
    WHERE i_metrics.interest_id = i_map.id
  ) 
) AS interest_map_id_count_unique,
(
  SELECT
    ARRAY_AGG(DISTINCT i_metrics.interest_id)
  FROM fresh_segments.interest_metrics AS i_metrics
  WHERE NOT EXISTS (
    SELECT
      1
    FROM fresh_segments.interest_map AS i_map 
    WHERE i_map.id = i_metrics.interest_id
  ) 
) AS interest_metrics_id_count_unique
```
|interest_map_id_count_unique|interest_metrics_id_count_unique|
|----|-----|
|[ 19598, 35964, 40185, 40186, 42010, 42400, 47789 ]|[ null ]|

<br>

**5.** Summarise the id values in the fresh_segments.interest_map by its total record count in this table


**6.** What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

**7.** Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?


