-- Exercise Questions : Performed in docker instance running on localhost for database schema

-- 1) What is the name of the category with the highest category_id in the dvd_rentals.category table?

SELECT
  name,
  category_id
FROM dvd_rentals.category
ORDER BY 1 desc;

-- use 1 number to order by name value or first column from select statement 


-- 2) For the films with the longest length, what is the title of the “R” rated film with the lowest replacement_cost in dvd_rentals.film table?

SELECT
  title, length, rating, replacement_cost
FROM dvd_rentals.film
WHERE rating = 'R'
ORDER BY length DESC, replacement_cost
LIMIT 1;


-- 3) Who was the manager of the store with the highest total_sales in the dvd_rentals.sales_by_store table?
SELECT
  manager,
  total_sales
FROM dvd_rentals.sales_by_store
ORDER BY total_sales DESC
LIMIT 1;


-- 4) What is the postal_code of the city with the 5th highest city_id in the dvd_rentals.address table?
SELECT
  postal_code, city_id
FROM dvd_rentals.address
ORDER BY city_id DESC
LIMIT 5;

