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

---

<br>

## Pattern Matching
String pattern matching is truly an essential skill for SQL. There are a few key tools and tricks that we have up our sleeve for any text matching problem:

* Exact pattern matching with =
* Efficient fuzzy matching using `LIKE` for case sensitive and `ILIKE` for case insensitive
* Regular expressions or RegEx using the ~ for case sensitive and suffixed * (~*) for case insensitive matching
* Using NOT LIKE, NOT ILIKE, !~ and !~* for negative matches

<br>

### `Exact Pattern Match`
Exact pattern matching is something that you are already doing!

We can simply use the = in our WHERE filters and CASE WHEN statements to perform this exact match.

However the only thing to be aware of is that you need to have the text exactly correct including the lettercase, spaces and any punctuation!

```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!'),
  ('Hello to the world!'),
  ('Hello, world')
)
SELECT text_value
FROM test_data 
WHERE text_value = 'Hello World!';
```
|text_value|
|----|
|Hello World!|

<br>

### `Case Sensitive Fuzzy Matching`
Fuzzy matching refers to any sort of matching which is not straight exact matches

`LIKE` is a super powerful operateor we use extensively in any SQL dialect. Often with wildcards for fuzzy string matching 

A wildcard percentage sign **'%'** character can be used to replace **any number** of characters in a string field and an underscore wilcard **'_'** can be used to replace any single character

**Wildcard Examples**

* Right `%` Wildcard
```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!'),
  ('Hello Santa!')
)
SELECT text_value
from test_data
WHERE text_value LIKE 'Hello%';
```
|text_value|
|----|
|Hello World!|
|Hello Santa!|

* Left `%` Wildcard
```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!'),
  ('Hello world!')
)
SELECT text_value
from test_data
WHERE text_value LIKE '%World!';
```
|text_value|
|----|
|Hello World!|
|hello World!|

* Double `%` Wildcard
```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!'),
  ('Hello world!'),
  ('Jello World is amazing')
)
SELECT text_value
from test_data
WHERE text_value LIKE '%ello World%';
```
|text_value|
|----|
|Hello World!|
|hello World!|
|Jello World is amazing|

* Multiple `%` Wildcards
  - Recall that this symbol can allow for any number of characters in between
```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!'),
  ('Hello world!'),
  ('Will this hello Word show up?')
)
SELECT text_value
FROM test_data
WHERE text_value LIKE '%el%Wor%'
```
|text_value|
|---|
|Hello World!|
|hello World!|
|Will this hello Word show up?|

<br>

* `_` Wildcards

We can also use the `_` character to match any **single** character which is very similar to a wildcard but it is explicity with the number of characters to match

```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!'),
  ('Hello world!'),
  ('Jello World')
)
SELECT text_value
FROM test_data
WHERE text_value LIKE '_ello_World_';
```
|text_value|
|----|
|Hello World!|
|hello World!|
* Note here on the returns being the first two items, the last item isn't chosen as there is no final character the last underscore accounts for and the third tiem isn't chosen due to the casing

<br>

### Wrong Letter Case Scenario
The text that is accompanying the wildcards must be of the correct case also.
What happens when you get the case wrong when using the LIKE with wildcards?

```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!'),
  ('Hello world!!!!!'),
  ('HEllo world')
)
SELECT text_value
from test_data
WHERE text_value LIKE '_ello_wor%';
```
|text_value|
|----|
|Hello world!!!!!|
* Note that neither of the first two would work with the casing of **World**
* Only the third value would be selected with the combination of the **any - %** at the end matching the allowed character(s) after and with the **single - _** matching the total characters before the string search match

<br>

### `Case Insensitive Match`
`ILIKE` is used when you need a case insensitive match where it doesn’t matter if the string has upper case or lower case and you are only interested in the characters themselves.

It is essentially the same as LIKE but should be used thoughtfully as there is an implicit cost in checking text strings for different lettercases - it’s not going to be as performant as checking for explicit lowercase or uppercase characters when used with the `LIKE` operator.

