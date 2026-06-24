/*

===============================================================================
Customer Report
===============================================================================

	Purpose:
	- Analyzes customer demographics, purchasing behavior,
	customer value, revenue contribution, and customer segmentation.

	Highlights:
	
	1. Customer Overview
	   - Total customers
	   - Total active customers
	   - Customer distribution by country
	   - Customer distribution by age group
	   - Customer distribution by gender
	   - Customer distribution by loyalty tier
	
	2. Customer Value Analysis
	   - Total revenue per customer
	   - Customer revenue ranking
	   - Average order value (AOV)
	   - Total orders per customer
	   - Total quantity purchased per customer
	   - First purchase date
	   - Last purchase date
	   - Customer tenure (days)
	   - Customer recency (days)
	
	3. Customer Segmentation
	   - VIP customers
	   - High-value customers
	   - Medium-value customers
	   - Low-value customers
	   
	4. Customer Behavior Analysis
		- Repeat buyers
		- One-time buyers
		- Repeat purchase rate
		- One-time purchase rate

	5. Revenue Contribution Analysis
	   - Revenue by loyalty tier
	   - Revenue contribution by loyalty tier
	   - Revenue by country
	   - Revenue contribution by country
	   - Revenue contribution by customer segment
	
	Business Questions Answered:
	
	- Who are the highest-value customers?
	- Which customers generate the most revenue?
	- How frequently do customers place orders?
	- How much do customers spend on average per order?
	- Which customers have the longest relationship with the business?
	- Which customers have purchased most recently?
	- Which customer segments contribute the most value?
	- What is the customer repeat purchase and one-time purchase rates?
	- Which loyalty tiers generate the highest revenue?
	- Which countries contribute the most revenue?
	- Which customer segment contribute the most revenue?
	- How is the customer base distributed across demographics?

===============================================================================
*/


-- ============================================================================
-- 1. CUSTOMER OVERVIEW
-- ============================================================================

-- Total Number of Customers

SELECT 
	COUNT(customer_id) AS total_customers
FROM customers;

-- Total Number of Active Customers (who at least made one purchase).

SELECT 
	COUNT(DISTINCT customer_id) total_active_customers
FROM transaction1;

-- Customer Distibution by Country.

WITH country_distribution AS
(
SELECT 
	country,
	COUNT(customer_id) AS customers_per_country
FROM customers
GROUP BY country
)
SELECT *,
	SUM(customers_per_country) OVER() AS total_customers,
	CONCAT(ROUND(customers_per_country*100/SUM(customers_per_country) OVER(), 2), '%') AS distribution_pct
FROM country_distribution
ORDER BY customers_per_country*100/SUM(customers_per_country) OVER() DESC;

-- Customer Distribution by Age.

WITH age_distribution AS
(
SELECT 
	customer_id,
	age,
	CASE
		WHEN age < 18 THEN 'Below 18' 
	    WHEN age >= 18 AND age <= 30 THEN '18-30'
	    WHEN age >= 31 AND age <= 40 THEN '31-40'
	    WHEN age >= 41 AND age <= 50 THEN '41-50'
	    ELSE 'Above 50'
	END AS age_group
FROM customers
),
age_distribution1 AS
(
SELECT 
	age_group,
	COUNT(customer_id) AS number_of_customers
FROM age_distribution
GROUP BY age_group
)
SELECT *,
	SUM(number_of_customers) OVER() AS total_customers,
	CONCAT(ROUND(number_of_customers*100/SUM(number_of_customers) OVER(), 2), '%') AS percent_distribution
FROM age_distribution1
ORDER BY number_of_customers*100/SUM(number_of_customers) OVER() DESC;

-- Customer Distribution by Gender.

WITH gender_distribution AS
(
SELECT 
	gender,
	COUNT(customer_id) AS number_of_customers
FROM customers
GROUP BY gender
)
SELECT *,
	SUM(number_of_customers) OVER() AS total_customers,
	CONCAT(ROUND(number_of_customers*100/SUM(number_of_customers) OVER(), 2), '%') AS distribution_pct
FROM gender_distribution
ORDER BY number_of_customers*100/SUM(number_of_customers) OVER() DESC;

-- Customer Distibution by Loyalty Tier.

WITH loyalty_distribution AS
(
SELECT 
	loyalty_tier,
	COUNT(customer_id) AS customers_per_loyalty_tier
FROM customers
GROUP BY loyalty_tier
)
SELECT *,
	SUM(customers_per_loyalty_tier) OVER() AS total_customers,
	CONCAT(ROUND(customers_per_loyalty_tier*100/SUM(customers_per_loyalty_tier) OVER(), 2), '%') AS distribution_pct
FROM loyalty_distribution
ORDER BY customers_per_loyalty_tier*100/SUM(customers_per_loyalty_tier) OVER() DESC;

-- ============================================================================
-- 2. CUSTOMER VALUE ANALYSIS
-- ============================================================================

