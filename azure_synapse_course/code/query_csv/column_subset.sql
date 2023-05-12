USE NYC_Taxi_Serverless
GO

-- Select Subset of Columns (CSV w/ Headers)
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
        Borough VARCHAR(15)  
        ,Zone    VARCHAR(50) 
    ) AS TaxiZone


-- Select Subset of Columns (CSV w/o Headers)
-- Specify Column Ordinal Position in WITH Clause
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone_without_header.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0'
    )
    WITH(
        Borough VARCHAR(15)  2
        ,Zone   VARCHAR(50)  3
    ) AS TaxiZone


-- Renaming Columns
-- Specify Column Ordinal Position in WITH Clause
-- Synapse Ignores Header Column (Explicit: Use FIRSTROW Instead)
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        -- HEADER_ROW = TRUE
        FIRSTROW = 2
    ) 
    WITH(
        LocationID      SMALLINT    
        ,Borough        VARCHAR(15) 
        ,Zone           VARCHAR(50) 
        ,ServiceZone    VARCHAR(15) 4
    ) AS TaxiZone

SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        -- HEADER_ROW = TRUE
        FIRSTROW = 2
    ) 
    WITH(
        location_id     SMALLINT    1
        ,borough        VARCHAR(15) 2
        ,zone           VARCHAR(50) 3   
        ,service_zone   VARCHAR(15) 4
    ) AS TaxiZone