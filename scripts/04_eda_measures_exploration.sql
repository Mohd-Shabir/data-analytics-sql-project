/*
===============================================================================
EDA : Measures Exploration (Big Numbers & KPIs)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To establish the baseline "Big Numbers" for the business.
===============================================================================
*/

-- 1. Find the Total Sales
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_sales;

-- 2. Find how many items were sold
SELECT SUM(quantity) AS total_items_sold FROM gold.fact_sales;

-- 3. Find the average selling price
SELECT AVG(price) AS avg_selling_price FROM gold.fact_sales;

-- 4. Find the Total number of Orders
SELECT 
    COUNT(order_number) AS total_order_items, 
    COUNT(DISTINCT order_number) AS total_unique_orders 
FROM gold.fact_sales;

-- 5. Find the total number of products
SELECT COUNT(product_key) AS total_products FROM gold.dim_products;

-- 6. Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- 7. Find the total number of customers who have placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers_with_orders FROM gold.fact_sales;


-- ==========================================
-- 8. Generate a Master KPI Report
-- WHY: To consolidate all key metrics into a single, easily readable summary table.
-- ==========================================

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'Active Buying Customers', COUNT(DISTINCT customer_key) FROM gold.fact_sales;


