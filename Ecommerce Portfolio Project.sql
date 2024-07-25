CREATE TABLE EcomProduct (
	product_id SERIAL PRIMARY KEY,
	product_name VARCHAR(50),
	category VARCHAR(50),
	price numeric(7,2),
	review_score numeric(2,1),
	review_count int
);

CREATE TABLE EcomSale (
	product_id SERIAL PRIMARY KEY,
	sales_month_1 int,
	sales_month_2 int,
	sales_month_3 int,
	sales_month_4 int,
	sales_month_5 int,
	sales_month_6 int,
	sales_month_7 int,
	sales_month_8 int,
	sales_month_9 int,
	sales_month_10 int,
	sales_month_11 int,
	sales_month_12 int
);

COPY EcomProduct (
	product_id,
	product_name,
	category,
	price,
	review_score,
	review_count
)
FROM 'D:\ecommerce_sales_analysis_1.csv'
DELIMITER ','
CSV HEADER;

COPY EcomSale (
	product_id,
	sales_month_1,
	sales_month_2,
	sales_month_3,
	sales_month_4,
	sales_month_5,
	sales_month_6,
	sales_month_7,
	sales_month_8,
	sales_month_9,
	sales_month_10,
	sales_month_11,
	sales_month_12
)
FROM 'D:\ecommerce_sales_analysis_2.csv'
DELIMITER ','
CSV HEADER;

-------

SELECT *
FROM ecomproduct;

SELECT *
FROM ecomsale;

-------

-- All Columns for products in the toys category 

SELECT *
FROM ecomproduct as ep
JOIN ecomsale as es
	ON ep.product_id = es.product_id
WHERE category = 'Toys'

-------

-- Number of Products for each category and the percentage with respect to the whole product portfolio

With catproduct (category,product_count,total_count)
as(
	SELECT category, COUNT(product_id) as product_count , SUM(COUNT(product_id)) OVER() as total_count
	FROM EcomProduct
	GROUP BY category
)
SELECT *, Round((product_count/total_count)*100,2) as count_percentage
FROM catproduct
ORDER BY count_percentage DESC

-------

-- Average review score, Min review score and Max review score for each category, 
	
SELECT category, COUNT(product_id) as product_count, SUM(review_score) as total_score, 
	ROUND((SUM(review_score)/COUNT(product_id)),2) as cat_avg_score,
	MIN(review_score), MAX(review_score)
FROM ecomproduct
GROUP BY category;

-------
	
-- Top 10 earning from each product for the month of Jan
-- Column sales_month_1 can be changed for a different month
	
SELECT es.product_id,product_name, category, ep.price,
	sales_month_1, (ep.price*sales_month_1) as total_amount_month_1
FROM ecomsale as es
JOIN ecomproduct ep
	ON es.product_id = ep.product_id
ORDER BY total_amount_month_1 DESC
LIMIT 10;

-------

-- Total earning from each product for the whole year

DROP TABLE if exists productyear;
CREATE TEMP TABLE productyear
(
	product_id int,
	unit_price numeric(7,2),
	total_qty int
);
INSERT INTO productyear
SELECT es.product_id, ep.price as unit_price,
	sales_month_1+sales_month_2+sales_month_3+sales_month_4+sales_month_5+sales_month_6
	+sales_month_7+sales_month_8+sales_month_9+sales_month_10+sales_month_11+sales_month_12 as total_qty
FROM ecomsale as es
JOIN ecomproduct ep
	ON es.product_id = ep.product_id;

SELECT *, (unit_price*total_qty) as total_amount
FROM productyear
ORDER BY total_amount DESC

-------

-- Total yearly earning for each category
-- Based on temp table productyear
	
SELECT DISTINCT(ep.category), SUM((ep.price*py.total_qty)) OVER(PARTITION BY category) as total_amount_cat 
FROM productyear as py
JOIN ecomproduct as ep
	ON py.product_id = ep.product_id
GROUP BY ep.category,ep.price,py.total_qty
ORDER BY category

















