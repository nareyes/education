/*
PolyBase 6 steps Process
1. CREATE MASTER KEY
2. CREATE DATABASE SCOPED CREDENTIAL
3. CREATE EXTERNAL DATA SOURCE
4. CREATE EXTERNAL FILE FORMAT 
5. CREATE EXTERNAL TABLE
6. CREATE TABLE AS 
*/


USE <ENTER DATABASE>
GO

/*
1. Create a Database Master Key. Only necessary if one does not already exist.
	Required to encrypt the credential secret in the next step.
	To access your Data Lake Storage account, you will need to create a Database Master Key to encrypt your credential secret. 
	You then create a Database Scoped Credential to store your secret. 
	When authenticating using service principals (Azure Directory Application user), 
	the Database Scoped Credential stores the service principal credentials set up in AAD. 
	You can also use the Database Scoped Credential to store the storage account key for Blob storage.
*/
DROP MASTER KEY;
CREATE MASTER KEY;
GO


/*
2.For blob storage key authentication: Create a database scoped credential
	IDENTITY: Provide any string, it is not used for authentication to Azure storage.
	SECRET: Provide your Azure storage account key.
*/
DROP DATABASE SCOPED CREDENTIAL BlobStorageCredential;
CREATE DATABASE SCOPED CREDENTIAL BlobStorageCredential
WITH
    IDENTITY = 'blobuser',  
	SECRET = 'ENTER KEY';
GO


/*
3. For blob: Create an external data source
	TYPE: HADOOP - PolyBase uses Hadoop APIs to access data in Azure Data Lake Storage.
	LOCATION: Provide Data Lake Storage blob account name and URI
	CREDENTIAL: Provide the credential created in the previous step.
*/
DROP EXTERNAL DATA SOURCE AzureBlobStorage;
CREATE EXTERNAL DATA SOURCE AzureBlobStorage
WITH (
    TYPE = HADOOP
    , LOCATION = 'ENTER LOCATION'
    , CREDENTIAL = BlobStorageCredential
);
GO


/*
4: Create an external file format
	FIELD_TERMINATOR: Marks the end of each field (column) in a delimited text file
	STRING_DELIMITER: Specifies the field terminator for data of type string in the text-delimited file.
	DATE_FORMAT: Specifies a custom format for all date and time data that might appear in a delimited text file.
	USE_TYPE_DEFAULT: Store missing values as default for datatype.
*/
DROP EXTERNAL FILE FORMAT CSVFileFormat;
CREATE EXTERNAL FILE FORMAT CSVFileFormat 
WITH (
	FORMAT_TYPE = DELIMITEDTEXT
	, FORMAT_OPTIONS (
		FIELD_TERMINATOR = ','
        , STRING_DELIMITER = ''
        , DATE_FORMAT      = 'yyyy-MM-dd HH:mm:ss'
        , USE_TYPE_DEFAULT = FALSE 
    )
);
GO


/*
5: Create an External Table
	LOCATION: Folder under the Data Lake Storage root folder.
	DATA_SOURCE: Specifies which Data Source Object to use.
	FILE_FORMAT: Specifies which File Format Object to use
	REJECT_TYPE: Specifies how you want to deal with rejected rows. Either Value or percentage of the total
	REJECT_VALUE: Sets the Reject value based on the reject type.
*/

/* IMP NOTE
External Tables are strongly typed. 
This means that each row of the data being ingested must satisfy the table schema definition. 
If a row does not match the schema definition, the row is rejected from the load.
*/
DROP SCHEMA [stage]
GO
CREATE SCHEMA [stage]
GO

DROP EXTERNAL TABLE [stage].FactTransactionHistory ;
CREATE EXTERNAL TABLE [stage].FactTransactionHistory (
    TransactionID	INT NOT NULL
	, ProductKey	INT NOT NULL
	, OrderDate		DATETIME NULL
	, Quantity		INT NULL
	, ActualCost	MONEY NULL
)