```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!'),
  ('Hello world!!!!!'),
  ('HEllo world'),
  ('HeLlO WoRlD')
)
SELECT text_value
from test_data
WHERE text_value ILIKE '%hello world%';
```
|text_value|
|----|
|Hello World!|
|hello World!|
|Hello world!!!!!|
|HEllo world|
|HeLlO WoRlD|

* All values returned regardless of casing
* Common to use ILIKE if a search doesn't result as casing is explicit with LIKE 

<br>

### `NOT LIKE` and `NOT ILIKE`
We can also use NOT in front of LIKE and ILIKE as a negative pattern matcher.

Let’s try to find all the films without the word ‘monkey’ in the description and confirm that this is the case.

First let’s check how many films we have:

```sql
SELECT COUNT(*)
FROM dvd_rentals.film_list;
```
|count|
|---|
|997|

* Let's check whether are any films with the word **monkey** in there:
```sql
SELECT COUNT(*)
FROM dvd_rentals.film_list 
WHERE description ILIKE '%monkey%';
```
|count|
|---|
|86|

* Let's confirm that the count and `NOT LIKE` are equal (911 is the difference)
```sql
SELECT COUNT(*)
FROM dvd_rentals.film_list 
WHERE description NOT ILIKE '%monkey%';
```
|count|
|---|
|911|

* A note on all of these fuzzy matching functions - you can use them with `AND` and `OR` operators for more complex logic that includes multiple words or phrases that you need to match.

<br>

### `Regular Expressions`
Regular Expressions or regex are the final piece of the pattern matching puzzle and are VERY VERY useful but can be VERY tricky to wrap your head around when getting started!

This section is by no means a complete guide for regex - but merely a quick start guide to get you thinking about certain scenarios where you might be able to use this in your daily tasks!

It’s been many many years since I first learned regex but it was one of the best investments I made - it really substantially improved my ability to manipulate text data!


#### **Meta Characters**
|Meta Characters|Description|
|-----|------|
|pipe  |	Boolean OR (either of two alternatives)|
|*	|Repeat the previous item zero or more times|
|+	|Repeat the previous item one or more times|
|?	|Repeat the previous item zero or one time|
|{m}|Repeat the previous item exactly m times|
|{m,}|	Repeat the previous item m or more times|
|{m,n}|Repeat the previous item at least m and not more than n times|
|.|Wildcard to denote any character|
|^|	Refers to the beginning of the text input|
|$|	Refers to the end of the text input|
|Parentheses ()|	Used to group items into a single logical item|
|Brackets []|specifies a character class, just as in POSIX regular expressions.|

<br>

`RegEx Example`
* Keep only records which start with hello or Hello or a capital J
```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!!'),
  ('Hello world!!!!!'),
  ('HELLO world'),
  ('Peanut Butter Jelly Sandwich'),
  ('Just for fun!'),
  ('just kidding!')
)
SELECT text_value
from test_data
WHERE text_value ~ '^(Hello|hello|J)';
```
|text_value|
|---|
|Hello World!|
|hello World!!|
|Hello world!!!!!|
|Just for fun!|
* ^ Carat start with (beginning of the text) and include 1 of the three items for a logistical or check to include any of the text values that satisfy 1 of the 3 values at the beginning

<br>

* Keep records that end in 2 to 5 exclamation marks using the left and right anchors ^ and $
```sql
WITH test_data (text_value) AS (
VALUES
  ('Hello World!'),
  ('hello World!!'),
  ('Hello world!!!!!'),
  ('HELLO world'),
  ('Peanut Butter Jelly Sandwich')
)
SELECT text_value
FROM test_data
-- anchors (start and end of the string - ^ then $)
-- . (wildcard) * (zero or more times) preceding our search for then the count of ! exclamations
-- (!) value - {2,5}
WHERE text_value ~ '^.*(!){2,5}$'
```
|text_value|
|---|
|hello World!!|
|Hello world!!!!!|

<br>

`More Characters`

Note that we use the brackest around the entire expression as best practice when we are doing a complete string match that includes the `^` and `$` left and right anchors - industry standard 

