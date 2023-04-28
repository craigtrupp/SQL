## HR Analytics Case Study Solution

<br>

### **Problem - Task Revisit**
* Generate reusable data assets to power 2 of their client HR analytic tools
* Database Views that the team can use for 2 key dashboards, reporting solutions and ad-hoc analytics requests
* `Reminder`
    - Previous Data Exploration has exposed the presence of data issues w/our datasets where data-entry issues looks to have incorrectly listed the date values

<br>

### `Required Insights`
#### **CompanyLevel**
* Current snapshot of all the data as well as a split by gender specifially:
    - Total # of employees
    - Average company tenure (in years)
    - Average latest payrise percentage
    - Statistical metrics for salary values including : (MIN, MAX, STDDEV, IQR, MED)

#### **Department Level**
* All metrics as per the company (above) but at department level, including an additional department level tenure metrics split by gender

#### **Title Level**
* Similar to department level metrics but instead, at a title level of granularity
* Also need to generate similar insights for both department and title levels where we need employee count and average tenure for each level instead of company wide numbers.

<br>

### `Employee Deep Dive`
The following insights must be generated for the Employee Deep Dive tool that can spotlight recent events for a single employee over time:

* See all the various employment history ordered by effective date including salary, department, manager and title changes
* Calculate previous historic payrise percentages and value changes
* Calculate the previous position and department history in months with start and end dates
* Compare an employee’s current salary, total company tenure, department, position and gender to the average benchmarks for their current position
* **Reminder** : SCD for date events and capturing slowly changing dimensions 

<br>

### `Visual Outputs`
### **Current Snapshot Reporting**
![Current Snapshot](images/FOutput_1.png)
![Current Snapshot](images/FOutput2.png)

<br>

### **Historic Employee Deep Dive**
![Emp Deep Dive 1](images/Emp1.png)
![Emp Deep Dive 2](images/Emp2.png)

---

<br>

## **Exploration**
* Quick Revisit of the provided data as we start breaking down the approach to solve the case study program

<br>

### ERD
* All available data within the `employees` schema and contains information about a company HR Analytica is supporting with it bespoke (custom-made) analytical tools

![ERD](images/ERD_PAnalytics.png)

<br>

### Data Exploration
Since we’ve been alerted to the presence of data issues for all date related fields - we will need to inspect each table to see what adjustments we need to make.

Additionally - we will start profiling all of our available tables to see how we can join them for our complete analytical solution.

From our initial inspection of the ERD - it also seems like there are slow changing dimension tables as we can see from_date and to_date columns for some tables.

Firstly let’s explore the available indexes from the employees schema before moving onto individual tables

#### **Table Indexes**
* can query our tables and their index info by accessing the `pg_indexes`
```sql
SELECT *
FROM pg_indexes
WHERE schemaname = 'employees';
```
|schemaname|tablename|indexname|tablespace|indexdef|
|---|----|----|----|-----|
|employees|employee|idx_16988_primary|null|CREATE UNIQUE INDEX idx_16988_primary ON employees.employee USING btree (id)|
|employees|department_employee|idx_16982_primary|null|CREATE UNIQUE INDEX idx_16982_primary ON employees.department_employee USING btree (employee_id, department_id)|
|employees|department_employee|idx_16982_dept_no|null|CREATE INDEX idx_16982_dept_no ON employees.department_employee USING btree (department_id)|
|employees|department|idx_16979_primary|null|CREATE UNIQUE INDEX idx_16979_primary ON employees.department USING btree (id)|
|employees|department|idx_16979_dept_name|null|CREATE UNIQUE INDEX idx_16979_dept_name ON employees.department USING btree (dept_name)|
|employees|department_manager|idx_16985_primary|null|CREATE UNIQUE INDEX idx_16985_primary ON employees.department_manager USING btree (employee_id, department_id)|
|employees|department_manager|idx_16985_dept_no|null|CREATE INDEX idx_16985_dept_no ON employees.department_manager USING btree (department_id)|
|employees|salary|idx_16991_primary|null|CREATE UNIQUE INDEX idx_16991_primary ON employees.salary USING btree (employee_id, from_date)|
|employees|title|idx_16994_primary|null|CREATE UNIQUE INDEX idx_16994_primary ON employees.title USING btree (employee_id, title, from_date)|


`Index Review`

In the above output we can see that there seems to be **unique** indexes on most available tables.

The following tables seem to have unique indexes on a single column:
- employees.employee
- employees.department

The rest of the tables seem to have multiple records for the employee_id values based off the indexes:
- employees.department_employee
- employees.department_manager
- employees.salary
- employees.title

Let’s start by analysing the single column index columns before we move onto the other tables below.

<br>

### **Individual Table Analysis**
* Historical tables all have `from_date` and `to_date` records signaling historical slow changing dimension style rows/data
* Tables show the relationship between `employee_id` and specific information for certain periods of time defined the by `from_date` and `to_date` with the **arbitrary** end date of 9999-01-01

<br>

#### `Employee`
* ERD Highlights
* Columns : [birth_date, gender, first name, last name, hire_date]

```sql
SELECT *
FROM employees.employee
LIMIT 2; 
```
|id|birth_date|first_name|last_name|gender|hire_date|
|---|----|---|----|----|----|
|10001|1953-09-02|Georgi|Facello|M|1986-06-26|
|10002|1964-06-02|Bezalel|Simmel|F|1985-11-21|

* Next let’s confirm that there is indeed only a single record per employee record as implied by the index:

```sql
WITH id_emp_cte AS (
    SELECT
        id,
        COUNT(*) AS emp_row_count
    FROM employees.employee
    GROUP BY id
)
-- group by returned aggregate value alias which will indicate how many rows (total unique id rows in employees from above) have the same unique count
-- alias references how many employees have x or n amounts of row in employee
SELECT 
  emp_row_count,
  COUNT(*) AS emp_w_n_counts
FROM id_emp_cte
GROUP BY emp_row_count
ORDER BY emp_w_n_counts;
```
|emp_row_count|emp_w_n_counts|
|---|---|
|1|300024|

* `Reminder`: Our initial hypothesis is that not all of our employees will exist in our other tables as there should be natural employee churn for any company - let’s keep this in mind as we continue with our data exploration.

<br>

#### `Department`
* The `employees.department table` is our other single column unique index table that contains unique id records for each dept_name - there are 9 unique departments.

```sql
SELECT
    DISTINCT(id) AS unique_departments,
    dept_name,
    (SELECT DISTINCT(COUNT(id)) FROM employees.department) AS distinct_total_count
FROM employees.department;
```
|unique_departments|dept_name|distinct_total_count|
|----|-----|----|
|d002|Finance|9|
|d009|Customer Service|9
|d008|Research|9|
|d001|Marketing|9|
|d004|Production|9|
|d003|Human Resources|9|
|d006|Quality Management|9|
|d005|Development|9|
|d007|Sales|9|

<br>

#### `Department_Employee`
Going by alphabetical order - our first historic table for analysis is `employees.department_employee`

This table shows which department employees were assigned to over time, with a new row for each updated scenario at an employee level.
```sql
SELECT *
FROM employees.department_employee
LIMIT 2;
```
|employee_id|department_id|from_date|to_date|
|----|----|-----|----|
|10001|d005|1986-06-26|9999-01-01|
|10002|d007|1996-08-03|9999-01-01|

* We can see that there only seems to be to_date = '9999-01-01' in our sample records - let’s investigate the distribution of this to_date column:

