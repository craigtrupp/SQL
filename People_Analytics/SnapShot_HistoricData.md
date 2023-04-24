## Snapshot & Historic Data
* A key area for any data work (analysts or scientists) is the handling and merging of historic and new data. Considerations and patterns for approaching datasets with like data will be covered in this tutorial

<br>

### **HR Case Study Problem Solving**
Now that we’ve fixed our data issue using some reproducible methods - let’s quickly recap what we’ve done so far and also revisit technical outputs we need to complete this HR analytics case study.

### **Background Recap**
We’ve been tasked by our client HR Analytica to create 2 analytical (review CaseStudy_Intro for requested metrics) views to power their dashboard outputs and further enable their in-house analytics team to generate additional reports and answer basic business questions using our data assets.

So far we have inspected the raw source data HR Analytica have shared with us inside the employees schema and we’ve applied corrections for a simple data input error by adding 18 years to each historic date record.

We now have a new `schema - mv_employees` complete with like-for-like materialized view versions of each of the tables from the employees with all corrected data.

The solution for the exercise in our previous tutorial: we also needed to apply an explicit data type cast from the TIMESTAMP to a DATE after adding our interval of 18 years!

### **Data Generation**
Please make sure you run the following SQL script directly in your SQLPad GUI otherwise you will not be able to run any of the following SQL code snippets later in this tutorial - the explicit type cast back to a DATE data type is also applied throughout this following code snippet below and we’ve also included the index creation steps to match our original datasets at the end of each view creation step.

#### `Original Indexes`
We can inspect the original indexes from our `employees - schema` using the following query - UNIQUE indexes literally mean that each index value will be unique and there is no risk of duplicates when using either a single column or a combination of multiple columns as shown in the most right indexdef column values.

We will cover this in more detail and also the types of indexes we can create in the Additional SQL component part of the Serious SQL course - 
* but for now we will use these original index definitions to help us recreate these indexes for our materialized views.

```sql
SELECT * FROM pg_indexes WHERE schemaname = 'employees';
```
|schemaname|tablename|indexname|indexdef|
|-----|-----|-----|-----|
|employees|employee|idx_16988_primary|CREATE UNIQUE INDEX idx_16988_primary ON employees.employee USING btree (id)|
|employees|department_employee|idx_16982_primary|CREATE UNIQUE INDEX idx_16982_primary ON employees.department_employee USING btree (employee_id, department_id)|
|employees|department_employee|idx_16982_dept_no|CREATE INDEX idx_16982_dept_no ON employees.department_employee USING btree (department_id)|
|employees|department|idx_16979_primary|CREATE UNIQUE INDEX idx_16979_primary ON employees.department USING btree (id)|
|employees|department|idx_16979_dept_name|CREATE UNIQUE INDEX idx_16979_dept_name ON employees.department USING btree (dept_name)|
|employees|department_manager|idx_16985_primary|CREATE UNIQUE INDEX idx_16985_primary ON employees.department_manager USING btree (employee_id, department_id)|
|employees|department_manager|idx_16985_dept_no|CREATE INDEX idx_16985_dept_no ON employees.department_manager USING btree (department_id)|
|employees|salary|idx_16991_primary|CREATE UNIQUE INDEX idx_16991_primary ON employees.salary USING btree (employee_id, from_date)|
|employees|title|idx_16994_primary|CREATE UNIQUE INDEX idx_16994_primary ON employees.title USING btree (employee_id, title, from_date)|

<br>

#### `Materialized View Script`
The following is the complete script we will need to use for the rest of this case study tutorial - note that all of the explicit date casts is applied throughout the code and the final index creation steps will be kept right at the end of the snippet below.

```sql
DROP SCHEMA IF EXISTS mv_employees CASCADE;
CREATE SCHEMA mv_employees;

-- department
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department;
CREATE MATERIALIZED VIEW mv_employees.department AS
SELECT * FROM employees.department;


-- department employee
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department_employee;
CREATE MATERIALIZED VIEW mv_employees.department_employee AS
SELECT
  employee_id,
  department_id,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.department_employee;

-- department manager
DROP MATERIALIZED VIEW IF EXISTS mv_employees.department_manager;
CREATE MATERIALIZED VIEW mv_employees.department_manager AS
SELECT
  employee_id,
  department_id,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.department_manager;

-- employee
DROP MATERIALIZED VIEW IF EXISTS mv_employees.employee;
CREATE MATERIALIZED VIEW mv_employees.employee AS
SELECT
  id,
  (birth_date + interval '18 years')::DATE AS birth_date,
  first_name,
  last_name,
  gender,
  (hire_date + interval '18 years')::DATE AS hire_date
FROM employees.employee;

-- salary
DROP MATERIALIZED VIEW IF EXISTS mv_employees.salary;
CREATE MATERIALIZED VIEW mv_employees.salary AS
SELECT
  employee_id,
  amount,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.salary;

-- title
DROP MATERIALIZED VIEW IF EXISTS mv_employees.title;
CREATE MATERIALIZED VIEW mv_employees.title AS
SELECT
  employee_id,
  title,
  (from_date + interval '18 years')::DATE AS from_date,
  CASE
    WHEN to_date <> '9999-01-01' THEN (to_date + interval '18 years')::DATE
    ELSE to_date
    END AS to_date
FROM employees.title;

-- Index Creation
-- NOTE: we do not name the indexes as they will be given randomly upon creation!
CREATE UNIQUE INDEX ON mv_employees.employee USING btree (id);
CREATE UNIQUE INDEX ON mv_employees.department_employee USING btree (employee_id, department_id);
CREATE INDEX        ON mv_employees.department_employee USING btree (department_id);
CREATE UNIQUE INDEX ON mv_employees.department USING btree (id);
CREATE UNIQUE INDEX ON mv_employees.department USING btree (dept_name);
CREATE UNIQUE INDEX ON mv_employees.department_manager USING btree (employee_id, department_id);
CREATE INDEX        ON mv_employees.department_manager USING btree (department_id);
CREATE UNIQUE INDEX ON mv_employees.salary USING btree (employee_id, from_date);
CREATE UNIQUE INDEX ON mv_employees.title USING btree (employee_id, title, from_date);
```
* Note the table abve as well for the index hierarchy and declaration of unique vs non-unique index creation
    - When in doubt, simply refer to the base schema and the index relationships/types

---