* The `\w` referes to a **word** character that is any alpha-numeric value and underscores
* The `\s` refers to **whitespace**
* The `+` refers to there being one or more of the previous characters

1. Which movies have 2 words in the title that both begin with the same letter?
```sql
SELECT title
FROM dvd_rentals.film
WHERE title ~ '^(M\w+\sM\w+$)';
```
|title|
|---|
|MAGIC MALLRATS|
|MAUDE MOD|
|MILE MULAN|
|MULAN MOON|
|MUPPET MILE|

 2. Which movies have 2 words in the title that both begin with the same letter?

 We can also use the **round - ()** brackets to group our pattern matches - in this case we used the `()` around the first letter of the first word and then we use the \1 after the \s whitespace to make sure that the pattern we’re looking matches that first letter!

We can assign up to 9 pattern match groups and refer to them using \1 through to \9
```sql
SELECT title,1 
FROM dvd_rentals.film
WHERE title ~ '^(\w)\w+\s\1\w+$'
LIMIT 10;
```
|title|?column?|
|---|---|
|BIKINI BORROWERS|1|
|BLANKET BEVERLY|1|
|BOONDOCK BALLROOM|1|
|BORROWERS BEDAZZLED|1|
|BROTHERHOOD BLANKET|1|
|BUCKET BROTHERHOOD|1|
|CAT CONEHEADS|1|
|CHARIOTS CONSPIRACY|1|
|CHEAPER CLYDE|1|
|CONFUSED CANDLES|1|

3. Return movie names that have a title with the first word starting with A but with the second word not starting with letters D, M or A
* Using the `[]` allows to define a specific character class the we want to **not** match by using the `^` character
```sql
SELECT title
FROM dvd_rentals.film
WHERE title ~ '^A\w+\s[^DMA]\w+$'
LIMIT 5;
```
|title|
|---|
|ACE GOLDFINGER|
|ADAPTATION HOLES|
|AFFAIR PREJUDICE|
|AFRICAN EGG|
|AGENT TRUMAN|

<br>

### Heirarchy of Preference
1. Use `LIKE` wherever possible as it is the most efficient and simple to read/understand
2. Use `ILIKE` sparingly as it is more computationally expensive than a case sensitive match
3. When using regex `~` always try to left anchor your patterns from the beginning of the text so valid indexes can be used
4. Avoid using `SIMILAR TO` which is available in most Standard SQL (word on the street is that this is going to be deprecated soon!)

The main reason for this heirarchy of pattern matching tools is mainly due to complexity and efficiency.

LIKE, ILIKE and ~ with a left anchor ^ can make use of PostgreSQL column indexes which will drastically speed up these operations on huge datasets.

<br>

### **Find and Replace**
Up until now we have been focused on identifying which records contain specific text or regular expressions, and also how to manipulate some text into different formats - but we have yet to look at updating our text columns themselves.

We have a few tools in our arsenal to do this within SQL and we can also use some of these tools with the power of regex to really make things interesting!

<br>

#### `Simple Replace`
* There is a simple REPLACE function which will replace a substring within a string, no regex required!
```sql
WITH test_data 
AS (
  SELECT 'Hello World!' AS text_value
)
SELECT REPLACE(text_value, 'Hello', 'Bonjour')
from test_data;
```
|replace|
|---|
|Bonjour World!|

```sql
-- Swap Robot with Huge Polar Bear in the description from the film called ANGELS LIFE
WITH ANGELS_LIFE AS (
SELECT *
FROM dvd_rentals.film 
WHERE title ~ '^ANGELS\sLIFE$'
)
SELECT
  title,
  description,
  REPLACE(description, 'Robot', 'Huge Polar Bear') AS modified_desc
FROM ANGELS_life;
```
|title|description|modified_desc|
|----|----|----|
|ANGELS LIFE|A Thoughtful Display of a Woman And a Astronaut who must Battle a Robot in Berlin|A Thoughtful Display of a Woman And a Astronaut who must Battle a Huge Polar Bear in Berlin|


<br>

### `Regular Expression Replace`
But what happens when you need to use some regex also? We can use the `REGEXP_REPLACE` function to do this

