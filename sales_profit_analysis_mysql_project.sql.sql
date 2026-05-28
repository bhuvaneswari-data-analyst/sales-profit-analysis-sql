-- =========================================
-- SALES AND PROFIT ANALYSIS MYSQL PROJECT
-- =========================================


-- =========================================
-- 1. TOTAL SALES
-- =========================================

SELECT ROUND(SUM(sales),2) AS total_sales
FROM sales_data;



-- =========================================
-- 2. TOTAL PROFIT
-- =========================================

SELECT ROUND(SUM(profit),2) AS total_profit
FROM sales_data;



-- =========================================
-- 3. TOTAL ORDERS
-- =========================================

SELECT COUNT(DISTINCT order_id) AS total_orders
FROM sales_data;



-- =========================================
-- 4. AVERAGE ORDER VALUE
-- =========================================

SELECT
ROUND(SUM(sales)/COUNT(DISTINCT order_id),2)
AS avg_order_value
FROM sales_data;



-- =========================================
-- 5. REGION WISE SALES
-- =========================================

SELECT
region,
ROUND(SUM(sales),2) AS total_sales

FROM sales_data

GROUP BY region

ORDER BY total_sales DESC;



-- =========================================
-- 6. REGION WISE PROFIT
-- =========================================

SELECT
region,
ROUND(SUM(profit),2) AS total_profit

FROM sales_data

GROUP BY region

ORDER BY total_profit DESC;



-- =========================================
-- 7. CATEGORY WISE SALES
-- =========================================

SELECT
category,
ROUND(SUM(sales),2) AS total_sales

FROM sales_data

GROUP BY category

ORDER BY total_sales DESC;



-- =========================================
-- 8. CATEGORY WISE PROFIT
-- =========================================

SELECT
category,
ROUND(SUM(profit),2) AS total_profit

FROM sales_data

GROUP BY category

ORDER BY total_profit DESC;



-- =========================================
-- 9. SUB CATEGORY WISE SALES
-- =========================================

SELECT
sub_category,
ROUND(SUM(sales),2) AS total_sales

FROM sales_data

GROUP BY sub_category

ORDER BY total_sales DESC;



-- =========================================
-- 10. TOP 5 CUSTOMERS
-- =========================================

SELECT

customer_name,

ROUND(SUM(sales),2) AS total_sales

FROM sales_data

GROUP BY customer_name

ORDER BY total_sales DESC

LIMIT 5;



-- =========================================
-- 11. YEAR AND QUARTER ANALYSIS
-- =========================================

SELECT

order_date,

YEAR(order_date) AS year,

QUARTER(order_date) AS quarter

FROM sales_data;



-- =========================================
-- 12. MIN AND MAX DATE
-- =========================================

SELECT

MIN(order_date) AS start_date,

MAX(order_date) AS end_date

FROM sales_data;



-- =========================================
-- 13. FISCAL YEAR FUNCTION
-- =========================================

CREATE FUNCTION get_fiscal_year (
order_date DATE
)

RETURNS INTEGER

DETERMINISTIC

BEGIN

DECLARE fiscal_year INT;

SET fiscal_year =
YEAR(DATE_ADD(order_date, INTERVAL 9 MONTH));

RETURN fiscal_year;

END;



-- =========================================
-- 14. FISCAL QUARTER FUNCTION
-- =========================================

CREATE FUNCTION get_fiscal_quarter (
order_date DATE
)

RETURNS CHAR(2)

DETERMINISTIC

BEGIN

DECLARE fiscal_quarter CHAR(2);

SET fiscal_quarter =
CONCAT(
'Q',
QUARTER(DATE_ADD(order_date, INTERVAL 9 MONTH))
);

RETURN fiscal_quarter;

END;



-- =========================================
-- 15. FISCAL YEAR & QUARTER OUTPUT
-- =========================================

SELECT

order_date,

get_fiscal_year(order_date) AS fiscal_year,

get_fiscal_quarter(order_date) AS fiscal_quarter

FROM sales_data;



