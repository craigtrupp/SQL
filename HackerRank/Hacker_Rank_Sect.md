## HackerRank SQL Challenges 🧑‍💻
* Starting SQL practice and challenges to stay sharp here with my fave, SQL.
* [HackerRank Profile](https://www.hackerrank.com/craigtrupp8)

---

### **Challenges Defined** 🥇
* Challenges and individual SQL queries only added to subsequent file below after passing test cases on platform
* Well ... found something fairly let's say "odd" on the platform, the SQL version in the IDE is not always consistent and thus I just spent 20 minutes realizing my syntax wasn't wrong but the SQL version() was lower than 8 which doesn't support window functions
    - Long story, short .. use the below SQL query to check the VERSION is **`8+`** and can support Window Functions
```sql
-- Check Version
SELECT VERSION();

-- Output   
5.7.27-0ubuntu0.18.04.1 
```
* The platfrom test for the following sub-domains at an **Entry/Easy, Medium, and Hard** difficulty setting
    - Select 🎱
    - Advanced Select 🎱 :heavy_plus_sign:
    - Aggregations 🔢
    - Basic Join ⛓️
    - Advanced Joins ⛓️ ➕
    - Alternative Queries :accept:

<br>

### **Files Locations** 📁
* #### **`Entry/Easy` SQL Difficulty Section**
    - Will highlight a few of these challenges following completion of the **`Difficulty - Easy`** section as all but 3 of the challenges for this Difficulty Setting are classified on the platform Under the Skill section as `SQL (Basic)`
        - **`Weather Observation Station 5`** - `SQL (Intermediate)` marked in this file [Weather Challenges - First Challenges](/HackerRank/diff_easy/weather_chall_easy.sql)
        - **`Draw the Triangle 1`** - `SQL (Advanced)`
    - **[Weather Challenges - First Challenges](/HackerRank/diff_easy/weather_chall_easy.sql)**
    - **[Second Set](/HackerRank/diff_easy/second_set.sql)**
        * Good Question on Triangle Defining and **CASE/WHEN** from a CTE - See sql query for more details on questions
    - **[Third Set](/HackerRank/diff_easy/third_file_measy.sql)**
        * "The Blunder" and "Top Earners" were challenges worth more points
            * These two including CAST'ing, dervied (subqueries), and SQL method chaining for cleaning up errors
    - **[Fourth Final Set](/HackerRank/diff_easy/final_section_challs.sql)**
        * Basic Joins
        * Use of **FLOOR** for agg average of joined rows for countries and continent data

<br>

### **Certifications**
[Basic - Platform Assesmment](https://www.hackerrank.com/certificates/657e0d176ccc)