<h1 style="text-align: center;">Serious SQL</h1>

![Learning Path](images/course_outline.png)

**Data with Danny** offers a robust path to learning, understanding and most importantly using `SQL` to display its' utility in any data career seeker journey! Below is a quick guide to the repository details and paths within the repository. A huge thank you to Danny for this truly magnificient class and challenging case studies for revealing the value in databases and what SQL can extract! Please see below for the following items
* Data Schemas used throughout the course (educational and sql challenges) - [Data](#data-used-in-course)
* Course Education Items and Case Study Walkthroughs - [Educational Content](#course-lecturecase-study-walkthroughs)
* SQL Challenges - [Mock Business SQL Challenges](#case-study-challenges)


---

## `Repository Contents 🗄️`
### **Data Used In Course**
* As a note, the `Docker YML` file can also be found within this repository at [Docker YML](/DD_SrSQL/serious-sql/docker-compose.yml) for access to the data used in the course material and subsequent case study challenges for each.
    - After running the **docker-compose up** command in your terminal, you can access the data model schemas and review the schemas with the **SQLPad GUI** accessable at your local host - `http://localhost:3000`
* Alternatively, you can run the following script within a **BigQuery sandbox** and avoid Docker to access the data used. Brief steps below for the **Free** Sandbox setup and sql file unpackaging into your sanbox-sql project 
    - [Big Query Sandbox Setup](https://cloud.google.com/bigquery/docs/sandbox)
    - [Script for Data Import](/DD_SrSQL/big-query-script/sandbox_script.sql)

<br>

### **Course Lecture/Case Study Walkthroughs**
* **[Data Exploration Section](/Data%20Exploration)**
    - Within this section of the repository you can find common SQL techniques and a mini case study in which we get to put them to work
    - `Techniques` 🤹‍♂️ 
        * Select & Sort, Summary Statistics, Record Counts & Distinct Values
        * Distribution Functions, Duplicate Identification & Handling
    - `Health Analytics Case Study` 🥼
        * [Health Analytics Case Study](/Data%20Exploration/HealthAnalytics_CaseStudy_Mini)
    - `Section Summary` 🖇️
        * [Section Summary](/Data%20Exploration/Summary_Notes/First_Section_Review.md)

<br>

* **[Marketing Analytics Section](/Marketing_Analytics_CaseStudy/)** 
    - This second section of the course turns to a sample business request and how the path to understanding and using our data can be leveraged to accomplish this sample business request.
    - The final solution was crafted with the following `techniques` 🤹‍♂️ 
        * Window Functions, Practical Application of Different Types of Table Joins, Case Statements for Data Transformation/Manipulation, Table Creation
    - `Data Overview` :page_with_curl:
        * Review Schema and **ERD** for Tables used in final solution development
        * [Data & ERD Overview](/Marketing_Analytics_CaseStudy/Understanding_Data.md)
    - `Case Study Overview, Business Request & Table Join Analysis` 🧾
        * Using the ERD this markdown file highlights the Objective of the Case Study as well as the framework for analyzing table joins
        * [Overview, Request & Join Analysis](/Marketing_Analytics_CaseStudy/MultipleTableJoins_CStudyReview.md)
    - `Case Study Solution - Deliverable SQL Script` :envelope_with_arrow:
        * Within the report section of the markdown file you can find the sql script that would be used to create the table for data insights 
        * [Case Study Solution](/Marketing_Analytics_CaseStudy/Sql_ScriptingSol.md)

<br>

* **[People Analytics Case Study](/People_Analytics)**
    - The second complete SQL case study mocks us assisting **HR Analytica** to construct datasets to answer basic reporting questions and also feed their bespoke People Analytics dashboards.
    - A heavry emphasis on creating **reusable data assets** mostly achieved through **VIEWS**
    - `Case Study Overview and Initial Data Exploration` 📃
        * [Overview & Explore](/People_Analytics/CaseStudy_Intro.md)
    - `Reusable Data Assets & Views` ♻️
        * [Data Assets & Views](/People_Analytics/DataAssets_Views.md)
    - `Historical Data & SCD` ⏲️
        * Idea of better understanding slowly changing dimensions
        * [Historical Data / SCD](/People_Analytics/SnapShot_HistoricData.md)
    - `Case Study Solution` 📑
        * [Cumulative Solution Markdown & Test Questions](/People_Analytics/HR_AnalyticsCStudy.md)

<br>

* **[Additional Techniques](/AdditionalTechniques)**
    - This particular short section looks into common approaches for 
        - **String Transformation & Functions** 🧵
            * Basic String Methods, Pattern Matching, RegEx
            * [String Techniques](/AdditionalTechniques/Str_Transformations.md) 
        - **Date and Time Conversion** 📅
            * Date Manipulation, Timestamp Manipulation, Time Zone Case Study (Brief), Aggregating on Date Intervals
            * [Date & Time](/AdditionalTechniques/Date_Time_Transformations.md)

<br>

### **Case Study Challenges**
* **[SQL Challenges](/Sql_Challenges)**
    - Each image below will link to the Case Study for each Challenge
        - Within easy case study file is a markdown file detailing the challenges/questions and data schema used as well as a stand-alone sql file with the queries for the solutions to the case study items
    - **[Section Markdown](/Sql_Challenges/SqlChallenges.md)**
        - Review of the 8 Week Challenge 

<p align="center">
    <a href="/Sql_Challenges/1_DannyDiner/Danny_Diners_Challenge.md">
        <img alt="Danny's Diner" src="images/cs_1.png"
        height="160" width="160">
    </a>
&nbsp; &nbsp;
    <a href="/Sql_Challenges/2_PizzaRunner/Pizza_Runner.md">
        <img alt="Pizza Runner" src="images/cs_2.png" height="161" width="161">
    </a>
&nbsp; &nbsp;
    <a href="/Sql_Challenges/3_Foodie_Fi/Foddie_Fi.md">
        <img alt="Foodie Fi" src="images/cs_3.png" 
        height="160" width="160">
    </a>
&nbsp; &nbsp;
    <a href="/Sql_Challenges/4_DataBank/Data_Bank_CStudy.md">
        <img alt="Data Bank" src="images/cs_4.png" 
        height="160" width="160">
    </a>
</p>

<br>

<p align="center">
    <a href="/Sql_Challenges/5_DataMart/DataMart_CS.md">
        <img alt="Data Mark" src="images/cs_5.png"
        height="160" width="160">
    </a>
&nbsp; &nbsp;
    <a href="/Sql_Challenges/6_CliqueBait/CBAttenCapturing.md">
        <img alt="Clique Bait" src="images/cs_6.png" height="160" width="160">
    </a>
&nbsp; &nbsp;
    <a href="/Sql_Challenges/7_BalancedTreeClothing/BalancedTreeCStudy.md">
        <img alt="Balanced Tree" src="images/cs_7.png" 
        height="160" width="160">
    </a>
&nbsp; &nbsp;
    <a href="/Sql_Challenges/8_FreshSegments/Fresh_Seg_Cstudy.md">
        <img alt="Fresh Segments" src="images/cs_8.png" 
        height="160" width="160">
    </a>
</p>

<br>

### **HackerRank** 🧑‍💻
* Keeping sharp and completing SQL challenges on the platform
* [Quick Section Details](/Data_SQL_Srs/Serious_SQL/HackerRank/Hacker_Rank_Sect.md)
