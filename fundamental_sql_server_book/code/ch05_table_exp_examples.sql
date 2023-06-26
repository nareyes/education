------------------------------------
--  Chapter 5: Table Expressions  --
------------------------------------
USE tsql_fundamentals;

-- Derived Table Basic Syntax
SELECT *
FROM (
    SELECT custid, companyname
    FROM Sales.Customers
    WHERE Country = N'USA'
) AS USCustomers


-- Derived Table w/ Column Aliasing
SELECT
    orderyear
    ,COUNT (DISTINCT custid) AS numcusts
FROM (
    SELECT YEAR(orderdate) AS orderyear, custid 
    FROM Sales.Orders
) AS O
GROUP BY orderyear -- Reference column alias from inner query

-- Standard query that produces same result as above
SELECT
    YEAR (orderdate) AS orderyear
    ,COUNT (DISTINCT custid) AS numcusts 
FROM Sales.Orders 
GROUP BY YEAR (orderdate); -- Unable to reference column aliases from SELECT


-- Derived Table w/ Argument
DECLARE @empid AS INT = 3 

SELECT
    orderyear 
    ,COUNT (DISTINCT custid) as numcusts 
FROM ( 
    SELECT custid, YEAR (orderdate) AS orderyear 
    FROM Sales.Orders 
    WHERE empid = @empid 
) AS O
GROUP BY orderyear; -- Returns distinct customers per year whose orders were handled by the input empoyee (@empid)


-- LEFT OUTER JOIN Derived Table
SELECT 
    CurrentYear.orderyear
    ,CurrentYear.numcusts AS curnumcusts
    ,PreviousYear.numcusts AS prvnumcusts
    ,CurrentYear.numcusts - PreviousYear.numcusts AS growth 
FROM ( 
    SELECT YEAR (orderdate) AS orderyear, COUNT (DISTINCT custid) AS numcusts 
    FROM Sales.Orders 
    GROUP BY YEAR (orderdate) 
) AS CurrentYear 
    LEFT OUTER JOIN ( 
        SELECT YEAR (orderdate) AS orderyear, COUNT (DISTINCT custid) AS numcusts 
        FROM Sales.Orders 
        GROUP BY YEAR (orderdate)     
    ) AS PreviousYear 
        ON CurrentYear.orderyear = PreviousYear.orderyear + 1; -- Ensures each year from the first derived table matches the previous year of the second


-- CTE General Form
/*
WITH <CTE Name> [(<target column list)]
AS <alias> (
    <inner query defining CTE>
)
<outer query against CTE>
*/

-- CTE Simple Example
WITH USACusts AS ( 
    SELECT custid, companyname 
    FROM Sales.Customers 
    WHERE country = N'USA' 
) -- Creates CTE returning all customers from the US (think of this as a temp table)

SELECT * FROM USACusts; -- Queries all rows and columns from the CTE (temp table)


-- Internal Aliasing
WITH CustTemp AS ( 
    SELECT YEAR (orderdate) AS orderyear, custid 
    FROM Sales.Orders 
)

SELECT 
    orderyear 
    ,COUNT (DISTINCT custid) AS numcusts 
FROM CustTemp 
GROUP BY orderyear;


-- External Aliasing
WITH CustTemp (orderyear, custid) AS ( 
    SELECT YEAR (orderdate) AS orderyear, custid 
    FROM Sales.Orders 
)

SELECT 
    orderyear
    ,COUNT (DISTINCT custid) AS numcusts 
FROM CustTemp 
GROUP BY orderyear;


-- CTE w/ Arguments
DECLARE @empid AS INT = 3; -- Preceding statement MUST be ended with semicolon

WITH CustTemp AS ( 
    SELECT YEAR (orderdate) AS orderyear, custid 
    FROM Sales.Orders 
    WHERE empid = @empid 
)

SELECT 
    orderyear
    ,COUNT (DISTINCT custid) AS numcusts 
FROM CustTemp 
GROUP BY orderyear; -- Returns number of customers from declared empoyee id 


-- Multiple CTEs
WITH CustTemp_1 AS ( 
    SELECT YEAR (orderdate) AS orderyear, custid 
    FROM Sales.Orders 
), -- CTEs must be seperated by commas

CustTemp_2 AS ( 
    SELECT orderyear, COUNT (DISTINCT custid) AS numcusts 
    FROM CustTemp_1 
    GROUP BY orderyear 
)

SELECT 
    orderyear
    ,numcusts 
FROM CustTemp_2 
WHERE numcusts > 70;


-- CTEs w/ Multiple Reference
WITH YearlyCount AS ( 
    SELECT 
        YEAR (orderdate) AS orderyear
        ,COUNT (DISTINCT custid) AS numcusts 
    FROM Sales.Orders 
    GROUP BY YEAR (orderdate) 
) 

SELECT 
    CurrentYear.orderyear
    ,CurrentYear.numcusts AS curnumcusts
    ,PreviousYear.numcusts AS prevnumcusts
    ,CurrentYear.numcusts - PreviousYear.numcusts AS yoygrowth 
FROM YearlyCount AS CurrentYear 
    LEFT OUTER JOIN YearlyCount AS PreviousYear 
        ON CurrentYear.orderyear = PreviousYear.orderyear + 1; -- Join condition states current year is the previous year + 1


-- Recursive CTE General Form
/*
WITH <CTE Name> [(<target column list)]
AS <alias> (
    <anchor member>
    UNION ALL
    <recursive member>
)
<outer query against CTE>
*/


