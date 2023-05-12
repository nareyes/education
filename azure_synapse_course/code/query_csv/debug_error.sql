USE NYC_Taxi_Serverless
GO

-- Generate Error
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
        ,Zone           VARCHAR(5) -- Incorrect Data Size
        ,ServiceZone    VARCHAR(15)
    ) AS TaxiZone


-- Update Parser Version (Returns Explicit Error)
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '1.0', -- Changed From 2.0
        -- HEADER_ROW = TRUE
        FIRSTROW = 2
    ) 
    WITH(
        LocationID      SMALLINT    
        ,Borough        VARCHAR(15) 
        ,Zone           VARCHAR(5) -- Incorrect Data Size
        ,ServiceZone    VARCHAR(15)
    ) AS TaxiZone