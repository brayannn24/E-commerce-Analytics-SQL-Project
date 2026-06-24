/*
===============================================================================
Sales Report
===============================================================================

Purpose:
    - Analyze sales performance, trends, and product contribution
      to identify growth opportunities and business performance.

Highlights:

    1. Sales Overview
       - Total Revenue
       - Total Orders
       - Total Quantity Sold
       - Average Revenue per Order

    2. Change Over Time Analysis
       - Sales by Year
       - Sales by Month
       - Customer Count by Month
       - Quantity Sold by Month

    3. Cumulative Analysis
       - Running Total Revenue
       - Running Average Revenue
       - Running Average Product Base Price

    4. Performance Analysis
       - Monthly Category Performance
       - Yearly Category Performance
       - Above-Average Sales Periods
       - Below-Average Sales Periods
       - Month-over-Month Growth
       - Year-over-Year Growth

    5. Proportion Analysis
       - Revenue Contribution by Category

    6. Sales Segmentation
       - Products by Price Range
       - Revenue Distribution Across Price Segments

Key KPIs:

       - Total Revenue
       - Total Orders
       - Total Quantity Sold
       - Average Order Value
       - Monthly Revenue Growth
       - Category Revenue Contribution

Business Questions Answered:

       - Is revenue growing over time?
       - Which categories generate the most revenue?
       - Which periods outperform the average?
       - What percentage of revenue comes from each category?
       - How are products distributed across price ranges?

===============================================================================
*/



-- ============================================================================
-- 1. SALES OVERVIEW
-- ============================================================================
 
SELECT 
	-- Total Revenue
	ROUND(SUM(gross_revenue), 2) AS total_revenue,
	-- Total Orders
	COUNT(transaction_id) AS total_orders,
	-- Total Quantity Sold
	SUM(quantity) AS total_quantity_sold,
	-- Average Order Value (AOV)
	ROUND(AVG(gross_revenue), 2) AS avg_order_value
FROM transaction1;

-- ============================================================================
-- 2. CHANGE-OVER-TIME ANALYSIS
-- ============================================================================

-- Sales by Year
WITH year_dist AS
(
SELECT 
	YEAR(timestamp) AS `year`,
	ROUND(SUM(gross_revenue), 2) AS sales_per_year
FROM transaction1
GROUP BY `year`
) 
SELECT *,
	ROUND(SUM(sales_per_year) OVER(), 2) AS total_revenue,
	ROUND(sales_per_year*100/SUM(sales_per_year) OVER(), 2) AS contribution_pct
FROM year_dist
ORDER BY `year` ASC;

-- Sales, Customer Count, and Quantity Sold by Month
SELECT 
	DATE_FORMAT(timestamp, '%Y-%m-01') AS `month`,
	COUNT(DISTINCT customer_id) AS customer_count,
	SUM(quantity) AS quantity_sold,
	ROUND(SUM(gross_revenue), 2) AS sales_per_month
FROM transaction1
GROUP BY `month`
ORDER BY `month` ASC;


-- ============================================================================
-- 3. CUMULATIVE ANALYSIS
-- ============================================================================

-- Running Total Revenue and Running Average Revenue by Month
WITH rt AS
(
SELECT 
	YEAR(`timestamp`) AS `year`,
	DATE_FORMAT(timestamp, '%Y-%m-01') AS `month`,
	ROUND(SUM(gross_revenue), 2) AS total_sales
FROM transaction1
GROUP BY YEAR(timestamp), DATE_FORMAT(timestamp, '%Y-%m-01')
)
SELECT 
	`month`,
	total_sales,
	ROUND(SUM(total_sales) OVER(PARTITION BY `year` ORDER BY `month`), 2) AS running_total_revenue,
	ROUND(AVG(total_sales) OVER(PARTITION BY `year` ORDER BY `month`), 2) AS running_avg_revenue
FROM rt
ORDER BY `month`;

