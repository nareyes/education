-------------------------------------
-- Chapter 7: Beyonnd Fundamentals --
-------------------------------------
USE tsql_fundamentals;

/*  Parts of a Window Functionn
- PARTITION BY
- ORDER BY
- ROWS BETWWEN <> AND <> */

-- Basic Example
SELECT
    empid
    ,ordermonth
    ,val
    ,SUM (val) OVER (
        PARTITION BY empid -- Grouped by empid
        ORDER BY ordermonth
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- Filters a frame
    ) AS runval
FROM Sales.EmpOrders;

--------------------------------------------------------------------
-- RANKING WINDOW FUNCTIONS (ROW_NUMBER, RANK, DENSE_RANK, NTILE) --
--------------------------------------------------------------------
-- Pg 216

-- Demonstration of All Functions
SELECT
    orderid
    ,custid
    ,val 
    ,ROW_NUMBER ()  OVER (ORDER BY val) AS rownum -- Non-Deterministic
    ,RANK ()        OVER (ORDER BY val) AS rnk -- Count of preceeding rank values plus 1
    ,DENSE_RANK ()  OVER (ORDER BY val) AS densernk -- Count of preceeding distinct rank values plus 1
    ,NTILE (100)    OVER (ORDER BY val) AS ntile -- Equally sized groups of rows based on argument
FROM Sales.OrderValues
ORDER BY val ASC;


-- ROW_NUMBER w/ PARTITION BY
SELECT 
    orderid
    ,custid
    ,val
    ,ROW_NUMBER () OVER (PARTITION BY custid ORDER BY val) AS custrownum
FROM Sales.OrderValues
ORDER BY custid ASC, val ASC;

------------------------------------------------------------------
-- OFFSET WINDOW FUNCTIONS (LAG, LEAD, FIRST_VALUE, LAST_VALUE) --
------------------------------------------------------------------
-- Pg 219

