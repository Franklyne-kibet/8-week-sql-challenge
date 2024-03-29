--SQL functions: Create temp table, CASE WHEN, TRIM, ALTER TABLE, ALTER data type, filtering using '%'

-- Customer orders
SELECT order_id, customer_id, pizza_id,
CASE
   WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ' '
   ELSE exclusions
   END AS exclusions,
CASE
   WHEN extras IS NULL OR extras LIKE 'null' THEN ' '
   ELSE extras
   END AS extras,
   order_time
INTO customer_orders_temp
FROM dbo.customer_orders

-- TABLE: runner_orders

--pickup_time - remove nulls and replace with ' '
--distance - remove km and nulls
--duration - remove minutes and nulls
--cancellation - remove NULL and null and replace with ' ' 

SELECT order_id, runner_id,
CASE
   WHEN pickup_time LIKE 'null' THEN ' '
   ELSE pickup_time
   END AS pickup_time,
CASE
   WHEN distance LIKE 'null' THEN ' '
   WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
   ELSE distance
   END AS distance,
CASE
   WHEN duration LIKE 'null' THEN ' '
   WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
   WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
   WHEN duration LIKE '%minutes' THEN TRIM ('minutes' FROM duration)
   ELSE duration
   END AS duration,
CASE
   WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN ' '
   ELSE cancellation
   END AS cancellation
INTO runner_orders_temp
FROM dbo.runner_orders;

ALTER TABLE runner_orders_temp
ALTER COLUMN pickup_time DATETIME;

ALTER TABLE runner_orders_temp
ALTER COLUMN distance FLOAT;

ALTER TABLE runner_orders_temp
ALTER COLUMN duration INT;

ALTER TABLE pizza_names
ALTER COLUMN pizza_name NVARCHAR(MAX);