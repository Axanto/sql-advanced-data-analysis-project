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

-- Which categories contribute the most to overall sales

-- 1. Using CTE
WITH category_sales AS (
SELECT 
	category,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	GROUP BY category
)	
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER ())*100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC

-- 2. Using Subquery
SELECT
  category,
  total_sales,
  SUM(total_sales) OVER () total_all_sales,
  CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER ())*100, 2), '%') AS percentage_of_total
FROM (
  SELECT
    category,
    SUM(sales_amount) AS total_sales
  FROM gold.fact_sales f
  LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
  GROUP BY category
) sub;