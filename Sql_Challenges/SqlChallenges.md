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

### `1 - Danny's Diner` 🥡
* Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 
* Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers. 
* The Dataset (Schema), ERD (Entity Relationship Diagram), and Case Study Questions can be found here : [Danny's Diner Challenge](/1_DannyDiner/Danny_Diners_Challenge.md)

<br>

### `2 - Pizza Runner` 🍕
* This Case Study looks to analyze various different sections in Danny's Pizza business
    - Pizza Metrics
    - Runner & Customer Expereince
    - Ingredient Optimization
    - Pricing and Ratings
* This challenge includes several examples of multiple joins, conditional `SUM CASES`, temp table creation, regex pattern and table creation as well as data cleanup for incomplete or incosistent data values across the database schema
* [Pizza Runner Challenge](/2_PizzaRunner/Pizza_Runner.md)

<br>

### `3 - Foodie Fi` 🥑
* Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!
* Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. This case study focuses on using subscription style digital data to answer important business questions.
* While this is a smaller data schema and relational model, the presence of SCD (slowly changing dimensions) offers unique challenges to aggregate or finding leading/trailing data for our customer data
* This challenge also introduces **distribution** functions used to bin customers and their event history for clearer insights on customer behavior
* [Foodie Fi Subscription Challenge](/3_Foodie_Fi/Foddie_Fi.md)

<br>

### `4 - Data Bank` 🏦
* This particular challenge mocks the management team at **Data Bank** looking to increase their total customer base by helping just how much data storage their customers would need
* Sections covered in this challenge focused on
    - Customer Metrics for Transaction and Node Usage
    - Descriptive Percentile and Statistic for Node Usage over different Partitions/Groups
    - Customer Transaction & Balance History over changing time dimensions
    - Threshold consideration for comparisons of balances in adjacent months
* Such approaches like `leading/lag window functions`, `generated series` for interval mocking, `conditional aggregate` functions for transaction determinstic values helped in the preparation of the customer & transaction data requested in the case study.
    - Window functions also included partitioned sections for customer balances and determining of activity against lagging balances
* [Data Bank Customer Challenge](/4_DataBank/Data_Bank_CStudy.md)

<br>

### `5 - Data Mart` 🛒
* Within this challenge, our case study covers a theoretical sales performance for Danny's online supermarket.
* Key business questions center around the following topics
    - Quantifiable impact of changes introduced for a particular time period
    - Platform, Region, Segment, & Customer Type impact by mocked change and subsequent data over different periods
* Tasks also included `Data Cleansing` to generate a new table within the schema for easier data aggregation and metrics for the mentioned subsets above
    - Type Casting
    - Date Segmenting 
    - Finer Data Points and Clarifying Text Representation
    - Conditional Type setting from sql function returns on uncleansed data
* The Data Exploration looks to use the date values and is most resourceful through our ability to partition and generate summary statistics by partitioned values like **calendar_year** over different demographics
* https://github.com/craigtrupp/SrsSQL/blob/main/Sql_Challenges/5_DataMart/DataMart_CS.md
* [Data Mart Challenge](/5_DataMart/DataMart_CS.md)


<br>

### `6 - Clique Bait` 🖱️
* In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.
* This is a heavily involved case study and start with a request to create an `ERD` based on provided data in a schema. The ERD can be found here and is also available directly through DB Diagram
    - https://github.com/craigtrupp/SrsSQL/blob/main/Sql_Challenges/6_CliqueBait/images/clique_bait_schema.png
    - https://dbdiagram.io/d/64c8195a02bd1c4a5e01a62c
    - Within the markdown file below, the `DDL` language can also be seen for the table relationship definition as well as potential Indexes for improved performance
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
* [Clique Bait Challenge](/6_CliqueBait/CBAttenCapturing.md)

<br>

### `7 - Balanced Tree Clothing` 🌳
* Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their 
    - sales performance and generate a basic financial report to share with the wider business.
* Case Study Questions include the following sections
    - High Level Sales Analysis
    - Transaction Analysis
    - Product Analysis
* The last section challenges us to deconstruct two tables to generate a current product table representation 
* [Balanced Tree Clothing Challenge](/7_BalancedTreeClothing/BalancedTreeCStudy.md)





