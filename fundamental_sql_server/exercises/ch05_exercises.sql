---------------------------------------------
--  Chapter 5 Exercises: Table Expressions --
---------------------------------------------
USE tsql_fundamentals
GO

-- EXERCISE 1
-- The following query attempts to filter orders that were not placed on the last day of the year. 
-- It’s supposed to return the order ID, order date, customer ID, employee ID, and respective end-of-year date for each order.
-- Explain the resulting error.
SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
    ,DATEFROMPARTS(YEAR(orderdate), 12, 31) AS endofyear
FROM Sales.Orders
WHERE orderdate <> endofyear;

/* Answer: A column aliased in the SELECT clause is referenced in the WHERE clause.
The WHERE clause is processed first, so the alias has not been established.
Correct the query using a derived table expression */
SELECT orderid, orderdate, custid, empid, endofyear
FROM (
    SELECT
        orderid
        ,orderdate
        ,custid
        ,empid
        ,DATEFROMPARTS (YEAR (orderdate), 12, 31) AS endofyear
    FROM Sales.Orders
) AS O
WHERE orderdate <> endofyear;


-- EXERCISE 2.1
-- Write a query that returns the maximum value in the orderdate column for each employee.
-- Table Involved: Sales.Orders
SELECT
    empid
    ,MAX (orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY empid
ORDER BY empid;



-- EXERCISE 2.2
-- Encapsulate the query from Exercise 2-1 in a derived table. 
-- Write a join query between the derived table and the Orders table.
-- Return the orders with the maximum order date for each employee.
-- Tables Involved: Sales.Orders

/*
Retention strategy
Define explicit columns in ADF

*/


-- EXERCISE 3.1
-- Write a query that calculates a row number for each order based on orderdate, orderid ordering.
-- Table Involved: Sales.Orders





-- EXERCISE 3.2
-- Write a query that returns rows with row numbers 11 through 20 based on the row-number definition in Exercise 3-1. 
-- Use a CTE to encapsulate the code from Exercise 3-1.
-- Table Involved: Sales.Orders



-- EXERCISE 4 (Advanced)
-- Write a solution using a recursive CTE that returns the management chain leading to Patricia Doyle (employee ID 9).
-- Table Involved: HR.Employees




-- EXERCISE 5.1
-- Create a view that returns the total quantity for each employee and year.
-- Tables Involved: Sales.Orders and Sales.OrderDetails




-- EXERCISE 5.2 (Advanced)
-- Write a query against Sales.VEmpOrders that returns the running total quantity for each employee and year.
-- Table Involved: Sales.VEmpOrders view




-- EXERCISE 6.1
-- Create an inline TVF that accepts as inputs a supplier ID (@supid AS INT) and a requested number of products (@n AS INT).
-- The function should return @n products with the highest unit prices that are supplied by the specified supplier ID.
-- Table Involved: Production.Products




-- EXERCISE 6.2
-- Using the CROSS APPLY operator and the function you created in Exercise 6-1, return the two most expensive products for each supplier.
-- Table Involved: Production.Suppliers

