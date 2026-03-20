/*
===============================================================================
Advanced Analytics: Performance Analysis (YoY, MoM)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.

===============================================================================
*/

-- ==========================================
-- 1. Yearly Product Performance (Year-over-Year)
-- ==========================================
-- WHY: To track if individual products are growing or declining in sales year over year.

WITH yearly_product_sales AS (
    -- Step 1: Aggregate sales per product per year
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
-- Step 2: Compare current sales to average and previous year sales
SELECT
    order_year,
    product_name,
    ROUND(current_sales, 2) AS current_sales,
    
    -- Average Performance Analysis
    ROUND(AVG(current_sales) OVER (PARTITION BY product_name), 2) AS avg_sales,
    ROUND(current_sales - AVG(current_sales) OVER (PARTITION BY product_name), 2) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    
    -- Year-over-Year (YoY) Analysis
    ROUND(LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year), 2) AS py_sales,
    ROUND(current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year), 2) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change

FROM yearly_product_sales
ORDER BY product_name, order_year;


-- ==========================================
-- 2. Company-Wide Month-over-Month (MoM) Growth 
-- ==========================================
-- WHY: To measure the overall business growth percentage from one month to the next.

WITH monthly_sales AS (
    -- Step 1: Aggregate total company sales per month
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales_amount) AS current_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), MONTH(order_date)
)
-- Step 2: Calculate the exact percentage of growth/decline compared to last month
SELECT 
    order_year,
    order_month,
    ROUND(current_sales, 2) AS current_sales,
    ROUND(LAG(current_sales) OVER (ORDER BY order_year, order_month), 2) AS previous_month_sales,
    ROUND(current_sales - LAG(current_sales) OVER (ORDER BY order_year, order_month), 2) AS mom_diff,
    
    -- Math: (Current - Previous) / Previous * 100 = Percentage Growth
    ROUND((current_sales - LAG(current_sales) OVER (ORDER BY order_year, order_month)) / 
          LAG(current_sales) OVER (ORDER BY order_year, order_month) * 100, 2) AS mom_growth_pct

FROM monthly_sales
ORDER BY order_year, order_month;