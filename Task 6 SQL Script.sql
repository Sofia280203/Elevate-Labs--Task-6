CREATE DATABASE OnlineStoreDB
USE OnlineStoreDB
CREATE TABLE Products (
    product_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,   -- Product ID is the primary key
    name VARCHAR(25) NOT NULL,                           -- Product name
    description TEXT,                                     -- Product description
    price DECIMAL(10, 2) NOT NULL,                        -- Product price
    category VARCHAR(50)                                 -- Product category
);
CREATE TABLE Customers (
    customer_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- Customer ID
    name VARCHAR(25) NOT NULL,                           -- Customer name
    email VARCHAR(25) UNIQUE NOT NULL,                   -- Unique email
    phone_number VARCHAR(15),                             -- Phone number
    address VARCHAR(55)                                  -- Address
);
CREATE TABLE Orders (
    order_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,     -- Order ID
    customer_id INT,                                      -- Foreign key to Customers table
    order_date DATE NOT NULL,                             -- Order date
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending', -- Order status
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) -- Relating orders to customers
);

CREATE TABLE Payments (
    payment_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,   -- Payment ID
    order_id INT,                                         -- Foreign key to Orders table
    payment_date DATE NOT NULL,                           -- Payment date
    amount DECIMAL(10, 2) NOT NULL,                       -- Payment amount
    payment_status ENUM('Paid', 'Unpaid') DEFAULT 'Unpaid', -- Payment status
	FOREIGN KEY (order_id) REFERENCES Orders(order_id)    -- Relating payments to orders
);

CREATE TABLE Inventory (
    inventory_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Inventory ID
    product_id INT,                                       -- Foreign key to Products table
    stock_quantity INT DEFAULT 0,                         -- Quantity in stock
    last_updated DATE DEFAULT (CURRENT_DATE),               -- Last updated date
    FOREIGN KEY (product_id) REFERENCES Products(product_id) -- Relating inventory to products
);

INSERT INTO Products (name, description, price, category) VALUES 
('Laptop', 'A high-performance laptop', 1200.00, 'Electronics'),
('Headphones', 'Wireless noise-cancelling headphones', 200.00, 'Electronics'),
('Book', 'Inspirational novel', 15.00, 'Books'); 

INSERT INTO Customers (name, email, phone_number, address) VALUES 
('John Doe', 'john@example.com', '1234567890', '123 Main St'),
('Jane Smith', 'jane@example.com', '0987654321', '456 Elm St'); 

INSERT INTO Orders (customer_id, order_date, status) VALUES 
(1, '2024-10-21', 'Pending'),
(2, '2024-10-20', 'Completed');

INSERT INTO Payments (order_id, payment_date, amount, payment_status) VALUES 
(1, '2024-10-21', 1200.00, 'Paid'),
(2, '2024-10-20', 200.00, 'Paid');

INSERT INTO Inventory (product_id, stock_quantity, last_updated) VALUES 
(1, 50, '2024-10-20'),
(2, 100, '2024-10-19'),
(3, 200, '2024-10-18');

SELECT * FROM Products
SELECT * FROM Customers WHERE customer_id = 1
SELECT o.order_id, o.order_date, p.payment_status  -- Selects order ID, order date, and payment status
FROM Orders o                                      -- Retrieves order details from the 'Orders' table
JOIN Payments p ON o.order_id = p.order_id; 

SELECT * FROM Payments WHERE payment_status = 'Unpaid'

SELECT p.name, SUM(pay.amount) AS total_sales    -- Selects product name and calculates total sales
FROM Products p                                  -- Retrieves product data from the 'Products' table
JOIN Orders o ON p.product_id = o.order_id       -- Joins the 'Orders' table to link product and orders
JOIN Payments pay ON o.order_id = pay.order_id   -- Joins the 'Payments' table to get payment amounts
GROUP BY p.product_id; 

