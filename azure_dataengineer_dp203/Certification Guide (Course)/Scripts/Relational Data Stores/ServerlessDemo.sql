-- Create Database
CREATE DATABASE DemoDB


-- Create Master Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'sknfd#isfnasdkf!bsk1'


-- Create Credentials for Containers in Demo Storage Account
CREATE DATABASE SCOPED CREDENTIAL SQLOnDemand
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',  
SECRET = 'sv=2018-03-28&ss=bf&srt=sco&sp=rl&st=2019-10-14T12%3A10%3A25Z&se=2061-12-31T12%3A10%3A00Z&sig=KlSU2ullCscyTS0An0nozEpo4tO5JAgGBvw%2FJX2lguw%3D'
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
      [Country_Code] VARCHAR (5)
    , [Country_Name] VARCHAR (100)
    , [Year] smallint
    , [Population] bigint
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