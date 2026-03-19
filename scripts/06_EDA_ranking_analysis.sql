/*
===============================================================================
EDA : Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), PARTITION BY
    - Clauses: GROUP BY, ORDER BY, LIMIT
===============================================================================
*/

-- ==========================================
-- 1. Product Ranking
-- ==========================================

-- 1. Which 5 products generate the highest revenue? (Simple Ranking)
-- WHY: To quickly identify the absolute best-sellers.
SELECT 
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- 2. Which 5 subcategory generate the highest revenue? (Window Function Approach)
-- WHY: To handle potential ties in revenue using the RANK() function dynamically.
SELECT *
FROM (
    SELECT
        p.subcategory,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.subcategory 
) AS ranked_products
WHERE rank_products <= 5;

-- 3. What are the 5 worst-performing products in terms of sales?
-- WHY: To identify products that may need to be discounted or removed from inventory.
SELECT 
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC
LIMIT 5;

-- 4. What is the #1 best-selling product within EACH subcategory?
-- WHY: To drill down further and identify the flagship product for every specific subcategory.
SELECT *
FROM (
    SELECT 
        p.category,
        p.subcategory,
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (PARTITION BY p.subcategory ORDER BY SUM(f.sales_amount) DESC) AS rank_in_subcategory
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category, p.subcategory, p.product_name
) AS subcategorized_ranking
WHERE rank_in_subcategory = 1
ORDER BY total_revenue DESC;

-- ==========================================
-- 2. Customer Ranking
-- ==========================================

-- 5. Who are the top 10 customers generating the highest revenue?
-- WHY: To identify VIP customers for targeted marketing and loyalty rewards.
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 6. Which 3 customers have placed the fewest orders?
-- WHY: To identify one-time buyers who might need a re-engagement email campaign.
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC
LIMIT 3;

-- ==========================================
-- 3. Advanced Ranking 
-- ==========================================

-- 7. What is the #1 best-selling product within EACH category?
-- WHY: To identify the flagship product for every single category using PARTITION BY.
SELECT *
FROM (
    SELECT 
        p.category,
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(f.sales_amount) DESC) AS rank_in_category
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category, p.product_name
) AS categorized_ranking
WHERE rank_in_category = 1
ORDER BY total_revenue DESC;

