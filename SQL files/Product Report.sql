/*
===============================================================================
Product Report
===============================================================================

Purpose:
    - Analyzes product performance, revenue generation,
      category contribution, and product segmentation.

Highlights:

    1. Product Overview
       - Total products
       - Total categories
       - Average product price
       - Product price range

    2. Product Performance Analysis
       - Total quantity sold per product
       - Product sales ranking
       - Top 10 selling products (by quantity)

    3. Product Revenue Analysis
       - Total revenue per product
       - Product revenue ranking
       - Top 10 revenue-generating products

    4. Product Category Analysis
       - Total revenue by category
       - Total quantity sold by category
       - Revenue contribution by category

    5. Product Segmentation
       - Star products
       - High-performing products
       - Medium-performing products
       - Low-performing products
       - Revenue contribution by product segmentation

    6. Key Business KPIs
       - Total Product Revenue
       - Total Quantity Sold
       - Average Product Price
       - Average Revenue per Product
       - Top Revenue Product
       - Top Selling Product

Business Questions Answered:

    - Which products generate the most revenue?
    - Which products sell the most units?
    - Which products are top performers?
    - Which categories contribute the most revenue?
    - Which categories drive the highest sales volume?
    - Which products should receive additional business focus?

===============================================================================
*/

-- ============================================================================
-- 1. PRODUCT OVERVIEW
-- ============================================================================

SELECT 
	-- Total products
	COUNT(product_id) AS total_products,
	-- Total categories
	COUNT(DISTINCT category) AS total_categories,
	-- Average product price
	ROUND(AVG(base_price), 2) AS avg_product_base_price,
	-- Product price range
	CONCAT(MIN(base_price), ' - ', MAX(base_price)) AS product_price_range
FROM products;

-- ============================================================================
-- 2. PRODUCT PERFORMANCE ANALYSIS
-- ============================================================================

WITH quantity_ranking AS 
(
SELECT 
	product_id,
	-- Total quantity sold per product
	SUM(quantity) AS total_quantity_sold
FROM transaction1
GROUP BY product_id
)
SELECT *,
	-- Product sales ranking
	DENSE_RANK() OVER(ORDER BY total_quantity_sold DESC) AS product_ranking,
	-- Top 10 selling products (by quantity)
	CASE
		WHEN DENSE_RANK() OVER(ORDER BY total_quantity_sold DESC) <= 10 THEN 'Top Selling Products' 
		ELSE 'N/A'
	END AS top_selling_products_by_quantity
FROM quantity_ranking;

-- ============================================================================
-- 3. PRODUCT REVENUE ANALYSIS
-- ============================================================================

WITH revenue_ranking AS
(
SELECT 
	product_id,
	-- Total revenue per product
	SUM(gross_revenue) AS total_revenue
FROM transaction1
GROUP BY product_id
)
SELECT *,
	-- Product revenue ranking
	DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS product_ranking,
	-- Top 10 revenue-generating products
	CASE 
		WHEN DENSE_RANK() OVER(ORDER BY total_revenue DESC) <= 10 THEN 'Top Reveue-Generating Products'
		ELSE 'N/A'
	END AS top_revenue_generating_products
FROM revenue_ranking;

-- ============================================================================
-- 4. PRODUCT CATEGORY ANALYSIS
-- ============================================================================

WITH revenue_contri AS
(
SELECT 
	p.category,
	-- Total revenue by category
	ROUND(SUM(t.gross_revenue), 2) AS revenue_per_category,
	-- Total quantity sold by category
	SUM(t.quantity) AS total_quantity_sold
FROM transaction1 AS t
JOIN products as p
	ON t.product_id = p.product_id 
GROUP BY p.category
)
SELECT *,
	-- Revenue contribution by category
	SUM(revenue_per_category) OVER() AS total_revenue,
	ROUND(revenue_per_category*100/SUM(revenue_per_category) OVER(), 2) AS revenue_contribution_pct
FROM revenue_contri
ORDER BY revenue_contribution_pct DESC;

-- ============================================================================
-- 5. PRODUCT SEGMENTATION AND REVENUE CONTRIBUTION
-- ============================================================================

WITH segmentation AS
(
SELECT
	product_id,
	SUM(gross_revenue) AS revenue_per_product,
	NTILE(4) OVER(ORDER BY SUM(gross_revenue) DESC) AS quartile
FROM transaction1
GROUP BY product_id
)
SELECT *,
	CASE
		WHEN quartile = 1 THEN 'Star Product' 
		WHEN quartile = 2 THEN 'High-Performing Product'
		WHEN quartile = 3 THEN 'Medium-Performing Product' 
		ELSE 'Low-Performing Product'
	END AS product_segment
FROM segmentation;

-- Revenue contribution by product segment
WITH revenue_dist AS
(
SELECT 
product_id,
	SUM(gross_revenue) AS revenue_per_product,
	NTILE(4) OVER(ORDER BY SUM(gross_revenue) DESC) AS quartile,
	CASE 
		WHEN NTILE(4) OVER(ORDER BY SUM(gross_revenue) DESC) = 1 THEN 'Star Product' 
		WHEN NTILE(4) OVER(ORDER BY SUM(gross_revenue) DESC) = 2 THEN 'High-Performing Product'
		WHEN NTILE(4) OVER(ORDER BY SUM(gross_revenue) DESC) = 3 THEN 'Medium-Performing Product'
		ELSE 'Low-Performing Product'
	END AS product_segment
FROM transaction1
GROUP BY product_id
)
SELECT 
	product_segment,
	ROUND(SUM(revenue_per_product), 2) AS revenue_per_product_segment,
	ROUND(SUM(SUM(revenue_per_product)) OVER(), 2) AS total_revenue,
	ROUND(SUM(revenue_per_product)*100/SUM(SUM(revenue_per_product)) OVER(), 2) AS contribution_pct
FROM revenue_dist
GROUP BY product_segment;



