--------------------------
--  Chapter 3 Exercises --
--------------------------

-- Write a query that generates five copies of each employee row.
-- Tables Invovled: HR.Employees and dbo.Nums
SELECT
    E.empid
    , E.firstname
    , E.lastname
    , N.n
FROM HR.Employees AS E
    CROSS JOIN dbo.Nums AS N
WHERE N.n <= 5
ORDER BY N.n ASC, E.empid ASC;

-- Write a query that returns a row for each employee and day in the range June 12, 2016 through June 16, 2016.
-- Tables Invovled: HR.Employees and dbo.Nums
SELECT 
    E.empid
    , DATEADD (DAY, N.n-1, CAST ('20160612' AS DATE)) AS date
FROM HR.Employees AS E
    CROSS JOIN dbo.Nums AS N
WHERE N.n <= DATEDIFF (DAY, '20160612', '20160616') + 1
ORDER BY E.empid, date;


-- Explain what’s wrong in the following query, and provide a correct alternative:
-- Explanation: A table aliase is used and then full table name is used to represent each attribute, resulting in multi-part identifier error.
/*
SELECT Customers.custid, Customers.companyname, Orders.orderid, Orders.orderdate
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
ON Customers.custid = Orders.custid; 
*/

-- Solution (Using specified aliases)
SELECT
    C.custid
    , C.companyname
    , O.orderid
    , O.orderdate
FROM Sales.Customers AS C
INNER JOIN Sales.Orders AS O
ON C.custid = O.custid;


-- Return US customers, and for each customer return the total number of orders and total quantities.
-- Tables Involved: Sales.Customers, Sales.Orders, and Sales.OrderDetails
SELECT
    C.custid
    , COUNT (DISTINCT O.orderid) AS numorders
    , SUM (D.qty) AS totalqty
FROM Sales.Customers AS C
    INNER JOIN Sales.Orders AS O
        ON C.custid = O.custid
    INNER JOIN Sales.OrderDetails AS D
        ON O.orderid = D.orderid
WHERE C.country = N'USA'
GROUP BY C.custid
ORDER BY C.custid ASC;


-- Return customers and their orders, including customers who placed no orders.
-- Tables Involved: Sales.Customers and Sales.Orders
SELECT
    C.custid
    , C.companyname
    , O.orderid
    , O.orderdate
FROM Sales.Customers AS C
    LEFT OUTER JOIN Sales.Orders AS O 
        ON C.custid = O.custid -- Customers without an order will have a NULL for orderid


-- Return customers who placed no orders.
-- Tables involved: Sales.Customers and Sales.Orders
SELECT
    C.custid
    , C.companyname
    , O.orderid
    , O.orderdate
FROM Sales.Customers AS C
    LEFT OUTER JOIN Sales.Orders AS O 
        ON C.custid = O.custid
WHERE O.orderid IS NULL; -- Returns customers with no associated orderid (references primary key)
/*It's important to reference a non-nullable attribute (such as orderid) so that the only possible way
to get nulls in this query, is of it's an outter row with no associated order*/


-- Return customers with orders placed on February 12, 2016, along with their orders.
-- Tables involved: Sales.Customers and Sales.Orders
SELECT
    C.custid
    , C.companyname
    , O.orderid
    , O.orderdate
FROM Sales.Customers AS C
    INNER JOIN Sales.Orders AS O 
        ON C.custid = O.custid
WHERE O.orderdate = '2016-02-12';


-- Write a query that returns all customers in the output, but matches them with their respective orders only if they were placed on February 12, 2016.
-- Tables involved: Sales.Customers and Sales.Orders
SELECT
    C.custid
    , C.companyname
    , O.orderid 
    , O.orderdate
FROM Sales.Customers AS C
    LEFT OUTER JOIN Sales.Orders AS O 
        ON C.custid = O.custid
        AND O.orderdate = N'2016-02-12'; -- Outer join preserves all customers
/*Date filter in on clause ensures customers without an order are still returned.*/


-- Explain why the following query isn’t a correct solution query for Exercise 7 (above):
-- Explanation: Because the non-preserved side filter in the where clause discards all UNKNOWN, so customers without an order are lost.
/*
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O
ON O.custid = C.custid
WHERE O.orderdate = '20160212' OR O.orderid IS NULL;
*/


-- Return all customers, and for each return a Yes/No value depending on whether the customer placed orders on February 12, 2016.
-- Tables involved: Sales.Customers and Sales.Orders
SELECT
    C.custid
    , C.companyname
    , CASE
        WHEN O.orderid IS NULL THEN 'No'
        ELSE 'Yes'
    END AS hasorder
FROM Sales.Customers AS C
    LEFT OUTER JOIN Sales.Orders AS O 
        ON C.custid = O.custid
        AND O.orderdate = N'2016-02-12';
/*Remember, the SELECT statement is processed after FROM so we can reference NULL orderids*/