
-- Query 1: Preview data
SELECT *
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS
LIMIT 10;

-- Query 2: Opening time
SELECT MIN(transaction_time) AS opening_time
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS;

-- Query 3: Closing time
SELECT MAX(transaction_time) AS closing_time
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS;

-- Query 4: Date and time analysis with revenue and counts
SELECT
    TO_DATE(transaction_date) AS transaction_date,
    DAYOFMONTH(TO_DATE(transaction_date)) AS day_of_month,
    DAYNAME(TO_DATE(transaction_date)) AS day_name,
    MONTHNAME(TO_DATE(transaction_date)) AS month_name,
    TO_CHAR(TO_DATE(transaction_date), 'YYYYMM') AS month_id,
    CASE
        WHEN transaction_time BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN transaction_time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        WHEN transaction_time BETWEEN '17:00:00' AND '19:59:59' THEN 'Evening'
        ELSE 'Night'
    END AS time_bucket,
    CASE
        WHEN DAYNAME(TO_DATE(transaction_date)) NOT IN ('Sat','Sun') THEN 'Weekday'
        ELSE 'Weekend'
    END AS day_classification,
    ROUND(SUM(IFNULL(transaction_qty,0)*IFNULL(unit_price,0)),0) AS revenue,
    COUNT(DISTINCT transaction_id) AS number_of_sales,
    COUNT(DISTINCT product_id) AS number_of_unique_products,
    COUNT(DISTINCT store_id) AS number_of_shops,
    store_location,
    product_category,
    product_detail,
    product_type
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS
GROUP BY
    TO_DATE(transaction_date),
    transaction_time,
    store_location,
    product_category,
    product_detail,
    product_type;

-- Query 5: 1-hour time bucket aggregation
SELECT 
    TO_DATE(transaction_date) AS transaction_date,
    DATE_TRUNC('HOUR', TO_TIMESTAMP(transaction_date || ' ' || transaction_time, 'YYYY-MM-DD HH24:MI:SS')) AS transaction_time_bucket,
    product_type,
    product_detail,
    SUM(CAST(REPLACE(unit_price, ',', '.') AS FLOAT) * transaction_qty) AS total_amount,
    SUM(transaction_qty) AS total_units_sold
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS
GROUP BY 
    TO_DATE(transaction_date),
    transaction_time_bucket,
    product_type,
    product_detail
ORDER BY 
    transaction_date,
    transaction_time_bucket,
    product_type;

-- Query 6: Top 10 products by revenue
SELECT 
    product_detail,
    SUM(transaction_qty * unit_price) AS highest_revenue
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS
GROUP BY product_detail
ORDER BY highest_revenue DESC
LIMIT 10;

-- Query 7: Bottom 10 products by revenue
SELECT 
    product_detail,
    SUM(transaction_qty * unit_price) AS lowest_revenue
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS
GROUP BY product_detail
ORDER BY lowest_revenue ASC
LIMIT 10;

-- Query 8: Total revenue
SELECT 
    ROUND(SUM(IFNULL(transaction_qty, 0) * IFNULL(unit_price, 0)), 2) AS total_revenue
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS;

-- Query 9: Transaction-level detail
SELECT 
    transaction_id,
    product_detail,
    unit_price,
    transaction_qty,
    (unit_price * transaction_qty) AS total_amount
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS;

-- Query 10: 30-minute time bucket aggregation
SELECT 
    TO_DATE(transaction_date) AS transaction_date,
    DATEADD(
        MINUTE,
        -MOD(EXTRACT(MINUTE FROM TO_TIMESTAMP(transaction_date || ' ' || transaction_time, 'YYYY-MM-DD HH24:MI:SS')), 30),
        DATE_TRUNC('MINUTE', TO_TIMESTAMP(transaction_date || ' ' || transaction_time, 'YYYY-MM-DD HH24:MI:SS'))
    ) AS time_interval,
    product_type,
    product_detail,
    SUM(transaction_qty * unit_price) AS total_amount,
    SUM(transaction_qty) AS total_units_sold
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS
GROUP BY 
    TO_DATE(transaction_date),
    time_interval,
    product_type,
    product_detail
ORDER BY 
    transaction_date,
    time_interval,
    product_type;

-- Query 11: Add 30-minute time bucket to each row
SELECT 
    *,
    DATEADD(
        MINUTE,
        -MOD(EXTRACT(MINUTE FROM TO_TIMESTAMP(transaction_date || ' ' || transaction_time, 'YYYY-MM-DD HH24:MI:SS')), 30),
        DATE_TRUNC('MINUTE', TO_TIMESTAMP(transaction_date || ' ' || transaction_time, 'YYYY-MM-DD HH24:MI:SS'))
    ) AS transaction_time_bucket
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS;

-- Query 12: Cast unit_price and calculate total amount
SELECT 
    transaction_id,
    REPLACE(unit_price, ',', '.')::FLOAT AS unit_price_casted,
    transaction_qty,
    (REPLACE(unit_price, ',', '.')::FLOAT * transaction_qty) AS total_amount
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS;

-- Query 13: Hourly aggregation by product type
SELECT 
    product_type,
    DATE_TRUNC('HOUR', TO_TIMESTAMP(transaction_date || ' ' || transaction_time, 'YYYY-MM-DD HH24:MI:SS')) AS transaction_time_bucket,
    SUM(CAST(REPLACE(unit_price, ',', '.') AS FLOAT) * transaction_qty) AS total_amount,
    SUM(transaction_qty) AS total_units_sold
FROM BRIGHT_COFFEE_SHOP.PUBLIC.ANALYSIS
GROUP BY product_type, transaction_time_bucket
ORDER BY product_type, transaction_time_bucket;
