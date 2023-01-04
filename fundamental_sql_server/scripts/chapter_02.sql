-------------------------------------
-- Chapter 2: Single Table Queries --
-------------------------------------

-- The FROM Clause
SELECT
    orderid, 
    custid, 
    empid, 
    orderdate, 
    freight
FROM Sales.Orders;


-- The WHERE Clause
SELECT 
    orderid, 
    custid, 
    empid, 
    orderdate, 
    freight 
FROM Sales.Orders
WHERE custid = 71;


-- The GROUP BY Clause
SELECT
  empid, 
  YEAR(orderdate) AS orderyear, 
  SUM(freight) AS totalfreight, 
  COUNT(*) AS numorders 
FROM Sales.Orders 
WHERE custid = 71 
GROUP BY empid, YEAR(orderdate);


-- The HAVING Clause
SELECT
    empid, 
    YEAR(orderdate) AS orderyear,
    COUNT(*) AS numorders 
FROM Sales.Orders 
WHERE custid = 71 
GROUP BY empid, YEAR(orderdate) 
HAVING COUNT(*) > 1;


-- The SELECT CLause
SELECT
    orderid,
    SUM(freight) AS totalfreight -- aliased column
FROM Sales.Orders
GROUP BY orderid;

SELECT DISTINCT 
    empid, 
    YEAR(orderdate) AS orderyear 
FROM Sales.Orders 
WHERE custid = 71;


-- The ORDER BY Clause
SELECT 
    empid, 
    YEAR(orderdate) AS orderyear, 
    COUNT(*) AS numorders 
FROM Sales.Orders 
WHERE custid = 71 
GROUP BY empid, YEAR(orderdate) 
HAVING COUNT(*) > 1 
ORDER BY empid ASC, orderyear DESC;


-- The TOP Filter
SELECT TOP (5)
    orderid,
    orderdate,
    custid,
    empid
FROM Sales.Orders
ORDER BY orderdate DESC; -- returns 5 rows

SELECT TOP (5) WITH TIES 
    orderid, 
    orderdate, 
    custid, 
    empid 
FROM Sales.Orders 
ORDER BY orderdate DESC; -- returns 8 rows due to duplicate orderdate results

SELECT TOP (100) *
FROM Sales.Orders; -- this query can be used to explore the table without pulling all rows

SELECT TOP (1) PERCENT
    orderid,
    orderdate,
    custid,
    empid
FROM Sales.Orders
ORDER BY orderdate DESC; -- returns the first 1% of records


-- The OFFSET-FETCH Filter
SELECT 
    orderid, 
    orderdate, 
    custid, 
    empid 
FROM Sales.Orders 
ORDER BY orderdate ASC, orderid ASC
	OFFSET 50 ROWS FETCH NEXT 25 ROWS ONLY;


-- Predicates and Operators
SELECT 
    orderid, 
    empid, 
    orderdate
FROM Sales.Orders
WHERE orderid IN(10248, 10249, 10250);

-- Predicates and Logical Operators
SELECT 
    orderid, 
    empid, 
    orderdate
FROM Sales.Orders 
WHERE orderid BETWEEN 10300 AND 10310; -- inclusive

SELECT  
    empid, 
    firstname, 
    lastname
FROM HR.Employees 
WHERE lastname LIKE N'D%'; -- N (NCHAR or NVARCHAR data types), % is a wild card, anything follows

-- Comparison Operators
SELECT 
    orderid, 
    empid, 
    orderdate
FROM Sales.Orders 
WHERE orderdate >= '2016-01-01';

-- Predicates and Comparison Operators
SELECT 
    orderid, 
    empid, 
    orderdate
FROM Sales.Orders
WHERE orderdate >= '2016-01-01' AND empid IN (1, 3, 5);

-- Arithmetic
SELECT 
    orderid, 
    productid, 
    qty, 
    unitprice, 
    discount, 
    qty * unitprice * (1 - discount) AS val
FROM Sales.OrderDetails;

