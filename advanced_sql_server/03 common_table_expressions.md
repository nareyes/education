# SQL CTEs
Created Date: 2022-07-11

> Metadata 🗃
> - Title: Advanced SQL Server Masterclass
> - Author: Travis Cuzick
> - Reference: Section 4

> Links & Tags 🔗
> - Index: [[Data Science Note Index]]
> - Atomic Tag: #datascience
> - Subatomic Tags: #sql #cte
> - Related Notes:

___ 
[Adventure Works Database](https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

### Notes

#### CTEs Introduction
- Common Table Expression
- CTEs allow us to write multi-stage queries in a linear, easy to read format
- Specifies temporary result set(s) that can be referenced by the final query in the CTE
	- Temporary tables that can only be referenced within the full CTE query
- All CTEs begin with a WITH statement, followed with temporary table(s) and a final query that references the temporary tables for a final output

``` sql
WITH
Sales AS (
    SELECT
        OrderDate,
        OrderMonth  =   DATEFROMPARTS (YEAR (OrderDate), MONTH (OrderDate), 1),
        TotalDue,
        OrderRank   =   ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS (YEAR (OrderDate), MONTH (OrderDate), 1) ORDER BY TotalDue DESC)
    FROM Sales.SalesOrderHeader
),

AvgSalesMinusTop10 AS (
    SELECT
        OrderMonth,
        TotalSales  =   SUM (TotalDue)
    FROM Sales
    WHERE OrderRank > 10
    GROUP BY OrderMonth
),

Purchases AS (
    SELECT
        OrderDate,
        OrderMonth  =   DATEFROMPARTS (YEAR (OrderDate), MONTH (OrderDate), 1),
        TotalDue,
        OrderRank   =   ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS (YEAR (OrderDate), MONTH (OrderDate), 1) ORDER BY TotalDue DESC)
    FROM Purchasing.PurchaseOrderHeader
),

AvgPurchasesMinusTop10 AS (
    SELECT
        OrderMonth,
        TotalPurchases  =   SUM (TotalDue)
    FROM Purchases
    WHERE OrderRank > 10
    GROUP BY OrderMonth
)

SELECT
    S.OrderMonth,
    S.TotalSales,
    P.TotalPurchases
FROM AvgSalesMinusTop10 AS S
    INNER JOIN AvgPurchasesMinusTop10 AS P
        ON S.OrderMonth = P.OrderMonth
ORDER BY OrderMonth ASC
```

| OrderMonth | TotalSales  | TotalPurchases |
|------------|-------------|----------------|
| 12/1/2011  | 1019635.675 | 7254.3006      |
| 1/1/2012   | 3622013.922 | 220767.0679    |
| 2/1/2012   | 1141791.612 | 7610.834       |
| 3/1/2012   | 2441839.153 | 218226.7469    |
| 4/1/2012   | 1341386.294 | 2496.2083      |