-- =========================================
-- 16. MONTHLY SALES TREND PROCEDURE
-- =========================================

CREATE PROCEDURE monthly_sales_trend (

IN p_fiscal_year INT

)

BEGIN

SELECT

MONTH(order_date) AS month_no,

MONTHNAME(order_date) AS month_name,

ROUND(SUM(sales),2) AS total_sales,

ROUND(SUM(profit),2) AS total_profit

FROM sales_data

WHERE get_fiscal_year(order_date)
= p_fiscal_year

GROUP BY month_no, month_name

ORDER BY month_no;

END;



-- =========================================
-- 17. EXECUTE MONTHLY SALES TREND
-- =========================================

CALL monthly_sales_trend(2024);



-- =========================================
-- 18. TOP CUSTOMERS PROCEDURE
-- =========================================

CREATE PROCEDURE top_customers_fiscal_year(

IN p_fiscal_year INT,

IN p_top_n INT

)

BEGIN

SELECT

customer_name,

ROUND(SUM(sales),2) AS total_sales,

ROUND(SUM(profit),2) AS total_profit

FROM sales_data

WHERE get_fiscal_year(order_date)
= p_fiscal_year

GROUP BY customer_name

ORDER BY total_sales DESC

LIMIT p_top_n;

END;



-- =========================================
-- 19. EXECUTE TOP CUSTOMERS
-- =========================================

CALL top_customers_fiscal_year(2024,5);



-- =========================================
-- 20. TOP REGIONS PROCEDURE
-- =========================================

CREATE PROCEDURE top_regions_fiscal_year(

IN p_fiscal_year INT,

IN p_top_n INT

)

BEGIN

SELECT

region,

ROUND(SUM(sales),2) AS total_sales,

ROUND(SUM(profit),2) AS total_profit

FROM sales_data

WHERE get_fiscal_year(order_date)
= p_fiscal_year

GROUP BY region

ORDER BY total_sales DESC

LIMIT p_top_n;

END;



-- =========================================
-- 21. EXECUTE TOP REGIONS
-- =========================================

CALL top_regions_fiscal_year(2024,3);



-- =========================================
-- 22. SALES SUMMARY VIEW
-- =========================================

CREATE VIEW sales_summary AS

SELECT

region,

category,

ROUND(SUM(sales),2) AS total_sales,

ROUND(SUM(profit),2) AS total_profit

FROM sales_data

GROUP BY region, category;



-- =========================================
-- 23. FISCAL SALES SUMMARY VIEW
-- =========================================

CREATE VIEW fiscal_sales_summary AS

SELECT

order_date,

get_fiscal_year(order_date) AS fiscal_year,

get_fiscal_quarter(order_date)
AS fiscal_quarter,

sales,
profit

FROM sales_data;



-- =========================================
-- 24. WINDOW FUNCTION
-- TOP SUB CATEGORY IN EACH CATEGORY
-- =========================================


SELECT

category,

sub_category,

ROUND(SUM(sales),2) AS total_sales,

DENSE_RANK() OVER(

PARTITION BY category

ORDER BY SUM(sales) DESC

) AS sales_rank

FROM sales_data

GROUP BY category, sub_category;



-- =========================================
-- 25. WINDOW FUNCTION
-- TOP PROFIT STATE IN EACH REGION
-- =========================================


SELECT

region,

state,

ROUND(SUM(profit),2) AS total_profit,

DENSE_RANK() OVER(

PARTITION BY region

ORDER BY SUM(profit) DESC

) AS profit_rank

FROM sales_data

GROUP BY region, state;




-- =========================================
-- 26. CTE ANALYSIS
-- CUSTOMERS ABOVE AVERAGE SALES
-- =========================================

WITH customer_sales AS (

SELECT

customer_name,

ROUND(SUM(sales),2) AS total_sales

FROM sales_data

GROUP BY customer_name

)

SELECT *

FROM customer_sales

WHERE total_sales >

(

SELECT AVG(total_sales)

FROM customer_sales

);