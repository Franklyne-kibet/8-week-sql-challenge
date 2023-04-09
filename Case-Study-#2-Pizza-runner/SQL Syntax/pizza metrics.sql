-- 1.How many pizzas were ordered?
SELECT COUNT(*) AS pizza_order_count
FROM customer_orders_temp;

-- 2.How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id)	AS unique_order_count
FROM customer_orders_temp; 

-- 3.How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders
FROM runner_orders_temp
WHERE distance != 0
GROUP BY runner_id;

-- 4.How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(c.pizza_id) AS delivered_pizza_count
FROM dbo.customer_orders_temp AS c
    JOIN dbo.runner_orders_temp AS r
        ON c.order_id = r.order_id
    JOIN dbo.pizza_names AS p
        ON	c.pizza_id = p.pizza_id
WHERE r.distance != 0
GROUP BY p.pizza_name;

--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name, COUNT(p.pizza_name) AS order_count
FROM dbo.customer_orders AS c
    JOIN dbo.pizza_names AS p
        ON c.pizza_id=p.pizza_id
GROUP BY c.customer_id,p.pizza_name
ORDER BY c.customer_id;

--6. What was the maximum number of pizzas delivered in a single order?
WITH pizza_count_cte AS
    (
        SELECT c.order_id, COUNT(c.pizza_id) AS pizza_per_order
        FROM dbo.customer_orders_temp AS c
            JOIN dbo.runner_orders_temp AS r
            ON c.order_id = r.order_id
        WHERE r.distance != 0
        GROUP BY c.order_id
    )
SELECT order_id, MAX(pizza_per_order) AS pizza_count
FROM pizza_count_cte
GROUP BY order_id;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id,
    SUM(
		CASE WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
		ELSE 0
		END)  AS atleast_1_change,
    SUM(
		CASE WHEN c.exclusions = ' ' OR c.extras = ' ' THEN 1
		ELSE 0
		END)  AS no_change
FROM customer_orders_temp AS c
    JOIN runner_orders_temp AS r
        ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;

--8. How many pizzas were delivered that had both exclusions and extras?
SELECT
    SUM(
	CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
	ELSE 0
	END) as pizza_count_w_exclusions_extras
FROM dbo.customer_orders_temp AS c
    JOIN dbo.runner_orders_temp AS r
        ON c.order_id = r.order_id
WHERE r.distance != 0
    AND exclusions <> ' '
    AND extras <> ' '

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
    DATEPART(HOUR, [order_time]) AS hour_of_day,
    COUNT(order_id) AS pizza_count
FROM dbo.customer_orders_temp
GROUP BY DATEPART(HOUR, [order_time]);

--10. What was the volume of orders for each day of the week?
SELECT
    FORMAT(DATEADD(DAY,2,order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
    COUNT(order_id) AS pizza_count
FROM dbo.customer_orders_temp
GROUP BY FORMAT(DATEADD(DAY,2,order_time), 'dddd');