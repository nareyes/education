------------------------------
-- Chapter 6: Set Operators --
------------------------------
USE tsql_fundamentals;


/* General Form
Input Query 1
<set_operator>
Input Query 2
[ORDER BY ...];

Set Operators Include: UNNION ALL, UNION, INTERSECT, EXCEPT
UNION, INTERSECT, and EXCEPT Are Implicitly Distinct
*/

-- UNION ALL (m + n Rows, Returns Multi-Set, Not Unique)
SELECT
    country
    ,region
    ,city
    ,source_table = 'Emp Table'
FROM HR.Employees

UNION ALL 

SELECT
    country
    ,region
    ,city
    ,source_table = 'Cust Table'
FROM Sales.Customers; -- Can return duplicate records


-- UNION
SELECT
    country
    ,region
    ,city
FROM HR.Employees

UNION 

SELECT
    country
    ,region
    ,city
FROM Sales.Customers; -- Returns unique records
/* If duplicates are possible, and the solution requires they be eliminated, use UNION.
Otherwise, use UNION ALL even if dupplicated cannot exists between the input queries.
UNION ALL avoids the cost of checking for duplicates. */


-- INTERSECT
SELECT
    country
    ,region
    ,city
FROM HR.Employees

INTERSECT 

SELECT
    country
    ,region
    ,city
FROM Sales.Customers;

-- INTERSECT Result Using INNER JOIN
SELECT DISTINCT
    E.country
    ,E.region
    ,E.city
FROM HR.Employees AS E
    INNER JOIN Sales.Customers AS C
        ON E.country = C.country
        AND E.region = C.region
        AND E.city = C.city
        OR (E.region IS NULL AND C.region IS NULL); -- Explicitly include NULLs
/* INTERSECT and INNER JOIN are similar, except in how they handle NULLs.
INTERSECT includes NULL matches, while INNER JOIN does not unless explicitly handled. */


-- INNTERSECT ALL Custom Solution (ALL Not Supported in T-SQL)
-- Returns Duplicate Intersections (Lower Of Both Input Queries)
SELECT
    country
    ,region
    ,city
    ,ROW_NUMBER () OVER (PARTITION BY country, region, city ORDER BY (SELECT 0)) AS rownum
FROM HR.Employees -- 4 records for UK, NULL, London

INTERSECT 

SELECT
    country
    ,region
    ,city
    ,ROW_NUMBER () OVER (PARTITION BY country, region, city ORDER BY (SELECT 0)) AS rownum
FROM Sales.Customers -- 6 recors for UK, NULL, London

ORDER BY country, region, city;
-- ORDER BY (SELECT <constannt>) Circumvents Required ORDER BY Clause
-- Result returns 4 recrods for UK, NULL, London


-- Exclude RowNum From Above Result Using CTE
WITH
INTERSECT_ALL AS (
SELECT
    country
    ,region
    ,city
    ,ROW_NUMBER () OVER (PARTITION BY country, region, city ORDER BY (SELECT 0)) AS rownum
FROM HR.Employees

INTERSECT 

SELECT
    country
    ,region
    ,city
    ,ROW_NUMBER () OVER (PARTITION BY country, region, city ORDER BY (SELECT 0)) AS rownum
FROM Sales.Customers
)

SELECT
    country
    ,region,city
FROM INTERSECT_ALL;


-- EXCEPT (Input Query Order Matters)
SELECT
    country
    ,region
    ,city
FROM HR.Employees

EXCEPT 

SELECT
    country
    ,region
    ,city
FROM Sales.Customers; -- All employee locations not in customer locations

SELECT
    country
    ,region
    ,city
FROM Sales.Customers

EXCEPT 

SELECT
    country
    ,region
    ,city
FROM HR.Employees; -- All customer locations not in employee locations


-- Precedence
/* INTERSECT precedes UNION and EXCEPT.
UNION and EXCEPT are evaluated in appearance order.
Force precedence with parenthesis */

SELECT country, region, city FROM Production.Suppliers
EXCEPT -- Evaluated Second
SELECT country, region, city FROM HR.Employees
INTERSECT -- Evaluated First
SELECT country, region, city FROM Sales.Customers;
-- Returns supplier locations that are not employee and customer locations

(SELECT country, region, city FROM Production.Suppliers
EXCEPT -- Evaluated First
SELECT country, region, city FROM HR.Employees)
INTERSECT -- Evaluated Second
SELECT country, region, city FROM Sales.Customers;
-- Returns supplier locations that are not employee locations, and that are also cusomter locations