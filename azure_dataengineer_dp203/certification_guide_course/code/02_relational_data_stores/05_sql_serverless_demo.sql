-- Create Database
CREATE DATABASE DemoDB


-- Create Master Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'INSERT PASSWORD'


-- Create Credentials for Containers in Demo Storage Account
CREATE DATABASE SCOPED CREDENTIAL SQLOnDemand
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',  
SECRET = 'INSERT SECRET'
GO


-- Create Data Source
CREATE EXTERNAL DATA SOURCE SQLOnDemandDemo WITH (
    LOCATION = 'https://SQLOnDemandstorage.blob.core.windows.net'
    , CREDENTIAL = SQLOnDemand
);


-- Query CSV Files
SELECT TOP 10 *
FROM OPENROWSET (
      BULK 'csv/population/*.csv'
      , DATA_SOURCE = 'SQLOnDemandDemo'
      , FORMAT = 'CSV'
      , PARSER_VERSION = '2.0'
)

WITH (
    [Country_Code]  VARCHAR (5)
  , [Country_Name]  VARCHAR (100)
  , [Year]          SMALLINT
  , [Population]    BIGINT
) AS R

WHERE
  Country_Name = 'Luxembourg' 
  AND [Year] = 2017;


-- Query Parquet Files
SELECT COUNT_BIG(*)
FROM OPENROWSET (
      BULK 'parquet/taxi/year=2017/month=9/*.parquet'
      , DATA_SOURCE = 'SQLOnDemandDemo'
      , FORMAT = 'PARQUET'
) AS NYC;


-- Query JSON Files
SELECT TOP 10 
    JSON_VALUE(jsonContent, '$.title') AS Titles
  , JSON_VALUE(jsonContent, '$.publisher') as Publisher
  , jsonContent
FROM OPENROWSET (
      BULK 'json/books/*.json'
    , DATA_SOURCE = 'SQLOnDemandDemo'
    , FORMAT = 'CSV'
    , FIELDTERMINATOR = '0x0b'
    , FIELDQUOTE = '0x0b'
    , ROWTERMINATOR = '0x0b'
)

WITH (
  jsonContent VARCHAR(8000)
) AS R

WHERE
  JSON_VALUE(jsonContent, '$.title') = 'Probabilistic and Statistical Methods in Cryptology, An Introduction by Selected Topics';