```sql
SELECT
    to_date,
    COUNT(*) as to_date_record_count
FROM employees.department_employee
GROUP BY to_date
HAVING COUNT(*) >= 25
ORDER BY to_date_record_count DESC
LIMIT 5;
```
|to_date|to_date_record_count|
|---|----|
|9999-01-01|240124|
|2000-04-14|48|
|2000-03-29|46|
|2001-02-10|46|
|1999-12-06|45|

From this initial view - we can see that the majority of values seem to “current” with the arbitrary 9999-01-01 date value.

We will need to leave this date value as is when we are adding our fixes to the date input error that we mentioned before.

Let’s also confirm that we also have a `many-to-one` relationship between this table and its `employee_id` field to help with our table joining efforts:
```sql
WITH dept_uniq_emp_counts AS (
  SELECT
    employee_id,
    COUNT(*) AS employee_dept_counts
  FROM employees.department_employee
  GROUP BY employee_id
)
-- see how many employees have more than 1 row instance within the one (employee) to many (dept_employee) inferred relationship
SELECT
  employee_dept_counts,
  COUNT(*) AS emps_with_n_counts
FROM dept_uniq_emp_counts
GROUP BY employee_dept_counts
ORDER BY employee_dept_counts DESC;

-- similar approach : same output - believe COUNT(DISTINCT) is giving how many unique ids appeared X amount of times
WITH employee_id_cte AS (
SELECT
  employee_id,
  COUNT(*) AS row_count
FROM employees.department_employee
GROUP BY employee_id
)
SELECT
  row_count,
  COUNT(DISTINCT employee_id) AS employee_count
FROM employee_id_cte
GROUP BY row_count
ORDER BY row_count DESC;
```
|row_count|employee_count|
|----|-----|
|2|31579|
|1|268445|

* We see it's still more common for employees to stay in the same department but there is rotation for employees being in different departments

* There is roughly 10% of rows with 2 records - this should introduce multiple records per employee_id match when we are performing table joins.

<br>

#### `Department Manager`
```sql
SELECT *
FROM employees.department_manager
LIMIT 5
```
|employee_id|department_id|from_date|to_date|
|-----|-----|-----|----|
|110022|d001|1985-01-01|1991-10-01|
|110039|d001|1991-10-01|9999-01-01|
|110085|d002|1985-01-01|1989-12-17|
|110114|d002|1989-12-17|9999-01-01|
|110183|d003|1985-01-01|1992-03-21|

* Let’s also investigate the distribution of this to_date column to see how many records are valid for the current period:
```sql
SELECT
  to_date,
  COUNT(*) AS record_count
FROM employees.department_manager
GROUP BY to_date
ORDER BY record_count DESC
LIMIT 5;
```
|to_date|record_count|
|----|-----|
|9999-01-01|9|
|1994-06-28|1|
|1991-09-12|1|
|1992-04-25|1|
|1991-03-07|1|

* Here we can see that there is vastly **less movement** for department managers as opposed to the **department employees** - there are still `9` relevant current records which matches up to how many `unique departments` there are based off our employees.department table analysis.


* Let’s again confirm how many rows we have per `employee_id`:
```sql
WITH employee_id_cte AS (
SELECT
  employee_id,
  COUNT(*) AS row_count
FROM employees.department_manager
GROUP BY employee_id
)
SELECT
  row_count,
  COUNT(DISTINCT employee_id) AS employee_count
FROM employee_id_cte
GROUP BY row_count
ORDER BY row_count DESC;
```
|row_count|employee_count|
|---|---|
|1|24|

* Here we can see that each `employee_id` that appears in the `employees.department_manager` table will only have a single record or a **one-to-one** relationship.
* Would assume an update or UPSERT type statmenet for any revoling department manager periods

<br>

#### `Salary`
The `employees.salary` table houses each employees salary over time - this is a key table for much of our analysis.

* Let’s investigate the records for a single employee with employee_id = 10001 in reverse chronological order with the most recent row first

```sql
SELECT *
FROM employees.salary
WHERE employee_id = 10001
ORDER BY from_date DESC;
```
|employee_id|amount|from_date|to_date|
|----|----|----|---|
|10001|88958|2002-06-22|9999-01-01|
|10001|85097|2001-06-22|2002-06-22|
|10001|85112|2000-06-22|2001-06-22|
|10001|84917|1999-06-23|2000-06-22|
|10001|81097|1998-06-23|1999-06-23|

* Let’s again investigate the distribution of the to_date column:
```sql
SELECT
  to_date,
  COUNT(*) AS record_count,
  COUNT(DISTINCT employee_id) AS employee_count
FROM mv_employees.salary
GROUP BY 1
ORDER BY 1 DESC
LIMIT 5;
```
|to_date|record_count|employee_count|
|----|-----|-----|
|9999-01-01|240124|240124|
|2020-08-01|686|686|
|2020-07-31|641|641|
|2020-07-30|673|673|
|2020-07-29|679|679|


```sql
-- Let’s also profile this table by the employee_id to see how many duplicates we should be expecting in our joins:
WITH emp_salary_counts AS (
  SELECT
    employee_id,
    COUNT(*) AS emp_counts
  FROM employees.salary
  GROUP BY employee_id
)
SELECT
  emp_counts AS total_salary_emp_counts,
  COUNT(*) AS total_salary_adjs,
  COUNT(DISTINCT employee_id) AS total_unique_employee_salary_changes
FROM emp_salary_counts
GROUP BY emp_counts
ORDER BY emp_counts DESC
LIMIT 5;
```
|total_salary_emp_counts|total_salary_adjs|total_unique_employee_salary_changes|
|----|-----|-----|
|18|8180|8180|
|17|16106|16106|
|16|16331|16331|
|15|16799|16799|
|14|17193|17193|

* The majority of employee records in this salary table will have more than 1 record so we should be careful when joining this table with the others.

<br>

#### `Title`
The `employees.title` table is our final one and should contain a similar historical record of all the different titles an employee has held throughout their tenure with the company.
```sql
SELECT *
FROM employees.title
LIMIT 5;
```
|employee_id|title|from_date|to_date|
|----|----|----|-----|
|10001|Senior Engineer|1986-06-26|9999-01-01|
|10002|Staff|1996-08-03|9999-01-01|
|10003|Senior Engineer|1995-12-03|9999-01-01|
|10004|Engineer|1986-12-01|1995-12-01|
|10004|Senior Engineer|1995-12-01|9999-01-01|

* We should expect similar numbers for the distribution by the to_date column also:
```sql
SELECT
  to_date,
  COUNT(*) AS record_count,
  COUNT(DISTINCT employee_id) AS employee_count
FROM mv_employees.title
GROUP BY 1
ORDER BY 1 DESC
LIMIT 5
```
|to_date|record_count|employee_count|
|-----|----|-----|
|9999-01-01|240124|240124|
|2020-08-01|40|40|
|2020-07-31|65|65|
|2020-07-30|53|53|
|2020-07-29|52|52|

* And finally let’s also confirm that we have multiple rows for each employee_id record in a many-to-one relationship.
```sql
WITH employee_id_cte AS (
SELECT
 employee_id,
 COUNT(*) AS row_count
FROM employees.title
GROUP BY employee_id
)
SELECT
 row_count,
 COUNT(DISTINCT employee_id) AS employee_count
FROM employee_id_cte
GROUP BY row_count
ORDER BY row_count DESC;
```
|row_count|employee_count|
|---|----|
|3|3014|
|2|137256|
|1|159754|

* In the above output - we can see that close to 50% of employees have only held a single title with a little over 3,000 having at most 3 different titles.

---

<br>

## **Analysis**
For our complete SQL solution we will need to split up components into the following parts:

1. Data Cleaning & Date Adjustments
2. Current Snaphsot Analysis
3. Historical Analysis

