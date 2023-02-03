# 🍜 Case Study #1: Danny's Diner

## 1. What is the total amount each customer spent at the restaurant?

    ```SQL
    SELECT customer_id, SUM(price) as amount_spent
    FROM sales s
        JOIN menu m ON s.product_id = m.product_id
    GROUP BY customer_id;
    ```

#### Steps:

- Use SUM and GROUP BY to find out total_sales contributed by each customer.
- Use JOIN to merge sales and menu tables as customer_id and price are from both tables.



