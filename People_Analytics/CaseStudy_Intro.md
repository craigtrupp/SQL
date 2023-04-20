# People Analytics Case Study
People Analytics or HR Analytics is an increasingly popular focus area for data professionals. Many business and people decisions which were traditionally based off senior management gut feels and intuition are starting to become more data-driven, despite what the above Dilbert comic depicts!

There is a lot of available high quality data in this field, and often the people insights that are discovered can lead to very important and impactful business decisions - often coming with full endorsement and support from senior executives such as the CEO or Chief of Staff.

In our second complete SQL case study - we will assist HR Analytica to construct datasets to answer basic reporting questions and also feed their bespoke People Analytics dashboards.

---

## Final Outputs (Company & Employee)
<br>

![Final Output](images/FOutput_1.png)
![Final Output 2](images/FOutput2.png)

![Emp Output 1](images/Emp1.png)
![Emp Output 2](images/Emp2.png)

---

<br>

## Key Technical Requirements
HR Analytica team requires 2 separate analytical views to be created using a single SQL script for two separate data assets that can be used for reporting purposes.

A current snapshot of the information is required to power HR Analytica’s People Analytics dashboard and Employee Deep Dive shown above.

The following data requirements is as follows:

### Dashboard Data Components

#### Company Level Insights
* Total number of employees
* Average company tenure in years
* Gender ratios
* Average payrise percentage and amount

#### Department Level Insights
* Number of employees in each department
* Current department manager tenure in years
* Gender ratios
* Average payrise percentage and amount

#### Title Level Insights
* Number of employees with each title
* Minimum, average, standard deviation of salaries
* Average total company tenure
* Gender ratios
* Average payrise percentage and amount


A historic data asset is also required by HR Analytica so their People Analytics team can perform deep dives into a specific employee’s history. This analysis is used for decision making when it comes to pay rises and promotions.

---

<br>

## Data Exploration
### ERD
![People Entity Relationship](images/ERD_PAnalytics.png)

### Tables
#### `employee`
Let’s start with the employees.employee table in the middle of the ERD.

After inspecting a few rows from this table - we can see that there is a unique row of personal information for each employee in our database. There is primary key on the id column which we can later join onto our other tables via the `employee_id` field.

There is the issue with the dates where our young unlucky intern accidentally input the year which is 18 years behind what it should be - so we will need to keep an eye on this one as we think about our data solutions for the case study!

#### `title`
Our second table is the employees.title table which contains the `employee_id` which we can join back to our employees.employee table.

After inspecting the data - we notice that there is in fact a **many-to-one** relationship between the employees.title and employees.employee tables.

In simple terms - in the employees.employee table there is only ever 1 row for each unique id value. However in the employees.title table - each employee_id value can have multiple title values over their career with the company.

If we reverse the direction of the table relationship - we can also say that `employees.employee` has a **one-to-many relationship** with the `employees.title` table. 

Note how there is both a `from_date` column and a to_date column in this dataset. We commonly refer to these sorts of tables as `slow changing dimension` tables or **SCDs** in data engineering terms.

This essentially means that certain records in an SCD table are “expired” once the relationship ceases to exist and the dates where these new relationships are effective and expire are recorded in this table as from_date and to_date respectively.

For our example employee_id = 10005 Kyoichi Maliniak’s title was originally “Staff” from 1989-09-12 to 1996-09-12 when he was then promoted to “Senior Staff” which is his current position until the “arbitrary” end date of 9999-01-01 in our dataset.

#### `salary`
The third table is the all-important employees.salary table - it also has a similar relationship with the unique employees.employee table in that there are many-to-one or one-to-many records for each employee and their salary amounts over time.

The same from_date and to_date columns exist in this table, along with it’s arbitrary end date of 9999-01-01 which we will need to deal with later.

#### `department_employee`
We now take a look at the employees.department_employee table which captures information for which department each employee belongs to throughout their career with our company.

In the same vain as the previous tables - we have the same slow changing dimension (SCD) style data design with a many-to-one relationship with the base employees.employee table (and vice-versa!)

This time instead of the salary or the title records - we now have the department_id value for where each employee was situated during various periods of their career.

#### `department_manager`
In the same way that the `employees.department_employee` table shows the relationship between employees and their respective departments throughout time - the `employees.department_manager` table shows the `employee_id` of the manager of each department throughout time.

#### `department`
The `employees.department` table is just like the employees.employee table where there is a 1:1 unique relationship between the id or department_id and the dept_name.

This also happens to be the only table where our unfortunate intern did not make a data entry mistake - but that was only because there were no date fields in this table!

---

<br>

### Appendix
* code was used within DBDiagram.io  to create ERD

```sql
TABLE department {
  "id" char(4) [NOT NULL]
  "dept_name" varchar(40) [NOT NULL]
  
Indexes {
  id [PK]
  dept_name [type: btree, name: "idx_16979_dept_name"]
}
}

TABLE department_employee {
  "employee_id" bigint [NOT NULL]
  "department_id" char(4) [NOT NULL]
  "from_date" date [NOT NULL]
  "to_date" date [NOT NULL]
  
Indexes {
  (employee_id, department_id) [PK]
  department_id [type: btree, name: "idx_16982_dept_no"]
}
}

TABLE department_manager {
  "employee_id" bigint [NOT NULL]
  "department_id" character(4) [NOT NULL]
  "from_date" date [NOT NULL]
  "to_date" date [NOT NULL]
  
Indexes {
  (employee_id, department_id) [PK]
  department_id [type: btree, name: "idx_16985_dept_no"]
}
}

enum employee_gender {
  M
  F
}

TABLE employee {
    "id" bigint [NOT NULL]
    "birth_date" date [NOT NULL]
    "first_name" varchar(14) [NOT NULL]
    "last_name" varchar(16) [NOT NULL]
    "gender" employee_gender [NOT NULL]
    "hire_date" date [NOT NULL]
    
Indexes {
  id [PK]
}
}

TABLE salary {
    "employee_id" bigint [NOT NULL]
    "amount" bigint [NOT NULL]
    "from_date" date [NOT NULL]
    "to_date" date [NOT NULL]

Indexes {
  (employee_id, from_date) [PK]
}
}

TABLE title {
  "employee_id" bigint [NOT NULL]
  "title" varchar(50) [NOT NULL]
  "from_date" date [NOT NULL]
  "to_date" date [NOT NULL]
  
Indexes {
  (employee_id, title, from_date) [PK]
}
}

Ref: "department"."id" < "department_employee"."department_id"

Ref: "department"."id" < "department_manager"."department_id"

Ref: "employee"."id" < "department_manager"."employee_id"

Ref: "employee"."id" < "department_employee"."employee_id"

Ref: "employee"."id" < "title"."employee_id"

Ref: "employee"."id" < "salary"."employee_id"
```



