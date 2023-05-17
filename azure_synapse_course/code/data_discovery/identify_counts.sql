USE NYC_Taxi_Serverless
GO


-- Explore
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIRSTROW = 2
    ) 
    WITH(
        location_id     SMALLINT    1
        ,borough        VARCHAR(15) 2
        ,zone           VARCHAR(50) 3   
        ,service_zone   VARCHAR(15) 4
    ) AS TaxiZone


-- Check for Duplicate LocationIDs
SELECT
    location_id
    ,COUNT(1) AS location_id_count 
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIRSTROW = 2
    ) 
    WITH(
        location_id     SMALLINT    1
        ,borough        VARCHAR(15) 2
        ,zone           VARCHAR(50) 3   
        ,service_zone   VARCHAR(15) 4
    ) AS TaxiZone
GROUP BY location_id
HAVING COUNT (1) > 1
ORDER BY location_id ASC;


-- Check Record Count Per Borough
SELECT
    borough
    ,COUNT(1) AS borough_count 
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIRSTROW = 2
    ) 
    WITH(
        location_id     SMALLINT    1
        ,borough        VARCHAR(15) 2
        ,zone           VARCHAR(50) 3   
        ,service_zone   VARCHAR(15) 4
    ) AS TaxiZone
GROUP BY borough
ORDER BY borough ASC;