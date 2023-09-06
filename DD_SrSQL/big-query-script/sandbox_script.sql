-- Create all relevant schemas for Serious SQL datasets
CREATE SCHEMA dvd_rentals;
CREATE SCHEMA health;
CREATE SCHEMA employees;
CREATE SCHEMA optimization;
CREATE SCHEMA trading;

-- Create all schemas for 8 Week SQL Challenge datasets
CREATE SCHEMA dannys_diner;
CREATE SCHEMA pizza_runner;
CREATE SCHEMA foodie_fi;
CREATE SCHEMA data_bank;
CREATE SCHEMA data_mart;
CREATE SCHEMA clique_bait;
CREATE SCHEMA balanced_tree;
CREATE SCHEMA fresh_segments;

------------------------
-- Serious SQL Datasets
------------------------

-- Load all required tables for `hedvd_rentals` schema
LOAD DATA OVERWRITE dvd_rentals.customer
FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/customer.csv']
);

LOAD DATA OVERWRITE dvd_rentals.actor
FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/actor.csv']
);
  
LOAD DATA OVERWRITE dvd_rentals.actor_info
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/actor_info.csv']
);

LOAD DATA OVERWRITE dvd_rentals.address
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/address.csv']
);

LOAD DATA OVERWRITE dvd_rentals.address
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/address.csv']
);

LOAD DATA OVERWRITE dvd_rentals.city
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/city.csv']
);

LOAD DATA OVERWRITE dvd_rentals.country
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/country.csv']
);

LOAD DATA OVERWRITE dvd_rentals.customer_list
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/customer_list.csv']
);

LOAD DATA OVERWRITE dvd_rentals.film
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/film.csv']
);

LOAD DATA OVERWRITE dvd_rentals.film_actor
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/film_actor.csv']
);

LOAD DATA OVERWRITE dvd_rentals.film_category
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/film_category.csv']
);

LOAD DATA OVERWRITE dvd_rentals.film_list
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/film_list.csv']
);

LOAD DATA OVERWRITE dvd_rentals.inventory
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/inventory.csv']
);

LOAD DATA OVERWRITE dvd_rentals.language
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/language.csv']
);

LOAD DATA OVERWRITE dvd_rentals.nicer_but_slower_film_list
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/nicer_but_slower_film_list.csv']
);

LOAD DATA OVERWRITE dvd_rentals.payment
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/payment.csv']
);

LOAD DATA OVERWRITE dvd_rentals.rental
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/rental.csv']
);

LOAD DATA OVERWRITE dvd_rentals.sales_by_film_category
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/sales_by_film_category.csv']
);

LOAD DATA OVERWRITE dvd_rentals.sales_by_store
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/sales_by_store.csv']
);

LOAD DATA OVERWRITE dvd_rentals.staff
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/staff.csv']
);

LOAD DATA OVERWRITE dvd_rentals.staff_list
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/staff_list.csv']
);

LOAD DATA OVERWRITE dvd_rentals.store
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/dvd_rentals/store.csv']
);

-- Load all required tables for `health` schema
LOAD DATA OVERWRITE health.user_logs
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/health/user_logs.csv']
);

LOAD DATA OVERWRITE health.users
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/health/users.csv']
);

-- Load all required tables for `employees` schema
LOAD DATA OVERWRITE employees.department
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/employees/department.csv']
);

LOAD DATA OVERWRITE employees.department_employee
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/employees/department_employee.csv']
);

LOAD DATA OVERWRITE employees.department_manager
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/employees/department_manager.csv']
);

LOAD DATA OVERWRITE employees.employee
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/employees/employee.csv']
);

LOAD DATA OVERWRITE employees.salary
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/employees/salary.csv']
);

LOAD DATA OVERWRITE employees.title
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/employees/title.csv']
);

-- Load all tables required for `optimization` schema
LOAD DATA OVERWRITE optimization.addresses
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/optimization/addresses.csv']
);

