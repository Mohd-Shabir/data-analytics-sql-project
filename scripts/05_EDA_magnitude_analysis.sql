/*
===============================================================================
EDA : Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - To understand data distribution across categories (the "size" of our groups).

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- ==========================================
-- 1. Single-Table Grouping (Dimensions)
-- ==========================================

-- 1. Where are our customers located? 
-- WHY: To quantify our customer base by country.
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- 2. What is the gender distribution of our customers?
-- WHY: To quantify our customer base by gender for demographic profiling.
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- 3. How is our inventory distributed across product categories?
-- WHY: To see which categories contain the most unique products.
SELECT
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- 4. What is the average production cost per category?
-- WHY: To identify which product categories are the most expensive to manufacture/stock.
SELECT
    category,
    ROUND(AVG(cost), 2) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- ==========================================
-- 2. Multi-Table Grouping (Combining Dimensions & Facts)
-- ==========================================

-- 5. Which product categories generate the highest total revenue?
-- WHY: To identify our most profitable product lines.
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 6. Who are our most valuable customers?
-- WHY: To identify top-spending individuals for potential loyalty/VIP programs.
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
ORDER BY total_revenue DESC;

-- 7. Which countries purchase the most physical items?
-- WHY: To understand global shipping volume and distribution logistics.
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;

-- 8. What is the Average Order Value (AOV) by Country? (Portfolio Enhancement)
-- WHY: To determine which countries spend the most money per individual order.
SELECT 
    c.country,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(DISTINCT f.order_number) AS total_orders,
    ROUND(SUM(f.sales_amount) / COUNT(DISTINCT f.order_number), 2) AS avg_order_value
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY avg_order_value DESC;


-- 9. Which countries buy the most expensive individual items?
-- WHY: To differentiate between customers who buy in bulk (high quantity) vs. premium buyers (high item price).
SELECT 
    c.country,
    SUM(f.sales_amount) AS total_revenue,
    SUM(f.quantity) AS total_items_sold,
    ROUND(SUM(f.sales_amount) / SUM(f.quantity), 2) AS avg_item_price
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY avg_item_price DESC;