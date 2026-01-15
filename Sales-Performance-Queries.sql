-- CREATED A DATABASE
CREATE DATABASE sales_analysis;
use sales_analysis;

-- CREATED A TABLE
CREATE TABLE superstore (
	order_id VARCHAR(50),
	order_date DATE,
	ship_date DATE,
	customer_name VARCHAR(100),
 	region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    sales FLOAT,
    profit FLOAT,
    quantity INT,
    discount FLOAT
);

-- USING SELECT RETRIEVE THE DATA
select * from superstore;

-- LOADED THE DATASET
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/superstore_sales.csv'
INTO TABLE superstore
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id, @order_date, @ship_date, @ship_mode, @customer_name,
 @segment, @state, @country, @market, @region,
 @product_id, @category, @sub_category, @product_name,
 @sales, @quantity, @discount, @profit, @shipping_cost, @order_priority, @year)
SET
order_id = @order_id,
order_date = STR_TO_DATE(@order_date,'%m/%d/%Y'),
ship_date  = STR_TO_DATE(@ship_date,'%m/%d/%Y'),
customer_name = @customer_name,
category = @category,
sub_category = @sub_category,
sales = @sales,
quantity = @quantity,
discount = @discount,
profit = @profit,
region = @region;

-- Total Sales & Total Profit (Overall Performance)
SELECT 
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit
FROM superstore;
#This shows the company’s overall revenue and profitability, 
#helping assess whether the business is financially healthy or not.

-- Sales by Region (Best & Worst Region) 
SELECT 
    region,
    ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;
#Identifies which region generates the highest revenue, 
#which is useful for planning expansion strategies.

-- Profit by Category
SELECT 
    category,
    ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY category
ORDER BY total_profit DESC;
#Shows which product category is the most profitable, 
#which is important for investment decisions.

-- Sub-Categories by Sales
SELECT 
    sub_category,
    ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY sub_category
ORDER BY total_sales DESC
LIMIT 5;
#Helps identify high-demand products, 
#supporting better marketing and inventory planning.

-- Loss-Making Products
SELECT 
    sub_category,
    ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY sub_category
HAVING total_profit < 0
ORDER BY total_profit;
#Identifies products that are causing losses to the business, 
#indicating the need to rethink pricing or discount strategies.

-- Impact of Discount on Profit 
SELECT 
    discount,
    ROUND(AVG(profit),2) AS avg_profit
FROM superstore
GROUP BY discount
ORDER BY discount;
#Shows how higher discounts are impacting profit, 
#helping to optimize the discount strategy.

-- Monthly Sales Trend
SELECT 
    MONTH(order_date) AS month,
    ROUND(SUM(sales),2) AS monthly_sales
FROM superstore
GROUP BY MONTH(order_date)
ORDER BY month;
#Helps detect seasonality, 
#such as whether sales peak during festive months or not.

-- Top 5 Customers by Profit
SELECT 
    customer_name,
    ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY customer_name
ORDER BY total_profit DESC
LIMIT 5;
#Identifies high-value customers, 
#which is critical for designing effective retention strategies.

-- CREATED TABLES 
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY, # USED primary key
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(200)
);

CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    order_date DATE,
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    sales DECIMAL(10,2),
    profit DECIMAL(10,2),
    discount DECIMAL(5,2),
    shipping_cost DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),#USED foreign key
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE shipping (
    ship_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    ship_mode VARCHAR(50),
    ship_date DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- INSERTED THE DATASET THROUGH QUERY
INSERT INTO customers VALUES
('C001','John Smith','Consumer','West'),
('C002','Amit Shah','Corporate','East');

INSERT INTO products VALUES
('P001','Technology','Phones','iPhone'),
('P002','Furniture','Chairs','Office Chair');

INSERT INTO orders VALUES
('O001','2023-01-10','C001','P001',1200,300,0.10,50),
('O002','2023-01-15','C002','P002',800,-50,0.20,70);

INSERT INTO shipping (order_id, ship_mode, ship_date)
VALUES
('O001','Second Class','2023-01-12'),
('O002','Standard Class','2023-01-18');

-- Top Customers by Sales
SELECT c.customer_name, SUM(o.sales) AS total_sales
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_sales DESC;
#High-value customers → retention focus.

-- Profit by Category
SELECT p.category, SUM(o.profit) AS total_profit
FROM orders o
JOIN products p #USED JOINS
ON o.product_id = p.product_id
GROUP BY p.category; #USED GROUP BY
#Most profitable categories identified.

-- Region-wise Sales
SELECT c.region, SUM(o.sales) AS total_sales
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.region;
#Expansion & marketing planning.

-- Discount vs Profit
SELECT p.category,
       AVG(o.discount) AS avg_discount,
       SUM(o.profit) AS total_profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.category;
#High discount → low profit detection.

-- Shipping Cost Efficiency
SELECT s.ship_mode,
       SUM(o.shipping_cost) AS total_shipping_cost,
       SUM(o.profit) AS total_profit
FROM orders o
JOIN shipping s
ON o.order_id = s.order_id
GROUP BY s.ship_mode; 
#Costly shipping modes identified.

-- INNER JOIN
#Retrieve only those orders for which valid customer details
      #are available.
 SELECT 
    o.order_id,
    c.customer_name,
    o.sales
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id;
#Ensures analysis is based on valid and complete customer data
     
-- LEFT JOIN     
#Display all orders, even if some customer details are missing
SELECT 
    o.order_id,
    c.customer_name,
    o.sales
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id;
#Helps identify data quality issues, 
#such as missing customer mappings

-- RIGHT JOIN
#Show all customers, including those 
#who have never placed an order.
SELECT 
    c.customer_name,
    o.order_id,
    o.sales
FROM orders o
RIGHT JOIN customers c
ON o.customer_id = c.customer_id;
#Identifies inactive or non-purchasing customers

-- FULL JOIN
#Retrieve all orders and all customers, 
#regardless of whether they match.
SELECT 
    o.order_id,
    c.customer_name,
    o.sales
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id

UNION  #USED TO COMBINE TWO ROWS

SELECT 
    o.order_id,
    c.customer_name,
    o.sales
FROM orders o
RIGHT JOIN customers c
ON o.customer_id = c.customer_id;
#Helps ensure no order or customer is missed in reporting