Finally we will generate the required data points for each of the sample visual outputs we’ve received from HR Analytica.

The key aspect of our entire SQL analysis will be to generate a completely reusable data asset in the form of multiple analytical views for the HR Analytica team to consume.

All of our analytical outptus will be generated in an entirely new view schema called `mv_employees` which will be refered to throughout our SQL code snippets and the final complete SQL script.

Let’s first start with the data cleaning component to adjust the dates and fix the date data issues.

<br>

### `Data Cleaning`
Firstly - we will need to adjust all of our relevant date fields due to the data issue identified by HR Analytica.

We will be incrementing all of the date fields except the arbitrary end date of 9999-01-01 - we will also need to cast our results back to a `DATE` data type as PostgreSQL interval addition forces the data type to a TIMESTAMP which we’d like to avoid to keep our data as similar to the original as possible.

To account for future updates and to maximise the efficiency and productivity for the HR Analytica team - we will be implementing our adjusted datasets as `materialized views` with **exact original indexes** as per the original tables in the employees schema.

```sql
-- Recall CASCADE call for removal full inclusion
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

<br>

### `Current Snapshot Analysis`
For our current company, department and title level dashboard outputs we will first create a current snapshot view which we will use as the base for each of the aggregated layers for the different dashboard outputs

#### **Analysis Plan**

Let’s start by listing out the steps we need to include for our granular current snapshot:

1. Apply LAG window functions on the salary materialized view to obtain the latest previous_salary value, keeping only current valid records with to_date = '9999-01-01'
2. Join previous salary and all other required information from the materialized views for the dashboard analysis (omitting the department_manager view)
3. Apply WHERE filter to keep only current records
4. Make sure to include the gender column from the employee view for all calculations
5. Use the hire_date column from the employee view to calculate the number of tenure years
6. Include the from_date columns from the title and department are included to calculate tenure
7. Use the salary table to calculate the current average salary
8. Include department and title information for additional group by aggregations
9. Implement the various statistical measures for the salary amount
10. Combine all of these elements into a single final current snapshot view

```sql
DROP VIEW IF EXISTS mv_employees.current_employee_snapshot CASCASDE;
CREATE VIEW mv_employees.current_employee_snapshot AS 
-- apply LAG to get previous salary amount for all employees
WITH cte_previous_salary AS (
    SELECT * FROM (
        SELECT 
            employee_id,
            to_date,
            LAG(amount, 1) OVER (
                PARTITION BY employee_id
                ORDER BY from_date
            ) AS amount
        FROM mv_employees.salary
    ) AS all_salaries
    -- keep only latest valid previous_salary records
    WHERE to_date = '9999-01-01'
),
-- combine all elements into a joined CTE
cte_joined_data AS (
    SELECT
        employee.id AS employee_id,
        employee.gender,
        employee.hire_date,
        title.title,
        salary.amount AS salary,
        -- referencing lag amount above for previous salary
        cte_previous_salary.amount AS previous_salary,
        department.dept_name AS department,
        -- need to keep the title and department from_date columns for tenure
        title.from_date AS title_from_date,
        department_employee.from_date AS department_from_date
  FROM mv_employees.employee
  INNER JOIN mv_employees.title
    ON employee.id = title.employee_id
  INNER JOIN mv_employees.salary
    ON employee.id = salary.employee_id
  -- join onto the CTE we created in the first step
  INNER JOIN cte_previous_salary
    ON employee.id = cte_previous_salary.employee_id
  INNER JOIN mv_employees.department_employee
    ON employee.id = department_employee.employee_id
  -- NOTE: department is joined only to the department_employee table!
  INNER JOIN mv_employees.department
    ON department_employee.department_id = department.id
  -- apply where filter to keep only relevant records
  WHERE salary.to_date = '9999-01-01'
    AND title.to_date = '9999-01-01'
    AND department_employee.to_date = '9999-01-01'
),
-- finally we can apply all our calculations in this final output
final_output AS (
  SELECT
    employee_id,
    gender,
    title,
    salary,
    department,
    -- salary change percentage
    ROUND(
      100 * (salary - previous_salary) / previous_salary::NUMERIC,
      2
    ) AS salary_percentage_change,
    -- tenure calculations
    DATE_PART('year', now()) -
      DATE_PART('year', hire_date) AS company_tenure_years,
    DATE_PART('year', now()) -
      DATE_PART('year', title_from_date) AS title_tenure_years,
    DATE_PART('year', now()) -
      DATE_PART('year', department_from_date) AS department_tenure_years
  FROM cte_joined_data
)
SELECT * FROM final_output LIMIT 3;
```
|employee_id|gender|title|salary|department|salary_percentage_change|company_tenure_years|title_tenure_years|department_tenure_years|
|----|----|----|----|----|----|----|----|-----|
|10001|M|Senior Engineer|88958|Development|4.54|17|17|17|
|10002|F|Staff|72527|Sales|0.78|18|7|7|
|10003|M|Senior Engineer|43311|Production|-0.89|17|8|8|

<br>

### **Dashboard Aggregation Views**
The next step is to perform different levels of aggregations to generate the required data outputs for each of the company, department and title level dashboards.

#### `Company Level`
```sql
-- company level aggregation view
DROP VIEW IF EXISTS mv_employees.company_level_dashboard;
CREATE VIEW mv_employees.company_level_dashboard AS
SELECT
  gender,
  COUNT(*) AS employee_count,
  -- SUM(COUNT(*)) - Total of all gender combined counts
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER ()) AS employee_percentage,
  ROUND(AVG(company_tenure_years)) AS company_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY gender;
```
```sql
-- look at dashboard grouped by gender using current_employee_snapshot view above
SELECT *
FROM mv_employees.company_level_dashboard;
```
|gender|employee_count|employee_percentage|company_tenure|avg_salary|avg_salary_percentage_change|min_salary|max_salary|median_salary|inter_quartile_range|stddev_salary|
|---|----|-----|----|----|---|----|----|---|----|-----|
|M|144114|60|13|72045|3|38623|158220|69830|23624|17363|
|F|96010|40|13|71964|3|38936|152710|69764|23326|17230|

<br>

#### `Department Level`
```sql
-- department level aggregation view
DROP VIEW IF EXISTS mv_employees.department_level_dashboard;
CREATE VIEW mv_employees.department_level_dashboard AS
SELECT
  gender,
  department,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY department
  )) AS employee_percentage,
  ROUND(AVG(department_tenure_years)) AS department_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, department;
```
```sql
SELECT *
FROM mv_employees.department_level_dashboard
LIMIT 5;
```
|gender|department|employee_count|employee_percentage|department_tenure|avg_salary|avg_salary_percentage_change|min_salary|max_salary|median_salary|inter_quartile_range|stddev_salary|
|---|----|----|----|----|-----|----|----|----|-----|-----|-----|
|M|Customer Service|10562|60|9|67203|3|39373|143950|65100|20097|15921|
|M|Development|36853|40|11|67713|3|39036|140784|66526|19664|14267|
|M|Finance|7423|60|11|78433|3|39012|142395|77526|24078|17242|
|M|Human Resources|7751|40|11|63777|3|39611|141953|62864|17607|12843|
|M|Marketing|8978|60|10|80293|3|39821|145128|79481|24990|17480|

<br>

#### `Title Level`
```sql
-- title level aggregation view
DROP VIEW IF EXISTS mv_employees.title_level_dashboard;
CREATE VIEW mv_employees.title_level_dashboard AS
SELECT
  gender,
  title,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY title
  )) AS employee_percentage,
  ROUND(AVG(title_tenure_years)) AS title_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, title;
