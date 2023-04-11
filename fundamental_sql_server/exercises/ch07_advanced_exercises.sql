-----------------------------------------------
--  Chapter 7 Exercises: Beyond Fundamentals --
-----------------------------------------------


-- EXERCISE 1
-- Write a query against the dbo.Orders table that computes both a rank and a dense rank for each customer order, partitioned by custid and ordered by qty.
-- Table Involved: dbo.Orders
SELECT
    custid
    ,orderid
    ,qty
    ,RANK () OVER (PARTITION BY custid ORDER BY qty ASC) AS rnk
    ,DENSE_RANK () OVER (PARTITION BY custid ORDER BY qty ASC) AS dnsrnk
    ,ROW_NUMBER () OVER (PARTITION BY custid ORDER BY qty ASC) AS rownum
FROM dbo.Orders;


-- EXERCISE 2
-- Write a query that returns distinct values and their associated row numbers from Sales.OrderValues.
-- Tables Involved: Sales.OrderValues View
WITH
DistinctValues AS (
    SELECT DISTINCT val
    FROM Sales.OrderValues
)

SELECT
    val
    ,ROW_NUMBER () OVER (ORDER BY val ASC) AS rownum
FROM DistinctValues;


-- EXERCISE 3
-- Write a query against the dbo.Orders table that computes for each customer order both the difference between the current order quantity 
-- and the customer’s previous order quantity and the difference between the current order quantity and the customer’s next order quantity.
-- Table Involved: dbo.Orders
SELECT
    custid
    ,orderid
    ,qty
    ,qty - LAG (qty) OVER (PARTITION BY custid ORDER BY orderdate ASC, orderid ASC) AS diffprev
    ,qty - LEAD (qty) OVER (PARTITION BY custid ORDER BY orderdate ASC, orderid ASC) AS diffnext
FROM dbo.Orders;


-- EXERCISE 4
-- Write a query against the dbo.Orders table that returns a row for each employee,
-- a column for each order year, and the count of orders for each employee and order year.
-- Table Involved: dbo.Orders
SELECT
    empid
    ,COUNT (CASE WHEN orderyear = 2014 THEN orderyear END) AS cnt2014
    ,COUNT (CASE WHEN orderyear = 2015 THEN orderyear END) AS cnt2015
    ,COUNT (CASE WHEN orderyear = 2016 THEN orderyear END) AS cnt2016
FROM (
    SELECT empid, YEAR (orderdate) AS orderyear
    FROM dbo.Orders
) AS tbl
GROUP BY empid;

-- Solution w/ PIVOT
SELECT
    empid
    ,[2014] AS cnt2014
    ,[2015] AS cnt2015
    ,[2016] AS cnt2016
FROM (
    SELECT empid, YEAR(orderdate) AS orderyear
    FROM dbo.Orders
) AS tbl
    PIVOT (
        COUNT (orderyear)
        FOR orderyear IN ([2014], [2015], [2016])
    ) AS pvt;


-- EXERCISE 5
-- Write a query against the EmpYearOrders table that unpivots the data, returning a row for each employee and order year with the number of orders.
-- Exclude rows in which the number of orders is 0 (in this example, employee 3 in the year 2015).
-- Table Involved: dbo.EmpYearOrders

-- Create EmpYearOrders
DROP TABLE IF EXISTS dbo.EmpYearOrders
GO

CREATE TABLE dbo.EmpYearOrders (
  empid     INT NOT NULL CONSTRAINT PK_EmpYearOrders PRIMARY KEY
  ,cnt2014  INT NULL
  ,cnt2015  INT NULL
  ,cnt2016  INT NULL
)
GO

INSERT INTO dbo.EmpYearOrders (empid, cnt2014, cnt2015, cnt2016)
    SELECT
        empid
        ,[2014] AS cnt2014
        ,[2015] AS cnt2015
        ,[2016] AS cnt2016
    FROM (
        SELECT empid, YEAR(orderdate) AS orderyear
        FROM dbo.Orders
    ) AS tbl
        PIVOT (
            COUNT (orderyear)
            FOR orderyear IN ([2014], [2015], [2016])
        ) AS pvt;

 SELECT * FROM dbo.EmpYearOrders;


 -- Solution w/ CROSS APPLY
SELECT
    empid
    ,orderyear
    ,numorders
FROM dbo.EmpYearOrders
    CROSS APPLY (VALUES
        (2014, cnt2014),
        (2015, cnt2015),
        (2016, cnt2016)
    ) AS A (orderyear, numorders)
WHERE numorders <> 0;

-- Solution w/ UNPIVOT
SELECT
    empid
    ,CAST (RIGHT (orderyear, 4) AS INT) AS orderyear
    ,numorders
FROM dbo.EmpYearOrders
    UNPIVOT (
        numorders FOR orderyear IN (cnt2014, cnt2015, cnt2016)
    ) AS unpvt
WHERE numorders <> 0;


-- EXERCISE 6
-- Write a query against the dbo.Orders table that returns the total quantities for each of the following:
-- (employee, customer, and order year), (employee and order year), and (customer and order year). 
-- Include a result column in the output that uniquely identifies the grouping set with which the current row is associated.
-- Table Involved: dbo.Orders
SELECT
    empid
    ,custid
    ,YEAR (orderdate) AS orderyear
    ,SUM (qty) AS sumqty
    ,GROUPING_ID (empid, custid, YEAR (orderdate)) AS groupingset 
FROM dbo.Orders
GROUP BY GROUPING SETS (
    (empid, custid, YEAR (orderdate))
    ,(empid, YEAR (orderdate))
    ,(custid, YEAR (orderdate))
);