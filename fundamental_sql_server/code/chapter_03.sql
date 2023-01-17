-----------------------
--  Chapter 3: Joins --
-----------------------
USE tsql_fundamentals;

-- CROSS JOIN
SELECT
    C.custid,
    E.empid
FROM Sales.Customers AS C
    CROSS JOIN HR.Employees AS E;


-- INNER JOIN
SELECT
    E.empid,
    E.firstname,
    E.lastname,
    O.orderid
FROM HR.Employees AS E
    INNER JOIN Sales.Orders AS O -- All rows have a match, so none are discarded
        ON E.empid = O.empid;


-- Multi-Join Queries
SELECT
    C.custid,
    C.companyname,
    O.orderid,
    OD.productid,
    OD.qty
FROM Sales.Customers AS C 
    INNER JOIN Sales.Orders AS O -- Results in all records from Customers with a matching record from Orders
        ON C.custid = O.custid
    INNER JOIN Sales.OrderDetails AS OD -- Results in all records from the preceding set with a matching record from OrderDetails
        ON O.orderid = OD.orderid;


-- OUTER JOINS
SELECT
    C.custid,
    C.companyname,
    O.orderid
FROM Sales.Customers AS C 
    LEFT OUTER JOIN Sales.Orders AS O -- Customers that have not placed an order will be in the result table with NULLs for orderid
        ON C.custid = O.custid;

SELECT
    C.custid,
    C.companyname,
    O.orderid
FROM Sales.Customers AS C 
    LEFT OUTER JOIN Sales.Orders AS O -- Returns inner rows only. Customers with a matching order id.
        ON C.custid = O.custid
WHERE O.orderid IS NOT NULL;

SELECT
    C.custid,
    C.companyname,
    O.orderid
FROM Sales.Customers AS C 
    LEFT OUTER JOIN Sales.Orders AS O -- Returns outer rows only. Customers without a matching order id.
        ON C.custid = O.custid
WHERE O.orderid IS NULL;