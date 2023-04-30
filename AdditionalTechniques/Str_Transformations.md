## String Transformations
This tutorial is going to be a fast paced example based guide which covers the following SQL string manipulation skills and concepts:

* String Functions
* Pattern Matching
* Regular Expressions

This tutorial will focus on simple manual data entries as well as data from the rentals schema that we also used for our Marketing Analytics case study.

---

<br>

### `Basic String Methods`
* First `N` Characters
```sql
SELECT
    LEFT('AVPCDEF');
```
|left|
|----|
|AVP|
```sql
SELECT
  LEFT(description, 51) AS short_description
FROM dvd_rentals.film
WHERE film_id = 14;
```
|short_description|
|------|
|A Emotional Drama of a A Shark And a Database Admin|

<br>

* Last `N` Characters
```sql
SELECT RIGHT('ABCDEFG', 3);
```
|right|
|---|
|EFG|
* Can CAST a numeric value should you want to use either **RIGHT** or **LEFT**
```sql
SELECT RIGHT(123456::TEXT, 3);
```
|right|
|---|
|456|

<br>

### `Substring By Position`
A substring is essentially a part of an existing string - the `SUBSTRING` function can be used with a start position integer parameter to specify which character to start the substring and a following length parameter to extract the following characters from the start position.

```sql
-- Return the next 10 characters from the description field from position 3 for film_id 22
SELECT 
  film_id,
  title,
  description,
  SUBSTRING(description, 3, 10)
FROM dvd_rentals.film
WHERE film_id = 22;
```
|film_id|title|description|substring|
|----|----|-----|----|
|22|AMISTAD MIDSUMMER|A Emotional Character Study of a Dentist And a Crocodile who must Meet a Sumo Wrestler in California| Emotional|

<br>

### `Character Length`
* What is the max number of characters in the description field and which film(s) share that max_length for description?
```sql
WITH max_film_desc AS (
SELECT
  MAX(CHAR_LENGTH(description)) AS max_film_description
FROM dvd_rentals.film
)
SELECT
  film_id,
  title,
  LEFT(description, 20) AS start_description,
  CHAR_LENGTH(description) AS description_length
FROM dvd_rentals.film 
WHERE CHAR_LENGTH(description) = (SELECT * FROM max_film_desc);
```
|film_id|title|start_description|description_length
|----|-----|------|-----|
|116|CANDIDATE PERDITION|A Brilliant Epistle|130|
|217|DAZED PUNK|A Action-Packed Stor|130|

<br>

### `Starting Position Of Text`
* Basic Usage
```sql
SELECT POSITION('a' in '12345a');
```
|position|
|---|
|6|

    * Note here is the 1 starting index and not zero

* What position does the word ‘Astronaut’ have in the description from the film called ANGELS LIFE?
```sql
SELECT 
  film_id,
  title,
  POSITION('Astronaut' in description) AS string_start_in_desc,
  SUBSTRING(description, POSITION('Astronaut' in description), CHAR_LENGTH('Astronaut')) AS entire_position_string
FROM dvd_rentals.film
WHERE title LIKE '%ANGELS LIFE%';
```
|film_id|title|string_start_in_desc|entire_position_string|
|----|-----|-----|------|
|25|ANGELS LIFE|39|Astronaut|

<br>

### `Convert to Lower Case`
* Basic Usage
```sql
SELECT LOWER('ABD');
```
|lower|
|---|
|abd|

* Using a CTE show the first 30 characters from the description and also the lower case version for film_id = 14
```sql
WITH film_id_14 AS (
SELECT
  film_id,
  title,
  LEFT(description, 30) as desc_first_30
FROM dvd_rentals.film
WHERE film_id = 14
)
SELECT
  film_id,
  title,
  desc_first_30,
  LOWER(desc_first_30) AS to_lower_desc
FROM film_id_14;
```
|film_id|title|desc_first_30|to_lower_desc|
|----|----|----|----|
|14|ALICE FANTASIA|A Emotional Drama of a A Shark|a emotional drama of a a shark|

<br>

