# SQL Window Functions
Created Date: 2022-06-30

> Metadata 🗃
> - Title: Advanced SQL Server Masterclass
> - Author: Travis Cuzick
> - Reference: Section 2

> Links & Tags 🔗
> - Index: [[Data Science Note Index]]
> - Atomic Tag: #datascience
> - Subatomic Tags: #sql #windowfunctions
> - Related Notes:

___ 
[Adventure Works Database](https://docs.microsoft.com/en-us/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms)

### Notes

#### Window Functions Introduction
- Allow you to use aggregate functions in your query without losing row-level detail
	- Aggregate functions by themselves group rows into a single output (force GROUP BY clause)
- The aggregate column is added to the result set as an additional column
- It's possible to group these calculations using PARTITION
	- Similar to GROUP BY for aggregate queries

#### The OVER Clause
- Determines the partition (or window) and ordering of a result set before a window function is applied
- A window function then performs an aggregation for each row in the window
- Can be used to compute moving averages, cumulative averages, running totals, or a top N per group
- Using the OVER clause without any arguments will apply the window function to the entire result set
- Arguments;
	- PARTITION BY: Divides query result set into partitions
	- ORDER BY: Defines logical order within each partition
	- ROWS/RANGE: Limits rows within the partition by specifying start and end points

``` sql
SELECT
    P.FirstName,
    P.LastName,
    E.JobTitle,
    H.Rate,
    AverageRate         = AVG (H.Rate) OVER (),
    MaximumRate         = MAX (H.Rate) OVER (),
    DiffFromAvgRate     = H.Rate - AVG (H.Rate) OVER (),
    PercentOfMaxRate    = H.Rate / MAX (H.Rate) OVER () * 100
FROM HumanResources.EmployeePayHistory AS H
    INNER JOIN Person.Person AS P
        ON H.BusinessEntityID = P.BusinessEntityID
    INNER JOIN HumanResources.Employee AS E
        ON H.BusinessEntityID = E.BusinessEntityID
```

| FirstName | LastName   | JobTitle                      | Rate    | AverageRate | MaximumRate | DiffFromAvgRate | PercentOfMaxRate |
|-----------|------------|-------------------------------|---------|-------------|-------------|-----------------|------------------|
| Ken       | Sánchez    | Chief Executive Officer       | 125.5   | 17.7588     | 125.5       | 107.7412        | 100              |
| Terri     | Duffy      | Vice President of Engineering | 63.4615 | 17.7588     | 125.5       | 45.7027         | 50.56            |
| Roberto   | Tamburello | Engineering Manager           | 43.2692 | 17.7588     | 125.5       | 25.5104         | 34.47            |
| Rob       | Walters    | Senior Tool Designer          | 8.62    | 17.7588     | 125.5       | -9.1388         | 6.86             |
| Rob       | Walters    | Senior Tool Designer          | 23.72   | 17.7588     | 125.5       | 5.9612          | 18.9             |

#### The PARTITION BY Clause
- Allows us to compute aggregate totals for groups within our data, while still retaining row-level detail
- Assigns each row of your query output to a group, without collapsing data into fewer rows as with GROUP BY
	- Instead of group being assigned based on the distinct values of ALL the non-aggregated columns of our data, we specify the columns these groups will be based on
- Arguments;
	- Columns you wish to group the result set by

``` sql
SELECT
    P.Name AS ProductName,
    C.Name AS ProductCategory,
    S.Name AS ProductSubcategory,
    P.ListPrice,
    AvgPriceByCategory                  =   AVG (P.ListPrice) OVER (PARTITION BY C.Name),
    AvgPriceByCategoryAndSubcategory    =   AVG (P.ListPrice) OVER (PARTITION BY C.Name, S.Name),
    ProductVsCategoryDelta              =   P.ListPrice - AVG (P.ListPrice) OVER (PARTITION BY C.Name)
FROM Production.Product AS P
    INNER JOIN Production.ProductSubcategory AS S
        ON P.ProductSubcategoryID = S.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS C
        ON S.ProductCategoryID = C.ProductCategoryID;
```

| ProductName                  | ProductCategory | ProductSubcategory | ListPrice | AvgPriceByCategory | AvgPriceByCategoryAndSubcategory | ProductVsCategoryDelta |
|------------------------------|-----------------|--------------------|-----------|--------------------|----------------------------------|------------------------|
| Water Bottle - 30 oz.        | Accessories     | Bottles and Cages  | 4.99      | 34.3489            | 7.99                             | -29.3589               |
| Mountain Bottle Cage         | Accessories     | Bottles and Cages  | 9.99      | 34.3489            | 7.99                             | -24.3589               |
| Road Bottle Cage             | Accessories     | Bottles and Cages  | 8.99      | 34.3489            | 7.99                             | -25.3589               |
| Sport-100 Helmet, Red        | Accessories     | Helmets            | 34.99     | 34.3489            | 34.99                            | 0.6411                 |
| Sport-100 Helmet, Black      | Accessories     | Helmets            | 34.99     | 34.3489            | 34.99                            | 0.6411                 |
| Sport-100 Helmet, Blue       | Accessories     | Helmets            | 34.99     | 34.3489            | 34.99                            | 0.6411                 |
| Taillights - Battery-Powered | Accessories     | Lights             | 13.99     | 34.3489            | 31.3233                          | -20.3589               |
| Headlights - Dual-Beam       | Accessories     | Lights             | 34.99     | 34.3489            | 31.3233                          | 0.6411                 |
| Headlights - Weatherproof    | Accessories     | Lights             | 44.99     | 34.3489            | 31.3233                          | 10.6411                |

#### The ROW_NUMBER Clause
- Window functions give us the ability to rank records without our data (across the entire query output or within partitioned)
- Ranks all records in the result set sequentially and ignores ties
- There is no guarantee rows will be ordered exactly the same with each execution unless the following ocnditions are true;
	- Values of the partitioned column are unique
	- Values of the ORDER BY columns are unique
	- Combinations of values of the partition column and ORDER BY columns are unique
- Arguments;
	- PARTITION BY: Divides query result set into partitions
	- ORDER BY: Defines logical order within each partition

``` sql
SELECT
    P.Name AS ProductName,
    C.Name AS ProductCategory,
    S.Name AS ProductSubcategory,
    P.ListPrice,
    PriceRank           =   ROW_NUMBER() OVER (ORDER BY P.ListPrice DESC),
    CategoryPriceRank   =   ROW_NUMBER() OVER (PARTITION BY C.Name ORDER BY P.ListPrice DESC),
    Top5PriceInCategory =   CASE
                                WHEN ROW_NUMBER() OVER (PARTITION BY C.Name ORDER BY P.ListPrice DESC) <= 5 THEN 'YES'
                                ELSE 'NO'
                            END
FROM Production.Product AS P
    INNER JOIN Production.ProductSubcategory AS S
        ON P.ProductSubcategoryID = S.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS C
        ON S.ProductCategoryID = C.ProductCategoryID;
```

| ProductName               | ProductCategory | ProductSubcategory | ListPrice | PriceRank | CategoryPriceRank | Top5PriceInCategory |
|---------------------------|-----------------|--------------------|-----------|-----------|-------------------|---------------------|
| All-Purpose Bike Stand    | Accessories     | Bike Stands        | 159       | 192       | 1                 | YES                 |
| Touring-Panniers, Large   | Accessories     | Panniers           | 125       | 194       | 2                 | YES                 |
| Hitch Rack - 4-Bike       | Accessories     | Bike Racks         | 120       | 200       | 3                 | YES                 |
| Hydration Pack - 70 oz.   | Accessories     | Hydration Packs    | 54.99     | 234       | 4                 | YES                 |
| Headlights - Weatherproof | Accessories     | Lights             | 44.99     | 248       | 5                 | YES                 |
| HL Mountain Tire          | Accessories     | Tires and Tubes    | 35        | 259       | 6                 | NO                  |
| Headlights - Dual-Beam    | Accessories     | Lights             | 34.99     | 260       | 7                 | NO                  |
| Sport-100 Helmet, Blue    | Accessories     | Helmets            | 34.99     | 261       | 8                 | NO                  |
| Sport-100 Helmet, Red     | Accessories     | Helmets            | 34.99     | 262       | 9                 | NO                  |
| Sport-100 Helmet, Black   | Accessories     | Helmets            | 34.99     | 263       | 10                | NO                  |

#### The RANK and DENSE_RANK Clause
- Return the rank of each row within the partition of a result set
	- Similar to ROW_NUMBER but differs in how ties are handled
- RANK provides the same numeric value for ties but maintains the overall rank order (example: 1, 2, 2, 4, 5)
- DENSE_RANK eliminates gaps in the ranking values (example: 1, 2, 3, 4, 5)
	- The rank of a specific row is one plus the number of distinct rank values that come before the specific row
- Arguments;
	- PARTITION BY: Divides query result set into partitions
	- ORDER BY: Defines logical order within each partition

``` sql
SELECT
    P.Name AS ProductName,
    C.Name AS ProductCategory,
    S.Name AS ProductSubcategory,
    P.ListPrice,
    PriceRank                           =   ROW_NUMBER() OVER (ORDER BY P.ListPrice DESC),
    CategoryPriceRankWithRowNum         =   ROW_NUMBER() OVER (PARTITION BY C.Name ORDER BY P.ListPrice DESC),
    CategoryPriceRankWithRank           =   RANK() OVER (PARTITION BY C.Name ORDER BY P.ListPrice DESC),
    CategoryPriceRankWithDenseRank      =   DENSE_RANK() OVER (PARTITION BY C.Name ORDER BY P.ListPrice DESC),
    Top5PriceInCategoryWithDenseRank    =   CASE
                                                WHEN DENSE_RANK() OVER (PARTITION BY C.Name ORDER BY P.ListPrice DESC) <= 5 THEN 'YES'
                                                ELSE 'NO'
                                            END   
FROM Production.Product AS P
    INNER JOIN Production.ProductSubcategory AS S
        ON P.ProductSubcategoryID = S.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS C
        ON S.ProductCategoryID = C.ProductCategoryID;
```

| ProductName               | ProductCategory | ProductSubcategory | ListPrice | PriceRank | CategoryPriceRankWithRowNum | CategoryPriceRankWithRank | CategoryPriceRankWithDenseRank | Top5PriceInCategoryWithDenseRank |
|---------------------------|-----------------|--------------------|-----------|-----------|-----------------------------|---------------------------|--------------------------------|----------------------------------|
| All-Purpose Bike Stand    | Accessories     | Bike Stands        | 159       | 192       | 1                           | 1                         | 1                              | YES                              |
| Touring-Panniers, Large   | Accessories     | Panniers           | 125       | 194       | 2                           | 2                         | 2                              | YES                              |
| Hitch Rack - 4-Bike       | Accessories     | Bike Racks         | 120       | 200       | 3                           | 3                         | 3                              | YES                              |
| Hydration Pack - 70 oz.   | Accessories     | Hydration Packs    | 54.99     | 234       | 4                           | 4                         | 4                              | YES                              |
| Headlights - Weatherproof | Accessories     | Lights             | 44.99     | 248       | 5                           | 5                         | 5                              | YES                              |
| HL Mountain Tire          | Accessories     | Tires and Tubes    | 35        | 259       | 6                           | 6                         | 6                              | NO                               |
| Headlights - Dual-Beam    | Accessories     | Lights             | 34.99     | 260       | 7                           | 7                         | 7                              | NO                               |
| Sport-100 Helmet, Blue    | Accessories     | Helmets            | 34.99     | 261       | 8                           | 7                         | 7                              | NO                               |
| Sport-100 Helmet, Red     | Accessories     | Helmets            | 34.99     | 262       | 9                           | 7                         | 7                              | NO                               |
| Sport-100 Helmet, Black   | Accessories     | Helmets            | 34.99     | 263       | 10                          | 7                         | 7                              | NO                               |


#### The LEAD and LAG Clause
- LEAD allows us to grab values from subsequent records relative to the position of the "current" record in our data
- LAG allows us to grab values from previous records relative to the position of the "current" record in our data
- These are useful when we want to compare current values to subsequent or previous values for analysis
- Arguments;
	- Scalar Expression: Value to be returned based on the specified offset
	- Offset: The number of rows or forward or backwards from which to obtain a value

``` sql
SELECT
    H.OrderDate,  
    H.PurchaseOrderID,
    V.Name AS VendorName,
    H.TotalDue,
    PrevOrderFromVendorAmt  =   LAG (H.TotalDue, 1) OVER (PARTITION BY H.VendorID ORDER BY H.OrderDate ASC),
    NextOrderFromVendorAmt  =   LEAD (H.TotalDue, 1) OVER (PARTITION BY H.VendorID ORDER BY H.OrderDate ASC),
    Next2OrderFromVendorAmt  =  LEAD (H.TotalDue, 2) OVER (PARTITION BY H.VendorID ORDER BY H.OrderDate ASC)
FROM Purchasing.PurchaseOrderHeader AS H
    INNER JOIN Purchasing.Vendor AS V
        ON H.VendorID = V.BusinessEntityID
WHERE YEAR (H.OrderDate) >= 2013 AND H.TotalDue > 500
ORDER BY H.VendorID, H.OrderDate;
```

| OrderDate  | PurchaseOrderID | VendorName              | TotalDue  | PrevOrderFromVendorAmt | NextOrderFromVendorAmt | Next2OrderFromVendorAmt |
|------------|-----------------|-------------------------|-----------|------------------------|------------------------|-------------------------|
| 2013-04-25 | 325             | Australia Bike Retailer | 1654.7486 | NULL                   | 553.8221               | 767.0528                |
| 2013-08-18 | 596             | Australia Bike Retailer | 553.8221  | 1654.7486              | 767.0528               | 553.8221                |
| 2013-09-08 | 849             | Australia Bike Retailer | 767.0528  | 553.8221               | 553.8221               | 655.9126                |
| 2013-10-13 | 1031            | Australia Bike Retailer | 553.8221  | 767.0528               | 655.9126               | 553.8221                |
| 2013-11-06 | 1095            | Australia Bike Retailer | 655.9126  | 553.8221               | 553.8221               | 767.0528                |
| 2013-12-12 | 1411            | Australia Bike Retailer | 553.8221  | 655.9126               | 767.0528               | 855.2203                |
| 2014-01-06 | 1648            | Australia Bike Retailer | 767.0528  | 553.8221               | 855.2203               | 533.1813                |
| 2014-01-16 | 1727            | Australia Bike Retailer | 855.2203  | 767.0528               | 533.1813               | 553.8221                |
| 2014-01-24 | 1806            | Australia Bike Retailer | 533.1813  | 855.2203               | 553.8221               | 767.0528                |
| 2014-03-05 | 2201            | Australia Bike Retailer | 553.8221  | 533.1813               | 767.0528               | 855.2203                |