-- Recursive CTE
WITH EmpsCTE AS (
    SELECT empid, mgrid, firstname, lastname
    FROM HR.Employees
    WHERE empid = 2

    UNION ALL 

    SELECT E2.empid, E2.mgrid, E2.firstname, E2.lastname
    FROM EmpsCTE AS E1
        INNER JOIN HR.Employees AS E2
            ON E1.empid = E2.mgrid
)

SELECT 
    empid
    ,mgrid
    ,firstname
    ,lastname
FROM EmpsCTE -- Returns all subordiantes (direct and indirect) for empid 2


-- Drop View
DROP VIEW IF EXISTS Sales.USACusts
GO

-- Create View
CREATE VIEW Sales.USACusts AS ( 
    SELECT 
        custid 
        ,companyname
        ,contactname
        ,contacttitle
        ,address
        ,city
        ,region
        ,postalcode
        ,country
        ,phone
        ,fax
    FROM Sales.Customers 
    WHERE country = N'USA' 
)
GO

SELECT * FROM Sales.USACusts;
GO


-- Altering a view to remove the fax number
ALTER VIEW Sales.USACusts AS ( 
    SELECT 
        custid
        ,companyname
        ,contactname
        ,contacttitle
        ,address
        ,city
        ,region
        ,postalcode
        ,country
        ,phone 
    FROM Sales.Customers 
    WHERE country = N'USA' 
)
GO

SELECT * FROM Sales.USACusts;


-- Query View w/ ORDER BY
SELECT
    custid
    ,companyname
    ,region
FROM Sales.USACusts
ORDER BY region;


-- VIEW OPTION: ENCRYPTION
-- Getting an Object Definition
SELECT OBJECT_DEFINITION (OBJECT_ID ('Sales.USACusts'));
GO

-- Altering a view to add encryption
ALTER VIEW Sales.USACusts WITH ENCRYPTION AS ( 
    SELECT 
        custid
        ,companyname
        ,contactname
        ,contacttitle
        ,address
        ,city
        ,region
        ,postalcode
        ,country
        ,phone
        ,fax
    FROM Sales.Customers 
    WHERE country = N'USA' 
)
GO

-- Object Definition Now NULL
SELECT OBJECT_DEFINITION (OBJECT_ID ('Sales.USACusts'));
GO


-- Altering View w/ Schema Binding
ALTER VIEW Sales.USACusts WITH SCHEMABINDING AS ( 
    SELECT 
        custid
        ,companyname
        ,contactname
        ,contacttitle
        ,address
        ,city
        ,region
        ,postalcode
        ,country
        ,phone
        ,fax
    FROM Sales.Customers 
    WHERE country = N'USA' 
)
GO


-- Altering View w/ Check Option
ALTER VIEW Sales.USACusts WITH SCHEMABINDING AS ( 
    SELECT 
        custid
        ,companyname
        ,contactname
        ,contacttitle
        ,address
        ,city
        ,region
        ,postalcode
        ,country
        ,phone
        ,fax
    FROM Sales.Customers 
    WHERE country = N'USA' 
) WITH CHECK OPTION
GO


-- Create a TVF
DROP FUNCTION IF EXISTS dbo.GetCustOrders
GO 

CREATE FUNCTION dbo.GetCustOrders 
    (@custid AS INT) RETURNS TABLE -- @custid is the input parameter
AS 
RETURN 
    SELECT 
        orderid
        ,custid 
        ,empid
        ,orderdate
        ,requireddate
        ,shippeddate
        ,shipperid
        ,freight
        ,shipname
        ,shipaddress
        ,shipcity
        ,shipregion
        ,shippostalcode
        ,shipcountry 
    FROM Sales.Orders 
    WHERE custid = @custid 
GO

-- Query a TVF
SELECT orderid, custid 
FROM dbo.GetCustOrders(1) AS O; -- Returns all orders from customer id 1


-- CROSS APPLY vs CROSS JOIN (Same Result)
SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
    CROSS JOIN HR.Employees AS E;

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
    CROSS APPLY HR.Employees AS E;


-- CROSS APPLY
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
    CROSS APPLY ( 
        SELECT TOP (3) orderid, empid, orderdate, requireddate
        FROM Sales.Orders AS O
        WHERE O.custid = C.custid
        ORDER BY orderdate DESC, orderid DESC
        -- OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY -- Can replace TOP
    ) AS A; -- Returns top 3 orders for each customer


-- OUTER APPLY (Return Outer Rows w/ NULL)
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
    OUTER APPLY (
        SELECT TOP (3) orderid, empid, orderdate, requireddate
        FROM Sales.Orders AS O
        WHERE O.custid = C.custid
        ORDER BY orderdate DESC, orderid DESC
        -- OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY -- Can replace TOP
    ) AS A; -- Returns top 3 orders for each customer, NULL for customers w/o an order (custid 22, 57)


-- Using TVFs in Place of APPLY (Improved Readability)
DROP FUNCTION IF EXISTS dbo.TopOrders
GO

CREATE FUNCTION dbo.TopOrders (
    @custid AS INT
    ,@n AS INT)
RETURNS TABLE AS
RETURN
  SELECT TOP (@n) orderid, empid, orderdate, requireddate
  FROM Sales.Orders
  WHERE custid = @custid
  ORDER BY orderdate DESC, orderid DESC
GO

-- Query a TVF (CROSS APPLY)
SELECT
  C.custid, C.companyname,
  A.orderid, A.empid, A.orderdate, A.requireddate
FROM Sales.Customers AS C
  CROSS APPLY dbo.TopOrders(C.custid, 3) AS A;

-- Query a TVF (OUTER APPLY)
SELECT
  C.custid, C.companyname,
  A.orderid, A.empid, A.orderdate, A.requireddate
FROM Sales.Customers AS C
  OUTER APPLY dbo.TopOrders(C.custid, 3) AS A;