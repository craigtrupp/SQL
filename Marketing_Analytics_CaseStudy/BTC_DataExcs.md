### For the following questions - they are not compulsory but you can use this new dataset as an opportunity to further develop your SQL skills.


1) What is the earliest and latest `market_date` values?
2) What was the historic all-time high and low values for the `close_price` and their dates?
3) Which date had the most volume traded and what was the close_price for that day?
4) How many days had a `low_price` price which was 10% less than the `open_price`?
5) What percentage of days have a higher `close_price` than `open_price`?
6) What was the largest difference between high_price and low_price and which date did it occur?
7) If you invested $10,000 on the 1st January 2016 - how much is your investment worth in 1st of February 2021? Use the close_price for this calculation

-- Hint: remember to decide whether you want NULLS FIRST or NULLS LAST in any ORDER BY queries and make use of CASE WHEN statements where possible!


<br><br>

1) What is the earliest and latest `market_date` values?

```sql
SELECT
  MAX(market_date) AS latest_market_date,
  MIN(market_date) AS earliest_market_date
FROM trading.daily_btc;
```

|latest_market_date|earliest_market_date|
|-----|-----|
|2021-02-24|2014-09-17|

<br>

2) What was the historic all-time high and low values for the `close_price` and their dates?

```sql
DROP TABLE IF EXISTS close_price_rankings;
CREATE TEMP TABLE close_price_rankings AS
SELECT
  market_date,
  close_price,
  RANK() OVER(
    ORDER BY close_price DESC
  ) AS top_closing,
  RANK() OVER(
    ORDER BY close_price
  ) AS low_closing
FROM trading.daily_btc
WHERE close_price IS NOT NULL;


SELECT *,
  CASE
    WHEN top_closing = 1 THEN 'Highest Close'
    WHEN low_closing = 1 THEN 'Lowest Close'
    END AS btc_close_ranking
  FROM close_price_rankings
  WHERE top_closing = 1 OR low_closing = 1;
```

|market_date|close_price|top_closing|low_closing|btc_close_ranking|
|-----|------|------|-------|-------|
|2015-01-14|178.102997|2349|1|Lowest Close|
|2021-02-21|57539.945313|1|2349|Highest Close|

<br>

3) Which date had the most volume traded and what was the close_price for that day?
```sql
DROP TABLE IF EXISTS volume_rank;
CREATE TEMP TABLE volume_rank AS
SELECT
  market_date,
  close_price,
  volume,
  RANK() OVER(
    ORDER BY volume DESC
  ) AS volume_top_rankings
FROM trading.daily_btc
WHERE close_price IS NOT null;

-- We'll take a look just at the top 5
SELECT * 
FROM volume_rank 
ORDER BY volume_top_rankings 
LIMIT 5;
```

|market_date|close_price|volume|volume_top_rankings|
|-----|-----|-----|------|
|2021-01-11|35566.656250|123320567399|1|
|2021-01-29|34316.386719|117894572511|2|
|2021-02-23|48824.425781|106102492824|3|
|2021-02-08|46196.464844|101467222687|4|
|2021-02-22|54207.320313|92052420332|5|

<br>

4) How many days had a `low_price` price which was 10% less than the `open_price`?
* Did a concatenation here to help with the view and grabbed the count of all days with a low_price 10% or less than the open price

```sql
--How many days had a low_price price which was 10% less than the open_price?
DROP TABLE IF EXISTS low_open_difference;
CREATE TEMP TABLE low_open_difference AS 
SELECT 
  low_price,
  open_price,
  ROUND(100 - ((low_price / open_price) * 100), 2) AS low_price_percent_diff,
  CONCAT(CAST(ROUND(100 - ((low_price / open_price) * 100), 2) AS varchar(100)), '%') AS low_price_percent_open_diff
FROM trading.daily_btc
WHERE (low_price IS NOT NULL and close_price IS NOT NULL)
ORDER BY low_price_percent_diff DESC;

SELECT COUNT(*)
FROM low_open_difference
WHERE low_price_percent_diff >= 10;

SELECT * FROM low_open_difference LIMIT 5;
```
|count|
|----|
|79|

|low_price|open_price|low_price_percent_diff|low_price_percent_open_diff|
|----|-------|-------|---------|
|4860.354004|7913.616211|38.58|38.58%|
|10194.900391|13836.099609|26.32|26.32%|
|11833.000000|15898.000000|25.57|25.57%|
|171.509995|223.893997|23.40|23.40%|
|910.416992|1156.729980|21.29|21.29%|


<br>

5) What percentage of days have a higher `close_price` than `open_price`?
```sql
-- What percentage of days have a higher close_price than open_price?
DROP TABLE IF EXISTS higher_close_open;
CREATE TEMP TABLE higher_close_open AS 
SELECT 
  COUNT(*) AS higher_close_total_days,
  (SELECT COUNT(*) FROM trading.daily_btc) AS total_btc_row_records
FROM trading.daily_btc
WHERE (close_price > open_price) AND (close_price IS NOT NULL and open_price IS NOT NULL);

SELECT
  higher_close_total_days,
  total_btc_row_records,
  -- had to cast one of the two count total (variables above) as numeric to get ROUND to work
  ROUND(CAST(higher_close_total_days AS numeric) / total_btc_row_records * 100, 2) AS higher_close_percentage
FROM higher_close_open;
```
|higher_close_total_days|total_btc_row_records|higher_close_percentage|higher_close_percentage_str|
|------|------|-------|----|
|1283|2353|54.53|54.53%|

