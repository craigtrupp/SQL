# Health Analytics Mini Case Study


We’ve just received an urgent request from the General Manager of Analytics at Health Co requesting our assistance with their analysis of the `health.user_logs` dataset.

The Health Co analytics team have shared with us their SQL script - they unfortunately ran into a few bugs that they couldn’t fix!

We’ve been asked to quickly debug their SQL script and use the resulting query outputs to quickly answer a few questions that the GM has requested for a board meeting about their active users.

---

<br>

## Business Questions
Before we start digging into the SQL script - let’s cover the business questions that we need to help the GM answer!

1. How many unique users exist in the logs dataset?
2. How many total measurements do we have per user on average?
3. What about the median number of measurements per user?
4. How many users have 3 or more measurements?
5. How many users have 1,000 or more measurements?

Looking at the logs data - what is the number and percentage of the active user base who:

6. Have logged blood glucose measurements?
7. Have at least 2 types of measurements?
8. Have all 3 measures - blood glucose, weight and blood pressure?

For users that have blood pressure measurements:

9. What is the median systolic/diastolic blood pressure values?

---

<br>

## Modified SQL Script Detail Against Original
* Output Summary for Biz Questions along with original query for reference

---

<br>

### Question 1 - How many unique users exist in the logs dataset?
* Provided
```sql
SELECT
  COUNT DISTINCT user_id
FROM health.user_logs;
```

<br>

* Revised
```sql
SELECT COUNT(DISTINCT id)
  FROM health.user_logs
```
|count|
|----|
|554|

<br>

* Good reminder here that the total count of rows for the dataset (table) : 43,891 total rows


---

<br>

### Question 2 - 8 (Temp Table)
* The temporary table user_measure_count is intended to be used here for some user counts
* Recall that this table `health.user_logs` does have duplicate rows for user measurements which will impact total user counts but the measure_value (particular Avg should be the same based on just a duplicate value)
* A few quick notes with queries below provided temp table to look at dataset then modify

<br>

* Provided Temp Table
```sql
DROP TABLE IF EXISTS user_measure_count;
CREATE TEMP TABLE user_measure_cout
SELECT
    id,
    COUNT(*) AS measure_count,
    COUNT(DISTINCT measure) as unique_measures
  FROM health.user_logs
  GROUP BY 1; 
```

<br>

* Total User Measurements in Table
```sql
SELECT 
  id as user,
  COUNT(*) as user_measure_counts
FROM health.user_logs
GROUP BY id
ORDER BY user_measure_counts DESC 
LIMIT 5;
```
|user|user_measure_counts|
|----|--------|
|054250c692e....|22325|
|0f7b13f3f05....|1589|
|ee653a96022....|1235|
|abc634a555b....|1212|
|576fdb528e5....|1018|

<br>

* Modified Temp Table
    + Modified Temp table will have have similar construct and include  
        * (id - username) 
        * (measure_count as total measures/row for that user)
        * (unique_meauses as total unique measures taken) 
            * `SELECT DISTINCT measure FROM health.user_logs` 
            * This is just three measures (most any user can have) - table only holds three measurement types for any measure taken (aka row in table) : [blood_glucose, blood_pressure, weight]

```sql
DROP TABLE IF EXISTS user_measure_count;
CREATE TEMP TABLE user_measure_count AS (
SELECT
    id AS user,
    COUNT(*) AS measure_count,
    COUNT(DISTINCT measure) as unique_measures
  FROM health.user_logs
  GROUP BY id
); 
```

---

<br>

### Question 2 - How many total measurements do we have per user on average
* Provided
```sql
SELECT
  ROUND(MEAN(measure_count))
FROM user_measure_count;
```

<br>

* Revised
```sql
SELECT 
  ROUND(AVG(measure_count)) AS Average_User_Total_Measurements
FROM user_measure_count;
```
|average_user_total_measurements|
|-------|
|79|

