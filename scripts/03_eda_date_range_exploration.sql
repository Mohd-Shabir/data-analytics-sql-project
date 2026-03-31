/*
===============================================================================
EDA : DATE Exploration 
===============================================================================

===============================================================================
*/

-- 1. What are the boundaries of our sales data? (First/Last Order Months range)
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- 2. What is the age range of our customer base? (Youngest & Oldest)
-- WHY: To understand our demographic boundaries. 
SELECT 
    MIN(birthdate) AS oldest_customer_birthdate,
    TIMESTAMPDIFF(YEAR, MIN(birthdate), CURDATE()) AS oldest_age_approx,
    MAX(birthdate) AS youngest_customer_birthdate,
    TIMESTAMPDIFF(YEAR, MAX(birthdate), CURDATE()) AS youngest_age_approx
FROM gold.dim_customers;



-- 3. How fast are we shipping products to customers?
-- WHY: To measure operational efficiency and customer satisfaction.
SELECT 
    ROUND(AVG(DATEDIFF(shipping_date, order_date)), 1) AS avg_days_to_ship,
    MAX(DATEDIFF(shipping_date, order_date)) AS max_days_to_ship,
    MIN(DATEDIFF(shipping_date, order_date)) AS min_days_to_ship
FROM gold.fact_sales
WHERE shipping_date IS NOT NULL;



-- 5. What unique years are present in our sales data?
-- WHY: To quickly see which years we have data for.
SELECT DISTINCT 
    YEAR(order_date) AS sales_year
FROM gold.fact_sales
ORDER BY sales_year;