```
```sql
SELECT *
FROM mv_employees.title_level_dashboard
LIMIT 5;
```
|gender|title|employee_count|employee_percentage|title_tenure|avg_salary|avg_salary_percentage_change|min_salary|max_salary|median_salary|inter_quartile_range|stddev_salary|
|----|---|----|----|----|----|---|---|---|----|----|-----|
|M|Assistant Engineer|2148|60|6|57198|4|39827|117636|54384|14972|11152|
|F|Assistant Engineer|1440|40|6|57496|4|39469|106340|55234|14679|10805|
|M|Engineer|18571|60|6|59593|4|38942|130939|56941|17311|12416|
|F|Engineer|12412|40|6|59617|4|39519|115444|57220|17223|12211|
|M|Manager|5|56|9|79351|2|56654|106491|72876|43242|23615|

<br>

### **Employee Historical Analysis**
For the historic employee deep dive analysis - we will need to split up our interim outputs into 3 parts:

1. Current Employee Information
- Full name
- Gender
- Birthday
- Department
- Title/Position tenure
- Company tenure
- Current salary
- Latest salary change percentage
- Manager name

2. Salary comparison to various benchmarks including:
- Company tenure
- Title/Position
- Department
- Gender

3. The last 5 historical employee events categorised into:
- Salary increase/decrease
- Department transfer
- Manager reporting line change
- Title changes

<br>

#### `Analysis Plan`
**Current Employee Information**

The current employee information is very similar to our previous `mv_employees.current_employee_snapshot` view we created - but with the addition of the manager information and the full name and birthday details.

For this step we will try to replace our previously created view to incorporate this new information.

By replacing the view using a `CREATE OR REPLACE` VIEW statement - we can avoid dropping our previously created derived views generated for each of the dashboards - saving us a bit of time!

In the final version of our complete SQL script we will be generating all of the views from scratch - but this is something useful to keep in mind when updating views, the only thing to take note of is that the column orders must be identical for the existing columns in the original view and any new columns must be placed afterwards.

**Salary Comparisons**

We will generate separate views based off the new updated mv_employees.current_employee_snapshot to generate baseline bencmarks for us to compare to our spotlighted eemployee.

**Employee Events**

We will need to generate a new historical view that incorporates all of the materialized views for our current snapshot - however we will further extend this by implementing additional `effective_date` and `expiry_date` columns to correctly capture the most accurate validitiy period for each record.

We will need to discard any invalid records which result from the join after applying the `GREATEST` and `LEAST` logic on our date fields instead of simply applying a WHERE filter to keep only the current records like we implemented for the current snapshot views.

We will also need to classify our events. To do this - we will use a `CASE WHEN` statement to accurately identify the types of events by comparing the salary, title, department and manager details with their LAG equivalent to check for changes.

We can also apply a `ROW_NUMBER` window function to keep only the latest 5 records by most recent `effective_date`

An important note on the employees who are no longer with the company:

Since we will have employee records present in our view who are no longer employed by the company - we can only compare their latest salary amount before leaving the company to the current benchmarks.

To simplify our SQL script - we will include a benchmark comparison for all employee salary records to the current benchmarks only for simplicity.

---

<br>

## **Report**
Finally let’s summarise the results of our analysis and compile a complete end to end SQL script we can use to recreate our entire workflow.

We will also regenerate the example data points provided for our visual examples for both the current and historic analysis components.

### `Final SQL Script`
The script is broken into 3 sections:

1. Create materialized views to fix date data issues
2. Current employee snapshot view
3. Aggregated dashboard views
4. Salary benchmark views
5. Historic employee deep dive view

```sql
/*---------------------------------------------------
1. Create materialized views to fix date data issues
----------------------------------------------------*/

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
CREATE UNIQUE INDEX ON mv_employees.employee USING btree (id);
CREATE UNIQUE INDEX ON mv_employees.department_employee USING btree (employee_id, department_id);
CREATE INDEX        ON mv_employees.department_employee USING btree (department_id);
CREATE UNIQUE INDEX ON mv_employees.department USING btree (id);
CREATE UNIQUE INDEX ON mv_employees.department USING btree (dept_name);
CREATE UNIQUE INDEX ON mv_employees.department_manager USING btree (employee_id, department_id);
CREATE INDEX        ON mv_employees.department_manager USING btree (department_id);
CREATE UNIQUE INDEX ON mv_employees.salary USING btree (employee_id, from_date);
CREATE UNIQUE INDEX ON mv_employees.title USING btree (employee_id, title, from_date);


/*-----------------------------------
2. Current employee snapshot view
-------------------------------------*/

DROP VIEW IF EXISTS mv_employees.current_employee_snapshot;
CREATE VIEW mv_employees.current_employee_snapshot AS
-- apply LAG to get previous salary amount for all employees
WITH cte_previous_salary AS (
  SELECT * FROM (
    SELECT
      employee_id,
      to_date,
      LAG(amount) OVER (
        PARTITION BY employee_id
        ORDER BY from_date
      ) AS amount
    FROM mv_employees.salary
  ) all_salaries
  -- keep only latest valid previous_salary records only
  -- must have this in subquery to account for execution order
  WHERE to_date = '9999-01-01'
),
-- combine all elements into a joined CTE
cte_joined_data AS (
  SELECT
    employee.id AS employee_id,
    -- include employee full name
    CONCAT_WS(' ', employee.first_name, employee.last_name) AS employee_name,
    employee.gender,
    employee.hire_date,
    title.title,
    salary.amount AS salary,
    cte_previous_salary.amount AS previous_salary,
    department.dept_name AS department,
    -- include manager full name
    CONCAT_WS(' ', manager.first_name, manager.last_name) AS manager,
    -- need to keep the title and department from_date columns for tenure calcs
    title.from_date AS title_from_date,
    department_employee.from_date AS department_from_date
  FROM mv_employees.employee
  INNER JOIN mv_employees.title
    ON employee.id = title.employee_id
  INNER JOIN mv_employees.salary
    ON employee.id = salary.employee_id
  -- join onto the CTE we created in the first step
  INNER JOIN cte_previous_salary
    ON employee.id = cte_previous_salary.employee_id
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
  -- apply where filter to keep only relevant records
  WHERE salary.to_date = '9999-01-01'
    AND title.to_date = '9999-01-01'
    AND department_employee.to_date = '9999-01-01'
    -- add in department_manager to_date column filter
    AND department_manager.to_date = '9999-01-01'
)
-- finally we can apply all our calculations in this final output
SELECT
  employee_id,
  employee_name,
  manager,
  gender,
  title,
  salary,
  department,
  -- salary change percentage
  ROUND(
    100 * (salary - previous_salary) / previous_salary::NUMERIC,
    2
  ) AS salary_percentage_change,
  -- tenure calculations
  DATE_PART('year', now()) -
    DATE_PART('year', hire_date) AS company_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', title_from_date) AS title_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', department_from_date) AS department_tenure_years
FROM cte_joined_data;


/*---------------------------
3. Aggregated dashboard views
-----------------------------*/

-- company level aggregation view
DROP VIEW IF EXISTS mv_employees.company_level_dashboard;
CREATE VIEW mv_employees.company_level_dashboard AS
SELECT
  gender,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER ()) AS employee_percentage,
  ROUND(AVG(company_tenure_years)) AS company_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY gender;

-- department level aggregation view
DROP VIEW IF EXISTS mv_employees.department_level_dashboard;
CREATE VIEW mv_employees.department_level_dashboard AS
SELECT
  gender,
  department,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY department
  )) AS employee_percentage,
  ROUND(AVG(department_tenure_years)) AS department_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, department;

