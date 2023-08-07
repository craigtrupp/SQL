# Balanced Tree Clothing Company
![btree](images/Balanced_Tree.png)

<br>

### **Introduction**
Balanced Tree Clothing Company prides themselves on providing an optimised range of clothing and lifestyle wear for the modern adventurer!

Danny, the CEO of this trendy fashion company has asked you to assist the team’s merchandising teams analyse their sales performance and generate a basic financial report to share with the wider business.

<br>

### **Available Data**
For this case study there is a total of 4 datasets for this case study - however you will only need to utilise 2 main tables to solve all of the regular questions, and the additional 2 tables are used only for the bonus challenge question!

<br>

`Product Details`
* `balanced_tree.product_details` includes all information about the entire range that Balanced Clothing sells in their store.

|product_id|price|product_name|category_id|segment_id|style_id|category_name|segment_name|style_name|
|----|----|----|-----|-----|-----|----|----|-----|
|c4a632|13|Navy Oversized Jeans - Womens|1|3|7|Womens|Jeans|Navy Oversized|
|e83aa3|32|Black Straight Jeans - Womens|1|3|8|Womens|Jeans|Black Straight|
|e31d39|10|Cream Relaxed Jeans - Womens|1|3|9|Womens|Jeans|Cream Relaxed|
|d5e9a6|23|Khaki Suit Jacket - Womens|1|4|10|Womens|Jacket|Khaki Suit|
|72f5d4|19|Indigo Rain Jacket - Womens|1|4|11|Womens|Jacket|Indigo Rain|

<br>

`Product Sales`
* `balanced_tree.sales` contains product level information for all the transactions made for Balanced Tree including **quantity, price, percentage discount, member status, a transaction ID** and also the **transaction timestamp**.

|prod_id|qty|price|discount|member|txn_id|start_txn_time|
|----|----|----|----|----|----|-----|
|c4a632|4|13|17|true|54f307|2021-02-13 01:59:43.296|
|5d267b|4|40|17|true|54f307|2021-02-13 01:59:43.296|
|b9a74d|4|17|17|true|54f307|2021-02-13 01:59:43.296|
|2feb6b|2|29|17|true|54f307|2021-02-13 01:59:43.296|
|c4a632|5|13|21|true|26cc98|2021-01-19 01:39:00.346|

<br>

`Product Hierarcy & Product Price`
Thes tables are used only for the bonus question where we will use them to recreate the **balanced_tree.product_details table**.


- balanced_tree.product_hierarchy

|id|parent_id|level_text|level_name|
|-----|-----|-----|-----|
|1|null|Womens|Category|
|2|null|Mens|Category|
|3|1|Jeans|Segment|
|4|1|Jacket|Segment|
|5|2|Shirt|Segment|

<br>

- balanced_tree.product_prices

|id|product_id|price|
|----|----|----|
|7|c4a632|13|
|8|e83aa3|32|
|9|e31d39|10|
|10|d5e9a6|23|
|11|72f5d4|19|

---

<br>

### **Case Study Questions**
The following questions can be considered key business questions and metrics that the Balanced Tree team requires for their monthly reports.

Each question can be answered using a single query - but as you are writing the SQL to solve each individual problem, keep in mind how you would generate all of these metrics in a single SQL script which the Balanced Tree team can run each month.

<br>

#### `A. High Level Sales Analysis`

**1** What was the total quantity sold for all products?
**2** What is the total generated revenue for all products before discounts?
**3** What was the total discount amount for all products?