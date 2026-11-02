create database retail_project;
use retail_project;
CREATE TABLE superstore (
    row_id            INT PRIMARY KEY,
    order_id          VARCHAR(20),
    order_date        DATE,
    ship_date         DATE,
    ship_mode         VARCHAR(20),
    customer_id       VARCHAR(15),
    customer_name     VARCHAR(40),
    segment           VARCHAR(20),
    country           VARCHAR(30),
    city              VARCHAR(40),
    state             VARCHAR(40),
    postal_code       VARCHAR(5),
    region            VARCHAR(10),
    product_id        VARCHAR(20),
    category          VARCHAR(20),
    sub_category      VARCHAR(20),
    product_name      VARCHAR(200),
    sales             DECIMAL(10,3),
    quantity          INT,
    discount          DECIMAL(4,2),
    profit            DECIMAL(10,4),
    order_year        INT,
    order_month       VARCHAR(3),
    days_to_ship      INT,
    postal_code_fixed VARCHAR(5)
);
select count(*) as total_rows from superstore;

SELECT ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM superstore;

-- SELECT = which columns to show, FROM = which table
SELECT category, sales, profit FROM superstore LIMIT 5;

-- SUM adds up, GROUP BY makes one row per category
SELECT category,
       ROUND(SUM(sales),0)  AS sales,
       ROUND(SUM(profit),0) AS profit
FROM superstore
GROUP BY category
ORDER BY profit DESC;

-- discount danger
SELECT discount,
       COUNT(*) AS order_lines,
       ROUND(SUM(profit),0) AS profit
FROM superstore
GROUP BY discount
ORDER BY discount;

-- WHERE = only keep rows that match
SELECT ROUND(SUM(profit),2) AS loss_above_40
FROM superstore
WHERE discount > 0.4;

-- furniture mystery
SELECT sub_category, ROUND(SUM(profit),0) AS profit
FROM superstore
WHERE category = 'Furniture'
GROUP BY sub_category
ORDER BY profit;

SELECT discount, ROUND(SUM(profit),0) AS profit
FROM superstore
WHERE sub_category = 'Tables'
GROUP BY discount
ORDER BY discount;

-- region trap
-- HAVING = a filter that works AFTER the adding-up
SELECT region, category, ROUND(SUM(profit),0) AS profit
FROM superstore
GROUP BY region, category
HAVING SUM(profit) < 0;

-- growth race
SELECT order_year,
       ROUND(SUM(sales),0)  AS sales,
       ROUND(SUM(profit),0) AS profit,
       ROUND(SUM(profit)/SUM(sales)*100,1) AS margin_pct
FROM superstore
GROUP BY order_year
ORDER BY order_year;

WITH yearly AS (
    SELECT order_year,
           SUM(sales)  AS sales,
           SUM(profit) AS profit
    FROM superstore
    GROUP BY order_year
)
SELECT order_year,
       ROUND((sales  - LAG(sales)  OVER (ORDER BY order_year))
             / LAG(sales)  OVER (ORDER BY order_year) * 100, 1) AS sales_growth_pct,
       ROUND((profit - LAG(profit) OVER (ORDER BY order_year))
             / LAG(profit) OVER (ORDER BY order_year) * 100, 1) AS profit_growth_pct
FROM yearly;

-- customer trap
SELECT customer_name,
       ROUND(SUM(sales),0)  AS sales,
       ROUND(SUM(profit),0) AS profit
FROM superstore
GROUP BY customer_name
ORDER BY SUM(profit)
LIMIT 3;

SELECT COUNT(*) AS losing_customers
FROM (
    SELECT customer_id
    FROM superstore
    GROUP BY customer_id
    HAVING SUM(profit) < 0
) AS t;