-- title level aggregation view
DROP VIEW IF EXISTS mv_employees.title_level_dashboard;
CREATE VIEW mv_employees.title_level_dashboard AS
SELECT
  gender,
  title,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (
    PARTITION BY title
  )) AS employee_percentage,
  ROUND(AVG(title_tenure_years)) AS title_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change)) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY
  gender, title;


/*-----------------------
4. Salary Benchmark Views
-------------------------*/

-- Note the slightly verbose column names - this helps us avoid renaming later!

DROP VIEW IF EXISTS mv_employees.tenure_benchmark;
CREATE VIEW mv_employees.tenure_benchmark AS
SELECT
  company_tenure_years,
  AVG(salary) AS tenure_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY company_tenure_years;

DROP VIEW IF EXISTS mv_employees.gender_benchmark;
CREATE VIEW mv_employees.gender_benchmark AS
SELECT
  gender,
  AVG(salary) AS gender_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY gender;

DROP VIEW IF EXISTS mv_employees.department_benchmark;
CREATE VIEW mv_employees.department_benchmark AS
SELECT
  department,
  AVG(salary) AS department_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY department;

DROP VIEW IF EXISTS mv_employees.title_benchmark;
CREATE VIEW mv_employees.title_benchmark AS
SELECT
  title,
  AVG(salary) AS title_benchmark_salary
FROM mv_employees.current_employee_snapshot
GROUP BY title;


/*----------------------------------
5. Historic Employee Deep Dive View
-----------------------------------*/

-- drop cascade required as there is 1 derived view!
DROP VIEW IF EXISTS mv_employees.historic_employee_records CASCADE;
CREATE VIEW mv_employees.historic_employee_records AS
-- we need the previous salary only for the latest record
-- other salary increase/decrease events will use a different field!
WITH cte_previous_salary AS (
  SELECT
    employee_id,
    amount
  FROM (
    SELECT
      employee_id,
      to_date,
      LAG(amount) OVER (
        PARTITION BY employee_id
        ORDER BY from_date
      ) AS amount,
      -- need to rank by descending to get latest record
      ROW_NUMBER() OVER (
        PARTITION BY employee_id
        ORDER BY to_date DESC
      ) AS record_rank
    FROM mv_employees.salary
  ) all_salaries
  -- keep only latest previous_salary records only
  -- must have this in subquery to account for execution order
  WHERE record_rank = 1
),
cte_join_data AS (
SELECT
  employee.id AS employee_id,
  employee.birth_date,
  -- calculated employee_age field
  DATE_PART('year', now()) -
    DATE_PART('year', employee.birth_date) AS employee_age,
  -- employee full name
  CONCAT_WS(' ', employee.first_name, employee.last_name) AS employee_name,
  employee.gender,
  employee.hire_date,
  title.title,
  salary.amount AS salary,
  -- need to separately define the previous_latest_salary
  -- to differentiate between the following lag record!
  cte_previous_salary.amount AS previous_latest_salary,
  department.dept_name AS department,
  -- use the `manager` aliased version of employee table for manager
  CONCAT_WS(' ', manager.first_name, manager.last_name) AS manager,
  -- calculated tenure fields
  DATE_PART('year', now()) -
    DATE_PART('year', employee.hire_date) AS company_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', title.from_date) AS title_tenure_years,
  DATE_PART('year', now()) -
    DATE_PART('year', department_employee.from_date) AS department_tenure_years,
  -- we also need to use AGE & DATE_PART functions here to generate month diff
  DATE_PART('months', AGE(now(), title.from_date)) AS title_tenure_months,
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
-- join onto our previous cte_previous_salary only for previous_latest_salary
INNER JOIN cte_previous_salary
  ON mv_employees.employee.id = cte_previous_salary.employee_id
),
-- now we apply the window function to order our transactions
-- we will filter out the top 5 in the next CTE step
cte_ordered_transactions AS (
  SELECT
    employee_id,
    birth_date,
    employee_age,
    employee_name,
    gender,
    hire_date,
    title,
    LAG(title) OVER w AS previous_title,
    salary,
    -- previous latest salary is based off the CTE
    previous_latest_salary,
    LAG(salary) OVER w AS previous_salary,
    department,
    LAG(department) OVER w AS previous_department,
    manager,
    LAG(manager) OVER w AS previous_manager,
    company_tenure_years,
    title_tenure_years,
    title_tenure_months,
    department_tenure_years,
    effective_date,
    expiry_date,
    -- we use a reverse ordered effective date window to capture last 5 events
    ROW_NUMBER() OVER (
      PARTITION BY employee_id
      ORDER BY effective_date DESC
    ) AS event_order
  FROM cte_join_data
  -- apply logical filter to remove invalid records resulting from the join
  WHERE effective_date <= expiry_date
  -- define window frame with chronological ordering by effective date
  WINDOW
    w AS (PARTITION BY employee_id ORDER BY effective_date)
),
-- finally we apply our case when statements to generate the employee events
-- and generate our benchmark comparisons for the final output
-- we aliased our FROM table as "base" for compact code!
final_output AS (
  SELECT
    base.employee_id,
    base.gender,
    base.birth_date,
    base.employee_age,
    base.hire_date,
    base.title,
    base.employee_name,
    base.previous_title,
    base.salary,
    -- previous latest salary is based off the CTE
    previous_latest_salary,
    -- previous salary is based off the LAG records
    base.previous_salary,
    base.department,
    base.previous_department,
    base.manager,
    base.previous_manager,
    -- tenure metrics
    base.company_tenure_years,
    base.title_tenure_years,
    base.title_tenure_months,
    base.department_tenure_years,
    base.event_order,
    -- only include the latest salary change for the first event_order row
    CASE
      WHEN event_order = 1
        THEN ROUND(
          100 * (base.salary - base.previous_latest_salary) /
            base.previous_latest_salary::NUMERIC,
          2
        )
      ELSE NULL
    END AS latest_salary_percentage_change,
    -- also include the amount change
    CASE
      WHEN event_order = 1
        THEN ROUND(
          base.salary - base.previous_latest_salary
        )
      ELSE NULL
    END AS latest_salary_amount_change,
    -- event type logic by comparing all of the previous lag records
    CASE
      WHEN base.previous_salary < base.salary
        THEN 'Salary Increase'
      WHEN base.previous_salary > base.salary
        THEN 'Salary Decrease'
      WHEN base.previous_department <> base.department
        THEN 'Dept Transfer'
      WHEN base.previous_manager <> base.manager
        THEN 'Reporting Line Change'
      WHEN base.previous_title <> base.title
        THEN 'Title Change'
      ELSE NULL
    END AS event_name,
    -- salary change
    ROUND(base.salary - base.previous_salary) AS salary_amount_change,
    ROUND(
      100 * (base.salary - base.previous_salary) / base.previous_salary::NUMERIC,
      2
    ) AS salary_percentage_change,
    -- benchmark comparisons - we've omit the aliases for succinctness!
    -- tenure
    ROUND(tenure_benchmark_salary) AS tenure_benchmark_salary,
    ROUND(
      100 * (base.salary - tenure_benchmark_salary)
        / tenure_benchmark_salary::NUMERIC
    ) AS tenure_comparison,
    -- title
    ROUND(title_benchmark_salary) AS title_benchmark_salary,
    ROUND(
      100 * (base.salary - title_benchmark_salary)
        / title_benchmark_salary::NUMERIC
    ) AS title_comparison,
    -- department
    ROUND(department_benchmark_salary) AS department_benchmark_salary,
    ROUND(
      100 * (salary - department_benchmark_salary)
        / department_benchmark_salary::NUMERIC
    ) AS department_comparison,
    -- gender
    ROUND(gender_benchmark_salary) AS gender_benchmark_salary,
    ROUND(
      100 * (base.salary - gender_benchmark_salary)
        / gender_benchmark_salary::NUMERIC
    ) AS gender_comparison,
    -- usually best practice to leave the effective/expiry dates at the end
    base.effective_date,
    base.expiry_date
  FROM cte_ordered_transactions AS base  -- used alias here for the joins below
  INNER JOIN mv_employees.tenure_benchmark
    ON base.company_tenure_years = tenure_benchmark.company_tenure_years
  INNER JOIN mv_employees.title_benchmark
    ON base.title = title_benchmark.title
  INNER JOIN mv_employees.department_benchmark
    ON base.department = department_benchmark.department
  INNER JOIN mv_employees.gender_benchmark
    ON base.gender = gender_benchmark.gender
  -- apply filter to only keep the latest 5 events per employee
  -- WHERE event_order <= 5
)
-- finally we are done with the historic values
SELECT * FROM final_output;

