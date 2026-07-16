/*==========================================
PRIMARY KEY VALIDATION
Checks:
1. Duplicate Primary Keys
2. Missing Primary Keys
==========================================*/

-- Customers
SELECT
'Customers' AS Table_Name,
Customer_ID,
COUNT(*) AS Duplicate_Count
FROM Customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

SELECT *
FROM Customers
WHERE Customer_ID IS NULL;

--------------------------------------------------

-- Products
SELECT
'Products',
Product_ID,
COUNT(*)
FROM Products
GROUP BY Product_ID
HAVING COUNT(*)>1;

SELECT *
FROM Products
WHERE Product_ID IS NULL;

--------------------------------------------------

-- Repeat same for
-- Sellers
-- Warehouses
-- Inventory
-- Orders
-- Payments
-- Delivery
-- Returns
-- Calendar

/*==========================================
FOREIGN KEY VALIDATION
Checks for orphan records
==========================================*/

-- Orders → Customers

SELECT
o.Order_ID,
o.Customer_ID
FROM Orders o
LEFT JOIN Customers c
ON o.Customer_ID=c.Customer_ID
WHERE c.Customer_ID IS NULL;

--------------------------------------------------

-- Orders → Products

SELECT
o.Order_ID,
o.Product_ID
FROM Orders o
LEFT JOIN Products p
ON o.Product_ID=p.Product_ID
WHERE p.Product_ID IS NULL;

--------------------------------------------------

-- Orders → Sellers

SELECT
o.Order_ID,
o.Seller_ID
FROM Orders o
LEFT JOIN Sellers s
ON o.Seller_ID=s.Seller_ID
WHERE s.Seller_ID IS NULL;

--------------------------------------------------

-- Orders → Warehouses

SELECT
o.Order_ID,
o.Warehouse_ID
FROM Orders o
LEFT JOIN Warehouses w
ON o.Warehouse_ID=w.Warehouse_ID
WHERE w.Warehouse_ID IS NULL;

--------------------------------------------------

-- Inventory → Products

SELECT
i.Inventory_ID,
i.Product_ID
FROM Inventory i
LEFT JOIN Products p
ON i.Product_ID=p.Product_ID
WHERE p.Product_ID IS NULL;

--------------------------------------------------

-- Inventory → Warehouses

SELECT
i.Inventory_ID,
i.Warehouse_ID
FROM Inventory i
LEFT JOIN Warehouses w
ON i.Warehouse_ID=w.Warehouse_ID
WHERE w.Warehouse_ID IS NULL;

--------------------------------------------------

-- Payments → Orders

SELECT
p.Payment_ID,
p.Order_ID
FROM Payments p
LEFT JOIN Orders o
ON p.Order_ID=o.Order_ID
WHERE o.Order_ID IS NULL;

--------------------------------------------------

-- Returns → Orders

SELECT
r.Return_ID,
r.Order_ID
FROM Returns r
LEFT JOIN Orders o
ON r.Order_ID=o.Order_ID
WHERE o.Order_ID IS NULL;

/*==========================================
MISSING VALUE ANALYSIS
==========================================*/

-- Customers

SELECT *
FROM Customers
WHERE Customer_ID IS NULL
OR Customer_Name IS NULL
OR Gender IS NULL
OR Age IS NULL
OR State IS NULL;

--------------------------------------------------

-- Products

SELECT *
FROM Products
WHERE Product_ID IS NULL
OR Product_Name IS NULL
OR Category IS NULL
OR Selling_Price IS NULL
OR Cost_Price IS NULL;

--------------------------------------------------

-- Orders

SELECT *
FROM Orders
WHERE Order_ID IS NULL
OR Customer_ID IS NULL
OR Product_ID IS NULL
OR Order_Date IS NULL
OR Quantity IS NULL;

/*==========================================
DUPLICATE BUSINESS RECORDS
==========================================*/

SELECT
Customer_ID,
Product_ID,
Order_Date,
COUNT(*) AS Duplicate_Count
FROM Orders
GROUP BY
Customer_ID,
Product_ID,
Order_Date
HAVING COUNT(*)>1;

/*==========================================
DATA TYPE VALIDATION
==========================================*/

SELECT *
FROM Products
WHERE TRY_CAST(Selling_Price AS DECIMAL(18,2)) IS NULL;

--------------------------------------------------

SELECT *
FROM Orders
WHERE TRY_CAST(Quantity AS INT) IS NULL;