SELECT * FROM Orders                              -- Selects all columns from the 'Orders' table
WHERE status = 'Completed'                        -- Filters only orders that are completed
AND order_date > CURDATE() - INTERVAL 1 MONTH

SELECT name, stock_quantity                  -- Selects product name and stock quantity
FROM Products p                              -- Retrieves product data from the 'Products' table
JOIN Inventory i ON p.product_id = i.product_id  -- Joins the 'Inventory' table for stock information
WHERE stock_quantity < 20

SELECT c.name, COUNT(o.order_id) AS order_count    -- Selects customer name and counts their orders
FROM Customers c                                   -- Retrieves customer data from the 'Customers' table
JOIN Orders o ON c.customer_id = o.customer_id     -- Joins the 'Orders' table to get order data
GROUP BY c.customer_id                             -- Groups by customer to count their orders
HAVING order_count > 1

SELECT AVG(amount) AS avg_order_value  -- Calculates the average amount from payments
FROM Payments

SELECT c.name, SUM(p.amount) AS total_spent    -- Selects customer name and calculates total amount spent
FROM Customers c                               -- Retrieves customer data from the 'Customers' table
JOIN Orders o ON c.customer_id = o.customer_id -- Joins 'Orders' table to get customer orders
JOIN Payments p ON o.order_id = p.order_id     -- Joins 'Payments' table to get payment amounts
GROUP BY c.customer_id                         -- Groups by customer ID to sum total spent
ORDER BY total_spent DESC                      -- Sorts by total spent in descending order
LIMIT 1

SELECT MONTHNAME(payment_date) AS month, SUM(amount) AS total_sales   -- Selects month name and calculates total sales for each month
FROM Payments                                                      -- Retrieves payment data from the 'Payments' table
GROUP BY MONTH(payment_date)

SELECT * FROM Orders  -- Selects all columns from the 'Orders' table
WHERE order_date BETWEEN '2024-10-01' AND '2024-10-31'

SELECT * FROM Orders WHERE status = 'Cancelled'

SELECT c.name, p.payment_status  -- Selects customer name and payment status
FROM Customers c                 -- Retrieves customer data from the 'Customers' table
JOIN Orders o ON c.customer_id = o.customer_id   -- Joins 'Orders' table to link customers and orders
JOIN Payments p ON o.order_id = p.order_id       -- Joins 'Payments' table to get payment statuses
WHERE p.payment_status = 'Unpaid'

SELECT p.name, SUM(i.stock_quantity) AS total_sold 
-- Join the Orders table with the Products table based on the product ID
FROM Orders o 
JOIN Products p ON o.order_id = p.product_id
-- Join the Products table with the Inventory table to get stock quantities
JOIN Inventory i ON p.product_id = i.product_id 
-- Filter only completed orders
WHERE o.status = 'Completed' 
-- Group results by product ID to calculate total sales per product
GROUP BY p.product_id 
-- Order the results by the total quantity sold in descending order
ORDER BY total_sold DESC 
-- Limit the result to the top 3 products with the highest sales
LIMIT 3

-- Select the name of the customer and the latest order date
SELECT c.name, MAX(o.order_date) AS last_order_date 
-- Perform a LEFT JOIN between Customers and Orders, so we include customers without any orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
-- Group by customer ID to get each customer's latest order
GROUP BY c.customer_id
-- Use HAVING to filter customers whose latest order date was more than 6 months ago or who have no orders at all
HAVING MAX(o.order_date) < CURDATE() - INTERVAL 6 MONTH
   OR MAX(o.order_date) IS NULL
   
-- Select the name of the products
SELECT p.name
-- Perform a LEFT JOIN between Products and Orders, matching product IDs with order IDs
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.order_id
-- Filter the results to only show products that have no matching order (i.e., have never been ordered)
WHERE o.order_id IS NULL