<br>

### **Technical Requirements**
For this case study request - we’ve explicitly been asked to generate reproducible analytical views that the in-house HR Analytica team can access to answer more questions.

We will also be tasked with generating valid data points and insights for the following two data products:

1. A current view of the company, department and title level insights
2. A deep dive tool to investigate all information on a single employee

<br>

#### `People Analytics Dashboard`
An example company level dashboard that includes the following insights:

- Total number of employees
- Average company tenure in years
- Gender ratios
- Average payrise percentage and amount

We will also need to generate similar insights for both department and title levels where we need employee count and average tenure for each level instead of company wide numbers!

<br>

#### `Employee Deep Dive`
Below is a example employee deep dive output from our second output that includes the following insights for a single employee over time:

- See all the various employment history ordered by effective date including salary, department, manager and title changes
- Calculate previous historic payrise percentages and value changes
- Calculate the previous position and department history in months with start and end dates
- Compare an employee’s current salary, total company tenure, department, position and gender to the average benchmarks for their current position

<br>

### Dashboards Visual Samples

#### `Company Level Insights`
![CompanyLevel](images/FOutput_1.png)
![CompanyLevel2](images/FOutput2.png)

<br>

#### `Employee Level Insights`
![Employee I](images/Emp1.png)
![Employee II](images/Emp2.png)

---

<br>

### **Current vs Historic**
Firstly we need to address the key difference between our 2 technical requirements - namely the difference between a `current snapshot` vs a `historic dataset`.

* The dashboard components are all based off current data  
* The deep dive employee analysis must be able to look at both current and the historic data.

This concept of current vs historic is super important when working with real world messy data - and especially when working with slowly changing dimensions (SCD) tables which are pretty much everywhere throughout all databases in medium to large companies!

Up until this point - perhaps you have encountered data which has date columns and lots of metrics - SCD tables we touched upon lightly in the previous tutorial but we are yet to really dig into exactly why they are useful!

Let’s revisit Georgi’s salary (employee_id = 10001) to reiterate this difference between current and historic before we roll into more SQL for our case study!

<br>

#### **Georgi’s Salary Revisited**
Let’s take another look at Georgi’s salary using our new materialized view version of the salary: mv_employees.salary

This `mv_employees.salary` is a perfect example of a **slow-changing dimension** table also known as a historic dataset where there is a “valid” period for each data point - the `from_date` and `to_date` columns signify the end of a specific period of time where the amount is **active**.

```sql
SELECT *
FROM mv_employees.salary
WHERE employee_id = 10001
ORDER BY from_date DESC
LIMIT 5;
```
|employee_id|amount|from_date|to_date|
|---|----|----|----|
|10001|88958|2020-06-22|9999-01-01|
|10001|85097|2019-06-22|2020-06-22|
|10001|85112|2018-06-22|2019-06-22|
|10001|84917|2017-06-23|2018-06-22|
|10001|81097|2016-06-23|2017-06-23|

<br>

`Visual Representation`
![Georgi Salary](images/grg_salary.png)

#### **Exercises**
The following questions have solutions at the end of this tutorial in the appendix - please give these a try to test your understanding of this historic and current concept as we will be leveraging this throughout the rest of this tutorial heavily!

1. What was Georgi’s starting salary at the beginning of 2009?
```sql
-- Initial View just to see record in our salary view if either date field has the year of interest
SELECT *
FROM mv_employees.salary
WHERE employee_id = 10001
    -- Match either window date holding the year value of interest
  AND (EXTRACT(year FROM from_date) = 2009 OR EXTRACT(year from to_date) = 2009)
ORDER BY from_date;
-- Now with that in focus, we can use BETWEEN to see where a record wedges the start date for the salary on the first day of that year
SELECT *
FROM mv_employees.salary
WHERE employee_id = 10001
    AND '2009-01-01' BETWEEN from_date AND to_date;
```
* First query output 

|employee_id|amount|from_date|to_date|
|----|-----|----|----|
|10001|66961|2008-06-25|2009-06-25|
|10001|71046|2009-06-25|2010-06-24|

* Second Query output

|employee_id|amount|from_date|to_date|
|---|----|---|-----|
|10001|66961|2008-06-25|2009-06-25|

<br>

2. What is Georgi’s current salary?
```sql
SELECT *
FROM mv_employees.salary
WHERE employee_id = 10001
AND to_date > NOW();

-- Anoter way using CURRENT_DATE
SELECT *
FROM mv_employees.salary
WHERE employee_id = 10001
  AND CURRENT_DATE BETWEEN from_date and to_date;
```
|employee_id|amount|from_date|to_date|
|----|----|----|----|
|10001|88958|2020-06-22|9999-01-01|

<br>

3. Georgi received a raise on 23rd of June in 2014 - how much of a percentage increase was it?
```sql
WITH raise_difference AS (
  SELECT 
    amount,
    from_date,
    to_date,
    LEAD(amount, 1) OVER (
      ORDER BY from_date
    ) AS future_amount
  FROM mv_employees.salary
  WHERE employee_id = 10001
  -- Get the 
    AND (to_date = '2014-06-23' OR from_date = '2014-06-23')
  ORDER BY from_date
  -- Using the limit we can still get the lead value for the second row we need
  LIMIT 1
)
SELECT 
  amount AS starting_amount,
  future_amount AS raise_amount,
  ROUND(((future_amount::numeric - amount::numeric)) / amount::numeric * 100, 2) AS perc_increase_numeric,
  CONCAT(ROUND(((future_amount::numeric - amount::numeric)) / amount::numeric * 100, 2), '%') AS perc_increase_str
FROM raise_difference;
```
|starting_amount|raise_amount|perc_increase_numeric|perc_increase_str|
|------|------|------|------|
|76884|80013|4.07|4.07%|

* Similar but provided answers & Cross Join
```sql
-- CTE with null value as filter for return perc_increase
WITH cte AS (
SELECT
  100 * (amount - LAG(AMOUNT) OVER (ORDER BY from_date))::NUMERIC /
    LAG(AMOUNT) OVER (ORDER BY from_date) AS percentage_difference
FROM mv_employees.salary
WHERE employee_id = 10001
  AND (
    from_date = '2014-06-23'
    OR to_date = '2014-06-23'
  )
)
SELECT *
FROM cte
WHERE percentage_difference IS NOT NULL;

-- Cross Join
-- Cross Join method
SELECT
  100 * (t2.after_amount - t1.before_amount) / t1.before_amount::NUMERIC AS percentage_difference
FROM
(
  SELECT
    amount AS before_amount
  FROM mv_employees.salary
  WHERE employee_id = 10001
    AND to_date = '2014-06-23'
) AS t1
CROSS JOIN
(
  SELECT
    amount AS after_amount
  FROM mv_employees.salary
  WHERE employee_id = 10001
    AND from_date = '2014-06-23'
) AS t2;
```