-- Precedence (AND has precedence over OR, despite the order query is written
SELECT 
    orderid, 
    custid, 
    empid, 
    orderdate 
FROM Sales.Orders 
WHERE  
    custid = 1 AND 
    empid IN(1, 3, 5) OR  
    custid = 85 AND 
    empid IN(2, 4, 6);


-- CASE Expressions
SELECT
    productid,
    productname,
    categoryid,
    CASE categoryid
        WHEN 1 THEN 'Beverages' 
        WHEN 2 THEN 'Condiments' 
        WHEN 3 THEN 'Confections' 
        WHEN 4 THEN 'Dairy Products' 
        WHEN 5 THEN 'Grains/Cereals' 
        WHEN 6 THEN 'Meat/Poultry' 
        WHEN 7 THEN 'Produce' 
        WHEN 8 THEN 'Seafood' 
        ELSE 'Unknown Category' -- Optional, Defaults to ELSE IS NULL
    END AS categoryname
FROM Production.Products; -- Simple CASE expression

SELECT
    orderid,
    custid,
    val,
    CASE
        WHEN val < 1000.00 THEN 'Less than 1000'
        WHEN val BETWEEN 1000.00 and 3000.00 THEN 'Between 1000 and 3000'
        WHEN val > 3000.00 THEN 'More than 3000'
        ELSE 'Unknown'
    END AS valuecategory
FROM Sales.OrderValues; -- Searched CASE expression


-- ISNULL (Returns first non NULL value)
SELECT ISNULL('Hello', 'World'); -- Returns 'Hello'
SELECT ISNULL(NULL, 'World'); -- Returns 'World'
SELECT ISNULL(NULL, NULL); -- Return NULL (there isn't a non-NULL value)


-- COALESCE (Returns first non NULL value)
SELECT COALESCE('Hello', NULL, 'World', NULL, NULL); -- Returns 'Hello'
SELECT COALESCE(NULL, NULL, 'Hello', NULL, 'World'); -- Returns 'Hello'


-- The LIKE Predicate
-- Percent Wildcard
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'D%'; -- Returns any lastname starts with D, with any length. 

-- Underscore Wildcard
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'_e%'; -- Returns any lastname with an e for the second character, with any length after the wildcard.

-- [List] Wildcard
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'[ABC]%'; -- Returns any lastname with A, B, or C as a first character, with any length. 

-- [Range] Wildcarad
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'[A-E]%'; -- Returns any lastname with A, B, C, D, or E as a first character, with any length.

-- [^ List or Range] Wildcard
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'[^A-E]%'; -- Returns any last name that does NOT start with A, B, C, D, or E, with and length. 

-- ESCAPE Character
SELECT
    empid,
    lastname
FROM HR.Employees
WHERE lastname LIKE N'%!_%' ESCAPE '!'; -- Returns any last name with an underscore in the name (zero results)


-- Converting to DATE
SELECT CONVERT(DATE, '02/12/2016', 101); -- YYYY-MM-DD
SELECT CONVERT(DATE, '02/12/2016', 103); -- YYYY-DD-MM


-- Date Filter Functions (does not maintain index improvements)
SELECT
    orderid,
    custid,
    empid,
    orderdate
FROM Sales.Orders
WHERE YEAR(orderdate) = 2015 AND MONTH(orderdate) = 01;


-- Date Filter Range (maintains index improvements)
SELECT
    orderid,
    custid,
    empid,    
    orderdate
FROM Sales.Orders
WHERE orderdate >= '2016-01-01' AND orderdate < '2016-02-01';


-- Current Date & Time Functions
SELECT 
  GETDATE()           AS [GETDATE], 
  CURRENT_TIMESTAMP   AS [CURRENT_TIMESTAMP], 
  GETUTCDATE()        AS [GETUTCDATE], 
  SYSDATETIME()       AS [SYSDATETIME], 
  SYSUTCDATETIME()    AS [SYSUTCDATETIME], 
  SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];


-- TRY_CAST
SELECT TRY_CAST('20160212' AS DATE);
SELECT TRY_CAST(SYSDATETIME() AS DATE);
SELECT TRY_CAST(SYSDATETIME() AS TIME); 

-- TRY_CONVERT
SELECT TRY_CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112); 
SELECT TRY_CONVERT(CHAR(12), CURRENT_TIMESTAMP, 114); 


-- DATEADD
SELECT DATEADD(YEAR, 1, '20160212'); 
SELECT DATEADD(MONTH, 3, '2016-02-01'); 
SELECT DATEADD(MONTH, -1, CAST('2016-02-1' AS DATE));


-- DATEDIFF and DATEDIFF_BIG
SELECT DATEDIFF(DAY, '2016-01-01', '2016-12-31');
SELECT DATEDIFF(MONTH, '2016-01-01', '2016-12-31');


-- DATEPART
SELECT DATEPART(MONTH, '2016-01-01');
SELECT DATEPART(YEAR, '2016-01-01');


-- YEAR, MONTH, DAY
SELECT 
  DAY('20160212') AS TheDay, 
  MONTH('20160212') AS TheMonth, 
  YEAR('20160212') AS TheYear;


-- DATENAME
SELECT DATENAME(MONTH, '2016-01-01'); -- Returns January
SELECT DATENAME(YEAR, '2016-01-01'); -- Returns 2016 (year does not have a name)


-- ISDATE
SELECT ISDATE('20160212'); -- Returns 1 (Yes)
SELECT ISDATE('20160230'); -- Returns 0 (No)
SELECT ISDATE('TEST'); -- Returns 0 (No)


-- FROMPARTS Functions
SELECT 
  DATEFROMPARTS(2016, 02, 12), -- Returns 2016-02-12
  DATETIME2FROMPARTS(2016, 02, 12, 13, 30, 5, 1, 7), -- Returns 2016-02-12 13:30:05.0000001
  DATETIMEFROMPARTS(2016, 02, 12, 13, 30, 5, 997), -- Returns 2016-02-12 13:30:05.997
  DATETIMEOFFSETFROMPARTS(2016, 02, 12, 13, 30, 5, 1, -8, 0, 7), -- Returns 2016-02-12 13:30:05.0000001 -08:00
  SMALLDATETIMEFROMPARTS(2016, 02, 12, 13, 30), -- Returns 2016-02-12 13:30:00
  TIMEFROMPARTS(13, 30, 5, 1, 7); -- Returns 13:30:05.0000001


-- EOMONTH Function
SELECT EOMONTH('2016-01-01'); -- Returns 2016-01-31

SELECT EOMONTH('2016-01-01', 3); -- Returns 2016-04-30

SELECT
    orderid,
    orderdate,
    custid,
    empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate); -- Returns all orders placed on the last day of the month