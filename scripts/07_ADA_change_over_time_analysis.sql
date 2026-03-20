/*
===============================================================================
Advanced Analytics: Change Over Time Analysis
===============================================================================
Purpose:
    - To monitor business trends, growth by tracking key performance metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

===============================================================================
*/

-- ==========================================
-- 1. Trend Analysis
-- ==========================================

-- 1. How are sales trending over time? (Standard Year/Month)
-- WHY: To spot seasonality (e.g., do we always sell more in November?) and track overall growth.
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


-- 2. How are sales trending over time? (Formatted for Dashboards)
-- WHY: To create a clean, readable text label (e.g., "2023-Jan") for charts and graphs.
SELECT
    DATE_FORMAT(order_date, '%Y-%b') AS order_month_label,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
-- We group by the label, but order by the actual year and month so it doesn't sort alphabetically!
GROUP BY DATE_FORMAT(order_date, '%Y-%b'), YEAR(order_date), MONTH(order_date) 
ORDER BY YEAR(order_date), MONTH(order_date);


-- ==========================================
-- 2. Seasonality Analysis 
-- ==========================================

-- 3. How do sales perform by Quarter?
-- WHY: To align our data with traditional business financial quarters (Q1, Q2, Q3, Q4).
SELECT
    YEAR(order_date) AS order_year,
    QUARTER(order_date) AS order_quarter,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), QUARTER(order_date)
ORDER BY YEAR(order_date), QUARTER(order_date);