4. What is the dollar amount difference between Georgi’s salary at date '2012-06-25' and '2020-06-21'
```sql
SELECT 
  t1.salary_2012, 
  t2.salary_2020,
  t2.salary_2020::numeric - t1.salary_2012 AS difference 
FROM
(
  SELECT 
    amount AS salary_2012
  FROM mv_employees.salary
  WHERE employee_id = 10001
    AND '2012-06-25' BETWEEN from_date AND to_date
) AS t1
CROSS JOIN
(
  SELECT
    amount as salary_2020
  FROM mv_employees.salary
  WHERE employee_id = 10001
    AND '2020-06-21' BETWEEN from_date AND to_date
) AS t2
```
|salary_2012|salary_2020|difference|
|----|-----|----|
|75994|85097|9103|

---

<br>

### Join Historic Tables
One key skill we really need to focus on is the ability to join multiple tables with multiple historic data points which all have different validity at different points in time.

This is one of the main differentiators between a junior/intermediate data analyst to an advanced level data analyst so please make sure this next following section is really well understood before moving on!

We have seen all of those from_date and to_date columns throughout this case study in many of the tables except the static employee and department tables.

Now we will demonstrate how to combine these tables using 2 separate methods and compare the results to help further our understanding.


#### `Naive Joins`
Firstly we will naively join our tables using the foreign key columns identified by our ERD without taking into account the `from_date` and `to_date` columns - then we will perform a simple COUNT(*) on the resulting joint table output to see how many rows and inspect a few results to check for inconsistencies.

We will be using a lot of column aliases as we have multiple tables with the same `from_date` and `to_date` column names so we will be prepending each of those columns with their specific table source, e.g. `salary_from_date` and `salary_to_date`

```sql
DROP TABLE IF EXISTS naive_join_table;
CREATE TEMP TABLE naive_join_table AS
SELECT
  employee.id,
  employee.birth_date,
  employee.first_name,
  employee.last_name,
  employee.gender,
  employee.hire_date,
  -- we do not need title.employee_id as employee.id is already included!
  title.title,
  title.from_date AS title_from_date,
  title.to_date AS title_to_date,
  -- same goes for the title.employee_id column
  salary.amount,
  salary.from_date AS salary_from_date,
  salary.to_date AS salary_to_date,
  -- same for department_employee.employee_id
  -- shorten department_employee to dept for the aliases
  department_employee.department_id,
  department_employee.from_date AS dept_from_date,
  department_employee.to_date AS dept_to_date,
  -- we do not need department.department_id as it is already included!
  department.dept_name
FROM mv_employees.employee
INNER JOIN mv_employees.title
  ON employee.id = title.employee_id
INNER JOIN mv_employees.salary
  ON employee.id = salary.employee_id
INNER JOIN mv_employees.department_employee
  ON employee.id = department_employee.employee_id
-- NOTE: department is joined only to the department_employee table!
INNER JOIN mv_employees.department
  ON department_employee.department_id = department.id;

SELECT
  COUNT(*) AS row_count
FROM naive_join_table;
```
|row_count|
|----|
|5124191|

* When we inspect the resulting `naive_join_table` we can see that we now have many more rows than our original separate datasets - this must be due to some duplicates in the original tables by the join columns! Let’s investigate a bit more by looking at some individual employees to see if we can identify why we have so many more records than before!

<br>

#### `Inspecting Individuals`
- **Georgi Facello**

Let’s also inspect good old `Georgi’s` records again by applying a `WHERE id = 10001` and sorting by his `salary_to_date` descending to see if it matches up with what we are expecting:

```sql
SELECT *
FROM naive_join_table
WHERE id = 10001
ORDER BY salary_to_date DESC;
```

* Here we can see that there seems to be no issue with Georgi’s records as we can see his title and department does not change at all throughout his entire career at the company - the only things that are changing is his salary - which we can see changing with the `salary_from_date` and `salary_to_date` records.

<br>

*  **Leah Anguita**

Let’s look at another employee with a bit more career activity to see if we can find any data issues - we apply another basic where filter WHERE id = 11669 in the script below:

```sql
SELECT *
FROM naive_join_table
WHERE id = 11669
ORDER BY salary_to_date DESC;

-- Ok - we have a lot of stuff going on here, and we may well have some issues too!

SELECT *
FROM naive_join_table
WHERE id = 11669
  AND salary_to_date = '9999-01-01';
```
* Here we can spot out first issue - there seems to be `duplicates` in both the **title** and **dept_name** related data leading not 4 records when there should only be 1 because Leah shouldn’t have 2 different titles or be in 2 different departments at the same time!

What can we do to remove all of these issues? Luckily there is a simply way!

<br>

#### `Current Records Only`
One way to deal with these sorts of duplicates in historical dimensions is to simply filter out anything which is not current.

In our example - we will need to only need to extract the title and dept_name for the current time which we can easily do using a basic filter WHERE <to_date> = '9999-01-01'

Let’s apply this simple fix to just Leah’s record to see if we return the only row we are expecting!

```sql
SELECT *
FROM naive_join_table
WHERE id = 11669
  AND salary_to_date = '9999-01-01'
  AND title_to_date = '9999-01-01'
  AND dept_to_date = '9999-01-01';
```

<br>

#### `Assessment`
So we can see that our naive join method seems to introduce many many duplicates into our dataset which we don’t need for our basic current snapshot analysis that we need for our initial dashboard view for the case study.

In fact - this is actually a very common mistake made by beginner SQL practitioners who do not understand the concept of historic vs current data, so please take special attention whenever you see any columns which represent the `“slow changing dimension”` of an effective/from and an expiry/to date!

So let’s now improve our original naive solution and apply further snapshot logic to only capture the current records that we need for our analytics dashboard.

<br>

#### `Current Record Join`
Let’s improve our original naive join method by applying those same filters in our previous query to view Leah’s current records.

