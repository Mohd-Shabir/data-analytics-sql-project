/*
===============================================================================
Advanced Analytics: Data Segmentation
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

===============================================================================
*/

-- ==========================================
-- 1. Product Cost Segmentation
-- ==========================================
-- WHY: To understand our inventory distribution across different price points.

WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below $100'
            WHEN cost >= 100 AND cost < 500 THEN '$100 - $499'
            WHEN cost >= 500 AND cost < 1000 THEN '$500 - $999'
            ELSE '$1000 and above'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


-- ==========================================
-- 2. Customer Loyalty Segmentation
-- ==========================================
-- WHY: To categorize customers based on their loyalty (lifespan) and lifetime value (spending) 
--      so marketing can target them appropriately.

WITH customer_spending AS (
    -- Step 1: Calculate lifetime spending and lifespan in months for each customer
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE order_date IS NOT NULL
    GROUP BY c.customer_key
)
-- Step 2 & 3: Apply the segmentation logic and aggregate the final results
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers,
    ROUND(SUM(total_spending), 2) AS total_revenue_from_segment
FROM (
    SELECT 
        customer_key,
        total_spending,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_revenue_from_segment DESC;


-- ==========================================
-- 3. Customer Churn Risk Segmentation
-- ==========================================
-- WHY: To identify customers who are active, at risk of leaving, or already lost, 
--      so marketing can send targeted win-back campaigns.

WITH customer_recency AS (
    -- Step 1: Find the most recent order for each customer and calculate the months since that order
    SELECT
        c.customer_key,
        MAX(f.order_date) AS last_order_date,
        -- We calculate the difference between their last order and the absolute latest date in the entire database
        TIMESTAMPDIFF(MONTH, MAX(f.order_date), (SELECT MAX(order_date) FROM gold.fact_sales)) AS months_since_last_order
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
    GROUP BY c.customer_key
)
-- Step 2 & 3: Segment based on recency and count the customers
SELECT 
    churn_status,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN months_since_last_order < 3 THEN '1. Active (Purchased recently)'
            WHEN months_since_last_order >= 3 AND months_since_last_order < 6 THEN '2. At Risk (Slipping away)'
            WHEN months_since_last_order >= 6 AND months_since_last_order < 12 THEN '3. Dormant (Needs win-back)'
            ELSE '4. Lost (Churned)'
        END AS churn_status
    FROM customer_recency
) AS segmented_customers
GROUP BY churn_status
ORDER BY churn_status;

