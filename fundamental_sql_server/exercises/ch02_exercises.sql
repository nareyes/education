------------------------------------------------
--  Chapter 2 Exercises: Single Table Queries --
------------------------------------------------
USE tsql_fundamentals
GO

-- EXERCISE 1
-- Write a query against the Sales.Orders table that returns orders placed in June 2015.
-- Tables Involved: TSQLV4 database and the Sales.Orders table.
SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
WHERE orderdate BETWEEN '2015-06-01' AND '2015-06-30'


-- EXERCISE 2
-- Write a query against the Sales.Orders table that returns orders placed on the last day of the month.
-- Tables Involved: TSQLV4 database and the Sales.Orders table.
SELECT
    orderid
    ,orderdate
    ,custid
    ,empid
FROM Sales.Orders
WHERE orderdate = EOMONTH(orderdate);


-- EXERCISE 3
-- Write a query against the HR.Employees table that returns employees with a last name containing the letter e twice or more.
-- Tables Involved: TSQLV4 database and the HR.Employees table.
SELECT
    empid
    ,firstname
    ,lastname
FROM HR.Employees
WHERE lastname LIKE N'%e%e%';


-- EXERCISE 4
-- Write a query against the Sales.OrderDetails table that returns orders with a total value (quantity * unitprice) greater than 10,000, sorted by total value.
-- Tables Involved: TSQLV4 database and the Sales.OrderDetails table.
SELECT
    orderid
    ,SUM (qty * unitprice) AS totalvalue
FROM Sales.OrderDetails
GROUP BY orderid
HAVING SUM (qty * unitprice) > 10000
ORDER BY totalvalue DESC;


-- EXERCISE 5
-- To check the validity of the data, write a query against the HR.Employees table that returns employees with a last name that starts with a lowercase English letter in the range a through z. 
-- Remember that the collation of the sample database is case insensitive (Latin1_General_CI_AS).
-- Tables Involved: TSQLV4 database and the HR.Employees table.
SELECT
    empid
    ,lastname
FROM HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';


-- EXERCISE 6
-- Explain the difference between the following two queries:
-- Query 1
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
WHERE orderdate < '20160501'
GROUP BY empid;
 -- Query 2
SELECT empid, COUNT(*) AS numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate) < '20160501';

/*
Answer: The WHERE clause is a row filter, whereas the HAVING clause is a group filter. 
Query 1 filters only orders placed before May 2016, groups them by the employee ID, and returns the number of orders each employee handled among the filtered ones. 
In other words, it computes how many orders each employee handled prior to May 2016. The query doesn’t include orders placed in May 2016 or later in the count. 
An employee will show up in the output as long as he or she handled orders prior to May 2016, regardless of whether the employee handled orders since May 2016.

Query 2 groups all orders by the employee ID, and then filters only groups having a maximum date of activity prior to May 2016. 
Then it computes the order count in each employee group. The query discards the entire employee group if the employee handled any orders since May 2016.
 In a sentence, this query returns for employees who didn’t handle any orders since May 2016 the total number of orders they handled.
*/


-- EXERCISE 7
-- Write a query against the Sales.Orders table that returns the three shipped-to countries with the highest average freight in 2015.
-- Tables Involved: TSQLV4 database and the Sales.Orders table.
SELECT TOP 3
    shipcountry
    ,AVG (freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate < '20160101'
GROUP BY shipcountry
ORDER BY avgfreight DESC; 

SELECT
    shipcountry
    ,AVG (freight) AS avgfreight
FROM Sales.Orders
WHERE orderdate >= '20150101' AND orderdate < '20160101'
GROUP BY shipcountry
ORDER BY avgfreight DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;


-- EXERCISE 8
-- Write a query against the Sales.Orders table that calculates row numbers for orders based on order date ordering (using the order ID as the tiebreaker) for each customer separately.
-- Tables Involved: TSQLV4 database and the Sales.Orders table.
SELECT
    custid
    ,orderdate
    ,orderid
    ,ROW_NUMBER() OVER (ORDER BY orderdate ASC, orderid ASC) as rownum
FROM Sales.Orders;


-- EXERCISE 9
-- Using the HR.Employees table, write a SELECT statement that returns for each employee the gender based on the title of courtesy. 
-- For ‘Ms.’ and ‘Mrs.’ return ‘Female’; for ‘Mr.’ return ‘Male’; and in all other cases (for example, ‘Dr.‘) return ‘Unknown’.
-- Tables Involved: TSQLV4 database and the HR.Employees table
SELECT
    empid
    ,firstname
    ,lastname
    ,titleofcourtesy
    ,CASE
        WHEN titleofcourtesy IN ('Ms.', 'Mrs.') THEN 'Female'
        WHEN titleofcourtesy = 'Mr.' THEN 'Male'
        ELSE 'Unknown'
    END AS gender
FROM HR.Employees;


-- EXERCISE 10
-- Write a query against the Sales.Customers table that returns for each customer the customer ID and region. 
-- Sort the rows in the output by region, having NULLs sort last (after non-NULL values). Note that the default sort behavior for NULLs in T-SQL is to sort first (before non-NULL values).
-- Tables Involved: TSQLV4 database and the Sales.Customers table.
SELECT
    custid
    ,region
FROM Sales.Customers
ORDER BY CASE WHEN region IS NULL THEN 1 ELSE 0 END, region;