We simply need to add that same block of WHERE filters directly at the bottom of our previous query:

```sql
WHERE salary_to_date = '9999-01-01'
  AND title_to_date = '9999-01-01'
  AND dept_to_date = '9999-01-01'
```

* Note how these filters are applied in the WHERE step with the original materialized view reference columns and not afterwards in a CTE - also we do not specify the filtering criteria within the JOIN criteria - this is for a few reasons

1. If we were to use an additional CTE - we would need to calculate ALL of the 5 million rows prior to the filtering occuring (slow)
2. We would have to write more code which is verbose and more difficult to read if we include all the filters within the ON conditions
3. Philosophically - we want to perform the join and then apply the filters, so the logic is easier to understand when written this way

```sql
DROP TABLE IF EXISTS current_join_table;
CREATE TEMP TABLE current_join_table AS
SELECT
  employee.id,
  employee.birth_date,
  employee.first_name,
  employee.last_name,
  employee.gender,
  employee.hire_date,
  -- we do not need title.employee_id as employee.id is already included!
  title.title,
  title.from_date AS title_from_date,
  title.to_date AS title_to_date,
  -- same goes for the title.employee_id column
  salary.amount,
  salary.from_date AS salary_from_date,
  salary.to_date AS salary_to_date,
  -- same for department_employee.employee_id
  -- shorten department_employee to dept for the aliases
  department_employee.department_id,
  department_employee.from_date AS dept_from_date,
  department_employee.to_date AS dept_to_date,
  -- we do not need department.department_id as it is already included!
  department.dept_name
FROM mv_employees.employee
INNER JOIN mv_employees.title
  ON employee.id = title.employee_id
INNER JOIN mv_employees.salary
  ON employee.id = salary.employee_id
INNER JOIN mv_employees.department_employee
  ON employee.id = department_employee.employee_id
-- NOTE: department is joined only to the department_employee table!
INNER JOIN mv_employees.department
  ON department_employee.department_id = department.id
-- NOTE: we use the original table.column references to help the optimizer
-- We DO NOT want to use a CTE for this extra filter step!!!
WHERE salary.to_date = '9999-01-01'
  AND title.to_date = '9999-01-01'
  AND department_employee.to_date = '9999-01-01';
  
-- See how many rows now for current table with scd past rows removed
SELECT
  COUNT(*) AS row_count
FROM current_join_table;
```
|count|
|----|
|240124|

This seemed to have worked well and now we should be able to access all of the relevant current data for our employees - but we have a few more requirements for our analytics dashboard - that average salary increase, and also we still have yet to cover our final historical employee deep dive!

Let’s try to answer a few exercise questions before we take a quick look at that salary increase step as it’s something we’ve already covered before in our Window Functions section of the course!

<br>

#### **Exercises**
All of these questions are based off the `current` dataset that we’ve just created - I would suggest you to save your queries somewhere because we might just be using these somewhere later on in our case study…

Write SQL queries to calculate the average salary for the following segments:

* Years of tenure: you can calculate tenure = current date - hire date in years
```sql
-- Just a little fun one to cast a str to a date format
SELECT EXTRACT(year FROM to_date('2021-05-03', 'YYYY-MM-DD'));

-- Way to extract date diff in years, days, months first
SELECT
  AGE(CURRENT_DATE, hire_date) AS tenure_total_date,
  DATE_PART('year', AGE(CURRENT_DATE, hire_date)) as years,
  -- Calculate Total Months
  (DATE_PART('year', AGE(CURRENT_DATE, hire_date)) * 12)::numeric + DATE_PART('month', AGE(CURRENT_DATE, hire_date)) AS total_months,
  -- Calculate Total Days (just flat 365 no leap year)
  (DATE_PART('year', AGE(CURRENT_DATE, hire_date)) * 365)::numeric + DATE_PART('month', AGE(CURRENT_DATE, hire_date)) AS total_days,
  CURRENT_DATE, 
  hire_date
FROM current_join_table
WHERE id = 11669;
```
|tenure_total_date|years|total_months|total_days|current_date|hire_date|
|-----|----|-----|------|---|-----|
|{ "years": 19, "days": 17 }|19|228|6935|2023-04-24|

<br>

* Yearly Averages
```sql
WITH year_agg_avgs AS (
  SELECT
    amount,
    EXTRACT('year' FROM CURRENT_DATE)::numeric - EXTRACT('year' FROM hire_date) AS years_spent
  FROM current_join_table
)
SELECT
  years_spent,
  ROUND(AVG(amount), 2),
  CONCAT('$', ROUND(AVG(amount), 2)) AS yearly_rounded_average
FROM year_agg_avgs
GROUP BY years_spent
ORDER BY years_spent DESC;
```
|years_spent|round|yearly_rounded_average|
|----|----|-----|
|20|78870.32|$78870.32|
|19|77411.45|$77411.45|
|18|75927.59|$75927.59|
|17|74201.56|$74201.56|
|16|73053.45|$73053.45|

<br>

```sql
-- Try months aggregates
WITH montly_agg_avgs AS (
  SELECT
    amount,
    (DATE_PART('year', AGE(CURRENT_DATE, hire_date)) * 12)::numeric + (DATE_PART('month', AGE(CURRENT_DATE, hire_date)))::numeric AS total_months
  FROM current_join_table
)
SELECT
  total_months,
  ROUND(AVG(amount), 2),
  CONCAT('$', ROUND(AVG(amount), 2)) AS monthly_rounded_average
FROM montly_agg_avgs
GROUP BY total_months
ORDER BY total_months DESC;
```
|total_months|round|monthly_rounded_average|
|----|-----|------|
|243|87128.50|$87128.50|
|242|79098.52|$79098.52|
|241|79294.71|$79294.71|
|240|79689.73|$79689.73|
|239|78959.16|$78959.16|

<br>

* Title
```sql
SELECT
  title,
  -- To nearest dollar (round defaults to zero)
  ROUND(AVG(amount)) AS avg_salary_per_title
FROM current_join_table
GROUP BY title
ORDER BY avg_salary_per_title DESC
LIMIT 5;
```
|title|avg_salary_per_title|
|---|----|
|Senior Staff|80706|
|Manager|77724|
|Senior Engineer|70823|
|Technique Leader|67507|
|Staff|67331|

<br>