* Swap everything from the beginning of the word Woman till the end of the word Astronaut in the description column with Weird Turtle from the film called ANGELS LIFE
  - Recall the `.` wildcard and `*` for count (zero or more times)

```sql
SELECT
  REGEXP_REPLACE (
    description,
    'Woman.*Astronaut',
    'Weird Turle'
  ) AS new_description
FROM dvd_rentals.film
WHERE title ~ '^ANGELS\sLIFE$'

-- With a + count for wildcard for at least one wildcard space between Woman & Astronaut
SELECT
  REGEXP_REPLACE (
    description, -- target text column
    'Woman.+Astronaut', -- what we want to find - regex pattern
    'Weird Turle' -- what we replace with
  ) AS new_description,
  description AS old_desc
FROM dvd_rentals.film
WHERE title ~ '^ANGELS\sLIFE$'
```
|new_description|old_desc|
|----|-----|
|A Thoughtful Display of a Weird Turle who must Battle a Robot in Berlin|A Thoughtful Display of a Woman And a Astronaut who must Battle a Robot in Berlin|

<br>

#### `RegEx Replace` For Previous Hyphen Removal & Padding
We can also retry our product related padding example question from before using a REGEXP_REPLACE here also.

In this example we actually use a blank string as the replacement value to simply delete the regex find target.

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
    REGEXP_REPLACE(product_code, '-.*$', ''),
    6,-- max length of padded output column
    '0' -- replacement character to pad if not at max length
  ) AS pad_item_no_hypen
FROM products
```

* `G` Flag/Mode to Replace All Matching Patterns

By default, the REGEXP_REPLACE method above will only find the first occurence of the pattern to replace. See below for the difference with the `/g` mode
```sql
WITH test_data (text_value) AS (
VALUES
  ('Say a little hello to my little friend, Danny!')
)
SELECT
  REGEXP_REPLACE(text_value, 'little', 'big') AS default_regexp_replace,
  REGEXP_REPLACE(text_value, 'little', 'big', 'g') AS global_all_occurences_regexp_replace
FROM test_data;
```
|default_regexp_replace|global_all_occurences_regexp_replace|
|-----|-----|
|Say a big hello to my little friend, Danny!|Say a big hello to my big friend, Danny!|


* `Regex Pattern Groups`

Additionally - we can also use the same `regex pattern groups` we mentioned earlier to capture and re-insert parts of the matched patterns into our replacement string.

Let’s say we want to capture all the names after the colon in the following example and add in a title for everyone

```sql
WITH test_data (text_value) AS (
VALUES
  ('My friends'' names are: Ken, Esteban and Shelly!')
)
SELECT
  -- () groups in regexp
  REGEXP_REPLACE(text_value, '(\w+), (\w+) and (\w+)', 'Mr. \1, Snr. \2, Ms. \3') AS titles,
  text_value AS non_titles
FROM test_data;
```
|titles|non_titles|
|----|---|
|My friends' names are: Mr. Ken, Snr. Esteban, Ms. Shelly!|My friends' names are: Ken, Esteban and Shelly!|

<br>

### **Regex Match**
Sometimes we might be interested in returning a result when our regular expression matches something in a target string instead of just returning a boolean true or false value.

The `REGEXP_MATCH` function does exactly that however there is a catch - the function actually returns an array data type, something that we have not yet seen in our SQL experience so far!

An array is a nested data structure that can reside within a column - you can think of it almost like multiple values within a single column.

Usually when we are looking to use the `REGEXP_MATCH` function we are only interested in the first time the regular expression matches in the target string input, so we most often just take the first element of this array by adding a [1] after the function expression.

In the following example - we want to extract the first matching value of {3} occurences of the class of capitalized letters [A-Z] followed by {3} occurences of numbers between [0-9]

```sql
WITH test_data (text_value) AS (
VALUES ('Hello World ABC123 XYZ123!')
)
SELECT (REGEXP_MATCH(text_value, '[A-Z]{3}[0-9]{3}'))[1]
from test_data;
```
|regexp_match|
|---|
|ABC123|

* Should we omit the bracket syntax following the call for the method, the type will be an array/list 
```sql
WITH test_data (text_value) AS (
VALUES ('Hello World ABC123 XYZ123')
)
SELECT (REGEXP_MATCH(text_value, '[A-Z]{3}[0-9]{3}'))
from test_data;
```
|regexp_match|
|---|
|[ "ABC123" ]|

<br>

We can also specify groups within the regex to return multiple elements in the array like so - let’s say we wanted to split our regex into 2 groups of ([A-Z]{3}) and ([0-9]{3})
* Return type is more or less a tuple with the found matches from the call

We can then further decompose our array output by using the UNNEST function to pop each element of the array into it’s own row - we call this transformation flattening an array with multiple elements to multiple rows.

```sql
WITH test_data (text_value) AS (
VALUES ('Hello World ABC123 XYZ123')
)
SELECT
  REGEXP_MATCH(text_value, '([A-Z]{3})([0-9]{3})') AS array_output
