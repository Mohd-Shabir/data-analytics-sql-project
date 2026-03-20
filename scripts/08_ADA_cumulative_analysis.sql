/*
===============================================================================
Advanced Analytics: Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

===============================================================================
*/

-- ==========================================
-- 1. Running Totals (Cumulative Sum)
-- ==========================================

-- 1. Calculate the Total Sales per Month and the Running Total
-- WHY: To track the compounding growth of revenue over the lifespan of the business.
SELECT
    order_year,
    order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_year, order_month) AS running_total_sales
FROM (
    -- Subquery: First, we aggregate the total sales per month
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date)
) AS monthly_sales;


-- ==========================================
-- 2. Moving Averages 
-- ==========================================

-- 2. Calculate the 3-Month Moving Average for Sales
-- WHY: To smooth out monthly volatility (spikes/drops) and identify underlying long-term trends.
SELECT
    order_year,
    order_month,
    total_sales,
    -- Calculates the average of the current month and the previous 2 months
    ROUND(AVG(total_sales) OVER (
        ORDER BY order_year, order_month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_average_3_months
FROM (
    SELECT
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date)
) AS monthly_sales;