* Department
```sql
SELECT
  dept_name,
  -- To nearest dollar (round defaults to zero)
  ROUND(AVG(amount)) AS avg_salary_per_dept
FROM current_join_table
GROUP BY dept_name
ORDER BY avg_salary_per_dept DESC
LIMIT 5;
```
|dept_name|avg_salary_per_dept|
|----|----|
|Sales|88853|
|Marketing|80059|
|Finance|78560|
|Research|67913|
|Production|67843|

<br>

* Gender
```sql
-- Avg Salary by Gender
SELECT
  gender,
  -- To nearest dollar (round defaults to zero)
  ROUND(AVG(amount)) AS avg_salary_per_gender
FROM current_join_table
GROUP BY gender
ORDER BY avg_salary_per_gender DESC
LIMIT 5;
```
|gender|avg_salary_per_gender|
|----|-----|
|M|72045|
|F|71964|

<br>

Using the outputs or scripts from the above - answer the following questions:

* What is the average salary of someone in the Production department?
```sql
-- Find Distinct Names 
SELECT DISTINCT(dept_name) 
FROM current_join_table 
WHERE (dept_name LIKE '%Prod%' OR dept_name LIKE '%prod%' OR dept_name LIKE '%PROD%');

-- Just returns Production
SELECT
  dept_name,
  ROUND(AVG(amount),0) as average_salary
FROM current_join_table
WHERE dept_name = 'Production'
GROUP BY dept_name;
```
|dept_name|average_salary|
|-----|-----|
|Production|67843|

<br>

* Which position has the highest average salary?
```sql
SELECT
  title,
  ROUND(AVG(amount),0) AS position_avg_salary
FROM current_join_table
GROUP BY title
ORDER BY position_avg_salary DESC
LIMIT 5;
```
|title|position_avg_salary|
|----|-----|
|Senior Staff|80706|
|Manager|77724|
|Senior Engineer|70823|
|Technique Leader|67507|
|Staff|67331|

<br>

* Which department has the lowest average salary?
```sql
-- Which department has the lowest average salary?
SELECT
  dept_name,
  ROUND(AVG(amount),0) as average_dept_salary
FROM current_join_table
GROUP BY dept_name
ORDER BY average_dept_salary
LIMIT 5;
```
|dept_name|average_dept_salary
|-----|-----|
|Human Resources|63922|
|Quality Management|65442|
|Customer Service|67285|
|Development|67658|
|Production|67843|

<br>

### `Average Salary Increase`
One of the current reporting dashboards insights that we need to generate is the average latest payrise percentage split by gender.

Since we already have the gender records directly in our current join table - we just need to calculate the difference in salary so we can calculate our percentage difference.

We can employ one of our trusty window function tools to solve this problem - `LAG`

Firstly - let’s prototype our solution with just the salary table for our favourite employee Georgi. Since we only need to have a single record with the `employee_id` record so we can join back onto our current snapshot view - we can apply the same to_date filter to make sure we capture the latest records and the LAG salary amount for our calculations:

Do you remember why we can’t use the WHERE filter directly without the CTE step below?

```sql
WITH lag_data AS (
SELECT
  employee_id,
  to_date,
  amount AS current_amount,
  -- The secondary where clause makes the partition a bit meaningless but likely logic to use later down the line which we'll then for certain want to group by
  LAG(amount) OVER (PARTITION BY employee_id ORDER BY to_date) AS previous_amount
FROM mv_employees.salary
WHERE employee_id = 10001
)
SELECT
  employee_id,
  current_amount - previous_amount AS salary_amount_change,
  100 * (current_amount - previous_amount) / previous_amount::NUMERIC AS salary_pc_change
FROM lag_data
WHERE to_date = '9999-01-01';
```
|employee_id|salary_amount_change|salary_pc_change|
|----|-----|-----|
|10001|3861|4.5371752235683984|

We will re-use this logic once we compile our entire SQL solution in the following tutorial - now let’s move onto the juicy part of this tutorial, Now that we’ve tackled how to easily obtain the current snapshot data - let’s now move our attention to the employee deep dive.

---

<br>

## Historic Views
One of the shortfalls of the current snapshot view is that we won’t be able to inspect the full history of a certain employee that we need for our second case study output. We will need to improve upon our existing SQL join to incorporate these historic data points for all our employees in the dataset.

We will need to populate the various events that have occured for each employee to show the timeline view on the left as well compare our target employee’s details to the average benchmark for their tenure, position/title, department and gender, as well as obtaining who their current manager is.


#### `Approach`
Let’s split up our analysis into a few steps so we can better understand the process for generating our historic data view.

1. Identify the current details required in the deep dive report:
- Name, gender, age, birthday, company tenure
  - Department name, department tenure, department manager
  - Salary amount

2. Perform comparison calculations for the following:
- Latest salary change (this should be the same as the current company metric too)
  - Salary comparison by tenure, position/title, department and gender benchmarks (remember the exercise question?)

3. The last 5 employee events - we’ll need to identify the following types of events:
- Salary increase/decrease with the new salary amount, $ change amount and percentage change
  - Title change from old to new title
  - Department transfer from old to new department name
  - Reporting Line Change from old to new manager (not shown in the template!)

<br>

### **Effective Expiry**
Up until now we’ve been dealing with all of the `from_date` and `to_date` columns separately for our salary, department_employee and title materialized views as we’ve only needed to apply the final basic filter of WHERE to_date = '9999-01-01' to identify the final current record for our records.

However for this challenge - we will need to clearly split out when each event occurs and also clearly capture the state of all the other metrics to validate that nothing else has changed.

Honestly - the first time I was faced with similar problems in the workplace I was in a state of total confusion because I had no idea what to do!

For this example - the easiest way would be to investigate a single customer and figure out exactly what happened for them - before coming up with new effective and expiry date columns to capture the overall validity of each record.

Let’s revisit our new employee spotlight Leah!

#### `Leah’s Events`
If we were to capture all of Georgi’s data using the simple naive join method - it will mean we will show all of his records.

Let’s explicitly only select the following columns to narrow our focus:

- title, title_from_date, title_to_date
- amount, salary_from_date, salary_to_date
- dept_name, dept_from_date and dept_to_date