-- Running Average Product Base Price
WITH rt1 AS
(
SELECT 
	YEAR(t.timestamp) AS `year`,
	DATE_FORMAT(t.timestamp, '%Y-%m-01') AS `month`,
	ROUND(AVG(p.base_price), 2) AS avg_base_price
FROM products AS p
JOIN transaction1 AS t
	ON p.product_id = t.product_id
GROUP BY YEAR(t.timestamp), DATE_FORMAT(t.timestamp, '%Y-%m-01')
)
SELECT 
	`month`,
	avg_base_price,
	ROUND(AVG(avg_base_price) OVER(PARTITION BY `year` ORDER BY `month`), 2) AS running_avg_base_price
FROM rt1;

-- ============================================================================
-- 4. Performance Analysis
-- ============================================================================

-- Monthly Category Performance

WITH sales_avg AS
(
SELECT 
	DATE_FORMAT(t.timestamp, '%Y-%m-01') AS `month`,
	p.category,
	SUM(t.quantity) AS total_quantity_sold,
	ROUND(SUM(t.gross_revenue), 2) AS total_sales
FROM transaction1 AS t
JOIN products AS p
	ON t.product_id = p.product_id
GROUP BY DATE_FORMAT(t.timestamp, '%Y-%m-01'), p.category
ORDER BY p.category, DATE_FORMAT(t.timestamp, '%Y-%m-01')
),
growth AS
(
SELECT *,
	ROUND(AVG(total_sales) OVER(PARTITION BY category), 2)  AS avg_sales_by_category,
	ROUND(total_sales - ROUND(AVG(total_sales) OVER(PARTITION BY category), 2), 2) AS avg_diff,
	CASE
		WHEN total_sales > ROUND(AVG(total_sales) OVER(PARTITION BY category), 2) THEN 'Above Average'
		WHEN total_sales < ROUND(AVG(total_sales) OVER(PARTITION BY category), 2) THEN 'Below Average'
		ELSE 'Average'
	END AS avg_remarks,
	LAG(total_sales) OVER(PARTITION BY category ORDER BY `month`) AS previous_month_sales,
	ROUND(total_sales - LAG(total_sales) OVER(PARTITION BY category ORDER BY `month`), 2) AS sales_diff,
	CASE
		WHEN LAG(total_sales) OVER(PARTITION BY category ORDER BY `month`) IS NULL THEN 'N/A'
		WHEN total_sales > LAG(total_sales) OVER(PARTITION BY category ORDER BY `month`) THEN 'Increased'
		WHEN total_sales < LAG(total_sales) OVER(PARTITION BY category ORDER BY `month`) THEN 'Decreased'
		ELSE 'No change'
	END AS sales_remarks,
	ROUND((total_sales - LAG(total_sales) OVER(PARTITION BY category ORDER BY `month`))*100/LAG(total_sales) OVER(PARTITION BY category ORDER BY `month`), 2) AS mom_growth_pct
FROM sales_avg
)
SELECT *,
	CASE
		WHEN mom_growth_pct IS NULL THEN 'N/A' 
		WHEN mom_growth_pct > 0 THEN 'Growth'
		WHEN mom_growth_pct < 0 THEN 'Decline'
		ELSE 'No Change'
	END AS mom_status
FROM growth;
	

-- Yearly Category Performance