-- This final view powers the employee deep dive tool
-- by keeping only the 5 latest events
DROP VIEW IF EXISTS mv_employees.employee_deep_dive;
CREATE VIEW mv_employees.employee_deep_dive AS
SELECT *
FROM mv_employees.historic_employee_records
WHERE event_order <= 5;
```

### `Further Simplified Employee Events`
We can also further reduce the above deep dive output into 2 separate views to simplify the data outputs required for the deep dive employee tool:

1. Current employee and salary benchmark details
2. Latest 5 historic employee events with detailed event info


**Current Employee Deep Dive Outputs**

We can also generate all of our data outputs in order as per the deep dive visual example:
```sql
SELECT
  employee_id,
  employee_name,
  UPPER(title || ' - ' || department) AS line_1,
  CASE
    WHEN gender = 'M'
      THEN UPPER('MALE ' || employee_age || ', BIRTHDAY ' || birth_date)
    ELSE UPPER('FEMALE ' || employee_age || ', BIRTHDAY ' || birth_date)
    END AS line_2,
  title_tenure_months,
  company_tenure_years,
  TO_CHAR(salary, '$FM999,999,999') AS salary,
  latest_salary_percentage_change,
  manager,
  -- salary benchmark values
  TO_CHAR(tenure_benchmark_salary, '$FM999,999,999') AS tenure_benchmark_salary,
  tenure_comparison,
  TO_CHAR(title_benchmark_salary, '$FM999,999,999') AS title_benchmark_salary,
  title_comparison,
  TO_CHAR(department_benchmark_salary, '$FM999,999,999') AS department_benchmark_salary,
  department_comparison,
  TO_CHAR(gender_benchmark_salary, '$FM999,999,999') AS gender_benchmark_salary,
  gender_comparison
FROM mv_employees.employee_deep_dive
WHERE employee_name = 'Leah Anguita'
  AND event_order = 1;
```

**Latest Five**

```sql
SELECT
  employee_id,
  event_order,
  event_name,
  CASE
    WHEN event_name IN ('Salary Increase', 'Salary Decrease')
      THEN 'New salary: ' || TO_CHAR(salary, '$FM999,999,999')
    WHEN event_name = 'Dept Transfer'
      THEN 'To: ' || department
    WHEN event_name = 'Reporting Line Change'
      THEN 'New manager: ' || manager
    WHEN event_name = 'Title Change'
      THEN 'To: ' || title
  END AS line_1,
  CASE
    WHEN event_name = 'Salary Increase'
      THEN 'Increase: ' || TO_CHAR(salary_amount_change, '$FM999,999,999') ||
        ' (+' || ROUND(salary_percentage_change::NUMERIC, 1) || ' %)'
    WHEN event_name = 'Salary Decrease'
      THEN 'Decrease: ' || TO_CHAR(salary_amount_change, '$FM999,999,999') ||
        ' (' || ROUND(salary_percentage_change::NUMERIC, 1) || ' %)'
    WHEN event_name = 'Dept Transfer'
      THEN 'From: ' || previous_department
    WHEN event_name = 'Reporting Line Change'
      THEN 'Previous manager: ' || previous_manager
    WHEN event_name = 'Title Change'
      THEN 'To: ' || previous_title
  END AS line_2,
  effective_date AS event_date
FROM mv_employees.employee_deep_dive
WHERE employee_name = 'Leah Anguita'
ORDER BY event_order;
```

---

<br>

### `Final Quiz Section`
To complete this HR Analytics case study - there is a total of 3 different quizzes broken down by analytical focus areas:

1. Current Analysis
2. Employee Churn
3. Management Analysis

### **Current Analysis**
1. What is the full name of the employee with the highest salary?
```sql
SELECT
  employee_name,
  salary
FROM mv_employees.current_employee_snapshot
WHERE salary = (SELECT MAX(salary) FROM mv_employees.current_employee_snapshot);

-- Simpler Order By (Same Result)
SELECT
  employee_name,
  salary
FROM mv_employees.current_employee_snapshot
ORDER BY salary DESC
LIMIT 1;
```
|employee_name|salary|
|----|----|
|Tokuyasu Pesch|158220|

2. How many current employees have the equal longest time in their current positions?
```sql
SELECT
  title_tenure_years AS years_in_position,
  COUNT(*) AS employee_counts_for_n_years
FROM mv_employees.current_employee_snapshot
GROUP BY title_tenure_years
ORDER BY years_in_position DESC
LIMIT 5;
```
|years_in_position|employee_counts_for_n_years|
|----|----|
|20|3505|
|19|3823|
|18|3781|
|17|3919|
|16|3886|

3. Which department has the highest number of current employees?
```sql
SELECT
  department,
  COUNT(*) AS employee_count_department
FROM mv_employees.current_employee_snapshot
GROUP BY department
ORDER BY employee_count_department DESC
LIMIT 2;
```
|department|employee_count_department|
|-----|----|
|Development|61386|
|Production|53304|

4. What is the largest difference between minimimum and maximum salary values for all current employees?
```sql
-- What is the largest difference between minimimum and maximum salary values for all current employees?
WITH min_max_diff AS (
SELECT
  MIN(salary) AS min_sal,
  MAX(salary) AS max_sal
FROM mv_employees.current_employee_snapshot
)
SELECT
  (max_sal - min_sal)::numeric AS max_sal_difference
FROM min_max_diff;
```
|max_sal_difference|
|---|
|119597|

5. How many male employees are above the average salary value for the Production department?
```sql
WITH male_production_emps AS (
SELECT *
FROM mv_employees.current_employee_snapshot
WHERE department = 'Production'
AND gender = 'M'
)
SELECT
  COUNT(*)
FROM male_production_emps 
WHERE salary > (SELECT AVG(salary) FROM mv_employees.current_employee_snapshot WHERE department = 'Production');

-- Another approach
WITH cte AS (
  SELECT
    gender,
    salary,
    AVG(salary) OVER () AS avg_salary
  FROM mv_employees.current_employee_snapshot
  WHERE
    department = 'Production'
)
SELECT
  SUM(
    CASE
      WHEN salary > avg_salary THEN 1
      ELSE 0
    END
  ) AS above_average_employee_count
FROM cte
WHERE gender = 'M';
```
|count|
|---|
|14999|

6. Which title has the highest average salary for male employees?
```sql
SELECT
  title,
  AVG(salary) AS title_avg_salary
