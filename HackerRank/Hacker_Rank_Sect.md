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
        - **`Draw the Triangle 2`** - `SQL (Advanced)`
            * Both are in the same file at the end 
            * [Draw the Triangle Procedures/Recursive CTE](/HackerRank/diff_easy/final_section_challs.sql)
    - **[Weather Challenges - First Challenges](/HackerRank/diff_easy/weather_chall_easy.sql)**
    - **[Second Set](/HackerRank/diff_easy/second_set.sql)**
        * Good Question on Triangle Defining and **CASE/WHEN** from a CTE - See sql query for more details on questions
    - **[Third Set](/HackerRank/diff_easy/third_file_measy.sql)**
        * "The Blunder" and "Top Earners" were challenges worth more points
            * These two including CAST'ing, dervied (subqueries), and SQL method chaining for cleaning up errors
    - **[Fourth Final Set](/HackerRank/diff_easy/final_section_challs.sql)**
        * Basic Joins
        * Use of **FLOOR** for agg average of joined rows for countries and continent data
        * Procedures and Looping Syntax for final challenges

<br>

* #### **`Medium` SQL Difficulty Section**
    * [**`First Medium Set`**](/HackerRank/diff_medium/first_medium_set.sql)
        - **THE PADS** - Text Manipulation combined WITH Union'ing of aggregate values CONCATENATED to create single column output
        - **Occupation** - CASE/WHEN structure for row setting of all values in table by occupation followed by a Window function to rank the Name alphabetically for each occupation. Then to create a single table with multiple column output, we group by the window function result to pair the top ranking names alphabetically for each Occupation on the same row and use the COALESCE (which requires an agg function on a string - just a hack to get a return) to use the value for the row ranked occupation or null should one occupation have more results for names than another
        - **Binary Tree Nodes** - Here we used a way of initially identifying the `Root` (Null for Parent) and `Leaf` (No Listed Parent of any other Nodes) to use an anti-join technique of **WHERE NOT EXISTS** for a self-join of the table's Nodes not existing in the same table anywhere as a Parent. Finally we could identify any `Inner` as the Node not being N in the union root and leaf CTE's
            ```sql
            leaf_nodes AS (
            SELECT
                *, 'Leaf' AS Tree_Description
            FROM BST AS lnodes_1
            WHERE NOT EXISTS (
                SELECT
                    1
                FROM BST AS lnodes_2
                WHERE lnodes_1.n = lnodes_2.p
                )
            )
            ```
    * [**`Second Medium Set`**](/HackerRank/diff_medium/second_medium_set.sql)
        - **New Companies** - Lower MYSQL Version so need to use a derived (subquery) to create a base table for then a distinct count of company figures in different tables which are all joined through a shared company_code
        - **Weather Observations**
            * Euclidean and Manhattan Distance 
            * Variation of Different Equations Based on two points which are the respective min/max values of the Longitude and Latitude 
            * `Median` values of LAT_N 
                - Did a few varieties of numeric and concatenated outputs here for a good idea of the flow and functionality of the CASE statements handling the median equation based on the count of the ordered cte. See below for context
                ```sql
                    WITH lat_n_ordered AS (
                    SELECT
                        LAT_N AS northern_latitude,
                        RANK() OVER(
                            ORDER BY LAT_N
                        ) AS latitude_ranking
                    FROM Station
                    WHERE LAT_N IS NOT NULL
                    ORDER BY latitude_ranking
                    )
                    SELECT
                        CASE 
                            WHEN (SELECT COUNT(*) FROM lat_n_ordered) % 2 = 0
                            THEN
                            CONCAT('N items was even with a median of : ' , ROUND(
                                (SELECT northern_latitude FROM lat_n_ordered
                                    WHERE latitude_ranking = (SELECT COUNT(*) FROM lat_n_ordered) / 2
                                ) + 
                                (SELECT northern_latitude FROM lat_n_ordered
                                    WHERE latitude_ranking = (SELECT COUNT(*) FROM lat_n_ordered) / 2 + 1
                                ) / 2
                            , 4))
                            ELSE
                            CONCAT('N items was odd with a median of : ', ROUND(
                                (SELECT 
                                    northern_latitude
                                FROM lat_n_ordered 
                                WHERE latitude_ranking = 
                                    FLOOR(
                                        ((SELECT COUNT(*) FROM lat_n_ordered) / 2) + 1
                                    ) -- 499 / 2 = 249.5 + 1 = 250.5 (FLOOR == 250)
                                )
                            , 4))
                        END AS median;
                ```
    * [**`Third Medium Set`**](/HackerRank/diff_medium/third_medium_set.sql)
        - **`The Report`** - This SQL challenge had a student and marks table that was joined based on the value their mark was between for a grade classifcation. Then based on a grade assigned from their mark range, either the student name was declared as Null or the student name. See further details for the sample output for a classificaiton of students and names
        - **`Top Competitors`** - This SQL challenge required a derived subquery joining multiple tables. Filltering was applied in the dervied/subquery for only selecting submissions for hacker who had achieved the max_score associated with the challenge pulled from the difficulty table. After the join path, a HAVING clause was used to ensure that the hacker had achieved a max_score on more than one challenge with a fairly straight forward order by path after that
        - **`Ollivander's Inventory`** - SQL Challenge for selecting wand with highest power for the least amount of galleons. Test cases detail a different answer than I currently have, submitting first then adjusting for change log history. 
            - Alright .... so theres a ton of comments in the code for this challenge
                * We have nested subqueries that we pull from (thanks for no CTE access ...ggrrr) that gives us the proper values we need for wands of a certain power at and age for minimum price
                * Next, there is a join on a subquery that gives us access to the fields for our subsequent where statement after the join on the subquery return
                    - Prior the queries final `where's` we'd have a massive table so it's alot of filtering
                    - Essentially its subqueries ... joined on subqueries which we then filter
                * Ranking would've been so much gd*** easier but we couldn't with the sql version in the provided challenge
<br>

### **Certifications**
[Basic - Platform Assesmment](https://www.hackerrank.com/certificates/657e0d176ccc)