-- LAG and LEAD (Arguments: return_element, num_offset, default_val)
-- First Argument Mandatory
SELECT
    custid
    ,orderid
    ,val
    ,LAG (val)  OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS prevval
    ,LEAD (val) OVER (PARTITION BY custid ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues
ORDER BY custid ASC, orderdate ASC, orderid ASC;


-- FIRST_VALUE and LAST_VALUE
SELECT
    custid
    ,orderid
    ,val
    ,FIRST_VALUE (val)  OVER (
        PARTITION BY custid
        ORDER BY orderdate, orderid
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- Returns first value in the partition
    ) AS firstval 
    ,LAST_VALUE (val)   OVER (
        PARTITION BY custid
        ORDER BY orderdate, orderid
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING -- Returns last value in the partition
    ) AS lastval
FROM Sales.OrderValues
ORDER BY custid ASC, orderdate ASC, orderid ASC;


--------------------------------
-- AGGREGATE WINDOW FUNCTIONS --
--------------------------------
-- Pg 221

-- SUM
SELECT
    orderid
    ,custid
    ,val
    ,SUM (val) OVER () AS totalvalue -- sum of val for entire table
    ,SUM (val) OVER (PARTITION BY custid) AS custtotalvalue -- sum of val for each customer
FROM Sales.OrderValues;


-- SUM w/ Detail
SELECT
    orderid
    ,custid
    ,val
    ,SUM (val) OVER () AS totalvalue -- sum of val for entire table
    ,100.0 * val / SUM (val) OVER () AS pctall -- percent of total value
    ,SUM (val) OVER (PARTITION BY custid) AS custtotalvalue -- sum of val for each customer
    ,val * 100.0 / SUM (val) OVER (PARTITION BY custid) AS pctcust -- percent of customer value
FROM Sales.OrderValues; 


-- SUM w/ Running Total
SELECT
    empid
    ,ordermonth
    ,val
    ,SUM (val) OVER (
        PARTITION BY empid -- Grouped by empid
        ORDER BY ordermonth
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- Filters a frame to all values from beginning of the partition to the current month
    ) AS runval
    ,SUM (val) OVER (PARTITION BY empid) AS emptotal
FROM Sales.EmpOrders;


--------------
-- PIVOTING --
--------------
-- Pg 224

-- Create Demo Table
USE tsql_fundamentals
GO

DROP TABLE IF EXISTS dbo.Orders
GO

CREATE TABLE dbo.Orders (
     orderid     INT         NOT NULL
    ,orderdate   DATE        NOT NULL
    ,empid       INT         NOT NULL
    ,custid      VARCHAR(5)  NOT NULL
    ,qty         INT         NOT NULL
    ,CONSTRAINT  PK_Orders   PRIMARY KEY(orderid)
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
    (30001, '20140802', 3, 'A', 10)
    ,(10001, '20141224', 2, 'A', 12)
    ,(10005, '20141224', 1, 'B', 20)
    ,(40001, '20150109', 2, 'A', 40)
    ,(10006, '20150118', 1, 'C', 14)
    ,(20001, '20150212', 2, 'B', 12)
    ,(40005, '20160212', 3, 'A', 10)
    ,(20002, '20160216', 1, 'C', 20)
    ,(30003, '20160418', 2, 'B', 15)
    ,(30004, '20140418', 3, 'C', 22)
    ,(30007, '20160907', 3, 'D', 30);

SELECT * FROM dbo.Orders;


-- Pivot w/ CASE Statements (Create Columns for CustId)
SELECT
    empid
    ,SUM (CASE WHEN custid = 'A' THEN qty END) AS A
    ,SUM (CASE WHEN custid = 'B' THEN qty END) AS B
    ,SUM (CASE WHEN custid = 'C' THEN qty END) AS C
    ,SUM (CASE WHEN custid = 'D' THEN qty END) AS D
FROM dbo.Orders
GROUP BY empid


-- PIVOT Operator
/*
Pivot Elements
- Grouping
- Spreading
- Aggregating

- Pivot Form (Always Use Derived Table in FROM Clause)
SELECT ...
FROM <derived_input_table>
    PIVOT (
        <agg_function>(<aggregation_element>)
        FOR <spreading_element> IN (<list_of_target_columns>)
    ) AS <result_table_alias>
WHERE ...;
 */

 -- PIVOT Example
SELECT empid, [A], [B], [C], [D]
FROM (
    SELECT empid, custid, qty
    FROM dbo.Orders
) AS tbl
    PIVOT (
        SUM (qty)
        FOR custid IN ([A], [B], [C], [D])
    ) AS pvt;


----------------
-- UNPIVOTING --
----------------
-- Pg 230

-- Create Demo Table
USE tsql_fundamentals
GO

DROP TABLE IF EXISTS dbo.EmpCustOrders
GO

CREATE TABLE dbo.EmpCustOrders (
    empid   INT        NOT NULL CONSTRAINT PK_EmpCustOrders PRIMARY KEY
    ,A      VARCHAR(5) NULL
    ,B      VARCHAR(5) NULL
    ,C      VARCHAR(5) NULL
    ,D      VARCHAR(5) NULL
);

INSERT INTO dbo.EmpCustOrders(empid, A, B, C, D)
    SELECT empid, [A], [B], [C], [D]
    FROM (
        SELECT empid, custid, qty
        FROM dbo.Orders
    ) AS tbl
        PIVOT (
            SUM (qty)
            FOR custid IN ([A], [B], [C], [D])
        ) AS pvt;

SELECT * FROM dbo.EmpCustOrders;


-- Unpivot w/ APPLY Operator (Pg 231 for Detail)
SELECT empid, custid, qty
FROM dbo.EmpCustOrders
    CROSS APPLY (VALUES 
        ('A', A)
        ,('B', B)
        ,('C', C)
        ,('D', D)
    ) AS C(custid, qty)
WHERE qty IS NOT NULL;


-- UNNPIVOT Operator
/*
Unpivot Elements
- Produce Copies
- Extract Values
- Eliminate Irrelevant Rows

- Unpivot Form
SELECT ...
FROM <derived_input_table>
    UNPIVOT (
        FOR <values_column> FOR <names_column> IN(<source_columns>)
    ) AS <result_table_alias>
WHERE ...;
 */

SELECT empid, custid, qty
FROM dbo.EmpCustOrders
    UNPIVOT (
        qty FOR custid IN ([A], [B], [C], [D])
    ) AS unpvt;


-------------------
-- GROUPING SETS --
-------------------
-- Pg 234

-- Single Grouped Queries Define a Single Grouping Set
SELECT 
    empid
    ,custid
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid; -- Grouping set (empid, custid)

SELECT 
    empid
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY empid; -- Grouping set (empid)

SELECT 
    custid
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY custid; -- Grouping set (custid)

SELECT SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY empid; -- Grouping set (empty)


-- Combining Multiple Groupes Sets w/ Union
-- Problems: Code Length, Performance
SELECT 
    empid
    ,custid
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid -- Grouping set (empid, custid)

UNION ALL

SELECT 
    empid
    ,NULL
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY empid -- Grouping set (empid)

UNION ALL

SELECT 
    NULL
    ,custid
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY custid -- Grouping set (custid)

UNION ALL

SELECT
    NULL
    ,NULL
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY empid; -- Grouping set (empty)


-- GROUPING SETS
SELECT
    empid
    ,custid
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY GROUPING SETS (
    (empid, custid)
    ,(empid)
    ,(custid)
    ,()
);

SELECT * FROM dbo.Orders; -- For comparison 


-- CUBE
SELECT
    empid
    ,custid
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY CUBE (empid, custid); -- CUBE Power Set


-- ROLLUP (Grouping Set Hierarchy A > B > C)
SELECT
    YEAR (orderdate) AS orderyear
    ,MONTH (orderdate) AS ordermonth
    ,DAY (orderdate) AS orderday
    ,SUM (qty) AS sumqty
FROM dbo.Orders
GROUP BY ROLLUP (
    YEAR (orderdate)
    ,MONTH (orderdate)
    ,DAY (orderdate)
);


-- GROUPING ID
-- Classify Grouping Sets
SELECT
    empid
    ,custid
    ,SUM (qty) AS sumqty
    ,GROUPING_ID (empid, custid) AS groupingset -- Produces integer bitmap
FROM dbo.Orders
GROUP BY CUBE (empid, custid);
/* 
CUBE (empid, custid) Represents 4 Grouping Sets
GROUPING_ID Associates a Key Per Grouping Set

Grouping Set        Grouping ID
(empid, custid)     0
(empid)             1
(custid)            2
()                  3
*/