FROM mv_employees.current_employee_snapshot
WHERE gender = 'M'
GROUP BY title
ORDER BY title_avg_salary DESC
LIMIT 5;
```
|title|title_avg_salary|
|----|----|
|Senior Staff|80735.479464575886|
|Manager|79350.600000000000|
|Senior Engineer|70869.908466419576|
|Technique Leader|67599.671025177354|
|Staff|67362.175434050272|

7. Which department has the highest average salary for female employees?
```sql
SELECT
  department,
  ROUND(AVG(salary), 2) AS dept_avg_salary
FROM mv_employees.current_employee_snapshot
WHERE gender = 'F'
GROUP BY department
ORDER BY dept_avg_salary DESC
LIMIT 5;
```
|department|dept_avg_salary|
|----|----|
|Sales|88835.96|
|Marketing|79699.77|
|Finance|78747.42|
|Research|68011.86|
|Production|67728.11|

8. Which department has the most female employees?
```sql
SELECT
  department,
  COUNT(*) AS dept_fem_emp_count
FROM mv_employees.current_employee_snapshot
WHERE gender = 'F'
GROUP BY department
ORDER BY dept_fem_emp_count DESC
LIMIT 5;


SELECT
  department,
  COUNT(*) AS employee_count
FROM mv_employees.current_employee_snapshot
WHERE gender = 'F'
GROUP BY department
ORDER BY employee_count;
```
|department|dept_fem_emp_count|
|----|---|
|Development|24533|
|Production|21393|
|Sales|14999|
|Customer Service|7007|
|Research|6181|

9. What is the gender ratio in the department which has the highest average male salary and what is the average male salary value for that department?
```sql
WITH max_avg_salary_departments  AS (
SELECT
  department,
  ROUND(AVG(salary)) AS male_dept_avg_sal
FROM mv_employees.current_employee_snapshot
WHERE gender = 'M'
GROUP BY department
ORDER BY male_dept_avg_sal DESC
LIMIT 1
),
department_counts AS (
SELECT
  (SELECT COUNT(*) FROM mv_employees.current_employee_snapshot WHERE gender = 'F' AND department = (SELECT department FROM max_avg_salary_departments)) AS female_dept_counts,
  (SELECT COUNT(*) FROM mv_employees.current_employee_snapshot WHERE gender = 'M' AND department = (SELECT department FROM max_avg_salary_departments)) AS male_dept_counts,
  (SELECT COUNT(*) FROM mv_employees.current_employee_snapshot WHERE department = (SELECT department FROM max_avg_salary_departments)) AS dept_total_counts,
  department,
  male_dept_avg_sal
FROM max_avg_salary_departments
)
SELECT 
  department,
  male_dept_avg_sal,
  ROUND(female_dept_counts::numeric / dept_total_counts, 3) AS female_ratio,
  ROUND(male_dept_counts::numeric / dept_total_counts, 3) AS male_ratio
FROM department_counts;

-- Their Approach
WITH department_cte AS (
  SELECT
    department,
    ROUND(AVG(salary)) as avg_salary
  FROM mv_employees.current_employee_snapshot
  WHERE gender = 'M'
  GROUP BY department
  ORDER BY avg_salary DESC
  LIMIT 1
)
SELECT
  gender,
  avg_salary,
  COUNT(*) AS employee_count
FROM mv_employees.current_employee_snapshot
INNER JOIN department_cte
  ON current_employee_snapshot.department = department_cte.department
GROUP BY gender, avg_salary;
```
|department|male_dept_avg_sal|female_ratio|male_ratio|
|----|----|-----|-----|
|Sales|88864|0.398|0.602|

* Second Table Output (Like the Join and using values from a top department better than my subquery approach)

|gender|avg_salary|employee_count|
|----|-----|-----|
|M|88864|22702|
|F|88864|14999|
10. HR Analytica want to change the average salary increase percentage value to 2 decimal places - what will the new value be for males for the company level dashboard?
```sql
DROP VIEW IF EXISTS mv_employees.company_level_dashboard;
CREATE VIEW mv_employees.company_level_dashboard AS
SELECT
  gender,
  COUNT(*) AS employee_count,
  ROUND(100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER ()) AS employee_percentage,
  ROUND(AVG(company_tenure_years)) AS company_tenure,
  ROUND(AVG(salary)) AS avg_salary,
  ROUND(AVG(salary_percentage_change), 2) AS avg_salary_percentage_change,
  -- salary statistics
  ROUND(MIN(salary)) AS min_salary,
  ROUND(MAX(salary)) AS max_salary,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)) AS median_salary,
  ROUND(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) -
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary)
  ) AS inter_quartile_range,
  ROUND(STDDEV(salary)) AS stddev_salary
FROM mv_employees.current_employee_snapshot
GROUP BY gender;
```

11. How many current employees have the equal longest overall time in their current positions (not in years)
* Trick here is using the interval and `CURRENT_DATE` function to get a interval more finite than years (days default return)
```sql
-- How many current employees have the equal longest overall time in their current positions (not in years)
SELECT
    -- Set new interval and current amount of time from most recent job start date "from_date"
  CURRENT_DATE - from_date AS tenure_interval,
  COUNT(DISTINCT employee_id) AS employee_count
FROM mv_employees.department_employee
-- only looking for current role so use "infinnite" type dimension
WHERE to_date = '9999-01-01'
GROUP BY tenure_interval
ORDER BY tenure_interval DESC
LIMIT 10;
```
|tenure_interval|employee_count|
|----|----|
|7420|9
|7407|1|
|7389|7|
|7388|45|
|7387|45|
|7386|34|
|7385|37|
|7384|34|
|7383|39|
|7382|39|
<br><br>

### **Employee Churn**
HR Analytica want to perform an employee churn analysis and wants you to help them answer the following questions using your generated views:

1. How many employees have left the company?
```sql
SELECT 
  COUNT(*) as churned_employees
FROM mv_employees.historic_employee_records
WHERE event_order = 1
AND CURRENT_DATE > expiry_date;

-- Idea of how many row in the historic view
-- SELECT COUNT(*) FROM mv_employees.historic_employee_records; (count - 3244239)

-- Theirs (Same 59,910)
SELECT
  COUNT(*) AS churn_employee_count
FROM mv_employees.historic_employee_records
WHERE event_order = 1
AND expiry_date != '9999-01-01';
```
|churned_employees|
|----|
|59910|
2. What percentage of churn employees were male?
```sql
-- What percentage of churn employees were male?
WITH churned_employees AS (
SELECT * 
FROM mv_employees.historic_employee_records
WHERE event_order = 1
AND CURRENT_DATE > expiry_date
),
churned_gender_counts AS (
SELECT 
  gender,
  COUNT(*) AS total_churned_gender_counts,
  (SELECT COUNT(*) FROM churned_employees) AS total_churned_employees
FROM churned_employees
GROUP BY gender
),
churned_gender_proportions AS (
SELECT
  gender,
  CASE
    WHEN gender = 'F'
      THEN ROUND(
        100 * (total_churned_gender_counts::numeric / total_churned_employees)
      , 2)
    ELSE NULL
  END AS female_churn_percentage,
  CASE
    WHEN gender = 'M'
      THEN ROUND(
        100 * (total_churned_gender_counts::numeric / total_churned_employees)
      , 2)
    ELSE NULL
  END as male_churn_percentage
FROM churned_gender_counts
)
SELECT * 
FROM churned_gender_proportions;

-- Just for Male
WITH calculations_cte AS (
  SELECT
    gender,
    ROUND(100 * COUNT(*) / (SUM(COUNT(*)) OVER ())::NUMERIC) AS churn_percentage
  FROM mv_employees.historic_employee_records
  WHERE
    event_order = 1
    AND expiry_date != '9999-01-01'
  GROUP BY gender
)
SELECT
  churn_percentage
