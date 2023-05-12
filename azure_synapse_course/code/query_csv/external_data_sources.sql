USE NYC_Taxi_Serverless
GO

-- Create External Data Source
-- Navigate: Data > Database > External Resources
-- Using HTTPS or ABFSS Protocol
CREATE EXTERNAL DATA SOURCE NYC_Taxi_File_Drop
WITH(
    LOCATION = 'https://synlakehousedev.dfs.core.windows.net/file-drop/'
)

CREATE EXTERNAL DATA SOURCE NYC_Taxi_File_Drop_HTTPS
WITH(
    LOCATION = 'https://synlakehousedev.dfs.core.windows.net/file-drop/'
)

CREATE EXTERNAL DATA SOURCE NYC_Taxi_File_Drop_ABFSS
WITH(
    LOCATION = 'abfss://file-drop@synlakehousedev.dfs.core.windows.net/'
)


/*
Benefits: Cleans queries and makes it easier for developers to query data lake.
Ability to create reusable sources that point to different zones in the lakehouse.
*/
CREATE EXTERNAL DATA SOURCE NYC_Taxi_Raw
WITH(
    LOCATION = 'https://synlakehousedev.dfs.core.windows.net/nyc-taxi/raw'
)

CREATE EXTERNAL DATA SOURCE NYC_Taxi_Processed
WITH(
    LOCATION = 'https://synlakehousedev.dfs.core.windows.net/nyc-taxi/raw'
)

CREATE EXTERNAL DATA SOURCE NYC_Taxi_Curated
WITH(
    LOCATION = 'https://synlakehousedev.dfs.core.windows.net/nyc-taxi/raw'
)


-- Examine Data Sources
SELECT 
    name 
    ,location
FROM sys.external_data_sources;


-- Drop Data Source
DROP EXTERNAL DATA SOURCE NYC_Taxi_File_Drop_HTTPS
GO


-- Drop Data Source (IF EXISTS)
IF EXISTS(
    SELECT name FROM sys.external_data_sources WHERE name = 'NYC_Taxi_File_Drop_ABFSS'
)
BEGIN
    DROP EXTERNAL DATA SOURCE NYC_Taxi_File_Drop_ABFSS
END


-- Query Using External Data Source
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'taxi_zone.csv',
        DATA_SOURCE = 'NYC_Taxi_File_Drop',
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