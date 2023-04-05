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