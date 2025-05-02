/* 
=====================================================================================================
Product Report
=====================================================================================================
Purpose:
	- This report consolidates key product metrics and behaviors
Highlights :
	1. Gathers essential fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low Performers .
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unqiue)
		- lifespan (in months) 	
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue

=====================================================================================================
*/

WITH base_query AS (
/* --------------------------------------------------------
1. Base Query: Retrieve core columns from table
----------------------------------------------------------- */ 
SELECT 
	f.order_number,
	p.product_key,
	f.order_date,
	p.product_name,
	p.product_number,
	p.category,
	p.subcategory,
	p.cost,
	f.quantity,
	f.customer_key,
	f.sales_amount
FROM gold.dim_products p
LEFT JOIN gold.fact_sales f
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
)
, product_aggregation AS(
/* --------------------------------------------------------
2. Product Aggregations: Summarizs key metrics at the product level
----------------------------------------------------------- */ 
SELECT 
	product_key,
	product_name,
	product_number,
	category,
	subcategory,
	cost,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_customer,
	MAX(order_date) AS last_sale_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY product_key,product_number, product_name, category, subcategory, cost
)

SELECT 
	product_key,
	product_name,
	product_number,
	category,
	subcategory,
	cost,
	last_sale_date,
	total_sales,
	CASE WHEN total_sales >= 750000 THEN 'High Performers'
		 WHEN total_sales BETWEEN 250000 AND 750000 THEN 'Mid-Range'
		 ELSE 'Low Performers'
	END reveue_seg,
	-- Recency
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	lifespan,
	total_orders,
	total_quantity,
	total_customer,
	avg_selling_price,
	-- avarage order revenue
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders 
	END AS avg_order_revenue,
	--  avarage monthly revenue
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales/lifespan
	END AS avg_monthly_spend
FROM product_aggregation