### `Convert to Upper Case`
* Using a subquery, show the first 20 characters from the first time ‘Shark’ is mentioned in the description field and also the upper case version for film_id = 14
```sql
SELECT
  first_20_after_shark,
  UPPER(first_20_after_shark)
FROM (
  SELECT
    film_id,
    title,
    SUBSTRING(description, POSITION('Shark' in description), 20) AS first_20_after_shark
  FROM dvd_rentals.film
  WHERE film_id = 14
) AS subquery;
```
|first_20_after_shark|upper
|----|----|
|Shark And a Database|SHARK AND A DATABASE|

<br>

### `Title Case`
* Basic Usage
```sql
SELECT INITCAP('a friendly hello to the world!');
```
|initcap|
|---|
|A Friendly Hello To The World!|

* USE CTE for first and last 17 characters of description, then use title casing
```sql
WITH first_last_17 AS (
SELECT 
  LEFT(description, 17) AS first_17,
  RIGHT(description, 17) AS last_17
FROM dvd_rentals.film
WHERE film_id = 14
)
SELECT
  first_17,
  INITCAP(first_17) AS init_first,
  last_17,
  INITCAP(last_17) AS init_last
FROM first_last_17;
```
|first_17|init_first|last_17|init_last|
|-----|-----|-----|-----|
|A Emotional Drama|A Emotional Drama|in Soviet Georgia|In Soviet Georgia|

<br>

### `Formatting Strings`
We can also adjust the format of non-text fields to convert them into a formatted string using the `TO_CHAR` function.

Let’s say we want to apply thousand separator formatting to our large numbers and also add in that dollar sign, just like we saw briefly in our HR Analytics case study.

You can use a variety of different inputs - the most important thing is to note the `total length` of the specified output format. We will see how this makes a difference in the following example.

The **FM** in the code below stands for fill mode which suppresses leading and trailing characters.

```sql
WITH numbers (column1) AS (
VALUES
  (123456789),
  (1234567890),  -- What do you think will happen?
  (123456.789),
  (1000),
  (100)
)
SELECT
  -- how many characters is our format below?
  TO_CHAR(column1, '$FM999,999,999')
FROM numbers;
```
|to_char|
|----|
|$123,456,789|
|$###,###,###|
|$123,457|
|$1,000|
|$100|

* Specified character representation for the second argument in the function call (start after FM designation) would only allow for values with 9 or less values in the string being transofrmed into a character

<br>

### `Padding Strings`
A very common transformation for product related data analytics teams is to “pad” the product numbers of a specific column to make the final output into a specific character length.

Using the following example data - let’s write a query to extract the numbers to the left of the `-` character and then we will try to “pad” our numbers with 0’s to create a final `product_id` column of character length 6.

* Ex Data
```sql
WITH products (product_code) AS (
VALUES
  ('1234-BOX'),
  ('3421-EACH'),
  ('35895-PACK'),
  ('451884-CARTON')
)
SELECT * FROM products;
```
|product_code|
|---|
|1234-BOX|
|3421-EACH|
|35895-PACK|
|451884-CARTON|

* Idea here is to use the `LPAD` function to take all values to the left of the **-** hyphen and pad with a 0 should the values not equate to a char_length of 6 

```sql
WITH products (product_code) AS (
VALUES
  ('1234-BOX'),
  ('3421-EACH'),
  ('35895-PACK'),
  ('451884-CARTON')
)
SELECT
  LPAD(
  -- Get the product code from the start to the position of the hyphen
    SUBSTRING(product_code, 0, POSITION('-' in product_code)),
  -- the max length of our padded output column
    6,
  -- the character we will use to "pad" our input text
    '0'
  )
FROM products;
```
|lpad|
|---|
|001234|
|003421|
|035895|
|451884|

* Another way using `LEFT`

```sql
WITH products (product_code) AS (
VALUES
  ('1234-BOX'),
  ('3421-EACH'),
  ('35895-PACK'),
  ('451884-CARTON')
)
SELECT
  LPAD(
  -- input text we want to apply the padding on, in this case it's a LEFT output
    LEFT(
      product_code,                       -- column target
      POSITION('-' IN product_code) - 1  -- subtract 1 from the position of dash
    ),
    6,   -- the max length of our padded output column
    '0'  -- the character we will use to "pad" our input text
  ) AS product_id
FROM products;
```