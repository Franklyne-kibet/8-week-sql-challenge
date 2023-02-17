-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) as total_sales
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

--5. Which item was the most popular for each customer?
WITH most_popular_cte AS
    (
        SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS order_count,
            DENSE_RANK() OVER(PARTITION BY s.customer_id
	    ORDER BY COUNT(s.product_id) DESC ) AS rank
        FROM menu m
            JOIN sales s
                ON m.product_id = s.product_id
        GROUP BY s.customer_id, m.product_name
    )
SELECT customer_id, product_name, order_count
FROM most_popular_cte
WHERE rank = 1;

-- 6.Which item was purchased first by the customer after they became a member?
WITH first_purchased_cte AS
    (
        SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
            DENSE_RANK() OVER(PARTITION BY s.customer_id
		ORDER BY s.order_date) as rank
        FROM dbo.sales AS s
            JOIN dbo.members AS m
                ON s.customer_id = m.customer_id
        WHERE s.order_date >= m.join_date
    )
SELECT s.customer_id, s.order_date, m2.product_name
FROM first_purchased_cte as s
    JOIN dbo.menu m2
        ON s.product_id = m2.product_id
WHERE rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH prior_purchase_cte AS
    (
        SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
            DENSE_RANK() OVER(PARTITION BY s.customer_id
		ORDER BY s.order_date DESC) as rank
        FROM dbo.sales AS s
            JOIN dbo.members AS m
                ON s.customer_id = m.customer_id
        WHERE s.order_date < m.join_date
    )
SELECT s.customer_id, s.order_date, m2.product_name
FROM prior_purchase_cte AS s
    JOIN dbo.menu AS m2
        ON s.product_id = m2.product_id
WHERE rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(DISTINCT(s.product_id)) AS unique_menu_item, SUM(price) as total_sales
FROM dbo.sales AS s
    JOIN dbo.members AS m
        ON s.customer_id = m.customer_id
    JOIN dbo.menu AS mm
        ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have? WITH price_point
WITH price_points AS
    (
        SELECT *,
            CASE 
			    WHEN product_id = 1 THEN price*20
			    ELSE price*10
		    END AS points
        FROM dbo.menu
    )
SELECT customer_id, SUM(points) AS total_points
FROM price_points AS p
    JOIN dbo.sales AS s
        ON p.product_id = s.product_id
GROUP BY customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

WITH dates_cte AS
    (
        SELECT *,
            DATEADD(DAY, 6, join_date) AS valid_date,
            EOMONTH('2021-01-31') AS last_date
        FROM members AS m
    )
SELECT d.customer_id,
    SUM(
        CASE 
			WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
			WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
			ELSE 10 * m.price
		END
        ) AS total_points
FROM dates_cte AS d
    JOIN sales AS s
        ON d.customer_id = s.customer_id
    JOIN menu AS m
        ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id

-- BONUS QUESTIONS
-- Join All The Things - Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
SELECT s.customer_id, s.order_date, m.product_name, m.price,
    CASE 
		WHEN mm.join_date > s.order_date THEN 'N'
		WHEN mm.join_date <= s.order_date THEN 'Y'
		ELSE 'N'
	END AS member
FROM sales AS s
    LEFT JOIN menu AS m
        ON s.product_id = m.product_id
    LEFT JOIN members as mm
        ON s.customer_id = mm.customer_id

-- Rank All The Things - Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
WITH summary_cte AS
    (
        SELECT s.customer_id, s.order_date, m.product_name, m.price,
            CASE 
                WHEN mm.join_date > s.order_date THEN 'N'
                WHEN mm.join_date <= s.order_date THEN 'Y'
            ELSE 'N'
        END AS member
        FROM sales AS s
            LEFT JOIN menu AS m
                ON s.product_id = m.product_id
            LEFT JOIN members as mm
                ON s.customer_id = mm.customer_id
    )
SELECT *,
    CASE 
		WHEN member = 'N' THEN NULL
		ELSE
			RANK() OVER(PARTITION BY customer_id, member
			ORDER BY order_date) 
		END AS ranking
FROM summary_cte