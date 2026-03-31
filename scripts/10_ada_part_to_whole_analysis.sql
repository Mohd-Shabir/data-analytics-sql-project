/*
===============================================================================
Advanced Analytics: Part-to-Whole Analysis
===============================================================================
Purpose:
    - To calculate how individual parts (categories, regions) contribute to the overall total.
    - To identify the most significant drivers of business performance.

===============================================================================
*/

-- ==========================================
-- 1. Category Contribution
-- ==========================================
-- WHY: To understand which product categories drive the largest percentage of our overall revenue.

WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(SUM(total_sales) OVER (), 2) AS overall_sales,
    -- Multiplying by 100.0 safely forces decimal math in MySQL!
    ROUND((total_sales * 100.0) / SUM(total_sales) OVER (), 2) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;


-- ==========================================
-- 2. Geographic Contribution 
-- ==========================================
-- WHY: To identify which countries make up the largest piece of our global revenue pie.

WITH country_sales AS (
    SELECT
        c.country,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.country
)
SELECT
    country,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(SUM(total_sales) OVER (), 2) AS overall_sales,
    ROUND((total_sales * 100.0) / SUM(total_sales) OVER (), 2) AS percentage_of_total
FROM country_sales
ORDER BY total_sales DESC;
