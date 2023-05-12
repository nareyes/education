-- Examine Data Types
-- Escape Single Quotes in Query
EXEC sp_describe_first_result_set N'
    SELECT
        TOP 100 *
    FROM
        OPENROWSET(
            BULK ''https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv'',
            FORMAT = ''CSV'',
            PARSER_VERSION = ''2.0'',
            HEADER_ROW = TRUE
        ) AS TaxiZone
'


-- Determine Actual Max Length per Column
SELECT
    MAX(LEN(LocationID)) AS Len_LocationID
    ,MAX(LEN(Borough)) AS Len_Borough
    ,MAX(LEN(Zone)) AS Len_Zone
    ,MAX(LEN(service_zone)) AS Len_Service_Zone
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TaxiZone


/*
- Adjusting data types and sizes has cost and permofrmance implications.
- Synapse is generous with its data type and size assignment.
- It is a best practice to adjust sizes when running queries in Serverless to minimize cost.
*/


-- Use WITH to Provide Explicit Data Types
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


-- Confirm Explicit Data Types
EXEC sp_describe_first_result_set N'
    SELECT
        TOP 100 *
    FROM
        OPENROWSET(
            BULK ''https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv'',
            FORMAT = ''CSV'',
            PARSER_VERSION = ''2.0'',
            HEADER_ROW = TRUE
        )
        WITH(
            LocationID      SMALLINT
            ,Borough        VARCHAR(15)
            ,Zone           VARCHAR(50)
            ,service_zone   VARCHAR(15)
        ) AS TaxiZone
'