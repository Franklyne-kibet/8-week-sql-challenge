-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) as amount_spent
FROM sales s
    JOIN menu m ON s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date)) AS visit_count
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH order_sales_cte AS
    (
        SELECT customer_id, order_date, product_name,
            DENSE_RANK() OVER(PARTITION BY s.customer_id
		ORDER BY s.order_date) AS rank
        FROM sales s
        JOIN menu m
            ON s.product_id = m.product_id
    )
SELECT customer_id, product_name
FROM order_sales_cte
WHERE rank=1
GROUP BY customer_id,product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers
SELECT TOP 1(COUNT(s.product_id)) AS most_purchased , product_name
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY most_purchased DESC;