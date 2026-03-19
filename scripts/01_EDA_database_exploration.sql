/*
===============================================================================
EDA : DATABASE EXPLORATION
===============================================================================
Purpose:
    To explore the structure of the database, including the list of tables, 
    columns, and their respective data types before querying the actual data.
===============================================================================
*/

-- 1. Explore All Objects in the Database
-- WHY: To see what tables or views exist inside the 'gold' schema.
SELECT 
    TABLE_NAME, 
    TABLE_TYPE 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'gold';

-- 2. Explore the Columns for a Specific Table (Quick View)
-- WHY: To quickly see the column names, data types, and if they allow NULLs.
DESCRIBE gold.dim_customers;

-- (run this for the other tables too)
DESCRIBE gold.dim_products;
DESCRIBE gold.fact_sales;

-- 3. Master Metadata Query (The "Data Dictionary" approach)
-- WHY: To pull a complete list of every single column across the entire Gold layer in one go.
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- Explore all column metadata (Data Dictionary) for the Gold Layer
SELECT 
*
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME, ORDINAL_POSITION;