/*
===============================================================================
EDA : Dimension Exploration
===============================================================================
Purpose:
    To understand the distribution of our descriptive data (Customers and Products)
    before we analyze the transactional sales data.
===============================================================================
*/


-- 1. Where are our customers located? (Geographic Distribution)
-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT 
    country 
FROM gold.dim_customers
ORDER BY country;

-- 2. What is the gender breakdown of our customers? (Demographic Distribution)
-- WHY: To understand our core demographic.

SELECT DISTINCT 
    gender 
FROM gold.dim_customers;



-- 3. What is our complete product hierarchy?
-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;











