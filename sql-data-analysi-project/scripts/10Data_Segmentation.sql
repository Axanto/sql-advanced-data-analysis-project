/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Goal:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

-- Segment products into cost ranges and count how many products fall into each segment
WITH product_segment AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'ABOVE 1000'
END cost_range
FROM gold.dim_products
)
SELECT
	cost_range,
	COUNT(product_key) AS total_products	
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC


/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

WITH customer_spending AS (
SELECT 
DISTINCT(f.customer_key),
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
SUM(f.sales_amount) AS total_spend,
DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS life_span,
CASE WHEN SUM(f.sales_amount) > 5000 AND  DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date))>=12 THEN 'VIP'
	 WHEN SUM(f.sales_amount) <= 5000 AND DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date))>=12 THEN 'Regular'
	 ELSE 'New'
END cust_seg
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
GROUP BY f.customer_key
)

SELECT
cust_seg,
COUNT(customer_key) AS total_customers
FROM customer_spending
GROUP BY cust_seg
ORDER BY total_customers DESC