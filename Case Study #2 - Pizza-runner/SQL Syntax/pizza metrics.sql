-- 1.How many pizzas were ordered?
SELECT COUNT(*) AS pizza_order_count
FROM customer_orders_temp

-- 2.How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id)	AS unique_order_count
FROM customer_orders_temp 

-- 3.How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders
FROM runner_orders_temp
WHERE distance != 0
GROUP BY runner_id

-- 4.