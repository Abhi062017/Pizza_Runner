SET SQL_SAFE_UPDATES = 0;

/* 21st Jan, 2025 3:22pm
SQL Case Study : Pizza Runner
YT Source : https://www.youtube.com/watch?v=KPNPKMoYB-k&t=2s&ab_channel=TurnToData
*/

-- Step 1 : Creating and populating tables
CREATE TABLE if not exists pizza_runners
(
  runner_id INTEGER,
  registration_date DATE
);

INSERT pizza_runners VALUES
(1, '2021-01-01'),
(2, '2021-01-03'),
(3, '2021-01-08'),
(4, '2021-01-15');

CREATE TABLE if not exists pizza_customer_orders
(
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT pizza_customer_orders VALUES
('1', '101', '1', '', '', '2020-01-01 18:05:02'),
('2', '101', '1', '', '', '2020-01-01 19:00:52'),
('3', '102', '1', '', '', '2020-01-02 23:51:23'),
('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');

CREATE TABLE if not exists pizza_runner_orders
(
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT pizza_runner_orders VALUES
('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

CREATE TABLE if not exists pizza_names
(
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT pizza_names VALUES
(1, 'Meatlovers'),
(2, 'Vegetarian');

CREATE TABLE if not exists pizza_recipes
(
  pizza_id INTEGER,
  toppings TEXT
);

INSERT pizza_recipes VALUES
(1, '1, 2, 3, 4, 5, 6, 8, 10'),
(2, '4, 6, 7, 9, 11, 12');

CREATE TABLE if not exists pizza_toppings
(
  topping_id INTEGER,
  topping_name TEXT
);

INSERT pizza_toppings VALUES
(1, 'Bacon'),
(2, 'BBQ Sauce'),
(3, 'Beef'),
(4, 'Cheese'),
(5, 'Chicken'),
(6, 'Mushrooms'),
(7, 'Onions'),
(8, 'Pepperoni'),
(9, 'Peppers'),
(10, 'Salami'),
(11, 'Tomatoes'),
(12, 'Tomato Sauce');

-- Step 2 : Eyeballing the tables

select * from pizza_runners;
select * from pizza_customer_orders;
select * from pizza_runner_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

-- Step 3 : Data Cleaning : Used Power Query to clean the table (replace values and trim) 'pizza_runner_orders' and replaced 'null' with null in the tables with 'null'
select * from pizza_runner_orders;
Update pizza_runner_orders
set 
	pickup_time = case when pickup_time IN ('null','') then null else pickup_time end,
	distance = case when distance IN ('null','') then null else distance end,
    duration = case when duration IN ('null','') then null else duration end,
    cancellation = case when cancellation IN ('null','') then null else cancellation end;

select * from pizza_customer_orders;
update pizza_customer_orders
set 
	extras = case when extras IN ('','null') then NULL else extras end,
	exclusions = case when exclusions IN ('null', '') then NULL else exclusions end;

-- Step 4 : Querying the data to gain insights

-- Q1). How many pizzas were ordered?
select count(1) from pizza_customer_orders;

-- Q2). How many unique customer orders were made?
select count(distinct(order_id)) from pizza_customer_orders;

-- Q3). How many successful orders were delivered by each runner?
select count(1) from pizza_runner_orders where cancellation is null;

-- Q4). How many of each type of pizza was delivered?
select n.pizza_name, count(*) orders_count
from pizza_customer_orders o
join pizza_names n on n.pizza_id=o.pizza_id
group by n.pizza_name
order by count(*) desc;

-- Q5). What were the types of pizzas ordered by each customer?
select o.customer_id, n.pizza_name
from pizza_customer_orders o
join pizza_names n on n.pizza_id=o.pizza_id
group by o.customer_id, n.pizza_name
order by o.customer_id;

-- Q6). What is the maximum number of pizzas delivered in a single order?
select customer_id, count(*)
from pizza_customer_orders
group by customer_id
order by count(*) desc
limit 1;

-- Q7). For each customer, how many delivered pizzas had at least 1 change and how many had no changes (change implies, exclusions or extras).

select co.customer_id, count(1) delivered_pizzas,
sum(case 
	when co.exclusions is not null or co.extras is not null then 1 else 0 end) atleast_1change,
sum(case
	when co.exclusions is null and co.extras is null then 1 else 0 end) no_change
from pizza_customer_orders co
join pizza_runner_orders ro on ro.order_id = co.order_id
where ro.cancellation is null
group by co.customer_id
order by co.customer_id;

-- Q8). How many pizzas were delivered that had both exclusions and extras
select co.customer_id, count(1) delivered_pizzas,
sum(case
	when co.exclusions is not null and co.extras is not null then 1 else 0 end) both_excl_extra
from pizza_customer_orders co
join pizza_runner_orders ro on ro.order_id = co.order_id
where ro.cancellation is null
group by co.customer_id
order by co.customer_id;

-- Q9). What was the total volume of pizzas ordered for each hour of the day?
select hour(order_time) 24hourformat, count(1) total_pizzas_ordered
from pizza_customer_orders
group by hour(order_time);

-- Q10). What was the total volume of pizzas ordered for each day of the week?
select date_format(order_time, '%a') dayofweek, weekday(order_time) daynumber,count(*) total_volume_pizza_orders 
from pizza_customer_orders
group by dayofweek, daynumber;  -- Note : 0 is day number of Mon, 1 is of Tue and so on.

