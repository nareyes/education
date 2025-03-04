CREATE TABLE dbo.Product (
	ProductID INT NOT NULL
	, Name VARCHAR(100) NOT NULL
	, ProductNumber NVARCHAR(25) NOT NULL
	, Color NVARCHAR(15) NULL
	, StandardCost VARCHAR(100) NOT NULL
	, ListPrice VARCHAR(100) NOT NULL
	, Size NVARCHAR(5) NULL
	, Weight VARCHAR(100) NULL
	, ProductCategoryID VARCHAR(100) NULL
	, ProductModelID VARCHAR(100) NULL
	, SellStartDate VARCHAR(100) NOT NULL
	, SellEndDate VARCHAR(100) NULL
	, ModifiedDate VARCHAR(100) NOT NULL

    , CONSTRAINT PK_Product_ProductID PRIMARY KEY CLUSTERED (ProductID)
)
GO

CREATE TABLE dbo.ProductCategory (
	ProductCategoryID INT NOT NULL
	, ParentProductCategoryID INT NULL
	, Name VARCHAR(100) NOT NULL

    , CONSTRAINT PK_ProductCategory_ProductCategoryID PRIMARY KEY CLUSTERED (ProductCategoryID)
)
GO