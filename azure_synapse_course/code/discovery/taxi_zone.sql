USE NYC_Taxi_Serverless
GO


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