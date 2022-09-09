# Summary Statistics

If you’re anything like me - looking at the raw data isn’t the best way to intuitively solve most of my problems!

In this tutorial we will focus on further analyzing and exploring our raw data through the use of powerful summary statistics.

The core ideas will become additional layers to our previous SQL knowledge but will also have a laser sharp focus on how to interpret some of these outputs that come out of our statistical analysis.

To start off, we will cover the base level of what you need to know about statistics, so don’t worry if you have zero math and stats knowledge!

When we use summary statistics in SQL, we can compute our statistics on individual columns, but more generally we often combine the functions used to generate certain statistics with the powerful core foundational concept of GROUP BY to calculate statistics within certain groups that we are interested in.

For the entirety of this tutorial - we will continue inspecting our `health.user_logs` dataset.

Once we’ve covered some of these initial statistical concepts, we’ll return to some of our past decisions in the previous duplicates tutorial to demonstrate their impact on our summary statistics.

___
<br>

## Statistics 101
Statistics is full of is what I like to call “threshold concepts” whereby once you learn their meaning and understand the concept - you will find it very difficult to forget them!

This is exactly the case with some of the following terms I will introduce below - chances are you’ve probably used these same terms before in school, Excel or some other data/math related applications.

As we introduce each statistical concept - I will demonstrate how to calculate each summary statistic on the measure_value column in the   `health.user_logs` table

___

<br>

## Central Location Statistics

Location statistics are something I’m sure you’ve come across - mainly the **mean**, **median** and **mode** values.

They are all measures of the central location summary statistics and are often used in analytical reports everywhere!

The implementation of each metric is different so be sure to read through the code snippets and run them in your SQL environment!


___
<br>

## Arithmetic Mean or Average

The Arithmetic Mean or Average is something I’m sure you’ve seen in the past. It’s definition is simply 
* the sum of all values divided by the total count of values for a set of numbers.

The mean is commonly used as a location summary statistic to show the central tendancy for a set of observations. Note that the mean can only be calculated for numbers and cannot be used on any other data type.

The following mathematical equation is commonly used to show the mean calculation.

* μ=∑Ni=1Xi/N


The **mu** greek letter μ on the left is the most commonly used mathematical symbol to represent the mean and you will see this very often in future!

For a set of observations containing a total of N numbers: x1,x2,x3,...,xN - the mean equals the [ sum of all xi from i = 1 to i = N ] divided by N

The little i subscript of the x value is what is known as a dummy variable and any letter can be used in this equation. Often i and j are used for most mathematical equations you’ll encounter, as well as in for loops in programming languages.

The SQL implementation is relatively simple but can change depending on the flavour of SQL you are using!

In PostgreSQL the mean is calculated using the AVG function like so:

```sql
SELECT
  AVG(measure_value)
FROM health.user_logs;
```

| avg |
|:---|
|1986.2288605267024675|

Wait a moment…what were our measures called again and how many record counts were there?
```sql
SELECT
  measure,
  COUNT(*) AS counts
FROM health.user_logs
GROUP BY measure
ORDER BY counts DESC;
```
|measure|count|
|----|-----|
|blood_glucose| 38692|
|weight|2782|
|blood_pressure|2417|

Do you notice something fishy going on? What happens if we also take a look at the AVG value across each measure too?

```sql
SELECT
  measure,
  ROUND(AVG(measure_value), 2) AS average,
  COUNT(*) AS counts
FROM health.user_logs
GROUP BY measure
ORDER BY counts DESC;
```

|measure|average|counts|
|----|-----|-----|
|blood_glucose| 177.35|38692|
|weight|28786.85|2782|
|blood_pressure|95.40|2417|

<br>

... Looks odd
Let's park this for the meantime but earmark it for later


___
<br>

## Ordered Set Aggregate Functions
When you think of the underlying steps of calculating the median or the mode - there are a few steps involved in the “algorithm” required to calculate the values 

### Median Algorithm
*   Sort all N values from smallest to largest
*   Inspect the central values of the sorted set:
* **if** N is odd:
    + the median is the value in the (N+1/2)th position   
* **else** if N is even:
    + the median is the average of values in the (N/2)th and 1+(N/2)th positions
    + [1,2,3,4] (N=4)
        + 4/2 = 2 so the 2nd position in the arr[1] (Zero Indexing)
        + 1 + (4/2) = 3 so the 3rd position in the arr[2] (Zero Indexing)
        + 2 + 3 (Arr position values) / 2 = 2.5 
    + Median value would be 2.5

<br>

### Python Code Algorithm
```python
import random as rd
import numpy as np
#Generate 1-100 with even or odd amount using multiple libraries
random_ints = []
np_random_ints = []
for i in range(14):
    random_ints.append(rd.randint(1,100))
for j in range(13):
    np_random_ints.append(np.random.randint(1, 100))
print(random_ints, '\n', np_random_ints)
random_ints.sort()
random_ints
len(random_ints)

def returnMedian(lst):
    """ 
    Returns Median Value of passed list similarly to Median Algorithm for SQL query below
    Validates if passed list is odd/even 
    Function requires a list of integer numeric types
    Arguments:
        lst : list of integers to pass to function
    Returns:
        Original List, Sorted List, Median Index Value if Odd (Zero Indexing Accounted For), Median Value of Passed List
    """
    if len(lst) % 2 != 0:
        # Account for zero indexing 
        # sorted_list = lst.sort() wouldn't work as the array method returns a nonetype and mutates the list in place
        sorted_list = sorted(lst)
        median_index = int((len(lst) + 1) / 2) - 1
        return (lst, sorted_list, median_index, sorted_list[median_index])
    else:
        sorted_list = sorted(lst)
        median_first_value = int((len(sorted_list) / 2) - 1)
        median_second_value = int(len(sorted_list) / 2)
        median_value = (sorted_list[median_first_value] + sorted_list[median_second_value]) / 2
        return (lst, sorted_list, median_value)
```
<br>

Mode Algorithm
Calculate the tally of values similar to a GROUP BY and COUNT
The mode is the values with the highest number of occurences


___