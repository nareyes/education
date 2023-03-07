--------------------------
--  Chapter 4 Exercises --
--------------------------

-- Write a query that returns all orders placed on the last day of activity that can be found in the Orders table.
-- Tables Invovled: Sales Orders
SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
WHERE orderdate = (SELECT MAX(O.orderdate)
                   FROM Sales.Orders AS O)
ORDER BY orderid DESC;


-- Write a query that returns all orders placed by the customer(s) who placed the highest number of orders. 
-- Note that more than one customer might have the same number of orders.
-- Tables Invovled: Sales.Orders
SELECT
    custid
    ,orderid
    ,orderdate
    ,empid
FROM Sales.Orders
WHERE custid IN (SELECT TOP 1 WITH TIES O.custid
                FROM Sales.Orders AS O
                GROUP BY O.custid
                ORDER BY COUNT (orderid) DESC)
ORDER BY custid ASC;


-- Write a query that returns employees who did not place orders on or after May 1, 2016.
-- Tables Invovled: HR.Employees and Sales.Orders
SELECT
    empid
    ,firstname
    ,lastname
FROM HR.Employees
WHERE empid NOT IN (SELECT O.empid
                    FROM Sales.Orders AS O
                    WHERE orderdate >= '2016-05-01')
ORDER BY empid ASC;

-- Write a query that returns countries where there are customers but not employees.
-- Tables Invovled: Sales.Customers and HR.Employees
SELECT DISTINCT country 
FROM Sales.Customers
WHERE country NOT IN (SELECT E.country 
                      FROM HR.Employees AS E)
ORDER BY country ASC;


-- Write a query that returns for each customer all orders placed on the customer’s last day of activity.
-- Table Involved: Sales.Orders
SELECT
    O1.custid
    ,O1.orderid
    ,O1.orderdate
    ,O1.empid
FROM Sales.Orders AS O1
WHERE orderdate = (SELECT MAX (O2.orderdate)
                   FROM Sales.Orders AS O2
                   WHERE O1.custid = O2.custid)
ORDER BY custid ASC;


-- Write a query that returns customers who placed orders in 2015 but not in 2016.
-- Tables Involved: Sales.Customers and Sales.Orders
SELECT
    C.custid 
    ,C.companyname
FROM Sales.Customers AS C
WHERE custid IN (SELECT O.custid
                 FROM Sales.Orders AS O
                 WHERE C.custid = O.custid AND YEAR (O.orderdate) = 2015)
    AND custid NOT IN (SELECT O.custid
                 FROM Sales.Orders AS O
                 WHERE C.custid = O.custid AND YEAR (O.orderdate) = 2016)
ORDER BY custid ASC;


-- Write a query that returns customers who ordered product 12.
-- Tables Involved: Sales.Customers, Sales.Orders, and Sales.OrderDetails



-- Write a query that calculates a running-total quantity for each customer and month.
-- Table Involved: Sales.CustOrders



-- Write a query that returns for each order the number of days that passed since the same customer’s previous order.
-- To determine recency among orders, use orderdate as the primary sort element and orderid as the tiebreaker.
-- Table Involved: Sales.Orders


-- Explain the difference between IN and EXISTS.
/* Whereas the IN predicate uses three-valued logic, the EXISTS predicate uses two-valued logic. 
When no NULLs are involved in the data, IN and EXISTS give you the same meaning in both their positive and negative forms (with NOT). 
When NULLs are involved, IN and EXISTS give you the same meaning in their positive form but not in their negative form. 
In the positive form, when looking for a value that appears in the set of known values in the subquery, both return TRUE, 
and when looking for a value that doesn’t appear in the set of known values, both return FALSE. 
In the negative forms (with NOT), when looking for a value that appears in the set of known values, both return FALSE; 
however, when looking for a value that doesn’t appear in the set of known values, NOT IN returns UNKNOWN (outer row is discarded),
whereas NOT EXISTS returns TRUE (outer row returned). */