---

<br>

### Question 3 - What about the median number of measurements per user?
* Provided
```sql
SELECT
  PERCENTILE_CONTINUOUS(0.5) WITHIN GROUP (ORDER BY id) AS median_value
FROM user_measure_count;
```

<br>

* Revised
```sql
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_count) AS median_value
FROM user_measure_count;
```
|median_value|
|------|
|2|

<br>

### Notes
* The `PERCENTILE_CONT` grabs the 50th percentile of the measure_counts (individual count of total measurements per user) grouped in order
    * The temp table has all unique users (554 rows) in an individual row
    * measure_count is organized in `ORDER` for all the rows which then plucks the `median` value with the function above
* This will help decrease any **noisy** outliers the Avg/Mean could reveal


---

<br>

### Question 4 - How many users have 3 or more measurements?
* Provided
```sql
SELECT
  COUNT(*)
FROM user_measure_count
HAVING measure >= 3;
```

<br>

* Revised
```sql
SELECT
  COUNT(*)
FROM user_measure_count
WHERE measure_count >= 3;
```
|count|
|----|
|209|

<br>

### Notes
* `HAVING` is like a `WHERE` clause that takes place after aggregation
    * As the question is not looking to aggregate (group) and values, a `WHERE` clause is only needed

---

<br>


### Question 5 - How many users have 1,000 or more measurements?
* Provided
```sql
SELECT
  SUM(id)
FROM user_measure_count
WHERE measure_count >= 1000;
```

<br>

* Revised
```sql
SELECT
  COUNT(*)
FROM user_measure_count
WHERE measure_count >= 1000;
```
|count|
|-----|
|5|

---

<br>

### Question 6 - Have logged blood glucose measurements?
* Provided
```sql
SELECT
  COUNT DISTINCT id
FROM health.user_logs
WHERE measure is 'blood_sugar';
```

<br>

* Revised
```sql
SELECT
  COUNT(DISTINCT id)
FROM health.user_logs
WHERE measure = 'blood_glucose';
```
|count|
|---|
|325|

<br>

### Notes
* Make sure to target right table here as our temporary table has unique `counts` for how many times a user was found in the parent `health.user_logs` and how many measure_types they may have used (total of 3 types) and such measure detail about types wouldn't be included in that temp table

---

<br>

### Question 7 - Have at least 2 types of measurements? (Back to TempTable!)
* Provided
```sql
SELECT
  COUNT(*)
FROM user_measure_count
WHERE COUNT(DISTINCT measures) >= 2;
```

<br>

* Revised
```sql
SELECT 
  COUNT(*)
FROM user_measure_count
WHERE unique_measures >= 2;
```
|count|
|----|
|204|

---

<br>

### Question 8 - Have all 3 measures - blood glucose, weight and blood pressure?
* Provided
```sql
SELECT
  COUNT(*)
FROM usr_measure_count
WHERE unique_measures = 3;
```

<br>

* Revised
```sql
SELECT
  COUNT(*)
FROM user_measure_count
WHERE unique_measures = 3;
```
|count|
|---|
|50|

---

<br>

### Question 9 - For users that have blood pressure measurements, what is the median systolic/diastolic blood pressure values?
* Provided
```sql
SELECT
  PERCENTILE_CONT(0.5) WITHIN (ORDER BY systolic) AS median_systolic
  PERCENTILE_CONT(0.5) WITHIN (ORDER BY diastolic) AS median_diastolic
FROM health.user_logs
WHERE measure is blood_pressure;
```

<br>

* Revised
```sql
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY systolic) AS median_systolic,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diastolic) AS median_diastolic
FROM health.user_logs
WHERE measure = 'blood_pressure'
```
|median_systolic|median_diastolic|
|------|-----|
|126|79|


<br>

---
<br>

## Summary
* Each Revised SQL Output has been tested against the following section's Quiz/Test for this Case Study for accuracy
