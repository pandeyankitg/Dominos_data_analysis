CREATE TABLE pizza_sales
	(
	pizza_id INT,	
	order_id INT,
	pizza_name_id VARCHAR(100),
	quantity INT,
	order_date DATE,
	order_time TIME,	
	unit_price	NUMERIC(5,2),
	total_price NUMERIC(10,2),
	pizza_size	VARCHAR(10),
	pizza_category	VARCHAR(100),
	pizza_ingredients VARCHAR(300),
	pizza_name VARCHAR(100)
)

--We have created a table now we need to upload the csv data into this table

SELECT * FROM pizza_sales
COPY pizza_sales FROM 'C:\Users\AnkitPandey\Desktop\pizza_sales.csv'
DELIMITER ','
CSV HEADER

-- Lets see if we have uploaded our dataset correctly
SELECT * FROM pizza_sales

--Now let's start firing SQL queries to derive the data we want from this dataset
--1. For total revenue we will have to add every prices in the column total_price

SELECT SUM(unit_price) FROM pizza_sales



--2. Now second KPI we have is average amount spent per order for this 
-- we will have to- Total Revenue/ Total no of distinct orders

(SELECT SUM(total_prize) FROM pizza_sales)/(SELECT COUNT DISTINCT(order_id) FROM pizza_sales)
-- Above structure of query is wrong so we will use as suggested by gpt

SELECT 
SUM(total_price)/COUNT(DISTINCT order_id) AS average_order_price 
FROM pizza_sales

-- Total Pizzas Sold: The sum of the quantities of all pizzas sold.

SELECT SUM(quantity) FROM pizza_sales

--  Total Orders: The total number of orders placed.
SELECT COUNT(DISTINCT order_id) FROM pizza_sales

-- Now lets find out average pizza sold per order
SELECT
	SUM(quantity)/ COUNT(DISTINCT order_id) AS average_pizza_per_order
FROM pizza_sales

-- We are getting the result as 2 upon firing this query because we are dividing two integers. which means we 
--are not getting the value after decimal.
-- Let's fix this by casting one of the integers to a floating point type 
SELECT 
	SUM(quantity)::FLOAT/COUNT(DISTINCT order_id) AS average_pizza_per_order
FROM pizza_sales


--Now lets count how many orders on daily basis-


