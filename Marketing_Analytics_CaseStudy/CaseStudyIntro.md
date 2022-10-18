# Marketing Analytics Case Study
In this second section of the technical components for this Serious SQL course we turn our attention to business problem solving within the marketing analytics space through a guided case study.

The aim of this case study is to further your learning by providing you with realistic business problems to solve utilizing only SQL.

These examples should both challenge you and expand your data skills by demonstrating how we can deploy simple algorithmic thinking, reverse engineering and most importantly - thinking in SQL - to solve problems!

---

<br>

## Why Case Studies?
To make these examples as close to real life as possible, new techniques will sprinkled throughout this section in a totally non-linear path.

In the **real world** - you won’t always have the luxury to learn everything sequentially like we’re taught in school, so this bouncing around from concept to concept will help you familiarize yourself with the current challenges in the data world!

The focus of these case studies is to help improve your business awareness and continue honing your SQL skills by reverse engineering expected outputs from raw data inputs.

Actually, this exact method of working backwards from an expected output from certain inputs is pretty much the same way we would tackle similar problems in the workplace. This is not just when using SQL for data analytics, but this extends to a wider range of programming problems where we may know what we need as outputs, and we simply need to figure out how to get from A to B!

---

<br>

## Learning Outcomes
The following SQL skills and concepts will be covered in this section of the Serious SQL course:

1. Learning how to interpret `ERDs` for data literacy and business context (**entity-relationship diagrams**)
    + Identify key columns of interest and how they are linked to other tables via foreign keys
    + Use ERDs to analyze the data types for different columns in database tables
    + Understand data context for various tables that cause inherent natural relationships between fields

2. Introduction to all types of **table joining** operations
    + Simple joins: left, inner
    + More involved joins: cross, anti, left-semi, full outer
    + Combination set operations: union, union all, intersect, except

3. Practical application of table joins
    + Joining multiple tables to combine disparate datasets into a single data structure
    + Joining interim SQL outputs for more advanced group-by, split, merge data hacking strategies
    + Performing table joins that use 2 or more table references in the ON condition
    + Using anti joins to exclude records in a sequential fashion

4. Filtering, window functions and aggregates for analytics and ranking
    + Using `ROW_NUMBER` to effecively rank order records with equal ties
    + Using `WHERE` filters to extract ranked records
    + Using multiple aggregate functions with different target partitions and ordering expressions for efficient data analysis
    + Using aggregate group by clauses to generate unique customer level insights

5. Case statements for data transformation and manipulation
    + Pivoting datasets from long to wide using MAX and CASE WHEN
    + Manipulating actual data values using conditional logic for business translation purposes

6. SQL scripting basics
    + Designing SQL workflows which can be easily understood and implemented
    + Managing multiple dependencies for downstream table joining operations by using temporary tables to store interim datasets

7. Manipulating text data
    + Converting text columns to title case
    + Combining multiple text and numeric data type columns into a single text expression