drop table if exists zepto;

CREATE TABLE zepto(
	sku_id SERIAL PRIMARY KEY,
	category VARCHAR(120),
	name VARCHAR(120) NOT NULL,
	mrp NUMERIC(8,2),
	discountpercent NUMERIC(5,2),
	availableQuantity INTEGER,
	discountedSellingPrice NUMERIC(8,2),
	weightInGms INTEGER,
	outOfStock BOOLEAN,
	quantity INTEGER
);

--Data Exploration

--Count of rows
SELECT COUNT(*) FROM zepto;

--sample data
SELECT * FROM zepto
LIMIT 10;

--check for null values in each column
SELECT * FROM zepto 
WHERE category IS NULL
OR name IS NULL
OR mrp IS NULL
OR discountpercent IS NULL
OR availablequantity IS NULL
OR discountedsellingprice IS NULL
OR weightingms IS NULL
OR outofstock IS NULL
OR quantity IS NULL;

--Show unique product categories available in the dataset
SELECT DISTINCT category 
FROM zepto
ORDER BY category;

--Get the count of products in stock and out of stock
SELECT outofstock, COUNT(sku_id)
FROM zepto
GROUP BY outofstock;

--product names present multiple times
SELECT name, COUNT(sku_id) as "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) >1
ORDER BY COUNT(sku_id) DESC;

--DATA CLEANING

-- Get the products where price =0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedsellingprice = 0;

DELETE FROM zepto 
WHERE mrp = 0;

--convert paise to rupees
UPDATE zepto
SET mrp = mrp/100.0,
discountedsellingprice = discountedsellingprice/100.0;

SELECT mrp, discountedsellingprice FROM zepto;

--Insight based/ Scenario based
-- Q1.Find the top 10 best value products based on the discounted percentage. - Business to know which products are heavily promoted
SELECT name, mrp, discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;

--Q2. What are the products with high MRP and are out of stock - To know the demmand of the product
SELECT DISTINCT name, mrp
FROM zepto
WHERE outofstock = TRUE AND mrp > 300
ORDER BY mrp DESC;

--Q3. Calculate Estimated Revenue for each category 
SELECT category,
SUM(discountedsellingprice * availablequantity) as total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

--Q4. Find all the products where mrp is greater than 500 and discount is less than 10%. - Not premium products and they already sell well without any promotions/ discounts
SELECT DISTINCT name,mrp, discountpercent
FROM zepto
WHERE mrp > 500 AND discountpercent < 10
ORDER BY mrp DESC, discountpercent DESC;

--Q5. Identify the top 5 categories offering highest average discount percent
SELECT category,
ROUND(AVG(discountpercent),2) as avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

--Q6. Find the price per gram for products above 100g and sort by best value - Helps pricing strategy
SELECT DISTINCT name, weightingms, discountedsellingprice,
ROUND((discountedsellingprice/weightingms),2) AS price_per_gram
FROM zepto
WHERE weightingms >= 100
ORDER BY price_per_gram;

--Q7. Group the products into categories like Low, Medium, bulk
SELECT DISTINCT name, weightingms,
CASE WHEN weightingms < 1000 THEN 'Low'
	 WHEN weightingms < 5000 THEN 'Medium'
	 ELSE 'Bulk'
	 END AS weight_category
FROM zepto;

--Q8. What is the total inventory weight per category - helpful for warehouse planning/ identify bulky product category
SELECT category,
SUM(weightingms * availablequantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;