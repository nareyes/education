-- Examine Database Collation
SELECT
    name
    ,collation_name
FROM sys.databases;


-- Apply Collation to a Query
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) 
    WITH(
        LocationID      SMALLINT
        ,Borough        VARCHAR(15) COLLATE Latin1_General_100_CI_AI_SC_UTF8
        ,Zone           VARCHAR(50) COLLATE Latin1_General_100_CI_AI_SC_UTF8
        ,service_zone   VARCHAR(15) COLLATE Latin1_General_100_CI_AI_SC_UTF8
    ) AS TaxiZone


-- Apply Collation to a Database
-- Not Applicable to Master Database
USE NYC_Taxi_Serverless;
ALTER DATABASE NYC_Taxi_Serverless COLLATE Latin1_General_100_CI_AI_SC_UTF8;


-- Confirm Collation Change
SELECT
    name
    ,collation_name
FROM sys.databases;


-- Query Will Now Run w/o Collation Warnings
-- Must Be Using Appropriate Database
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) 
    WITH(
        LocationID      SMALLINT
        ,Borough        VARCHAR(15)
        ,Zone           VARCHAR(50)
        ,service_zone   VARCHAR(15)
    ) AS TaxiZone