from test_data;
```
|array_output|
|--|
|[ "ABC", "123" ]|

* Quick idea here how the expression groups are being captured
```sql
WITH test_data (text_value) AS (
VALUES ('Hello ABB457 World ABC123 XYZ123')
)
SELECT
  REGEXP_MATCH(text_value, '([A-Z]{3})([0-9]{3})') AS array_output
from test_data;
```
|array_output|
|---|
|[ "ABB", "457" ]|

* Next we have the flattened array output: (Each captured group it's own row)
```sql
WITH test_data (text_value) AS (
VALUES ('Hello World ABC123 XYZ123')
)
SELECT
  UNNEST(REGEXP_MATCH(text_value, '([A-Z]{3})([0-9]{3})')) AS flat_output
from test_data;
```
|flat_output|
|---|
|ABC|
|123|

<br>

### **Multiple Regex Matches**
So what happens if we actually wanted to keep all the different values that might match with our regular expression - did you notice that the XYZ123 also would have matched with our regex [A-Z]{3}[0-9]{3} ?

For this use case we can use the `REGEX_MATCHES` function to do this - but we’ll also need to use the `'g'` global mode to make sure all of the regex patterns are being matched and not stopped after the first match!

Usually when we are not dealing with groups of patterns to match - we will use that same [1] array slicing to return just the first element of the array as a text field.

```sql
WITH test_data (text_value) AS (
VALUES ('Hello World ABC123 XYZ123')
)
SELECT
  (REGEXP_MATCHES(text_value, '[A-Z]{3}[0-9]{3}'))[1] AS default_mode,
  (REGEXP_MATCHES(text_value, '[A-Z]{3}[0-9]{3}', 'g'))[1] AS global_mode
from test_data;
```
|default_mode|global_mode|
|----|-----|
|ABC123|ABC123|
|null|XYZ123|

<br>

#### Address Type Example
What is the count of address type in the dvd_rentals.address table?

```sql
SELECT address
FROM dvd_rentals.address
LIMIT 5;
```
|address|
|----|
|47 MySakila Drive|
|28 MySQL Boulevard|
|23 Workhaven Lane|
|1411 Lillydale Drive|
|1913 Hanoi Way|

Here we can see that the last word seems to be the perfect target for us to extract and then perform a simple `COUNT`

Firstly we need to use some regular expression to get us the final word from the address field in that table.

```sql
SELECT
  -- RegEXP ending part to count by the end of the string
  (REGEXP_MATCH(address, '(\w+)$'))[1] AS address_final_part,
  COUNT(*) AS address_final_counts
