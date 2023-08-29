<h1 style="text-align: center;"> 🚀 Case Study Challenges 🚀 </h1> 

Following completing the educational material for `Serious SQL`, the course offers robust SQL challenges to put our skills to the test. Each section below will provide a quick introduction to the various case studies followed by links to the respective case study where the individual queries/answers can be found as well as context to the database schema/ERD in use for each. Before visiting the respective challenges, please see a summary of some of the techniques and skills used to complete the challenges.

<br>

### **Primary Skills Covered in Challenges**
* Select & Sort Data ⛏️
* Record Counts & Distinct Values 🧾
* Summary Statistics 📊
* Distribution Functions 🛒
* Table Joins 🧑‍🤝‍🧑
* Set Operations ⛓️
* Temp Tables 🍽️
* Views 🌅
* Window Functions :window:
* CTEs 🤲
* PostgreSQL Methods such as **array_agg** and **regex_match** :man_technologist: 
* Recursive CTE's :recycle:
---

<br>

## **Individual Challenges** 
* A quick `Note` on the challenges and referenced **Case Study Files** below per section
* Each section/challenge below contains a root **markdown file** containing the following details
    - Challenge Introduction
    - Available Data 
    - Case Study Questions By Section
    - My SQL Path to the Solution for the Question 
* There is also a sole based SQL file for each Case Study that contains each section's final query for the solution to that particular section's question. 

<br>

### `1 - Danny's Diner` 🥡
* Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 
* Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers. 
* **Case Study Items**
    - Customer, Item & Loyalty Rewards Details
        * Customer Data : Total Spend, Most Popular Item, Purchase History
        * Item Data : Greatest/Least Purchased Item, Item Purchase by Member Status, 
        * Reward Details : Customer Reward Points by Item Multiplier, Customer Points by Promotion time points multiplier
