# E-commerce-Analytics-SQL-Project

**Project Overview**

A SQL-based analytics project that transforms raw e-commerce data into actionable business insights through sales, customer, and product performance reporting.

The project focuses on building structured reports, KPIs, and segmentation analyses to support data-driven business decisions.

This project is divided into three main reports: 

    •	Sales Report
    
    •	Customer Report
    
    •	Product Report
  
**Tools Used**

    •	MySQL - Data analysis and reporting
    
    •	DBeaver  - Database management and query execution
    
    •	GitHub – Version control and project documentation

**Dataset**

The dataset used for this project was acquired from Kaggle and contains synthetic data generated using Python. 

The analysis was performed using the following tables:

	Transactions
    
	Contains sales transaction records including:
    
    -	Transaction ID
    -	Purchase Timestamp
    -	Customer ID
    -	Product ID
    -	Quantity
    -	Revenue
    -	Discount Information
    -	Gross Revenue
    -	Campaign ID
    -	Refund Flag
    
    Customers
    
    Contains customer demographic information including:
    
    -	Customer ID
    -	Signup Date
    -	Country
    -	Age
    -	Gender
    -	Loyalty Tier
    -	Acquisition Channel
    
    Products
    
    Contains product information including:
    
    -	Product ID
    -	Category
    -	Brand ID
    -	Base Price
    -	Launch Date
    -	Premium Information
    
**SQL Skills Demonstrated**

    •	Data Cleaning
    
    •	Data Validation
    
    •	Common Table Expressions
    
    •	Inner Joins
    
    •	Window Functions (NTILE, DENSE RANK, RUNNING TOTAL, LAG)
    
    •	Aggregate Functions
    
    •	CASE Statements
    
    •	Customer Segmentation
    
    •	Revenue Contribution Analysis
    
    •	KPI Development
  
**Sales Report**

**Objectives**

To analyze overall business performance and sales over time.

**Key Analyses**

    •	Sales Overview
    
    •	Sales by Year
    
    •	Sales by Month
    
    •	Running Revenue Analysis
    
    •	Monthly and Yearly Category Performance
    
    •	Month-over-Month (MoM) Growth
    
    •	Year-over-Year (YoY) Growth
    
    •	Revenue Contribution by Category
    
    •	Product Price Segment Analysis

**Business Questions Answered**

    •	Is revenue growing over time?
    
    •	Which categories generate the most revenue?
    
    •	Which periods outperform the average?
    
    •	What percentage of revenue comes from each category?
    
    •	How are products distributed across price ranges?

**Customer Report**

**Objectives**

To analyze customer demographics, purchasing behavior, and customer value.

**Key Analyses**

    •	Customer Overview
    
    •	Customer Distribution by Country
    
    •	Customer Distribution by Age Group
    
    •	Customer Distribution by Gender
    
    •	Customer Distribution by Loyalty Tier
    
    •	Customer Value Analysis
    
    •	Customer Segmentation (VIP, High, Medium, Low)
    
    •	Customer Behavior Analysis (Repeat Purchase Rate, One-Time Purchase Rate)
    
    •	Revenue Contribution by Loyalty Tier
    
    •	Revenue Contribution by Country
    
    •	Revenue Contribution by Customer Segment

**Business Questions Answered**

    •	Who are the highest-value customers?
    
    •	Which customers generate the most revenue?
    
    •	How frequently do customers place orders?
    
    •	How much do customers spend on average per order?
    
    •	Which customers have the longest relationship with the business?
    
    •	Which customers have purchased most recently?
    
    •	Which customer segment contribute the most value?
    
    •	What are the customer repeat purchase and one-time purchase rates?
    
    •	Which loyalty tiers generate the highest revenue?
    
    •	Which countries contribute the most revenue?
    
    •	Which customer segment contributes the most revenue?
    
    •	How is the customer base distributed across demographics?

**Product Report**

**Objectives**

To analyze product performance, revenue generation, and category contribution.

**Key Analyses**

    •	Product Overview
    
    •	Product Performance Analysis
    
    •	Product Revenue Analysis
    
    •	Product Category Analysis
    
    •	Product Segmentation (Star, High-Performing, Medium-Performing, Low-Performing)

**Business Questions Answered**

    •	Which products generate the most revenue?
    
    •	Which products sell the most units?
    
    •	Which products are top performers?
    
    •	Which categories contribute the most revenue?
    
    •	Which categories drive the highest sales volume?
    
    •	Which products should receive additional business focus?

**Key Findings**

**Sales Insights**

    •	Over the three-year period, total revenue reached $8,373,966.36, with 2021 contributing the largest share at 33.64%.
    
    •	The Electronics category contributed the largest share of total sales at 41.22%, followed by the Home category at 23.84%.
    
    •	Products priced below $100 accounted for the majority of the product catalog, representing 76.25% of all products.
    
    •	Products priced below $100 generated the largest share of total sales, contributing 51.66% of revenue, followed by products priced between $100 and $299.99, which accounted for 46.67%.

**Customer Insights**

    •	There are 100,000 customers in total, of which 60.09% are active customers who have made at least one purchase.
    
    •	The United States accounts for the largest share of customers, representing 34.93% of the customer base.
    
    •	Customers aged 31–40 comprise the largest age group, accounting for 38.46% of all customers.
    
    •	60.28% of customers belong to the Bronze loyalty tier, making it the largest loyalty segment.
    
    •	Customer IDs 72115 and 11800 are the highest revenue-generating customers, each contributing $1,858.32 in gross revenue.
    
    •	Among active customers, 39.23% are repeat buyers, while 60.77% are one-time buyers.
    
    •	The Bronze loyalty tier generated the highest revenue, contributing 53.47% of total revenue.
    
    •	The United States generated the largest share of revenue, accounting for 35.23% of total revenue.
    
    •	VIP customers contributed the largest share of revenue, generating 59.39% of total revenue.

**Product Insights**

    •	There are 2,000 products distributed across 6 product categories. 
    
    •	The average product base price is $72.17, with prices ranging from $5.11 to $464.58. 
    
    •	Product ID 496 generated the highest revenue, contributing $33,310.35 in sales. 
    
    •	The Electronics category recorded the highest sales volume, with 29,194 units sold.
    
    •	Star Products generated the largest share of product revenue, accounting for 51.22% of total sales.

**Key Takeaways**

Through this project, I developed practical experience in:

    •	Writing complex analytical SQL queries
    
    •	Building business-focused KPI reports
    
    •	Performing customer and product segmentation
    
    •	Using window functions for advanced analytics
    
    •	Translating raw data into actionable business insights

**Author**

Bryan Rafael Eniego

Aspiring Data Analyst | Petroleum Engineer | SQL | Data Analytics 
