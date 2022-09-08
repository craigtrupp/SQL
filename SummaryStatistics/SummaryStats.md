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

### Arithmetic Mean or Average

The Arithmetic Mean or Average is something I’m sure you’ve seen in the past. It’s definition is simply 
* the sum of all values divided by the total count of values for a set of numbers.

The mean is commonly used as a location summary statistic to show the central tendancy for a set of observations. Note that the mean can only be calculated for numbers and cannot be used on any other data type.

The following mathematical equation is commonly used to show the mean calculation.

* μ=∑Ni=1XiN

![Image](https://you.com/proxy?url=https%3A%2F%2Ftse2.mm.bing.net%2Fth%3Fid%3DOIP.DvJnM9pV-cPOliLzw8PfdAHaEo%26w%3D690%26c%3D7%26pid%3DApi%26p%3D0 "Mu calculation")

The **mu** greek letter μ on the left is the most commonly used mathematical symbol to represent the mean and you will see this very often in future!

For a set of observations containing a total of N numbers: x1,x2,x3,...,xN - the mean equals the [ sum of all xi from i = 1 to i = N ] divided by N

The little i subscript of the x value is what is known as a dummy variable and any letter can be used in this equation. Often i and j are used for most mathematical equations you’ll encounter, as well as in for loops in programming languages.

The SQL implementation is relatively simple but can change depending on the flavour of SQL you are using!

In PostgreSQL the mean is calculated using the AVG function like so: