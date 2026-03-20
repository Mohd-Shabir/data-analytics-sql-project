/*
===============================================================================
Report: (Product) Performance & Segmentation View
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors into a final view.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue performance and cost ranges.
    3. Aggregates product-level metrics (orders, sales, quantity, customers, lifespan).
    4. Calculates KPIs (recency, average order revenue, average monthly revenue).
===============================================================================
*/

DROP VIEW IF EXISTS gold.report_products;

CREATE VIEW gold.report_products AS

WITH base_query AS (
    /*---------------------------------------------------------------------------
    1) Base Query: Retrieves core columns from fact_sales and dim_products
    ---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  
),
product_aggregations AS (
    /*---------------------------------------------------------------------------
    2) Product Aggregations: Summarizes key metrics at the product level
    ---------------------------------------------------------------------------*/
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(sales_amount / NULLIF(quantity, 0)), 2) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
/*---------------------------------------------------------------------------
  3) Final Query: Combines all product results into one output
---------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    
    -- Cost Range Segment (Portfolio Enhancement)
    CASE 
        WHEN cost < 100 THEN 'Below $100'
        WHEN cost >= 100 AND cost < 500 THEN '$100 - $499'
        WHEN cost >= 500 AND cost < 1000 THEN '$500 - $999'
        ELSE '$1000 and above'
    END AS cost_range,

    last_sale_date,
    TIMESTAMPDIFF(MONTH, last_sale_date, CURDATE()) AS recency_in_months,
    
    -- Revenue Performance Segment
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    
    lifespan,
    total_orders,
    ROUND(total_sales, 2) AS total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    
    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders, 2)
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN ROUND(total_sales, 2)
        ELSE ROUND(total_sales / lifespan, 2)
    END AS avg_monthly_revenue

FROM product_aggregations;


SELECT * FROM gold.report_products;