LOAD DATA OVERWRITE optimization.employees
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/optimization/employees.csv']
);

-- Load all tables required for `trading` schema
LOAD DATA OVERWRITE trading.daily_btc
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/trading/daily_btc.csv']
);

LOAD DATA OVERWRITE trading.daily_eth
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/serious-sql/trading/daily_eth.csv']
);

--------------------------------
-- 8 Week SQL Challenge Datasets
--------------------------------

-- Load all required tables for `dannys_diner` schema
LOAD DATA OVERWRITE dannys_diner.members
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/dannys_diner/members.csv']
);

LOAD DATA OVERWRITE dannys_diner.menu
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/dannys_diner/menu.csv']
);

LOAD DATA OVERWRITE dannys_diner.sales
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/dannys_diner/sales.csv']
);

-- Load all required tables for `pizza_runner` schema
LOAD DATA OVERWRITE pizza_runner.customer_orders
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/pizza_runner/customer_orders.csv']
);

LOAD DATA OVERWRITE pizza_runner.pizza_names
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/pizza_runner/pizza_names.csv']
);

LOAD DATA OVERWRITE pizza_runner.pizza_recipes
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/pizza_runner/pizza_recipes.csv']
);

LOAD DATA OVERWRITE pizza_runner.pizza_toppings
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/pizza_runner/pizza_toppings.csv']
);

LOAD DATA OVERWRITE pizza_runner.runner_orders
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/pizza_runner/runner_orders.csv']
);

LOAD DATA OVERWRITE pizza_runner.runners
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/pizza_runner/runners.csv']
);

-- Load all required tables for `foodie_fi` schema
LOAD DATA OVERWRITE foodie_fi.plans
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/foodie_fi/plans.csv']
);

LOAD DATA OVERWRITE foodie_fi.subscriptions
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/foodie_fi/subscriptions.csv']
);

-- Load all required tables for `data_bank` schema
LOAD DATA OVERWRITE data_bank.plans
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/data_bank/customer_nodes.csv']
);

LOAD DATA OVERWRITE data_bank.customer_transactions
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/data_bank/customer_transactions.csv']
);

-- Load all required tables for `data_mart` schema
LOAD DATA OVERWRITE data_mart.weekly_sales
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/data_mart/weekly_sales.csv']
);

-- Load all required tables for `clique_bait` schema
LOAD DATA OVERWRITE clique_bait.campaign_identifier
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/clique_bait/campaign_identifier.csv']
);

LOAD DATA OVERWRITE clique_bait.event_identifier
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/clique_bait/event_identifier.csv']
);

LOAD DATA OVERWRITE clique_bait.events
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/clique_bait/events.csv']
);

LOAD DATA OVERWRITE clique_bait.page_hierarchy
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/clique_bait/page_hierarchy.csv']
);

LOAD DATA OVERWRITE clique_bait.users
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/clique_bait/users.csv']
);

-- Load all required tables for `fresh_segments` schema
LOAD DATA OVERWRITE fresh_segments.interest_map
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/fresh_segments/interest_map.csv']
);

LOAD DATA OVERWRITE fresh_segments.interest_metrics
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/fresh_segments/interest_metrics.csv']
);

LOAD DATA OVERWRITE fresh_segments.json_data
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/fresh_segments/json_data.csv']
);

-- Load all required tables for `balanced_tree` schema
LOAD DATA OVERWRITE balanced_tree.product_details
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/balanced_tree/product_details.csv']
);

LOAD DATA OVERWRITE balanced_tree.product_hierarchy
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/balanced_tree/product_hierarchy.csv']
);

LOAD DATA OVERWRITE balanced_tree.product_prices
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/balanced_tree/product_prices.csv']
);

LOAD DATA OVERWRITE balanced_tree.sales
  FROM FILES (
  format = 'CSV',
  uris = ['gs://dwd-datasets/8-week-sql-challenge/balanced_tree/sales.csv']
);