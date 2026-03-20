/*
===============================================================================
Report: (Customer) Performance & Segmentation View
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors into a final view.

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers by Loyalty (VIP/Regular/New), Age Group, and Churn Risk.
    3. Aggregates customer-level metrics (orders, sales, quantity, lifespan).
    4. Calculates KPIs (recency, average order value, average monthly spend).
===============================================================================
*/

DROP VIEW IF EXISTS gold.report_customers;

CREATE VIEW gold.report_customers AS

WITH base_query AS (
    /*---------------------------------------------------------------------------
    1) Base Query: Retrieves core columns from tables
    ---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL
), 
customer_aggregation AS (
    /*---------------------------------------------------------------------------
    2) Customer Aggregations: Summarizes key metrics at the customer level
    ---------------------------------------------------------------------------*/
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)
/*---------------------------------------------------------------------------
3) Final Query: Applies logic and combines into the final report
---------------------------------------------------------------------------*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    
    -- Loyalty Segment
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    
    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency_months,
    
    -- Churn Risk Segment (Portfolio Enhancement)
    CASE 
        WHEN TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) < 3 THEN '1. Active'
        WHEN TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) >= 3 AND TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) < 6 THEN '2. At Risk'
        WHEN TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) >= 6 AND TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) < 12 THEN '3. Dormant'
        ELSE '4. Lost (Churned)'
    END AS churn_status,

    total_orders,
    ROUND(total_sales, 2) AS total_sales,
    total_quantity,
    total_products,
    lifespan,
    
    -- Compute average order value (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders, 2)
    END AS avg_order_value,
    
    -- Compute average monthly spend
    CASE 
        WHEN lifespan = 0 THEN ROUND(total_sales, 2)
        ELSE ROUND(total_sales / lifespan, 2)
    END AS avg_monthly_spend

FROM customer_aggregation;


SELECT * FROM gold.report_customers;