--------------------------------------------------

SELECT *
FROM Customers
WHERE TRY_CAST(Age AS INT) IS NULL;
/*==========================================
DATE VALIDATION
==========================================*/

-- Future Order Dates

SELECT *
FROM Orders
WHERE Order_Date>GETDATE();

--------------------------------------------------

-- Dispatch Before Order

SELECT *
FROM Orders
WHERE Dispatch_Date<Order_Date;

--------------------------------------------------

-- Delivery Before Dispatch

SELECT *
FROM Orders
WHERE Actual_Delivery<Dispatch_Date;

--------------------------------------------------

-- Expected Before Order

SELECT *
FROM Orders
WHERE Expected_Delivery<Order_Date;
/*==========================================
BUSINESS RULE VALIDATION
==========================================*/

-- Negative Prices

SELECT *
FROM Products
WHERE Selling_Price<=0
OR Cost_Price<=0;

--------------------------------------------------

-- Invalid Quantity

SELECT *
FROM Orders
WHERE Quantity<=0;

--------------------------------------------------

-- Negative Shipping

SELECT *
FROM Orders
WHERE Shipping_Cost<0;

--------------------------------------------------

-- Invalid Stock

SELECT *
FROM Inventory
WHERE Current_Stock<0
OR Maximum_Stock<=Minimum_Stock;

--------------------------------------------------

-- Invalid Customer Age

SELECT *
FROM Customers
WHERE Age<18
OR Age>100;

--------------------------------------------------

-- Invalid Ratings

SELECT *
FROM Products
WHERE Rating<0
OR Rating>5;
/*==========================================
CATEGORY CONSISTENCY
==========================================*/

SELECT Gender,COUNT(*) FROM Customers
GROUP BY Gender;

SELECT Prime_Member,COUNT(*) FROM Customers
GROUP BY Prime_Member;

SELECT Category,COUNT(*) FROM Products
GROUP BY Category;

SELECT Warehouse_Type,COUNT(*) FROM Warehouses
GROUP BY Warehouse_Type;

SELECT Order_Status,COUNT(*) FROM Orders
GROUP BY Order_Status;

SELECT Payment_Status,COUNT(*) FROM Payments
GROUP BY Payment_Status;

SELECT Inventory_Status,COUNT(*) FROM Inventory
GROUP BY Inventory_Status;

SELECT Return_Reason,COUNT(*) FROM Returns
GROUP BY Return_Reason;
/*==========================================
CALCULATION VALIDATION
==========================================*/

-- Selling Price should be greater than Cost Price

SELECT *
FROM Products
WHERE Selling_Price<Cost_Price;

--------------------------------------------------

-- Discount Validation

SELECT *
FROM Orders
WHERE Discount<0
OR Discount>1;

--------------------------------------------------

-- Lifetime Value

SELECT *
FROM Customers
WHERE Lifetime_Value<0;
/*==========================================
DATA QUALITY SUMMARY
==========================================*/

SELECT
COUNT(*) AS Total_Customers,
SUM(CASE WHEN Customer_Name IS NULL THEN 1 ELSE 0 END) AS Missing_Name,
SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Missing_Age,
MIN(Age) AS Minimum_Age,
MAX(Age) AS Maximum_Age,
AVG(Age) AS Average_Age
FROM Customers;

--------------------------------------------------

SELECT
COUNT(*) AS Total_Products,
MIN(Selling_Price) AS Min_Price,
MAX(Selling_Price) AS Max_Price,
AVG(Selling_Price) AS Avg_Price
FROM Products;

--------------------------------------------------

SELECT
COUNT(*) AS Total_Orders,
MIN(Order_Date) AS First_Order,
MAX(Order_Date) AS Last_Order
FROM Orders;


/*==========================================
OUTLIER DETECTION
==========================================*/

-- Customer Age

SELECT *
FROM Customers
WHERE Age>
(
SELECT AVG(Age)+3*STDEV(Age)
FROM Customers
);

--------------------------------------------------

-- Selling Price

SELECT *
FROM Products
WHERE Selling_Price>
(
SELECT AVG(Selling_Price)+3*STDEV(Selling_Price)
FROM Products
);

--------------------------------------------------

-- Delivery Cost

SELECT *
FROM Delivery
WHERE Delivery_Cost>
(
SELECT AVG(Delivery_Cost)+3*STDEV(Delivery_Cost)
FROM Delivery
);

