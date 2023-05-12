-- OPENROWSET
-- Use HTTPS or ABFSS Protocol

-- HTTPS
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'https://synlakehousedev.dfs.core.windows.net/file-drop/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ',', -- Default = ,
        ROWTERMINATOR = '\n' -- Default = \n
    ) AS TaxiZone


-- ABFSS
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'abfss://file-drop@synlakehousedev.dfs.core.windows.net/taxi_zone.csv',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n'
    ) AS TaxiZone