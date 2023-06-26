-----------------------------------------
--  Chapter 6 Exercises: Set Operators --
-----------------------------------------

-- EXERCISE 1
-- Explain the difference between the UNION ALL and UNION operators. 
-- Answer: UNION ALL returns all occurences, while UNION returns DISTINCT occurences.

-- EXERCISE 2
-- Write a query that generates a virtual auxiliary table of 10 numbers in the range 1 through 10 without using a looping construct. 
-- You do not need to guarantee any order of the rows in the output of your solution.
-- Tables Involved: None
SELECT 1 AS n
UNION ALL SELECT 2
UNION ALL SELECT 3
UNION ALL SELECT 4
UNION ALL SELECT 5
UNION ALL SELECT 6
UNION ALL SELECT 7
UNION ALL SELECT 8
UNION ALL SELECT 9
UNION ALL SELECT 10;

-- ALternate Solutions Using VALUES
SELECT n
FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS Nums(n);


-- EXERCISE 3
-- Write a query that returns customer and employee pairs that had order activity in January 2016 but not in February 2016.
-- Table Involved: Sales.Orders
SELECT
    custid
    ,empid
FROM Sales.Orders
WHERE YEAR (orderdate) = 2016 AND MONTH (orderdate) = 01

EXCEPT

SELECT
    custid
    ,empid
FROM Sales.Orders
WHERE YEAR (orderdate) = 2016 AND MONTH (orderdate) = 02;


-- EXERCISE 4
-- Write a query that returns customer and employee pairs that had order activity in both January 2016 and February 2016.
-- Table Involved: Sales.Orders
SELECT
    custid
    ,empid
FROM Sales.Orders
WHERE YEAR (orderdate) = 2016 AND MONTH (orderdate) = 01

INTERSECT

SELECT
    custid
    ,empid
FROM Sales.Orders
WHERE YEAR (orderdate) = 2016 AND MONTH (orderdate) = 02;


-- EXERCISE 5
-- Write a query that returns customer and employee pairs that had order activity in both January 2016 and February 2016 but not in 2015.
-- Table Involved: Sales.Orders
SELECT custid ,empid FROM Sales.Orders
WHERE YEAR (orderdate) = 2016 AND MONTH (orderdate) = 01

INTERSECT -- Evaluated First

SELECT custid ,empid FROM Sales.Orders
WHERE YEAR (orderdate) = 2016 AND MONTH (orderdate) = 02

EXCEPT -- Evaluated Second

SELECT custid ,empid FROM Sales.Orders
WHERE YEAR (orderdate) = 2015;


-- EXERCISE 6 (Advanced)
/* Reference Query
SELECT country, region, city
FROM HR.Employees
UNION ALL
SELECT country, region, city
FROM Production.Suppliers;*/
-- You are asked to add logic to the query so that it guarantees that the rows from Employees are returned in the output before the rows from Suppliers.
-- Also, within each segment, the rows should be sorted by country, region, and city
-- Tables Involved: HR.Employees and Production.Suppliers
SELECT
    country
    ,region
    ,city
FROM (
    SELECT 1 AS sortcol, country, region, city
    FROM HR.Employees
    UNION ALL
    SELECT 2, country, region, city
    FROM Production.Suppliers
) AS D
ORDER BY sortcol, country, region, city;