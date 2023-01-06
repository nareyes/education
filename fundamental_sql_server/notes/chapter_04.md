# Ch 4: Subqueries
- SQL supports writing queries within queries, or nesting queries
- The outermost query is returned to the caller and is known as the outer query
- The innermost query's result is used by the outer query and is known as the inner query
- This eliminates the need for separate steps in your solution, like declaring variables
- Subqueries can be self-contained or correlated
- Subqueries can return a single value, multiple values, or a whole table result (reviewed in Ch 5) 

##### Self-Contained Subqueries
- Subqueries that are independent of the tables in the outer query
- Logically, subqueries are evaluated once before the outer query is evaluated
	- The outer query uses the results of the subquery

###### Self-Contained Scaler Subquery Examples
- Returns a single value (query will fail otherwise)
	- If a scalar subquery (inner query) returns no value, the empty result is converted to NULL,
		- The outer query then returns an empty set
- Can appear anywhere in the outer query where a single-valued expression can appear
	- WHERE (Using the = comparison operator to return a scalar result)
	- SELECT

``` SQL
-- Query the Orders table and return information about the order with the maximum orderID in the table

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
```

*These last two examples are for illustration purposes only. Because an equality operator is used in the WHERE clause, these are considered scalar. But because these subqueries can potentially return more than 1 result, the equality predicate is incorrectly used. If the subquery happens to return 0 or 1 value, it runs. Otherwise, it will fail. These queries should be handled with an IN predicate in a multivalued subquery (below).*

##### Self-Contained Multivalued Subquery Examples
- Returns multiple values in a single column
- The IN predicate can be used to operate on multi-valued subqueries
	- < Scalar Expression > IN < Multivalued Subquery >
	- The predicate evaluates to true if the scalar expression is equal to any of the values returned by the subquery
	- You can use the NOT IN predicate to negate the IN predicate

``` SQL
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
SELECT O.orderid
FROM HR.Employees AS E
INNER JOIN Sales.Orders AS O
    ON E.empid = O.empid
WHERE E.lastname LIKE N'D%';
```

*Query problems can sometimes be solved multiple ways. Keep an eye on performance when choosing which to use.* 

##### Correlated Subqueries
- Refer to attributes from the tables that appear in the outer query
- Subquery is dependent on the outer query and cannot be invoked independently

``` SQL
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
```

##### The EXISTS Predicate
- Predicate accepts a subquery as input and returns TRUE if the subquery returns any rows and FALSE otherwise
- You can negate the EXISTS predicate with the NOT operator
- EXISTS uses two-valued logic (TRUE, FALSE) and not three-valued logic (TRUE, FALSE, UNKOWN)

``` SQL
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
```

##### Beyond the Fundamentals of Subqueries
- Returning previous or next values (more efficient with LAG and LEAD window functions)
	- Complication arises since result sets have no order, so an expression needs to be written that obtains maximum (or minimum) value that is smaller (or larger) than the current value
- Returning a running total (window functions that accomplish this task will be reviewed later)
	- You use a correlated subquery to sum the total of previous years with the current year

``` SQL
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
```

##### Dealing with Misbehaving Subqueries
- NULL trouble
- Substitution errors in subquery column names