SELECT 
    CASE EXTRACT(DOW FROM order_date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_of_week,
    COUNT(DISTINCT order_id) AS total_orders
FROM 
    pizza_sales
GROUP BY 
    EXTRACT(DOW FROM order_date)
ORDER BY 
    EXTRACT(DOW FROM order_date);

--Now lets derive how these orfers are being placed on monthly basis

SELECT 
   CASE EXTRACT(MONTH FROM order_date)
    WHEN 1 THEN 'January'
    WHEN 2 THEN 'February'
    WHEN 3 THEN 'March'
    WHEN 4 THEN 'April'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'June'
    WHEN 7 THEN 'July'
    WHEN 8 THEN 'August'
    WHEN 9 THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
   END AS month_name,
COUNT (DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY 
EXTRACT(MONTH FROM order_date)


-- Now lets see if we sort out no of orfers on hourly basis on 24 hour
SELECT 
   EXTRACT(HOUR FROM order_time) AS Timing,
COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY 
EXTRACT(HOUR FROM order_time)
ORDER BY EXTRACT(HOUR FROM order_time)

--The result we have got does not really look appealing let's rename 
--the first column here so that the readability can be improved
SELECT 
    CASE EXTRACT (HOUR FROM order_time)
	WHEN 1 THEN '1AM'
	WHEN 2 THEN '2AM'
	WHEN 3 THEN '3AM'
	WHEN 4 THEN '4AM'
	WHEN 5 THEN '5AM'
	WHEN 6 THEN '6AM'
	WHEN 7 THEN '7AM'
	WHEN 8 THEN '8AM'
	WHEN 9 THEN '9AM'
	WHEN 10 THEN '10AM'
	WHEN 11 THEN '11AM'
	WHEN 12 THEN '12AM'
	WHEN 13 THEN '1PM'
	WHEN 14 THEN '2PM'
	WHEN 15 THEN '3PM'
	WHEN 16 THEN '4PM'
	WHEN 17 THEN '5PM'
	WHEN 18 THEN '6PM'
	WHEN 19 THEN '7PM'
	WHEN 20 THEN '8PM'
	WHEN 21 THEN '9PM'
	WHEN 22 THEN '10PM'
	WHEN 23 THEN '11PM'
	WHEN 24 THEN '12PM'
END AS order_time,
COUNT (DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY EXTRACT(HOUR FROM order_time)

-- Let's try to improve the readability a lil more

/* SELECT 
    CASE EXTRACT(HOUR FROM order_time)
    WHEN 1 OR 2 OR 3 OR 4 THEN 'Midnight'
    WHEN 5 OR 6 OR 7 OR 8 THEN 'Early Morning'
    WHEN 9 OR 10 OR 11 OR 12 THEN 'Morning'
    WHEN 13 OR 14 OR 15 OR 16 THEN 'Noon'
    WHEN 17 OR 18 OR 19 THEN 'Night' 
END AS order_time,
COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY EXTRACT(HOUR FROM order_time) */




SELECT
  CASE
    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 1 AND 4 THEN 'Midnight'
    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 5 AND 8 THEN 'Early Morning'
    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 9 AND 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 13 AND 16 THEN 'Noon'
    WHEN EXTRACT(HOUR FROM order_time) BETWEEN 17 AND 19 THEN 'Evening'
    ELSE 'Night'  -- Handle cases outside specified ranges
  END AS order_time,
  COUNT(DISTINCT order_id) AS total_orders
FROM pizza_sales
GROUP BY EXTRACT(HOUR FROM order_time);
--We need to fix the above query a lil bcs the output we are getting 


-- Now lets find out what is the distribution of pizza sales category-wise
SELECT COUNT(DISTINCT order_id), pizza_category 
FROM pizza_sales
GROUP BY pizza_category


-- Now let's try to find out the most sold pizza size

SELECT pizza_size, COUNT (DISTINCT order_id)
FROM pizza_sales
GROUP BY pizza_size


--Now let's try to find out the most sold pizza name(no. of order wise)
SELECT COUNT(DISTINCT order_id),pizza_name
FROM pizza_sales
GROUP BY pizza_name
ORDER BY COUNT DESC

----Now let's try to find out the most sold pizza name(No of quantity wise)
SELECT
    pizza_name,
    SUM(quantity) AS total_quantity_sold-across_all_orders
FROM
    pizza_sales
GROUP BY
    pizza_name
ORDER BY
    total_quantity_sold DESC

-- What is the total revenue generated by each pizza size (e.g., small, medium, large)?

SELECT SUM(total_price),pizza_size 
FROM pizza_sales
GROUP BY pizza_size
ORDER BY SUM DESC


--Which pizza has the highest total sales revenue?

SELECT SUM(total_price) AS Total_revenue, pizza_name
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_revenue DESC

--sales(quantity wise) of different pizza sizes across 12 months
SELECT 
	SUM(quantity) AS No_of_orders, 
	pizza_size,
	EXTRACT(MONTH FROM order_date) AS month_name
FROM 
	pizza_sales
GROUP BY 
	pizza_size,
    month_name
ORDER BY month_name DESC
    
--Lets try another query and lets use timestamp and TO_CHAR 

SELECT 
    SUM(quantity) AS total_quantity,
    pizza_size,
    TO_CHAR(TO_TIMESTAMP(EXTRACT(MONTH FROM order_date)::TEXT, 'MM'), 'Month') AS month_name
FROM 
    pizza_sales
GROUP BY 
    pizza_size, 
    month_name
ORDER BY 
    month_name ASC

--
SELECT 
    SUM(quantity) AS total_quantity,
    pizza_size,
    TO_CHAR
	 (TO_TIMESTAMP
	   (EXTRACT
	      (MONTH FROM order_date)::TEXT,
	                                   'MM'),
	                                       'Month')
	                                          AS month_name,
EXTRACT(MONTH FROM order_date) AS month_number
FROM 
    pizza_sales
GROUP BY 
    pizza_size, 
    month_name,
    month_number
ORDER BY 
    pizza_size, 
    month_number;

--sales(total quantity) of different pizza category across 12 months

SELECT
    SUM(quantity) AS no_of_order,
    pizza_category,
    TO_CHAR(TO_TIMESTAMP(EXTRACT(MONTH FROM order_date)::TEXT,'MM'),'Month') AS month_name,
	EXTRACT(MONTH FROM order_date) AS month_number
FROM 
    pizza_sales
GROUP BY 
	pizza_category,
    month_name,
    month_number
ORDER BY 
    pizza_category,
	month_number

-- Total no of orders (not quantity) across 12 months
SELECT 
	SUM(DISTINCT order_id),
    TO_CHAR(TO_TIMESTAMP(EXTRACT(MONTH FROM order_date)::TEXT,'MM'),'Month') AS month_name,
    EXTRACT(MONTH FROM order_date) AS month_number
FROM 
    pizza_sales
GROUP BY 
    month_name,
	month_number
ORDER BY
    month_number

-- Total no of orders quantity wise across 12 months
SELECT 
	SUM(quantity) AS No_of_orders,
    TO_CHAR(TO_TIMESTAMP(EXTRACT(MONTH FROM order_date)::TEXT,'MM'),'Month') AS month_name,
    EXTRACT(MONTH FROM order_date) AS month_number
FROM 
    pizza_sales
GROUP BY 
    month_name,
    month_number
ORDER BY
    month_number

--Which pizza_name has the highest average quantity ordered per order?
---average quantity for a pizza= no.of order/total quantity of that pizza

SELECT 
     pizza_name,
     (COUNT(DISTINCT order_id) / SUM(quantity)::FLOAT) AS average_no_of_pizza
FROM
    pizza_sales
GROUP BY
    pizza_name
ORDER BY average_no_of_pizza DESC

     
--Total quantity and total revenue for every pizza category

SELECT
      pizza_category,
      SUM(quantity) AS Total_quantity,
      SUM(total_price) AS Total_revenue
FROM
      pizza_sales
GROUP BY 
      pizza_category
ORDER BY 
      Total_revenue
      
--What is the average unit price of pizzas in each category out of total revenue?
---Average unit price would be = Total price/ total quantity

SELECT
      pizza_category,
      (SUM(total_price) / SUM(quantity)) AS average_unit_price
FROM
      pizza_sales
GROUP BY 
      pizza_category
ORDER BY 
      average_unit_price DESC

--Weekend sales vs. weekday sales (Total revenue)? 
SELECT 
     CASE EXTRACT (DOW FROM order_date)
      WHEN 0 THEN 'Weekend'
      WHEN 1 THEN 'Weekday'
      WHEN 2 THEN 'Weekday'
      WHEN 3 THEN 'Weekday'
      WHEN 4 THEN 'Weekday'
      WHEN 5 THEN 'Weekend'
      WHEN 6 THEN 'Weekend'
END AS Weekday_or_Weekend,
SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY 
        EXTRACT(DOW FROM order_date)
ORDER BY 
        EXTRACT(DOW FROM order_date)

/* The SELECT CASE we have utilized above is extracting everyweek days as seperate entity. let's
try another method to get a better result */


SELECT
  CASE
    WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend'
    ELSE 'Weekday'
  END AS Weekday_or_Weekend,
  SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY CASE WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend' ELSE 'Weekday' END
ORDER BY CASE WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend' ELSE 'Weekday' END;


-- lets get to find out which top 5 pizzas are sold mostly
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Order
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Order DESC
LIMIT 5;

SELECT current_database();

--Weekend sales vs. weekday sales (Total Orders)? 


--What is the total quantity of each pizza sold?

--How does the average order quantity vary by pizza size?

--How does the total price of orders vary by pizza category?

--What is the distribution of order quantities for different pizza sizes?