* **`Case Study Files`** 
    * [Danny's Diner Challenge](/Sql_Challenges/1_DannyDiner/Danny_Diners_Challenge.md)
    * [Danny's Diner Queries](/Sql_Challenges/1_DannyDiner/Dannys_Dinner_queries.sql)


<br>

### `2 - Pizza Runner` 🍕
* This Case Study looks to analyze various different sections in Danny's Pizza business
* **Case Study Sections**
    - Pizza Metrics
        * Unique Customer Orders, Total Pizzas Ordered, Successful Orders Per Runner
        * Each Type of Pizza Per Successful Delivery, Max Pizza Delivered in Order
        * Pizzas Delivered w/Exclusions & w/Extras, Delivered Pizzas w/at least 1 change
        * Order Aggregates over time : Volume of Orders for each day of the week, pizzas ordered for each hour
    - Runner & Customer Expereince
        * Average distance travelled per run and by each customer, longest & shortest delivery times, average spped for each runner for delivery
        * Successful delivery percentage for each runner, average time in minutes for each runner to arrive to pickup order, Runner signups
    - Ingredient Optimization
        * Standard ingredients per pizza, Most commonly added extras or common exclusions
        * Dynamic Order Item Generation for pizza w/toppings and any exclusions and/or extras
            - Multiple Table joins and dynamic/conditional setting of eventual concatenated values
    - Pricing and Ratings
        * Price/Extra Change Impact on Revenue, General Revenue w/o delivery fees, Runner cost on revenue by runner rate per kilometer traveled
        * Addition of Ratings System, Table Generation including rating and customer/order details
* This challenge includes several examples of multiple joins, conditional `SUM CASES`, temp table creation, regex pattern and table creation as well as data cleanup for incomplete or incosistent data values across the database schema
* **`Case Study Files`** 
    * [Pizza Runner Challenge](/Sql_Challenges/2_PizzaRunner/Pizza_Runner.md)
    * [Pizza Runner Queries](/Sql_Challenges/2_PizzaRunner/Pizza_Runner_queries.sql)

<br>

### `3 - Foodie Fi` 🥑
* Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
* Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.
* While this is a smaller data schema and relational model, the presence of SCD (slowly changing dimensions) offers unique challenges to aggregate or finding leading/trailing data for our customer data
* This challenge also introduces **distribution** functions used to bin customers and their event history for clearer insights on customer behavior
* **Case Study Sections**
    - Customer Journey
        - Join Path for Data Access
    - Data Analysis Questions
        - Customer Plan Distribution
        - Time Distribution for Customers and Usage of different Subscription Levels
        - General Customer Subscription Upgrades and Downgrades Counts/Percentages
        - Customer Churn Data
    - Payment Table Creation - New Table w/following requirements
        - Montly payments always occur on the same day of the month as the original start_date
        - Upgrades from basic to monthly (or pror plans) are reduced by the current paid amount in that month and start immediately
        - Upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
        - once a customer churn, they will no longer make payments
* **`Case Study Files`** 
    * [Foodie Fi Subscription Challenge](/Sql_Challenges/3_Foodie_Fi/Foddie_Fi.md)
    * [Foodie Fi Individual Queries](/Sql_Challenges/3_Foodie_Fi/Foodie_Fi_queries.sql)

<br>

### `4 - Data Bank` 🏦
* This particular challenge mocks the management team at **Data Bank** looking to increase their total customer base by helping just how much data storage their customers would need
* **Sections covered in this challenge** focused on
    - Customer Metrics for Transaction and Node Usage
    - Descriptive Percentile and Statistic for Node Usage over different Partitions/Groups
    - Customer Transaction & Balance History over changing time dimensions
    - Threshold consideration for comparisons of balances in adjacent months
* Such approaches like `leading/lag window functions`, `generated series` for interval mocking, `conditional aggregate` functions for transaction determinstic values helped in the preparation of the customer & transaction data requested in the case study.
    - Window functions also included partitioned sections for customer balances and determining of activity against lagging balances
* **`Case Study Files`** 
    * [Data Bank Customer Challenge](/Sql_Challenges/4_DataBank/Data_Bank_CStudy.md)
    * [Data Bank Individual Queries](/Sql_Challenges/4_DataBank/Data_Bank_CStudy_sql.sql)

<br>

### `5 - Data Mart` 🛒
* Within this challenge, our case study covers a theoretical sales performance for Danny's online supermarket.
* Key business questions center around the following topics
    - Quantifiable impact of changes introduced for a particular time period
    - **Platform, Region, Segment, & Customer Type** impact by mocked change and subsequent data over different periods
* Tasks also included `Data Cleansing` to generate a new table within the schema for easier data aggregation and metrics for the mentioned subsets above
    - Type Casting
    - Date Segmenting 
    - Finer Data Points and Clarifying Text Representation
    - Conditional Type setting from sql function returns on uncleansed data
* The **Data Exploration Section** looks to use the date values and is most resourceful through our ability to partition and generate summary statistics by partitioned values like **calendar_year** over different demographics
* **`Case Study Files`** 
    * [Data Mart Challenge](/Sql_Challenges/5_DataMart/DataMart_CS.md)
    * [Data Mart Individual Queries](/Sql_Challenges/5_DataMart/Data_Mart_CS.sql)


<br>

### `6 - Clique Bait` 🖱️
* In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.
* This is a heavily involved case study and start with a request to create an `ERD` based on provided data in a schema. The ERD can be found here and is also available directly through DB Diagram
    - [Clique Bait Schema - DB Diagram](/Sql_Challenges/6_CliqueBait/images/clique_bait_schema.png)
    - https://dbdiagram.io/d/64c8195a02bd1c4a5e01a62c
    - Within the challenge markdown file, the `DDL` language can also be seen (Section A) for the table relationship definition as well as potential Indexes for improved performance
* The challenge mocks tasks involving data from `user`, `events`, `products` and `campaign analysis` tables for user events
* **Digital Analysis** involves questions including
    - User Visits by Event Types 
    - Percentage of Purchase Events by user individual visits
    - Website/Page Statistics by product and product category
    - Cart Addition Events and Purchase Conversion Rates
* **Product Funnel Analysis**
    - Table/View generation for product views, cart additions, abandonments, and purchases
    - Similar analysis for product categorical statistics
* **Campaign Analysis**
    - Temp Table Creation via chained CTE information gathering
    - Conditional Case Setting and Subquerying for Campaign designation with respect to ad impressions and clicks per unique user visit and chaining to products included in user site visit
* **`Case Study Files`** 
    * [Clique Bait Challenge](/Sql_Challenges/6_CliqueBait/CBAttenCapturing.md)
    * [Clique Bait Individual Queries](/Sql_Challenges/6_CliqueBait/CBAttCap_qrs.sql)

<br>

### `7 - Balanced Tree Clothing` 🌳
* Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their 
    - sales performance and generate a basic financial report to share with the wider business.
* **Case Study Questions** include the following sections
    - High Level Sales Analysis 
        * Total Product Counts
        * Revenue pre/post discount
    - Transaction Analysis
        * Unique Transactions
        * Percentile Values for Revenue Per Transaction
        * Percentage Split of Member vs Non-Members
    - Product Analysis
        * Top Products by total revenue
        * Quantity, Revenue, and Discount Totals by Segment
        * Total Transaction Penetration Per Product
        * Product Unique Combination Rankings 
            - Recursive CTE
    - Table Reconstruction from Series of Self Joins and Foreing Key Table
        *  The last section challenges us to deconstruct two tables to generate a current product table representation
* **`Case Study Files`** 
    * [Balanced Tree Clothing Challenge](/Sql_Challenges/7_BalancedTreeClothing/BalancedTreeCStudy.md)
    * [Balanced Tree Individual Queries](/Sql_Challenges/7_BalancedTreeClothing/balanced_tree_case.sql)

<br>

### `8 - Fresh Segments` 🥭
* Danny created **Fresh Segments**, a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.
* Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.
    - In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.
* Danny has asked for your assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.
* **Case Study Questions** : The following questions can be considered key business questions that are required to be answered for the Fresh Segments team.
    * Data Exploration & Cleansing
        - Table Alterations, Column Mutations
        - Shared Index Analysis for Interest_ID Mapping
        - Null Handling Scenarios & Table Join Considerations
        - Data Creation / Index Setting prior to Data Collection 
    * Interest Analysis
        - Distributed Data and Available Data from Unique InterestIDs 
        - Cumulative Percentage of Unique InterestIDs available data makeup
        - Unique InterestIDs per month
        - Possible Data Point Omission through cumulative percentage of uniuqe interstID key contributing data points and filtering of less seen observations
    * Segment Analysis
        - Top Composition Segmenting By Unique Interests, CTE chained to Union Output w/subsequent Ranking of Segments
            * Non Repeating Interests for Uniqueness of Values
        - Lowest Average Percentile Ranking By Aggregated Interest Metric Data
        - Largest Standard Deviation for Interests with 5 months at least of reporting data
    * Index Analysis 
        - Moving Average for Composition Ranking in 3 Month Period
        - Monthy Ranking of Top 10 Interests Per Month
        - Average Composition for Top 10 Interest Per Month Ranked
* **`Case Study Files`**
    * [Fresh Segments Challenge](/Sql_Challenges/8_FreshSegments/Fresh_Seg_Cstudy.md)
    * [Fresh Segments Individual Queries](/Sql_Challenges/8_FreshSegments/Fresh_Seg_Cstudy_qs.sql)




