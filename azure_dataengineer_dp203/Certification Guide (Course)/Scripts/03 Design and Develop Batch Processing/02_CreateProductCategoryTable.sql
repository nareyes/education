CREATE TABLE dbo.ProductCategory (
	ProductCategoryID INT NOT NULL
	, ParentProductCategoryID INT NULL
	, Name VARCHAR(100) NOT NULL

    , CONSTRAINT PK_ProductCategory_ProductCategoryID PRIMARY KEY CLUSTERED (ProductCategoryID)
)
GO