# SQL Subqueries
Created Date: 2022-07-06

> Metadata 🗃
> - Title: Advanced SQL Server Masterclass
> - Author: Travis Cuzick
> - Reference: Section 3

> Links & Tags 🔗
> - Index: [[Data Science Note Index]]
> - Atomic Tag: #datascience
> - Subatomic Tags: #sql #subqueries
> - Related Notes:

___ 
[Adventure Works Database](https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

### Notes

#### Subqueries Introduction
- Subqueries allow us to break more complex queries into parts
	- Best suited for straightforward two-step queries
- Consists of a nested inner query (temp table) referenced by outer query
	- The inner query can be referenced like a table or view

``` sql
SELECT
    PurchaseOrderID,
    VendorID,
    OrderDate,
    TaxAmt,
    Freight,
    TotalDue,
    TotalDueRank
FROM (
    SELECT
        PurchaseOrderID,
        VendorID,
        OrderDate,
        TaxAmt,
        Freight,
        TotalDue,
        TotalDueRank = ROW_NUMBER () OVER (PARTITION BY VendorID ORDER BY TotalDue DESC)
    FROM Purchasing.PurchaseOrderHeader
) AS Rank
WHERE TotalDueRank <= 3;
```

| PurchaseOrderID | VendorID | OrderDate  | TaxAmt   | Freight  | TotalDue  | TotalDueRank |
|-----------------|----------|------------|----------|----------|-----------|--------------|
| 325             | 1492     | 2013-04-25 | 119.8008 | 37.4378  | 1654.7486 | 1            |
| 1727            | 1492     | 2014-01-16 | 61.9164  | 19.3489  | 855.2203  | 2            |
| 2517            | 1492     | 2014-04-07 | 61.9164  | 19.3489  | 855.2203  | 3            |
| 1879            | 1494     | 2014-02-04 | 707.784  | 221.1825 | 9776.2665 | 1            |
| 1958            | 1494     | 2014-02-11 | 707.784  | 221.1825 | 9776.2665 | 2            |
| 1800            | 1494     | 2014-01-23 | 707.784  | 221.1825 | 9776.2665 | 3            |
| 925             | 1496     | 2013-09-17 | 165.5413 | 51.7317  | 2286.5395 | 1            |
| 1325            | 1496     | 2013-12-04 | 165.5413 | 51.7317  | 2286.5395 | 2            |
| 397             | 1496     | 2013-06-25 | 67.1832  | 20.9948  | 927.968   | 3            |

``` sql
SELECT
    PurchaseOrderID,
    VendorID,
    OrderDate,
    TaxAmt,
    Freight,
    TotalDue,
    TotalDueRank
FROM (
    SELECT
        PurchaseOrderID,
        VendorID,
        OrderDate,
        TaxAmt,
        Freight,
        TotalDue,
        TotalDueRank = DENSE_RANK () OVER (PARTITION BY VendorID ORDER BY TotalDue DESC)
    FROM Purchasing.PurchaseOrderHeader
) AS Rank
WHERE TotalDueRank <= 3;
```

| PurchaseOrderID | VendorID | OrderDate  | TaxAmt   | Freight | TotalDue  | TotalDueRank |
|-----------------|----------|------------|----------|---------|-----------|--------------|
| 325             | 1492     | 2013-04-25 | 119.8008 | 37.4378 | 1654.7486 | 1            |
| 1727            | 1492     | 2014-01-16 | 61.9164  | 19.3489 | 855.2203  | 2            |
| 2517            | 1492     | 2014-04-07 | 61.9164  | 19.3489 | 855.2203  | 2            |
| 3307            | 1492     | 2014-06-13 | 61.9164  | 19.3489 | 855.2203  | 2            |
| 167             | 1492     | 2012-05-30 | 56.8764  | 17.7739 | 785.6053  | 3            |
| 925             | 1496     | 2013-09-17 | 165.5413 | 51.7317 | 2286.5395 | 1            |
| 1325            | 1496     | 2013-12-04 | 165.5413 | 51.7317 | 2286.5395 | 1            |
| 397             | 1496     | 2013-06-25 | 67.1832  | 20.9948 | 927.968   | 2            |
| 1957            | 1496     | 2014-02-11 | 62.1432  | 19.4198 | 858.353   | 3            |
| 3537            | 1496     | 2014-07-02 | 62.1432  | 19.4198 | 858.353   | 3            |
| 2747            | 1496     | 2014-04-25 | 62.1432  | 19.4198 | 858.353   | 3            |

#### Scalar Subqueries
- Subqueries that return a single value
- Useful when comparing values in a result set to a scalar value
	- Using aggregate calculations in the WHERE clause for filtering

``` sql
SELECT
    BusinessEntityID,
    JobTitle,
    VacationHours,
    MaxVacationHours = (SELECT MAX(VacationHours) FROM HumanResources.Employee),
    PercentOfMaxVacationHours = VacationHours * 1.0 / (SELECT MAX(VacationHours) FROM HumanResources.Employee)
FROM HumanResources.Employee
WHERE VacationHours * 1.0 / (SELECT MAX(VacationHours) FROM HumanResources.Employee) >= 0.8;
```

| BusinessEntityID | JobTitle                          | VacationHours | MaxVacationHours | PercentOfMaxVacationHours |
|------------------|-----------------------------------|---------------|------------------|---------------------------|
| 1                | Chief Executive Officer           | 99            | 99               | 1.000                     |
| 27               | Production Supervisor - WC60      | 80            | 99               | 0.808                     |
| 40               | Production Supervisor - WC60      | 82            | 99               | 0.828                     |
| 48               | Production Technician - WC10      | 83            | 99               | 0.838                     |
| 49               | Production Technician - WC10      | 88            | 99               | 0.889                     |
| 121              | Shipping and Receiving Supervisor | 93            | 99               | 0.939                     |
| 122              | Stocker                           | 97            | 99               | 0.980                     |
| 123              | Shipping and Receiving Clerk      | 95            | 99               | 0.960                     |
| 227              | Facilities Manager                | 86            | 99               | 0.869                     |
| 228              | Maintenance Supervisor            | 92            | 99               | 0.929                     |

#### Correlated Subqueries
- Subqueries that run once for each record in the main/outer query
- Return a scalar output for each of those records
- Can be used in either the SELECT or WHERE clause

``` sql
SELECT
    H.PurchaseOrderID,
    H.VendorID,
    H.OrderDate,
    H.TotalDue,
    NonRejectedItems    = (
        SELECT COUNT (*)
        FROM Purchasing.PurchaseOrderDetail AS D
        WHERE D.PurchaseOrderID = H.PurchaseOrderID AND D.RejectedQty = 0
    ),
    MostExpensiveItem   = (
        SELECT MAX (UnitPrice)
        FROM Purchasing.PurchaseOrderDetail AS D
        WHERE D.PurchaseOrderID = H.PurchaseOrderID
    )
FROM Purchasing.PurchaseOrderHeader AS H
```

| PurchaseOrderID | VendorID | OrderDate  | TotalDue   | NonRejectedItems | MostExpensiveItem |
|-----------------|----------|------------|------------|------------------|-------------------|
| 1               | 1580     | 2011-04-16 | 222.1492   | 1                | 50.26             |
| 2               | 1496     | 2011-04-16 | 300.6721   | 2                | 45.5805           |
| 3               | 1494     | 2011-04-16 | 9776.2665  | 1                | 16.086            |
| 4               | 1650     | 2011-04-16 | 189.0395   | 0                | 57.0255           |
| 5               | 1654     | 2011-04-30 | 22539.0165 | 1                | 37.086            |
| 6               | 1664     | 2011-04-30 | 16164.0229 | 1                | 26.5965           |
| 7               | 1678     | 2011-04-30 | 64847.5328 | 3                | 46.0635           |
| 8               | 1616     | 2011-04-30 | 766.1827   | 5                | 49.644            |
| 9               | 1492     | 2011-12-14 | 767.0528   | 5                | 49.6965           |
| 10              | 1602     | 2011-12-14 | 1984.6192  | 3                | 47.4705           |

#### EXISTS and NOT EXISTS Operators in Correlated Subqueries
- Checks if there is matching record (EXISTS) or not (NOT EXISTS)
- Does not add any fields to our result set, simply returns records where the logic is true
- Similar to joins, but better suited when there is a one-to-many relationship
	- When we need to check for a match from a secondary table and we only want to return a single record from the one side

``` sql 
-- EXISTS
SELECT
    H.PurchaseOrderID,
    H.OrderDate,
    H.SubTotal,
    H.TaxAmt
FROM Purchasing.PurchaseOrderHeader AS H
WHERE EXISTS (
    SELECT *
    FROM Purchasing.PurchaseOrderDetail AS D
    WHERE D.PurchaseOrderID = H.PurchaseOrderID AND D.OrderQty > 500 AND D.UnitPrice > 50
)
ORDER BY H.PurchaseOrderID;
```

| PurchaseOrderID | OrderDate  | SubTotal  | TaxAmt   |
|-----------------|------------|-----------|----------|
| 12              | 2011-12-14 | 34644.225 | 2771.538 |
| 23              | 2011-12-15 | 37312.275 | 2984.982 |
| 42              | 2012-01-16 | 34644.225 | 2771.538 |
| 69              | 2012-01-25 | 91117.95  | 7289.436 |

``` sql
-- NOT EXISTS
SELECT
    H.PurchaseOrderID,
    H.OrderDate,
    H.SubTotal,
    H.TaxAmt
FROM Purchasing.PurchaseOrderHeader AS H
WHERE NOT EXISTS (
    SELECT *
    FROM Purchasing.PurchaseOrderDetail AS D
    WHERE D.PurchaseOrderID = H.PurchaseOrderID AND D.RejectedQty > 0
)
ORDER BY H.PurchaseOrderID;

```

| PurchaseOrderID | OrderDate  | SubTotal | TaxAmt   |
|-----------------|------------|----------|----------|
| 1               | 2011-04-16 | 201.04   | 16.0832  |
| 2               | 2011-04-16 | 272.1015 | 21.7681  |
| 3               | 2011-04-16 | 8847.3   | 707.784  |
| 5               | 2011-04-30 | 20397.3  | 1631.784 |

#### PIVOT Operator
- PIVOT flattens the result set
- Generates a column for each unique value in the pivoted column
- We can apply aggregate functions to the values that fall under the pivoted columns
- *Similar to pivot tables in excel*

``` sql
SELECT
    [Employee Gender] = Gender,
    [Sales Representative], 
    [Buyer], 
    [Janitor]
FROM (
    SELECT 
        JobTitle,
        Gender, 
        VacationHours
    FROM HumanResources.Employee
) AS S
PIVOT (
    AVG (VacationHours)
    FOR JobTitle IN ([Sales Representative], [Buyer], [Janitor])
) AS P
ORDER BY [Employee Gender] ASC;
```

| Employee Gender | Sales Representative | Buyer | Janitor |
|-----------------|----------------------|-------|---------|
| F               | 30                   | 54    | 90      |
| M               | 31                   | 56    | 88      |