```sql
SELECT
  title,
  title_from_date,
  title_to_date,
  amount,
  salary_from_date,
  salary_to_date,
  dept_name,
  dept_from_date,
  dept_to_date
FROM naive_join_table
WHERE id = 11669
ORDER BY
  title_to_date DESC,
  dept_to_date DESC,
  salary_to_date DESC;
```

|title|title_from_date|title_to_date|amount|salary_from_date|salary_to_date|dept_name|dept_from_date|dept_to_date|
|-----|----|-----|-----|-----|-----|-----|-----|-----|
|Senior Engineer|2020-05-12|9999-01-01|47373|2020-05-11|9999-01-01|Customer Service|2019-06-12|9999-01-01|
|Senior Engineer|2020-05-12|9999-01-01|47046|2019-05-11|2020-05-11|Customer Service|2019-06-12|9999-01-01|
|Senior Engineer|2020-05-12|9999-01-01|43681|2018-05-11|2019-05-11|Customer Service|2019-06-12|9999-01-01|
|Senior Engineer|2020-05-12|9999-01-01|43930|2017-05-12|2018-05-11|Customer Service|2019-06-12|9999-01-01|
|Senior Engineer|2020-05-12|9999-01-01|43577|2016-05-12|2017-05-12|Customer Service|2019-06-12|9999-01-01|
|Senior Engineer|2020-05-12|9999-01-01|41183|2015-05-12|2016-05-12|Customer Service|2019-06-12|9999-01-01|
|Senior Engineer|2020-05-12|9999-01-01|47373|2020-05-11|9999-01-01|Production|2015-05-12|2019-06-12|
|Senior Engineer|2020-05-12|9999-01-01|47046|2019-05-11|2020-05-11|Production|2015-05-12|2019-06-12|
|Senior Engineer|2020-05-12|9999-01-01|43681|2018-05-11|2019-05-11|Production|2015-05-12|2019-06-12|
|Senior Engineer|2020-05-12|9999-01-01|43930|2017-05-12|2018-05-11|Production|2015-05-12|2019-06-12|
|Senior Engineer|2020-05-12|9999-01-01|43577|2016-05-12|2017-05-12|Production|2015-05-12|2019-06-12|
|Senior Engineer|2020-05-12|9999-01-01|41183|2015-05-12|2016-05-12|Production|2015-05-12|2019-06-12|
|Engineer|2015-05-12|2020-05-12|47373|2020-05-11|9999-01-01|Customer Service|2019-06-12|9999-01-01|
|Engineer|2015-05-12|2020-05-12|47046|2019-05-11|2020-05-11|Customer Service|2019-06-12|9999-01-01|
|Engineer|2015-05-12|2020-05-12|43681|2018-05-11|2019-05-11|Customer Service|2019-06-12|9999-01-01|

* Cut off here but we get the idea

Here we can see very clearly there are basic separations between Leah’s company activity based off the way we’ve sorted the data:

1. Leah had a title change from Engineer to Senior Engineer starting from 2020-05-12
2. She also had salary changes in May from 2015 each year through to 2020 with his latest increase on the 2020-05-11 from $47,046 to $47,373
3. She changed departments from Productuction to Customer Service on 2019-06-12

So our challenge is - how can we perform this same analysis using only SQL and not needing to do these manual steps?

Additionally - there are going to be a ton of redundant unnecessary data points which are not valid, what sort of filter can we apply to remove these records in a similar way that we removed all our non-current records in the current snapshot view?

There is one logical leap that we need to do in order to solve both of these problem - we’ll need to perform some row-wise operations on the date columns!

<br>

### **Row-wise Date Calculations**
This is actually a difficult concept to grasp at first - but we will want to perform MAX and MIN calculations on the from_date and to_date columns in order to calculate the latest and earliest effective and expiry dates respectively for each row of data.

However - we can’t really do this with multiple column inputs into the MAX and MIN functions - instead we will need to use their rowwise equivalent functions GREATEST and LEAST

This is best explained by inspecting a few example rows from the different cases:

#### `Current Data Points`
Scenario 1 is the most current valid data point with to_date = '9999-01-01' but different from_date columns for title, salary and department.

|title|title_from_date|title_to_date|amount|salary_from_date|salary_to_date|dept_name|dept_from_date|dept_to_date|
|-----|-----|-----|----|----|----|----|----|------|
|Senior Engineer|2020-05-12|9999-01-01|47373|2020-05-11 00:00:00|9999-01-01|Customer Service|2019-06-12|9999-01-01|

Here we actually want to take the latest `from_date` as logically - it is the most recent point in time where all of these data points were valid. We can think of this calculation as calculating the **latest effective date**.

Naturally - the expiry date for this specific data point will be the 9999-01-01 as it is all equal in the `to_date` column values.

```sql
SELECT
  title,
  dept_name,
  amount,
  -- Latest Effective Date (Most Recent)
  GREATEST(
    title_from_date,
    salary_from_date,
    dept_from_date
  ) AS effective_date,
  LEAST(
    title_to_date,
    salary_to_date,
    dept_to_date
  ) AS expiry_date,
  title_from_date,
  salary_from_date,
  dept_from_date,
  title_to_date,
  salary_to_date,
  dept_to_date
FROM naive_join_table
WHERE id = 11669
  AND title_to_date = '9999-01-01'
  AND dept_to_date = '9999-01-01'
  AND salary_to_date = '9999-01-01';
```
|title|dept_name|amount|effective_date|expiry_date|title_from_date|salary_from_date|dept_from_date|title_to_date|salary_to_date|dept_to_date|
|----|-----|-----|-----|-----|------|-----|-----|-----|----|---|
|Senior Engineer|Customer Service|47373|2020-05-12|9999-01-01|2020-05-12|2020-05-11|2019-06-12|9999-01-01|9999-01-01|9999-01-01|

* If we now apply the same logic to all of the records and not just those with the to_date = '9999-01-01' record - we can start identifying the next filter logic we need to apply.

<br>

### **All Data Points** 
If we simply remove the WHERE filters on the dates we had in our previous query - we’ll be able to see a few more rows of data from Leah’s records.

Additionally if we think about our effective and expiry paradigm - we shouldn’t have have any records where the effective date is after the expiry date, if we now apply this filter and then order by our effective_date field - we can see if we need to apply any further filters to our analysis.