WITH sales_avg1 AS
(
SELECT 
	Year(t.timestamp) AS `year`,
	p.category,
	SUM(t.quantity) AS total_quantity_sold,
	ROUND(SUM(t.gross_revenue), 2) AS total_sales
FROM transaction1 AS t
JOIN products AS p
	ON t.product_id = p.product_id
GROUP BY Year(t.timestamp), p.category
ORDER BY p.category, Year(t.timestamp)
),
growth1 AS
(
SELECT *,
	ROUND(AVG(total_sales) OVER(PARTITION BY category), 2)  AS avg_sales_by_category,
	ROUND(total_sales - ROUND(AVG(total_sales) OVER(PARTITION BY category), 2), 2) AS avg_diff,
	CASE
		WHEN total_sales > ROUND(AVG(total_sales) OVER(PARTITION BY category), 2) THEN 'Above Average'
		WHEN total_sales < ROUND(AVG(total_sales) OVER(PARTITION BY category), 2) THEN 'Below Average'
		ELSE 'Average'
	END AS avg_remarks,
	LAG(total_sales) OVER(PARTITION BY category ORDER BY `year`) AS previous_year_sales,
	ROUND(total_sales - LAG(total_sales) OVER(PARTITION BY category ORDER BY `year`), 2) AS sales_diff,
	CASE
		WHEN LAG(total_sales) OVER(PARTITION BY category ORDER BY `year`) IS NULL THEN 'N/A'
		WHEN total_sales > LAG(total_sales) OVER(PARTITION BY category ORDER BY `year`) THEN 'Increased'
		WHEN total_sales < LAG(total_sales) OVER(PARTITION BY category ORDER BY `year`) THEN 'Decreased'
		ELSE 'No change'
	END AS sales_remarks,
	ROUND((total_sales - LAG(total_sales) OVER(PARTITION BY category ORDER BY `year`))*100/LAG(total_sales) OVER(PARTITION BY category ORDER BY `year`), 2) AS yoy_growth_pct
FROM sales_avg1
) 
SELECT *,
	CASE
		WHEN yoy_growth_pct IS NULL THEN 'N/A' 
		WHEN yoy_growth_pct > 0 THEN 'Growth'
		WHEN yoy_growth_pct < 0 THEN 'Decline'
		ELSE 'No Change'
	END AS yoy_status
FROM growth1;

-- ============================================================================
-- 5. Proportion Analysis
-- ============================================================================

-- Revenue Contribution by Category

WITH contri AS
(
SELECT p.category,
ROUND(SUM(t.gross_revenue), 2) AS sales_per_category
FROM transaction1 AS t
JOIN products AS p
	ON t.product_id = p.product_id
GROUP BY p.category
)
SELECT *,
SUM(sales_per_category) OVER() AS total_sales,
ROUND(sales_per_category*100/SUM(sales_per_category) OVER(), 2) AS contribution_pct
FROM contri
ORDER BY contribution_pct DESC;

-- ============================================================================
-- 6. Sales Segmentation
-- ============================================================================

-- Products by Price Range

WITH seg AS 
(
SELECT 
	product_id,
	base_price,
	CASE
		WHEN base_price < 100 THEN 'Less than 100'
		WHEN base_price >= 100 AND base_price < 300 THEN '100-299.99'
		WHEN base_price >= 300 AND base_price <= 500 THEN '300-500'
		ELSE 'Above 500'
	END AS price_segment
FROM products
) 
SELECT 
	price_segment,
	COUNT(product_id) AS no_of_products,
	COUNT(product_id)*100/(
							SELECT COUNT(product_id)
							FROM products 
						  ) AS distribution_pct
FROM seg
GROUP BY price_segment;

-- Revenue Distribution Across Price Segments

WITH rev_dist AS
(
SELECT 
	t.product_id,
	p.base_price,
	t.gross_revenue,
	CASE
		WHEN p.base_price < 100 THEN 'Less than 100'
		WHEN p.base_price >= 100 AND p.base_price < 300 THEN '100-299.99'
		WHEN p.base_price >= 300 AND p.base_price <= 500 THEN '300-500'
		ELSE 'Above 500'
	END AS segment
FROM transaction1 AS t
JOIN products AS p
	ON t.product_id = p.product_id
),
rev_pct AS
(
SELECT 
	segment,
	ROUND(SUM(gross_revenue), 2) AS sales_by_segment
FROM rev_dist
GROUP BY segment
)
SELECT *,
	ROUND(SUM(sales_by_segment) OVER(), 2) AS total_sales,
	ROUND(sales_by_segment*100/SUM(sales_by_segment) OVER(), 2) AS segment_pct
FROM rev_pct;
