WITH (
	LOCATION = 'ENTER FILE PATH' 
	, DATA_SOURCE = AzureBlobStorage
	, FILE_FORMAT = CSVFileFormat
	, REJECT_TYPE = VALUE
	, REJECT_VALUE = 0 -- Entire load will fail if there is more than 0 errors
)
GO

DROP EXTERNAL TABLE [stage].DimBigProduct ;
CREATE EXTERNAL TABLE [stage].DimBigProduct (
	[ProductKey] 				INT NOT NULL
	, [EnglishProductName] 		NVARCHAR(80) NULL
	, [ProductAlternateKey] 	NVARCHAR(56) NULL
	, [FinishedGoodsFlag] 		NVARCHAR(60) NOT NULL
	, [Color] 					NVARCHAR(15) NOT NULL
	, [SafetyStockLevel] 		SMALLINT NULL
	, [ReorderPoINT] 			SMALLINT NULL
	, [StandardCost] 			MONEY NULL
	, [ListPrice] 				MONEY NULL
	, [Size] 					NVARCHAR(50) NULL
	, [SizeUnitMeasureCode] 	NCHAR(3) NULL
	, [WeightUnitMeasureCode]	NCHAR(3) NULL
	, [Weight] 					FLOAT NULL
	, [DaysToManufacture] 		INT NULL
	, [ProductLine] 			NCHAR(2) NULL
	, [Class] 					NCHAR(2) NULL
	, [Style] 					NCHAR(2) NULL
	, [ProductSubcategoryKey] 	INT NULL
	, [ModelName] 				NVARCHAR(50) NULL
	, [StartDate] 				DATETIME NULL
	, [EndDate] 				DATETIME NULL
)

WITH (
	LOCATION = 'ENTER FILE PATH' 
	, DATA_SOURCE = AzureBlobStorage
	, FILE_FORMAT = CSVFileFormat
	, REJECT_TYPE = VALUE
	, REJECT_VALUE = 0 -- Entire load will fail if there is more than 0 errors
)
GO


/* 
6 CREATE TABLE AS  - CTAS and Load Data
	CTAS creates a new table and populates it with the results of a select statement. 
	CTAS defines the new table to have the same columns and data types as the results of the select statement. 
	If you select all the columns from an external table, the new table is a replica of the columns and data types in the external table.
*/
DROP SCHEMA [prod]
GO
CREATE SCHEMA [prod]
GO

-- DROP TABLE [prod].[FactTransactionHistory];
CREATE TABLE [prod].[FactTransactionHistory]       
WITH (
	DISTRIBUTION = HASH(ProductKey) 
) 

AS 
SELECT * FROM [stage].[FactTransactionHistory]        
OPTION (
	LABEL = 'Load [prod].[FactTransactionHistory1]'
);

CREATE TABLE [prod].[DimBigProduct]       
WITH (
	DISTRIBUTION = ROUND_ROBIN
) 

AS 
SELECT * FROM [stage].[BigDimProduct]        
OPTION (
	LABEL = 'Load [prod].[BigDimProduct]'
);

ALTER TABLE prod.DimBigProduct
ADD CONSTRAINT PK_DimBigProduct PRIMARY KEY (ProductKey)
GO


-- Verify number of rows
SELECT COUNT (*) FROM [prod].[FactTransactionHistory];
SELECT COUNT (*) FROM [prod].[DimBigProduct];


/*
By default, tables are defined as a clustered columnstore index. 
After a load completes, some of the data rows might not be compressed into the columnstore. 
To optimize query performance and columnstore compression after a load, rebuild the table to force the columnstore index to compress all the rows.
*/
ALTER INDEX ALL ON [prod].[FactTransactionHistory_Lake] REBUILD;


-- Verify the data was loaded into the 60 distributions
-- Verify distribution sizes are not skewed
DBCC PDW_SHOWSPACEUSED('prod.FactTransactionHistory');
DBCC PDW_SHOWSPACEUSED('prod.DimBigProduct');