```sql
SELECT * FROM (
  SELECT
    title,
    dept_name,
    amount,
    GREATEST(
      title_from_date,
      salary_from_date,
      dept_from_date
    ) AS effective_date,
    LEAST(
      title_to_date,
      salary_to_date,
      dept_to_date
    ) AS expiry_date,
    title_from_date,
    salary_from_date,
    dept_from_date,
    title_to_date,
    salary_to_date,
    dept_to_date
  FROM naive_join_table
  WHERE
    id = 11669
) subquery
WHERE effective_date <= expiry_date
ORDER BY effective_date;
```
|title|dept_name|amount|effective_date|expiry_date|title_from_date|salary_from_date|dept_from_date|title_to_date|salary_to_date|dept_to_date|
|----|-----|-----|-----|-----|----|----|----|-----|-----|-----|
|Engineer|Production|41183|2015-05-12|2016-05-12|2015-05-12|2015-05-12|2015-05-12|2020-05-12|2016-05-12|2019-06-12|v
|Engineer|Production|43577|2016-05-12|2017-05-12|2015-05-12|2016-05-12|2015-05-12|2020-05-12|2017-05-12|2019-06-12|
|Engineer|Production|43930|2017-05-12|2018-05-11|2015-05-12|2017-05-12|2015-05-12|2020-05-12|2018-05-11|2019-06-12|
|Engineer|Production|43681|2018-05-11|2019-05-11|2015-05-12|2018-05-11|2015-05-12|2020-05-12|2019-05-11|2019-06-12|
|Engineer|Production|47046|2019-05-11|2019-06-12|2015-05-12|2019-05-11|2015-05-12|2020-05-12|2020-05-11|2019-06-12|
|Engineer|Customer Service|47046|2019-06-12|2020-05-11|2015-05-12|2019-05-11|2019-06-12|2020-05-12|2020-05-11|9999-01-01|
|Engineer|Customer Service|47373|2020-05-11|2020-05-12|2015-05-12|2020-05-11|2019-06-12|2020-05-12|9999-01-01|9999-01-01|
|Senior Engineer|Customer Service|47373|2020-05-12|9999-01-01|2020-05-12|2020-05-11|2019-06-12|9999-01-01|9999-01-01|9999-01-01|

* This looks great now and we can easily see that thereis a clear chronological order of events with no overlaps between the effective and expiry dates as we wanted!
* I'm interpreting the `GREATEST` AND `LEAST` here in tandem for sliding changing dimensions to extract the most recent `from_date` with **GREATEST** picking the most recent or "Greatest Date" from the provided 3 `from_dates` and pairing with the least recent or "LEAST" date for a `to_date`
* Now for each row instance, the most recent effective date of the 3 `from` (Pulled Greatest Date Field) could be ahead of the least recent expiration date of the 3 `to` (Pulled Least Date Field). See below for an example of how only one of the below rows was pulled 

#### `Flat Amount Value and Returned Values` : How above filtered
```sql
SELECT
    title,
    dept_name,
    amount,
    GREATEST(
      title_from_date,
      salary_from_date,
      dept_from_date
    ) AS effective_date,
    LEAST(
      title_to_date,
      salary_to_date,
      dept_to_date
    ) AS expiry_date,
    title_from_date,
    salary_from_date,
    dept_from_date,
    title_to_date,
    salary_to_date,
    dept_to_date
  FROM naive_join_table
  WHERE
    id = 11669
  AND amount = 41183
```
|title|dept_name|amount|effective_date|expirty_date|title_from_date|salary_from_date|dept_from_date|title_to_date|salary_to_date|dept_to_date|
|---|----|-----|----|-----|-----|----|----|-----|----|----|
|Senior Engineer|Production|41183|2020-05-12|2016-05-12|2020-05-12|2015-05-12|2015-05-12|9999-01-01|2016-05-12|2019-06-12|
|Senior Engineer|Customer Service|41183|2020-05-12|2016-05-12|2020-05-12|2015-05-12|2019-06-12|9999-01-01|2016-05-12|9999-01-01|
|Engineer|Production|41183|2015-05-12|2016-05-12|2015-05-12|2015-05-12|2015-05-12|2020-05-12|2016-05-12|2019-06-12|
|Engineer|Customer Service|41183|2019-06-12|2016-05-12|2015-05-12|2015-05-12|2019-06-12|2020-05-12|2016-05-12|9999-01-01|

* This particular value which we only see now once with our updated filter is attributed to pairing events that don't overlap (in time) with our table rows. In essence the greatest date associated to a `from` date for a change in either title, salary, or department would only want to be shown if the most historic "oldest" date in the `to` field is less than or equal to that change in the from field. 

Now we need to focus on our final piece of the puzzle for these events - how can we classify these events to match with our requested event types?

<br>

### **Logic Clauses**
For this section of the tutorial - we will need to apply some logic to identify what specific types of events occured for our employees after we’ve combined their data points and assigned the effective_date and expiry_date columns.

Let’s create an employee_events table with more information to simplify our analysis using the previous logic that we worked on with the GREATEST and LEAST functions calculated on each row with the WHERE effective_date <= expiry_date filter applied also:

```sql
DROP TABLE IF EXISTS employee_events;
CREATE TEMP TABLE employee_events AS
SELECT * FROM (
  SELECT
    id,
    title,
    dept_name,
    amount,
    GREATEST(
      title_from_date,
      salary_from_date,
      dept_from_date
    ) AS effective_date,
    LEAST(
      title_to_date,
      salary_to_date,
      dept_to_date
    ) AS expiry_date
  FROM naive_join_table
) subquery
WHERE effective_date <= expiry_date
ORDER BY effective_date;
```
* For this part - let’s revisit what sort of logical flags we need to apply again to define our events:

#### **Last Employee Events**
Last 5 Employee Events
* Salary Increase/Decrease
* $ Change Amount in Salary & Percentage Change
* Title change 
* Department Transfer
* Reporting Line Change from old to new manager 

<br>

### `Salary Events`
In the following example - we will implement the logic for the salary increase and decrease events before we tackle the other events.

For our `LAG` window function we will need to compare the amount again just like in our previous example - we just need to be careful with our PARTITION BY and ORDER BY clauses.

We will also use the LAG window function with a CASE WHEN so we can differentiate between an increase or decrease event by comparing the amount and the LAG(amount) values for each record - there is also one question - what do we do when the amount values are the same? I’m going to leave them as NULL for now - but see if you can figure out why before the next section.