WITH segmentation AS
(
SELECT 
	customer_id,
	-- Total revenue per customer
	ROUND(SUM(gross_revenue), 2) AS gross_revenue_per_customer,
	-- Customer revenue ranking
	DENSE_RANK() OVER(ORDER BY SUM(gross_revenue) DESC) AS customer_ranking_by_gross_revenue,
	-- Average order value (AOV)
	ROUND(AVG(gross_revenue), 2) AS avg_order_value,
	-- Total orders per customer
	COUNT(DISTINCT transaction_id) AS total_orders_per_customer,
	-- Total quantity purchased per customer
	SUM(quantity) AS total_quantity_purchased_per_customer,
	-- First purchase date
	DATE(MIN(timestamp)) AS first_purchase_date,
	-- Last purchase date
	DATE(MAX(timestamp)) AS last_purchase_date,
	-- Customer tenure (days)
	DATEDIFF(DATE(MAX(timestamp)), DATE(MIN(timestamp))) AS customer_tenure_days,
	-- Customer recency (days)
	DATEDIFF(CURDATE(), DATE(MAX(timestamp))) AS recency_days,
	-- ============================================================================
	-- 3. CUSTOMER SEGMENTATION
	-- ============================================================================
	NTILE(4) OVER(ORDER BY SUM(gross_revenue) DESC) AS quartile
FROM transaction1
GROUP BY customer_id
)
SELECT *,
CASE
	WHEN quartile = 1 THEN 'VIP'
    WHEN quartile = 2 THEN 'High'
    WHEN quartile = 3 THEN 'Medium'
    ELSE 'Low'
END AS customer_segment
FROM segmentation
ORDER BY gross_revenue_per_customer DESC;

-- ============================================================================
-- 4. CUSTOMER BEHAVIOR ANALYSIS
-- ============================================================================

WITH rp AS
(
SELECT customer_id,
COUNT(transaction_id) AS no_of_transactions_made
FROM transaction1 
GROUP BY customer_id
),
rp1 AS
(
SELECT *,
CASE
	WHEN no_of_transactions_made > 1 THEN 'Repeat Buyer'
	ELSE 'One-Time Buyer'
END customer_type
FROM rp
)
SELECT 
-- Repeat Buyers
COUNT(CASE WHEN customer_type = 'Repeat Buyer' THEN 1 END) AS repeat_buyer,
-- One-time buyers
COUNT(CASE WHEN customer_type = 'One-Time Buyer' THEN 1 END) AS one_time_buyer,
-- Repeat purchase rate
CONCAT(ROUND(COUNT(CASE WHEN customer_type = 'Repeat Buyer' THEN 1 END)*100/(SELECT
																			 COUNT(DISTINCT customer_id)
																             FROM transaction1), 2), '%') AS repeat_purchase_rate,
-- One-time purchase rate																             
CONCAT(ROUND(COUNT(CASE WHEN customer_type = 'One-Time Buyer' THEN 1 END)*100/(SELECT
																			 COUNT(DISTINCT customer_id)
																             FROM transaction1), 2), '%') AS one_time_purchase_rate
FROM rp1;

-- ============================================================================
-- 5. REVENUE CONTRIBUTION ANALYSIS
-- ============================================================================

-- Revenue by Loyalty Tier

WITH loyalty AS
(
SELECT 
c.loyalty_tier,
ROUND(SUM(t.gross_revenue), 2) AS gross_revenue_per_tier
FROM transaction1 AS t
JOIN customers AS c
	ON t.customer_id = c.customer_id
GROUP BY c.loyalty_tier
)
SELECT *,
ROUND(SUM(gross_revenue_per_tier) OVER(), 2) AS total_revenue,
-- Revenue contribution by loyalty tier
CONCAT(ROUND(gross_revenue_per_tier*100/SUM(gross_revenue_per_tier) OVER(), 2), '%') AS distribution_pct
FROM loyalty
ORDER BY gross_revenue_per_tier DESC;

-- Revenue by Country

WITH country AS
(
SELECT 
c.country,
ROUND(SUM(t.gross_revenue), 2) AS gross_revenue_per_country
FROM transaction1 AS t
JOIN customers AS c
	ON t.customer_id = c.customer_id
GROUP BY c.country
)
SELECT *,
ROUND(SUM(gross_revenue_per_country) OVER(), 2) AS total_revenue,
-- Revenue contribution by country
CONCAT(ROUND(gross_revenue_per_country*100/SUM(gross_revenue_per_country) OVER(), 2), '%') AS percent_distribution
FROM country
ORDER BY gross_revenue_per_country DESC;

-- Revenue contribution by customer segment

WITH cust_segment AS
(
SELECT 
	customer_id,
	SUM(gross_revenue) AS revenue_per_customer,
	NTILE(4) OVER(ORDER BY SUM(gross_revenue) DESC) AS quartile 
FROM transaction1
GROUP BY customer_id
),
segment_dist AS
(
SELECT *,
	CASE
		WHEN quartile = 1 THEN 'VIP' 
		WHEN quartile = 2 THEN 'High'
		WHEN quartile = 3 THEN 'Medium'
		ELSE 'Low'
	END AS customer_segment
FROM cust_segment
)
SELECT 
	customer_segment,
	ROUND(SUM(revenue_per_customer), 2) AS revenue_by_segment,
	(SELECT 
		ROUND(SUM(gross_revenue), 2)
	FROM transaction1
	) AS total_revenue,
	ROUND(SUM(revenue_per_customer)*100/(SELECT 
								  	 SUM(gross_revenue)
								   FROM transaction1
								  ), 2) AS distribution_pct
FROM segment_dist
GROUP BY customer_segment;
	
	