FROM calculations_cte
WHERE gender = 'M';
```
|gender|female_churn_percentage|male_churn_percentage|
|-----|-----|-------|
|M|null|59.86|
|F|40.14|null|
3. Which title had the most churn?
```sql
-- Which title had the most churn?
WITH churned_employees AS (
SELECT  
  title,
  COUNT(*) AS churned_title_count
FROM mv_employees.historic_employee_records
WHERE event_order = 1 AND expiry_date < CURRENT_DATE
GROUP BY title
)
SELECT * 
FROM churned_employees
ORDER BY churned_title_count DESC;
```
|title|churned_title_count|
|---|----|
|Engineer|16320|
|Staff|15607|
|Senior Engineer|11810|
|Senior Staff|10826|
|Technique Leader|3100|
|Assistant Engineer|2247|
4. Which department had the most churn?
```sql
WITH churned_employees AS (
SELECT  
  department,
  COUNT(*) AS churned_dept_count
FROM mv_employees.historic_employee_records
WHERE event_order = 1 AND expiry_date < CURRENT_DATE
GROUP BY department
)
SELECT * 
FROM churned_employees
ORDER BY churned_dept_count DESC;

-- Theirs
SELECT
  department,
  COUNT(*) AS churn_employee_count
FROM mv_employees.historic_employee_records
WHERE
  record_order = 1 AND
  expiry_date != '9999-01-01'
GROUP BY department
ORDER BY churn_employee_count DESC
LIMIT 5;
```
|department|churned_dept_count|
|-----|-----|
|Development|15578|
|Production|13373|
|Sales|9228|
5. Which year had the most churn?
```sql
WITH churned_employees AS (
SELECT  
  EXTRACT(year FROM expiry_date) AS churn_year,
  COUNT(*) AS churned_year_count
FROM mv_employees.historic_employee_records
WHERE event_order = 1 AND expiry_date < CURRENT_DATE
GROUP BY churn_year
)
SELECT * 
FROM churned_employees
ORDER BY churned_year_count DESC;
```
|churn_year|churned_year_count|
|---|----|
|2018|7610|
|2019|7248|
|2017|6964|
|2016|5941|
|2015|5066|
6. What was the average salary for each employee who has left the company?
```sql
SELECT
  AVG(salary) AS average_final_salary
FROM mv_employees.historic_employee_records
WHERE
  event_order = 1 AND
  expiry_date != '9999-01-01';
```
|average_final_salary|
|---|
|61577.450744425157|
7. What was the median total company tenure for each churn employee just bfore they left?
```sql
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY company_tenure_years) AS median_company_tenure
FROM latest_expiry_cte
WHERE
  event_order = 1
  AND expiry_date != '9999-01-01';
```
|median_company_tenure|
|---|
|12|
8. On average, how many different titles did each churn employee hold?
```sql
-- Get churned employee_id
WITH churned_employees AS (
SELECT 
  employee_id
FROM mv_employees.historic_employee_records
WHERE
  event_order = 1
  AND expiry_date < CURRENT_DATE
),
-- churned_employee_title_count
churned_emp_title_count AS (
  SELECT
    employee_id,
    COUNT(DISTINCT title) AS churn_employee_title_count
  FROM mv_employees.historic_employee_records
  WHERE employee_id in (SELECT employee_id FROM churned_employees)
  GROUP BY employee_id
)
SELECT 
  ROUND(AVG(churn_employee_title_count), 1) AS average_title_amounts_chrn_emps
FROM churned_emp_title_count;

-- Theirs
WITH churn_employees_cte AS (
  SELECT
    employee_id
  FROM mv_employees.historic_employee_records
  WHERE
    event_order = 1
    AND expiry_date != '9999-01-01'
),
title_count_cte AS (
SELECT
  employee_id,
  COUNT(DISTINCT title) AS title_count
FROM mv_employees.historic_employee_records AS t1
WHERE EXISTS (
  SELECT 1
  FROM churn_employees_cte
  WHERE historic_employee_records.employee_id = churn_employees_cte.employee_id
)
GROUP BY employee_id
)
SELECT
  AVG(title_count) AS average_title_count
FROM title_count_cte;
```
|average_title_amounts_chrn_emps|
|----|
|1.2|
9. What was the average last pay increase for churn employees?
```sql
-- What was the average last pay increase for churn employees?
WITH churned_employees AS (
SELECT 
  DISTINCT(employee_id)
FROM mv_employees.historic_employee_records
WHERE
  event_order = 1
  AND expiry_date < CURRENT_DATE
),
-- Need to find the most recent pay_inc
pay_raise_recent_ranks AS (
SELECT
  employee_id,
  event_name,
  salary_amount_change,
  -- Create new field for salary raise rankings by receny (using event_order)
  RANK() OVER (
    PARTITION BY employee_id
    ORDER BY event_order
  ) AS salary_raise_recency_rank
FROM mv_employees.historic_employee_records
WHERE 
  event_name = 'Salary Increase'
  AND employee_id in (SELECT * FROM churned_employees)
)
-- Now get avg salary_amount_change when salary_raise_recency_rank = 1 (each employee that had the event will have that event ranked first in the RANK window function above)
SELECT
-- Round to nearest dollar
  ROUND(AVG(salary_amount_change))
FROM pay_raise_recent_ranks
WHERE salary_raise_recency_rank = 1;
```
|round|
|----|
|2250|
10. What proportion of churn employees had a pay decrease event in their last 5 events?
```sql
-- What percentage of churn employees had a pay decrease event in their last 5 events?
WITH churned_employees AS (
SELECT 
  DISTINCT(employee_id)
FROM mv_employees.historic_employee_records
WHERE
  event_order = 1
  AND expiry_date < CURRENT_DATE
),
pay_decreases_in_five_recent_events AS (
SELECT
  employee_id,
  COUNT(*) AS decrease_events
FROM mv_employees.historic_employee_records
WHERE 
  event_order <= 5
  AND employee_id in (SELECT * FROM churned_employees)
  AND event_name = 'Salary Decrease'
GROUP BY employee_id
),
churn_n_decrease_churned AS (
SELECT
  (SELECT COUNT(*) FROM churned_employees) AS total_churned,
  (SELECT COUNT(*) FROM pay_decreases_in_five_recent_events) AS total_churned_decrease_count
)
SELECT
  total_churned, 
  total_churned_decrease_count,
  ROUND(total_churned_decrease_count::numeric / total_churned) as churned_pay_decrease_percentage_in_last_5_events
FROM churn_n_decrease_churned

-- Better Version lol
WITH decrease_cte AS (
  SELECT
    employee_id,
    MAX(
      CASE WHEN event_name = 'Salary Decrease' THEN 1
      ELSE 0 END
    ) AS salary_decrease_flag
  FROM mv_employees.employee_deep_dive AS t1
  WHERE EXISTS (
    SELECT 1
    FROM mv_employees.employee_deep_dive AS t2
    WHERE t2.event_order = 1
      AND t2.expiry_date != '9999-01-01'
      AND t1.employee_id = t2.employee_id
    )
  GROUP BY employee_id
)
SELECT
  ROUND(100 * SUM(salary_decrease_flag) / COUNT(*)::NUMERIC) AS percentage_decrease
FROM decrease_cte;
```
|total_churned|total_churned_decrease_count|churned_pay_decrease_percentage_in_last_5_events|
|---|-----|----|
|59910|14328|24|
11. How many current employees have the equal longest overall time in their current positions (not in years)?