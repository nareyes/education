/* 
Analysis to decide which distribution method and key will be best for our use-case.
Use-case is to load DimBigProduct and FactTransactionHistory into Azure
These are larger tables which is better sutied for PolyBase
 */


USE Adventure_Works_DW
GO


-- Analyze Counts
SELECT COUNT (*) FROM dbo.DimBigProduct AS CountBigProduct; -- 30,300 Records
SELECT COUNT (*) FROM dbo.FactTransactionHistory AS CountTransactionHistory; -- 37,605,696 Records


-- Round Robin (Even distributions among 60 distributions +/- 1)
SELECT 
    CP.[Distribution] + 1
    , COUNT (*) AS DistributionRecords
FROM (
    SELECT ROW_NUMBER () OVER (ORDER BY (SELECT NULL)) AS RowNum 
    FROM dbo.FactTransactionHistory
) AS SUBQ
    CROSS APPLY (
        SELECT RowNum % 60 [Distribution]
    ) AS CP
GROUP BY [Distribution]
ORDER BY [Distribution];


-- Explore Hash Key Candidates
-- TransactionID is likely unique and not a good canditate
-- ProductKey is a good canditate
-- Quantity and ActualCost would not be good canditates
-- OrderDate could be a good hask key but not a join key (not the best canditate)
SELECT
    CS.Name 
    , TT.Name
FROM SYS.Columns AS CS 
    INNER JOIN SYS.Types AS TT 
        ON CS.SYStem_Type_ID = Tt.SYStem_Type_ID 
WHERE Object_ID = OBJECT_ID ('FactTransactionHistory');


-- Analyze Distinct Column Counts (confirms ProductKey is the best option for a hash key)
-- Hash Keys should have more than 60 distinct values so no distribution is left empty
SELECT
    COUNT (DISTINCT TransactionID) AS CountTransactionID
    , COUNT (DISTINCT ProductKey) AS CountProductKey
    , COUNT (DISTINCT Quantity) AS CountQuantity
    , COUNT (DISTINCT ActualCost) AS CountActualCost
    , COUNT (DISTINCT OrderDate) AS CountOrderDate
FROM dbo.FactTransactionHistory


-- Group by ProductKey and assign to 60 distributions to analyze distribution counts
-- No distribution is left empty and none are heavily skewed
SELECT
    CP.[Distribution] + 1
    , SUM (RecordCount) AS DistributionRecords
FROM (
    SELECT 
        DENSE_RANK() OVER (ORDER BY ProductKey) AS RowNum
        , COUNT (*) AS RecordCount
    FROM dbo.FactTransactionHistory
    GROUP BY ProductKey
) AS SUBQ
    CROSS APPLY (
        SELECT RowNum % 60 [Distribution]
        ) AS CP
GROUP BY [Distribution]
ORDER BY [Distribution];


-- Distribution is not everything, you have to think about the query patterns as well
-- Analyze which tables contain the ProductKey column as this will likely be a join key
SELECT OBJECT_NAME(Object_ID) AS TableName
FROM SYS.Columns
WHERE Name = 'ProductKey';


-- Analyzing data types for unecessary unicode types
SELECT
    OBJECT_NAME(Object_ID) AS TableName
    , CS.Name AS ColumnName
FROM SYS.Columns AS CS 
    INNER JOIN SYS.Types AS TS
        ON CS.System_Type_ID = TS.System_Type_ID
WHERE
    TS.Name IN ('NVARCHAR', 'NCHAR')
    AND (OBJECT_NAME (Object_ID) LIKE 'Dim%' OR OBJECT_NAME (Object_ID) LIKE 'Fact%');


-- Since English columns don't require UNICDE we should change it to VARCHAR to safe space
ALTER TABLE dbo.DimBigProduct
ALTER COLUMN EnglishProductName VARCHAR (80);