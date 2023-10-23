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
    
    * [**`HackerRankings`**](/HackerRank/diff_medium/hacker_rankings.sql)
        - **`Hacker Challenges Rankings`** = So ... because these files are getting pretty lengthy, we're just gonna do a challenge per file. For this particular challenge we are ranking users from a join on the `hacker_id` to `challenges_created` and ranking off of the challenges created by those users. With the output requirement, we are needing to isolate any users not with a top ranking (so most challenges created) being unique. Any hackers who have created the same amount of challenges but are not a top ranked user (in terms of challenges created) are to be excluded from the output. Long story short, exclude any non top ranked users who don't have a unique amount of challenges created.
    * [**`Hacker Rankings - Contest Leaderboard`**](/HackerRank/diff_medium/hacker_cleaderboard.sql)
        - **`Contest Leaderboard`** - This one is fairly straightforward but the version restriction doesn't allow for CTE or Ranking functions. The hacker can submit multiple times for the same challenge id so it's just a multiple aggregation in terms of finding the max score for a hacker's submitted challenge (group by hacker_id, name, challenge_id). Then from this derived value (within the subquery) we can sum the total of each of the hacker's max score from every challenge and order by the output needed for the challenge to pass. Recall any derived(subquery) must be named.
    * [**`SQL Project Planning `**](/HackerRank/diff_medium/sql_project_planning.sql)
        - **`Advanced Join - Project Planning`** A fair bit to review here but a way of using a sequence of unique start & end values as joining partners then ordering by a date difference of our unique start and end dates. 
            - As consecutive dates are designated as being log entries for the same project. Our query looks at creating a unique head (start_dates) and unique tail (end_dates) where each date is not within the other column
            - Using a Ranking function for our unique end and start dates, we can later join on the ranked value in a chained CTE manner to create a query to output the start and end dates of projects listed by the number of days it took to complete the project in ascending order. Note that ties for the same amount of days between projects is based by past dates (or earlier in the year). See query attached for further details
        - `Sample Input/ Output`

        |Task_id|Start_Date|End_Date|
        |----|------|------|
        |1|2015-10-01|2015-10-02|
        |2|2015-10-02|2015-10-03|
        |3|2015-10-03|2015-10-04|
        |4|2015-10-13|2015-10-14|
        |5|2015-10-14|2015-10-15|
        |6|2015-10-28|2015-10-29|
        |7|2015-10-30|2015-10-31|

        |Start_Date|End_Date|
        |-----|-------|
        |2015-10-28| 2015-10-29|
        |2015-10-30| 2015-10-31|
        |2015-10-13| 2015-10-15|
        |2015-10-01| 2015-10-04|

    * [**`SQL Placements`**](/HackerRank/diff_medium/placements.sql)
        - **`Advanced Join - Student/Friend Placement`** : Challenge was intended to generate a table output which detailed using shared id tables for values of interest. For example, we needed the salary of both the student and friend data in need so we can use multiple joins on the same table and be explict about which value to match on and alias the same table twice to reference values from multiple rows in the salary table to multiple ids on the same row. This then allows for easier comparison which the query is ultimately after in its' output. 
            - `Takeaways` : 
                * You can either use a CTE and chained type of table joins to reference an id value in multiple ways as it pertains to the belonger of the id. **`ex`** : StudentID is noted in a FriendTable as a Friend_Id. You can use the friend_id to declare a student's friend than use the output from that join to look back up to the student to just get the student details
                * Also, when needing to reference the id value for a value type of pull on the same row, you can reference the table in two separate joins by aliasing the table twice to reference one Id value for a salary as opposed to another id on the same row for a different salary by simply opening up two left joins for the Ids to get each salary output on the same row
    
    * [**`Symmetric Pairs`**](/HackerRank/diff_medium/sympairs.sql)
        - **`Advanced Join - Coordinate Pairs`** - This used a union all statement initially to create a duplicated table output in which we swapped X and Y to live on one larger table. After Union all (needed for potential duplicate coordinate pairs) with the column swapping, we can use a grouping statement with column indexing position on the doubled table to give us a count for the coordinate pairs. Next, in order to filter or **single** duplicated pairs from the union all, we can filter on the coordinate counts being greater than a simple duplicate (2) or the other pairs we're after with X and Y not being equal and their grouped counts being greater than 2. We wouldn't want just any pair of X not equaling Y as when we swap the positions, there will be instances were there are generated pairs that have no mirrored counterpart and are simply unique coordinates, the multiple where filtering handles that. From the lines 45 down is where we are at in the logic and output. This provides the symmetric pair and a count (which has been duplicated with our union all). Now we need to find a way to **group** these coordinate pairs as we simply want one instance of the symmetric pair with the lowest x value. To achieve this, I did a `CASE/WHEN` statement to declare the min/max coordinate value of any pair which we can then group for to .. in a sense half our table and join the pairs together. With the symmetric pairs now designated for their min/max value and grouped/joined, we can output the pairs that had the lowest value to match the desired output for the challenges.
            - `Takeaways`:
                * When looking for pairs, we can use UNION  or UNION all type statement to create a table that while duplicated, has swapped the positional values of **coordinates** that thus allows for subsequent grouping 
                * With the unique pairs generated and with any duplicated pairs (duplicated in a single table and doubled in the union all statement) we can use filtering to remove any simply unique coordinates (wouldn't have a match when swapping their X and Y value in the union all output) as well as duplicated coordinates that would match just that 1 time so making for 2
                    - Where clause in CTE `filtered_pairs` accounts for this
                    - First part of condition is to capture duplicates that would have been duplicated in the same table and thus is a simple `gt > 2` type check on the aggregated column
                * I got a little stuck here and had the output for the unique pairs now in both orders (both sets of pairs)
                    - To combat this I did a `CASE/WHEN` to uniquely set the min/max value for each coordinate pair which allowed me to then group by those coordinate values to combine the coordinate pairs into one single row of output I could use
                    - The aggregate `ROUND(COUNT(*) / 2)` column was just a little fun I had with setting the pair count
                        - This wasn't needed for the output and I'd likely have to check my logic for counting of pairs but just a bit of fun for how an aggregated value for a grouped statistic can be mutated
            
<br>

### **Certifications**
[Basic - Platform Assesmment](https://www.hackerrank.com/certificates/657e0d176ccc)