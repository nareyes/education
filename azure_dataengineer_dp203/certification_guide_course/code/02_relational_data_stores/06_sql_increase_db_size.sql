/*
This script creates two new tables in AdventureWorks:
dbo.DimBigProduct
dbo.FactTransactionHistory

Export these tables to text files and upload in Azure Storage or ADLS Gen2 for PolyBase exercise.
*/


USE Adventure_Works_DW
GO


SELECT
	P.ProductKey + (A.Number * 1000) AS ProductKey
	, P.EnglishProductName + CONVERT(VARCHAR, (A.Number * 1000)) AS EnglishProductName
	, P.ProductAlternateKey + '-' + CONVERT(VARCHAR, (A.Number * 1000)) AS ProductAlternateKey
	, P.FinishedGoodsFlag
	, P.Color
	, P.SafetyStockLevel
	, P.ReorderPoint
	, P.StandardCost
	, P.ListPrice
	, P.Size
	, P.SizeUnitMeasureCode
	, P.WeightUnitMeasureCode
	, P.Weight
	, P.DaysToManufacture
	, P.ProductLine
	, P.Class
	, P.Style
	, P.ProductSubcategoryKey
	, P.ModelName
	, P.StartDate
	, P.EndDate
INTO dbo.DimBigProduct
FROM dbo.DimProduct AS P
	CROSS JOIN Master..SPT_Values AS A
		WHERE
			A.Type = 'p'
			AND A.Number BETWEEN 1 AND 50
GO


ALTER TABLE dbo.DimBigProduct
ALTER COLUMN ProductKey INT NOT NULL	
GO


ALTER TABLE dbo.DimBigProduct
ADD CONSTRAINT PK_DimBigProduct PRIMARY KEY (ProductKey)
GO


SELECT 
	ROW_NUMBER() OVER (ORDER BY X.TransactionDate, (SELECT NEWID())) AS TransactionID
	, P1.ProductKey
	, X.TransactionDate AS OrderDate
	, X.Quantity
	, CONVERT (MONEY, P1.ListPrice * X.Quantity * RAND(CHECKSUM(NEWID())) * 2) AS ActualCost
INTO dbo.FactTransactionHistory
FROM (
	SELECT
		P.ProductKey, 
		P.ListPrice,
		CASE
			WHEN P.ProductKey % 26 = 0 THEN 26
			WHEN P.ProductKey % 25 = 0 THEN 25
			WHEN P.ProductKey % 24 = 0 THEN 24
			WHEN P.ProductKey % 23 = 0 THEN 23
			WHEN P.ProductKey % 22 = 0 THEN 22
			WHEN P.ProductKey % 21 = 0 THEN 21
			WHEN P.ProductKey % 20 = 0 THEN 20
			WHEN P.ProductKey % 19 = 0 THEN 19
			WHEN P.ProductKey % 18 = 0 THEN 18
			WHEN P.ProductKey % 17 = 0 THEN 17
			WHEN P.ProductKey % 16 = 0 THEN 16
			WHEN P.ProductKey % 15 = 0 THEN 15
			WHEN P.ProductKey % 14 = 0 THEN 14
			WHEN P.ProductKey % 13 = 0 THEN 13
			WHEN P.ProductKey % 12 = 0 THEN 12
			WHEN P.ProductKey % 11 = 0 THEN 11
			WHEN P.ProductKey % 10 = 0 THEN 10
			WHEN P.ProductKey % 9 = 0 THEN 9
			WHEN P.ProductKey % 8 = 0 THEN 8
			WHEN P.ProductKey % 7 = 0 THEN 7
			WHEN P.ProductKey % 6 = 0 THEN 6
			WHEN P.ProductKey % 5 = 0 THEN 5
			WHEN P.ProductKey % 4 = 0 THEN 4
			WHEN P.ProductKey % 3 = 0 THEN 3
			WHEN P.ProductKey % 2 = 0 THEN 2
			ELSE 1 
		END AS ProductGroup
	FROM dbo.DimBigProduct AS P
) AS P1

CROSS APPLY (
	SELECT
		TransactionDate
		, CONVERT(INT, (RAND(CHECKSUM(NEWID())) * 100) + 1) AS Quantity
	FROM (
		SELECT 
			DATEADD(dd, Number, '20130101') AS TransactionDate
			, NTILE(P1.ProductGroup) OVER (ORDER BY Number) AS GroupRange
		FROM Master..SPT_Values
		WHERE Type = 'p'
	) AS Z
	WHERE Z.GroupRange % 2 = 1
) AS X


ALTER TABLE dbo.FactTransactionHistory
ALTER COLUMN TransactionID INT NOT NULL
GO


ALTER TABLE dbo.FactTransactionHistory
ADD CONSTRAINT PK_FactTransactionHistory PRIMARY KEY (TransactionID)
GO


CREATE NONCLUSTERED INDEX IX_ProductId_TransactionDate
ON dbo.FactTransactionHistory (
	ProductKey
	, OrderDate
)
INCLUDE (
	Quantity
	, ActualCost
)
GO


-- Analyze Counts
SELECT COUNT (*) FROM dbo.DimBigProduct AS CountBigProduct; -- 30,300 Records
SELECT COUNT (*) FROM dbo.FactTransactionHistory AS CountTransactionHistory; -- 37,605,696 Records