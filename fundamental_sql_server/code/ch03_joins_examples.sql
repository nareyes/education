-----------------------
--  Chapter 3: Joins --
-----------------------
USE tsql_fundamentals;

-- CROSS JOIN
SELECT
    C.custid
    ,E.empid
FROM Sales.Customers AS C
    CROSS JOIN HR.Employees AS E;


-- SELF CROSS JOIN
SELECT
    E1.empid, E1.firstname, E1.lastname
    ,E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1
    CROSS JOIN HR.Employees AS E2;


-- SELF CROSS JOIN (Produce Sequence of Numbers)
DROP TABLE IF EXISTS dbo.Digits
GO

CREATE TABLE dbo.Digits (digit INT NOT NULL PRIMARY KEY);
INSERT INTO dbo.Digits(digit)
    VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9);

SELECT * FROM dbo.Digits;


-- Create Sequence of 1,000 Numbers
SELECT
    (D1.digit + 1) 
    + (D2.digit * 10) 
    + (D3.digit * 100) AS n
FROM dbo.Digits AS D1
    CROSS JOIN dbo.Digits AS D2
    CROSS JOIN dbo.Digits AS D3
ORDER BY n;


-- INNER JOIN
SELECT
    E.empid
    ,E.firstname
    ,E.lastname
    ,O.orderid
FROM HR.Employees AS E
    INNER JOIN Sales.Orders AS O -- All rows have a match, so none are discarded
        ON E.empid = O.empid;


-- COMPOSITE JOIN
DROP TABLE IF EXISTS dbo.TableA
GO

CREATE TABLE dbo.TableA (
    col1 INT NOT NULL, col2 INT NOT NULL 
    PRIMARY KEY (Col1, Col2)
);

DROP TABLE IF EXISTS dbo.TableB
GO

CREATE TABLE dbo.TableB (
    col1 INT NOT NULL, col2 INT NOT NULL 
    FOREIGN KEY (Col1) REFERENCES dbo.TableA (Col1)
    FOREIGN KEY (Col1) REFERENCES dbo.TableA (Col1)
);

SELECT *
FROM dbo.TableA AS A
    INNER JOIN dbo.TableB AS B
        ON A.col1 = B.col1
        AND A.col2 = B.col2;


-- NON_EQUI JOINS
SELECT
    E1.empid, E1.firstname, E1.lastname
    ,E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1
    INNER JOIN HR.Employees AS E2
        ON E1.empid < E2.empid;


-- MULTI-JOIN QUERIES
SELECT
    C.custid
    ,C.companyname
    ,O.orderid
    ,OD.productid
    ,OD.qty
FROM Sales.Customers AS C 
    INNER JOIN Sales.Orders AS O -- Results in all records from Customers with a matching record from Orders
        ON C.custid = O.custid
    INNER JOIN Sales.OrderDetails AS OD -- Results in all records from the preceding set with a matching record from OrderDetails
        ON O.orderid = OD.orderid;


-- OUTER JOINS
SELECT
    C.custid
    ,C.companyname
    ,O.orderid
FROM Sales.Customers AS C 
    LEFT OUTER JOIN Sales.Orders AS O 
        ON C.custid = O.custid; -- Customers that have not placed an order will be in the result table with NULLs for orderid

SELECT
    C.custid
    ,C.companyname
    ,O.orderid
FROM Sales.Customers AS C 
    LEFT OUTER JOIN Sales.Orders AS O 
        ON C.custid = O.custid
WHERE O.orderid IS NOT NULL; -- Returns inner rows only. Customers with a matching order id.

SELECT
    C.custid
    ,C.companyname
    ,O.orderid
FROM Sales.Customers AS C 
    LEFT OUTER JOIN Sales.Orders AS O 
        ON C.custid = O.custid
WHERE O.orderid IS NULL; -- Returns outer rows only. Customers without a matching order id
-- In both queries above, orderid is a primary key in the Customers table so NULLs are not expected on the preserved side

SELECT
    D.Date 
    ,O.orderid 
    ,O.custid 
    ,O.empid
FROM dbo.DateDetail AS D 
    LEFT JOIN Sales.Orders AS O
        ON D.Date = O.orderdate
WHERE D.Date BETWEEN N'2014-01-01' AND N'2016-12-31'
ORDER BY D.Date ASC; -- Returns ever day in range with associated order (if there was an order)

SELECT
    C.custid
    ,C.companyname
    ,O.orderid 
    ,O.orderdate
FROM Sales.Customers AS C
    LEFT OUTER JOIN Sales.Orders AS O
        ON C.custid = O.custid
WHERE O.orderdate >= '2016-01-01'; -- This negates the outer join
/*Referencing an attribute from the non-preserved side usually indicates a bug.
The query will run, but may not perform as expected. In this case, the filter predicate
removes all outer rows since it results as UNKNOWN for rows without an orderdate (outer rows).
This is essentially an inner join, and either the wrong join was used, or the predicate should be adjusted.*/

SELECT
    C.custid
    ,O.orderid 
    ,OD.productid
    ,OD.qty
FROM Sales.Customers AS C
    LEFT OUTER JOIN Sales.Orders AS O
        ON C.custid = O.custid
    INNER JOIN Sales.OrderDetails AS OD
        ON O.orderid = OD.orderid; -- This negates the outer join (same as above)
/*Rows that evaluate to UNKNOWN are discarded again, which may be unintended. This query is equivalent
to using inner joins for both join operations.*/

SELECT
    C.custid
    ,COUNT (*) AS numorderswrong -- counts all rows (including nulls)
    ,COUNT (orderid) AS numorders -- counts all rows with an associated orderid
FROM Sales.Customers AS C
    LEFT OUTER JOIN Sales.Orders AS O
        ON C.custid = O.custid
WHERE C.custid IN (22, 57)
GROUP BY C.custid;