```sql
WITH lag_data AS (
SELECT
  id,
  title,
  dept_name,
  amount,
-- we have `id` in our table not employee_id!
  LAG(amount) OVER (
    PARTITION BY id
    ORDER BY effective_date
  ) AS previous_amount,
  effective_date,
  expiry_date
FROM employee_events
-- we have `id` in our table not employee_id!
WHERE id = 11669
)
SELECT
  id,
  title,
  dept_name,
  amount,
  previous_amount,
  CASE
    WHEN amount > previous_amount
      THEN 'Salary Increase'
    WHEN amount < previous_amount
      THEN 'Salary Decrease'
    ELSE NULL
  END AS event_name,
  effective_date,
  expiry_date
FROM lag_data
ORDER BY effective_date;
```
![Lag Salary Events Case](images/SEvents_LAG.png)

See how the null values actually line up to other types of events - we can see that the final row is a change in title and the 3rd last row is a switch in department.

We can add more LAG fields into our lag_data CTE and use them in additional conditions on our CASE WHEN statement to identify these 2 events also - but before we do that, we don’t seem to have our department manager details in this cut of the data do we?
* LAG is defaulting to NULL currenlty without a second argument. Could likely use a `COALESCE` here to go through events to fill event_name not just in the case of a salary change

Let’s go and fix that first before we come back and apply our logic for the title and department transfers.

<br>

### **Manager Issues**
In our previous `naive_join_table` we omitted the department_manager view on purpose for this specific part!

This is slightly trickier than normal as we need to obtain the manager’s name for our final visual output - and the only place to get the first_name and last_name values are from the employee view.

```sql
SELECT * FROM mv_employees.department_manager LIMIT 5;
```
|employee_id|department_id|from_date|to_date|
|-----|----|-----|-----|
|110022|d001|2003-01-01|2009-10-01|
|110039|d001|2009-10-01|9999-01-01|
|110085|d002|2003-01-01|2007-12-17|
|110114|d002|2007-12-17|9999-01-01|
|110183|d003|2003-01-01|2010-03-21|

How can we refer to this same view when we’ve already using in our join conditions for our employees - effectively using it to base all of our analysis?

Simple - we just join onto it again! But this time we can join onto a different column to avoid duplicating our analysis.

Let’s add onto our previous **naive_join_table** logic with our `effective_date` and `expiry_date` components and then also add on our `department_manager` and another join onto the employee view to grab the name data.

Also we will concatenate first and last names to create a full_name column and also a manager column.

And let’s throw in the LAG values for our `amount`, `title`, `dept_name` and `manager_name` columns:

```sql
DROP TABLE IF EXISTS historic_join_table;
CREATE TEMP TABLE historic_join_table AS
WITH join_data AS (
SELECT
  employee.id AS employee_id,
  employee.birth_date,
  CONCAT_WS(' ', employee.first_name, employee.last_name) AS full_name,
  employee.gender,
  employee.hire_date,
  title.title,
  salary.amount AS salary,
  department.dept_name AS department,
  -- use the `manager` aliased version of employee table for manager
  CONCAT_WS(' ', manager.first_name, manager.last_name) AS manager,
  GREATEST(
    title.from_date,
    salary.from_date,
    department_employee.from_date,
    department_manager.from_date
  ) AS effective_date,
  LEAST(
    title.to_date,
    salary.to_date,
    department_employee.to_date,
    department_manager.to_date
  ) AS expiry_date
FROM mv_employees.employee
INNER JOIN mv_employees.title
  ON employee.id = title.employee_id
INNER JOIN mv_employees.salary
  ON employee.id = salary.employee_id
INNER JOIN mv_employees.department_employee
  ON employee.id = department_employee.employee_id
-- NOTE: department is joined only to the department_employee table!
INNER JOIN mv_employees.department
  ON department_employee.department_id = department.id
-- add in the department_manager information onto the department table
INNER JOIN mv_employees.department_manager
  ON department.id = department_manager.department_id
-- join again on the employee_id field to another employee for manager's info
INNER JOIN mv_employees.employee AS manager
  ON department_manager.employee_id = manager.id
)
SELECT
  employee_id,
  birth_date,
  full_name,
  gender,
  hire_date,
  title,
  LAG(title) OVER w AS previous_title,
  salary,
  LAG(salary) OVER w AS previous_salary,
  department,
  LAG(department) OVER w AS previous_department,
  manager,
  LAG(manager) OVER w AS previous_manager,
  effective_date,
  expiry_date
FROM join_data
WHERE effective_date <= expiry_date
-- define window frame
WINDOW
  w AS (PARTITION BY employee_id ORDER BY effective_date);


-- Sample employee
SELECT *
FROM historic_join_table
WHERE employee_id = 11669
ORDER BY effective_date;
```
|employee_id|birth_date|full_name|gender|hire_date|title|previous_title|salary|previous_salary|department|previous_department|manager|previous_manager|effective_date|expiry_date|
|----|----|-----|-----|-----|----|----|----|----|----|---|--|---|----|-----|
|11669|1975-03-03|Leah Anguita|M|2004-04-07|Engineer|null|41183|null|Production|null|Oscar Ghazalie|null|2015-05-12|2016-05-12|
|11669|1975-03-03|Leah Anguita|M|2004-04-07|Engineer|Engineer|43577|41183|Production|Production|Oscar Ghazalie|Oscar Ghazalie|2016-05-12|2017-05-12|
|11669|1975-03-03|Leah Anguita|M|2004-04-07|Engineer|Engineer|43930|43577|Production|Production|Oscar Ghazalie|Oscar Ghazalie|	2017-05-12|2018-05-11|


* More rows but above is the picture

---

<br>

### `Summary`
In this tutorial we covered the following:

1. Identify and recreate original indexes for materialized views using the pg_indexes table
2. Compare current and historic values for our SCD (slow changing dimension) tables
3. Naively join our tables and apply a WHERE filter to extract current values with to_date = '9999-01-01'
4. Use LAG window function to compare previous records for changing information
5. Use rowwise GREATEST and LEAST functions to calculate effective and expiry dates for each record in our join tables
6. Use CASE WHEN statements to identify employee events based off changing lag values
7. Join onto 2 instances of the employee materialized view to obtain manager information without introducing duplicates


Notice how throughout this tutorial - we have been creating temporary tables instead of using views - this will be implemented properly in the next tutorial as we cover the final SQL solution in a portfolio project style!