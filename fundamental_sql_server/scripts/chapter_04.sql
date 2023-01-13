-----------------------------
--  Chapter 4: Subqueries  --
-----------------------------
USE tsql_fundamentals;

-- Using a variable (less efficient)
DECLARE @maxid AS INT = (SELECT MAX(orderid) FROM Sales.Orders);

SELECT
    orderid,
    orderdate,
    empid,
    custid
FROM Sales.Orders
WHERE orderid = @maxid; -- Filters query where orderid equals the declared variable (max orderid)

-- Using a self-contained scalar subquery (more efficient)
SELECT
    orderid, 
    orderdate, 
    empid, 
    custid 
FROM Sales.Orders
WHERE orderid = (SELECT MAX(O.orderid)
                 FROM Sales.Orders AS O)

-- Non-scalar subquery (fails)
SELECT orderid
FROM Sales.Orders
WHERE empid = (SELECT E.empid
               FROM HR.Employees AS E
               WHERE E.lastname LIKE N'D%'); -- Multiple employees with a lastname starting with 'D'

-- NULL value subquery (returns empty set)
SELECT orderid
FROM Sales.Orders
WHERE empid = (SELECT E.empid
              FROM HR.Employees AS E
              WHERE E.lastname LIKE N'A%'); -- No lastnames that begin with A


-- IN Predicate
SELECT
    empid,
    orderid
FROM Sales.Orders
WHERE empid IN
    (SELECT E.empid
    FROM HR.Employees AS E
    WHERE E.lastname LIKE N'D%');


-- Negating the IN predicate
SELECT
    custid,
    companyname
FROM Sales.Customers
WHERE custid NOT IN
    (SELECT DISTINCT O.custid
    FROM Sales.Orders AS O); -- Returns customers with no orders (NOT IN) (Best practice is to qualify subquery to exclude NULLs, will be reviewed later)


-- The first query problem can technically be solved by joining Orders and Employees
SELECT
    E.empid,
    O.orderid
FROM HR.Employees AS E
INNER JOIN Sales.Orders AS O
    ON E.empid = O.empid
WHERE E.lastname LIKE N'D%';


-- Correlated Subquery
SELECT
    custid,
    orderid,
    orderdate,
    empid
FROM Sales.Orders AS O1
WHERE O1.orderid = 
    (SELECT MAX(O2.orderid)
    FROM Sales.Orders AS O2
    WHERE O2.custid = O1.custid); -- OrderID equals the value returned by the subquery


-- Correlated Subquery
SELECT 
    orderid, 
    custid, 
    val, 
    CAST(100.0 * val / ( 
        SELECT SUM(O2.val) 
        FROM Sales.OrderValues AS O2 
        WHERE O2.custid = O1.custid) AS NUMERIC(5, 2) 
    ) AS pct 
FROM Sales.OrderValues AS O1 
ORDER BY custid, orderid; -- Percentage of the current order value out of the customer total


-- Return customers from Spain who did place orders
SELECT 
    custid, 
    companyname 
FROM Sales.Customers AS C 
WHERE country = N'Spain' 
    AND EXISTS ( 
        SELECT * FROM Sales.Orders AS O 
        WHERE O.custid = C.custid 
    ); -- The outer query filters customers from Spain for whom the EXISTS predicate returns true (current customer has related orders in the Orders table)


-- Returns customers from Spain who did NOT place orders
SELECT 
    custid, 
    companyname 
FROM Sales.Customers AS C 
WHERE country = N'Spain' 
    AND NOT EXISTS ( 
        Select * FROM Sales.Orders AS O 
        WHERE O.custid = C.custid 
    ); -- The outer query filters customers from Spain for whom the EXISTS predicate reutnrs true (current customer does not have related orders in the Orders table)


-- Returning previous orders
SELECT 
    orderid, 
    orderdate, 
    empid, 
    custid, 
    (SELECT MAX(O2.orderid) 
    FROM Sales.Orders AS O2 
    WHERE O2.orderid < O1.orderid) AS prevorderid 
FROM Sales.Orders AS O1;


-- Returning Next Orders
SELECT 
    orderid, 
    orderdate, 
    empid, 
    custid, 
    (SELECT MIN(O2.orderid) 
    FROM Sales.Orders AS O2 
    WHERE O2.orderid > O1.orderid) AS nextorderid 
FROM Sales.Orders AS O1;


-- Running Aggregate
SELECT 
    orderyear, 
    qty, 
    (SELECT SUM(O2.qty) 
    FROM Sales.OrderTotalsByYear AS O2 
    WHERE O2.orderyear <= O1.orderyear) AS runqty -- Sums all previous year with current year (running total) 
FROM Sales.OrderTotalsByYear AS O1 
ORDER BY orderyear;