FROM dvd_rentals.address
GROUP BY address_final_part
ORDER BY address_final_counts DESC;
```
|address_final_part|address_final_counts|
|-----|----|
|Parkway|76|
|Manor|66|
|Lane|60|
|Street|60|
|Place|59|
|Avenue|59|
|Way|59|
|Drive|56|
|Loop|54|
|Boulevard|54|

<br>

### **Another Padding Example**
Let’s also revisit that left padded `product_id` example we’ve been using throughout this tutorial.

Let’s now demonstrate one more way to perform the same transformation but this time using the REGEXP_MATCH as well:

```sql
WITH products (product_code) AS (
VALUES
  ('1234-BOX'),
  ('3421-EACH'),
  ('35895-PACK'),
  ('451884-CARTON')
)
SELECT
  -- No regex example
  LPAD(
    -- use the position of the dash minus 1
    LEFT(product_code, POSITION('-' IN product_code) - 1),
    6,   -- the max length of our padded output column
    '0'  -- the character we will use to "pad" our input text
  ) AS no_regex,
  -- REGEXP_REPLACE example
  LPAD(
    -- replace everything from the dash to the end with a blank string
    REGEXP_REPLACE(product_code, '-.*$', ''),
    6,   -- the max length of our padded output column
    '0'  -- the character we will use to "pad" our input text
  ) AS replace_regex,
  LPAD(
    -- remember to get the first element of array
    -- \d is shorthhand for digits [0-9]
    (REGEXP_MATCH(product_code, '^\d{1,6}'))[1],  
    6,  -- the max length of our padded output column
    '0' -- the character we will use to "pad" our input text
  ) AS match_regex
FROM products;
```
|no_regex|replace_regex|match_regex|
|----|-----|-----|
|001234|001234|001234|
|003421|003421|003421|
|035895|035895|035895|
|451884|451884|451884|

<br>

### Splitting Strings
Sometimes when we deal with messy data - we’ll see multiple data points stuck inside one column and we’ll need to **“split”** it up so we can have an easier time analysing it.

Let’s take for example this toy dataset with user_id, event_name and an event_date data points - but they are all stuck in one column;

* Sample Data all in one column
```sql
WITH events (logs) AS (
VALUES
  ('user1-click-20210101'),
  ('user2-buy-20210201')
)
SELECT * FROM events;
```
|logs|
|----|
|user1-click-20210101|
|user2-buy-20210201|

* We can use the `SPLIT_PART` to separate these values by specifying a **delimiter** for each of these values as well as a position for the new columns:

```sql
WITH events (logs) AS (
VALUES
  ('user1-click-20210101'),
  ('user2-buy-20210201')
)
SELECT
  SPLIT_PART(logs, '-', 1) AS user_id,
  SPLIT_PART(logs, '-', 2) AS event_name,
  SPLIT_PART(logs, '-', 3)::DATE AS event_date -- CAST'ing as a DATE
FROM events;
```
|user_id|event_name|event_date|
|---|-----|-----|
|user1|click|2021-01-01|
|user2|buy|2021-02-01|

---

<br>

### `Appendix`

#### **Regex Resources**
There is a ton of information on more advanced regex in the PostgreSQL documentation!

[PostgreSQL RegEx](https://www.postgresql.org/docs/current/functions-matching.html#REGULAR-EXPRESSION-DETAILS)

Honestly it is a bit tricky to go through at first so take your time and be kind on yourself.

The key to getting good at regex is to learn the basic fundamentals and then try a few challenging examples to test your understanding!

Always test your regular expressions against use cases - this is MANDATORY!!!

Regex is something that you can definitely learn on the fly, as and when you need it - but it’s always handy to have a few resources up your sleeve!

<br>

#### **RegExr**
[RegEx Session](regexr.com)

* This is an interactive interface that is really useful for grappling with ideas or when in need of a little help for a tricky pattern

<br>

#### **I Hate Regex**
[I Hate RegEx](ihateregex.io/)

This is another awesome resource with lots and lots of knowledge on specific problems which are already solved using Regex!

Some of the examples are amazing - I highly recommend taking a look at the Credit Cards example if you want to have your mind blowing experience!

<br>

#### **Regex Cheatsheets**
Here are some cheatsheets and other handy blog posts I’ve used in the past to get my regex done quickly!

[Cheat RegEx](cheatography.com) <br>
[MIT Cheatsheet](https://web.mit.edu/hackl/www/lab/turkshop/slides/regex-cheatsheet.pdf)<br>
[RexEgg](rexegg.com)