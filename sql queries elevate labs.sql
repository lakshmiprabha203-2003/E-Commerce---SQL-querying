create database ecommerce;
use ecommerce;
set sql_safe_updates=0;
-- Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

-- Products table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Orders table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- OrderDetails table
CREATE TABLE OrderDetails (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Customers VALUES
(1, 'John Smith', 'New York', 'USA'),
(2, 'Jane Doe', 'Los Angeles', 'USA'),
(3, 'Amit Sharma', 'Delhi', 'India'),
(4, 'Priya Kapoor', 'Mumbai', 'India'),
(5, 'Emma Wilson', 'London', 'UK');

INSERT INTO Products VALUES
(101, 'Laptop', 'Electronics', 800.00),
(102, 'Smartphone', 'Electronics', 500.00),
(103, 'Headphones', 'Accessories', 50.00),
(104, 'Shoes', 'Fashion', 70.00),
(105, 'Watch', 'Accessories', 120.00);

INSERT INTO Orders VALUES
(1001, 1, '2025-08-01'),
(1002, 2, '2025-08-02'),
(1003, 3, '2025-08-03'),
(1004, 4, '2025-08-04'),
(1005, 5, '2025-08-05');

INSERT INTO OrderDetails VALUES
(1, 1001, 101, 1),
(2, 1001, 103, 2),
(3, 1002, 102, 1),
(4, 1003, 104, 3),
(5, 1004, 105, 1),
(6, 1005, 101, 2),
(7, 1005, 104, 1);

select * from customers;
select * from products;
select * from Orders;
select * from OrderDetails;

# List all customers from India
select customer_name from customers where country="India";

# Show all products priced above $100, ordered by price descending
select product_name from products where price>100 order by price desc;

# Find the total quantity of each product sold.
SELECT 
    (SELECT product_name 
     FROM products 
     WHERE products.product_id = OrderDetails.product_id) AS product_name,
    SUM(quantity) AS total_quantity
FROM OrderDetails
GROUP BY product_id;

# Get all orders placed after August 2, 2025.
select product_name from products where product_id in (select product_id from OrderDetails where order_id in (select order_id from Orders where order_date>2025-08-02));

# Show customer name, product name, and quantity for each order (INNER JOIN).
SELECT c.customer_name, p.product_name, od.quantity
FROM Orders o
INNER JOIN Customers c ON o.customer_id = c.customer_id
INNER JOIN OrderDetails od ON o.order_id = od.order_id
INNER JOIN Products p ON od.product_id = p.product_id;

# List all customers and the products they ordered (LEFT JOIN).
SELECT c.customer_name, p.product_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN OrderDetails od ON o.order_id = od.order_id
LEFT JOIN Products p ON od.product_id = p.product_id;

# List all products and customers who ordered them (RIGHT JOIN).
SELECT p.product_name, c.customer_name
FROM Products p
RIGHT JOIN OrderDetails od ON p.product_id = od.product_id
RIGHT JOIN Orders o ON od.order_id = o.order_id
RIGHT JOIN Customers c ON o.customer_id = c.customer_id;

# Find products that have a price higher than the average product price.
select product_name from products where price>(select avg(price) from products);

# Get the customer(s) who ordered the most expensive product.
select customer_name from customers where customer_id in
 (select customer_id from orders where order_id in 
 (select order_id from OrderDetails where product_id in 
 (select product_id from products where price = (select max(price) from products))));
-- SELECT DISTINCT c.customer_name
-- FROM Customers c
-- JOIN Orders o ON c.customer_id = o.customer_id
-- JOIN OrderDetails od ON o.order_id = od.order_id
-- JOIN Products p ON od.product_id = p.product_id
-- WHERE p.price = (SELECT MAX(price) FROM Products);

# Find the total sales (price × quantity) for each category.
select p.category, sum(p.price*od.quantity) as total_sales from products p join OrderDetails od on p.product_id = od.product_id group by category; 

# Get the average price of products in the "Accessories" category.
select avg(price) from products where category="Accessories";

# Create a view that shows customer_name, product_name, quantity, and total_price.
SET sql_mode = '';
create view sales_view as 
select c.customer_name, p.product_name, od.quantity, sum(price) as total_price from customers c 
join orders o on c.customer_id = o.customer_id 
join OrderDetails od on o.order_id = od.order_id
join products p on p.product_id = od.product_id;
select * from sales_view;

# Create an index on the Orders table for order_date to improve date range queries.
CREATE INDEX idx_order_date ON Orders(order_date);
SHOW INDEX FROM Orders;


