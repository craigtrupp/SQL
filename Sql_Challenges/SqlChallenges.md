# SQL Challenges
Following completing the educational material for `Serious SQL`, the course offers robust SQL challenges to put our skills to the test. Below will hold an introduction to the various case studies followed by links to the respective markdown files for each case study where the individual queries/answers can be found as well as context to the database schema in use for each. Before visiting the respective challenges, please see a summary of some of the techniques and skills used to complete the challenges

<br>

### Skills Covered in Challenges
* Select & Sort Data
* Record Counts & Distinct Values
* Summary Statistics
* Distribution Funtions
* Table Joins
* Set Operations
* Temp Tables
* Views
* Window Functions
* CTEs
* PostgreSQL Methods such as **array_agg** and **regex** methods to parse patterns and strings

---

<br>

### `Danny's Diner`
* Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 
* Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers. 
* The Dataset (Schema), ERD (Entity Relationship Diagram), and Case Study Questions can be found here : https://github.com/craigtrupp/SrsSQL/blob/main/Sql_Challenges/1_DannyDiner/Danny_Diners_Challenge.md

<br>

### `Pizza Runner`
* This Case Study looks to analyze various different sections in Danny's Pizza business
    - Pizza Metrics
    - Runner & Customer Expereince
    - Ingredient Optimization
    - Pricing and Ratings
* This challenge includes several examples of multiple joins, conditional `SUM CASES`, temp table creation, regex pattern and table creation as well as data cleanup for incomplete or incosistent data values across the database schema
* https://github.com/craigtrupp/SrsSQL/blob/main/Sql_Challenges/2_PizzaRunner/Pizza_Runner.md

<br>

### `Foodie Fi`
* Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
* Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.
* While this is a smaller data schema and relational model, the presence of SCD (slowly changing dimensions) offers unique challenges to aggregate or finding leading/trailing data for our customer data
* This challenge also introduces **distribution** functions used to bin customers and their event history for clearer insights on customer behavior
* https://github.com/craigtrupp/SrsSQL/blob/main/Sql_Challenges/3_Foodie_Fi/Foddie_Fi.md