-- Select the product category and the sum of payment amounts as total revenue
SELECT p.category, SUM(pay.amount) AS total_revenue
-- Join the Products table with the Orders table using product_id and order_id
FROM Products p
JOIN Orders o ON p.product_id = o.order_id
-- Join the Payments table to retrieve payment details
JOIN Payments pay ON o.order_id = pay.order_id
-- Group the results by product category to calculate total revenue per category
GROUP BY p.category
-- Order the results by total revenue in descending order
ORDER BY total_revenue DESC 

-- Select the customer name and the count of canceled orders for each customer
SELECT c.name, COUNT(o.order_id) AS canceled_orders
-- Join the Customers table with the Orders table using customer_id
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
-- Filter to include only orders that have been canceled
WHERE o.status = 'Cancelled'
-- Group the results by customer_id to count the number of canceled orders per customer
GROUP BY c.customer_id
-- Filter the results to show only customers with more than 2 canceled orders
HAVING COUNT(o.order_id) > 2

-- Select the customer name and the average time between order date and payment date
SELECT c.name, AVG(DATEDIFF(pay.payment_date, o.order_date)) AS avg_payment_time
FROM Customers c
-- Join the Customers table with the Orders table using customer_id
JOIN Orders o ON c.customer_id = o.customer_id
-- Join the Orders table with the Payments table using order_id
JOIN Payments pay ON o.order_id = pay.order_id
-- Group the results by customer_id to calculate the average payment time for each customer
GROUP BY c.customer_id

-- Select the product name and the count of distinct customers who ordered each product
SELECT p.name, COUNT(DISTINCT o.customer_id) AS unique_customers
FROM Products p
-- Join the Products table with the Orders table using product_id and order_id
JOIN Orders o ON p.product_id = o.order_id
-- Group the results by product_id to count unique customers for each product
GROUP BY p.product_id
-- Only include products that have more than 5 unique customers
HAVING COUNT(DISTINCT o.customer_id) > 5

-- Select the month name from the payment_date for grouping sales by month
SELECT 
    MONTHNAME(payment_date) AS month, 
    -- Calculate the total sales for each month
    SUM(amount) AS total_sales,
    -- Use the LAG() function to get the total sales from the previous month
    LAG(SUM(amount), 1) OVER (ORDER BY MONTH(payment_date)) AS previous_month_sales,
    -- Calculate the percentage growth rate compared to the previous month
    (SUM(amount) - LAG(SUM(amount), 1) OVER (ORDER BY MONTH(payment_date))) / 
    LAG(SUM(amount), 1) OVER (ORDER BY MONTH(payment_date)) * 100 AS growth_rate
-- Specify the table to calculate the sales from
FROM Payments
-- Group the results by the month of the payment date
GROUP BY MONTH(payment_date) 

-- Select the month name from the payment_date for grouping sales by month
SELECT 
    MONTHNAME(payment_date) AS month, 
    -- Calculate the total sales for each month
    SUM(amount) AS total_sales,
    -- Use the LAG() function to get the total sales from the previous month
    LAG(SUM(amount), 1) OVER (ORDER BY MONTH(payment_date)) AS previous_month_sales,
    -- Calculate the percentage growth rate compared to the previous month
    (SUM(amount) - LAG(SUM(amount), 1) OVER (ORDER BY MONTH(payment_date))) / 
    LAG(SUM(amount), 1) OVER (ORDER BY MONTH(payment_date)) * 100 AS growth_rate
-- Specify the table to calculate the sales from
FROM Payments
-- Group the results by the month of the payment date
GROUP BY MONTH(payment_date);

-- Select the customer's name from the Customers table
SELECT c.name, 
    -- Count the number of distinct months in which the customer has placed orders
    COUNT(DISTINCT MONTH(o.order_date)) AS active_months 
-- Join the Customers table with the Orders table based on the customer_id
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
-- Group the results by customer_id to aggregate order data for each customer
GROUP BY c.customer_id
-- Filter the results to only include customers with orders in more than one month
HAVING active_months > 1

