USE NYC_Taxi_Serverless
GO

/* Template
CREATE EXTERNAL DATA SOURCE NYC_Taxi_File_Drop
WITH(
    LOCATION = <file_path>,
    CREDENTIAL = <credential_name>,
    TYPE = {HADOOP}
)

Credential and Type Are Optional Arguments
Type = Hadoop Only Supported w/ Dedicated SQL Pools
*/

-- Create External Data Source
-- Navigate: Data > Database > External Resources
-- Using HTTPS or ABFSS Protocol (Container Properties for URL)
CREATE EXTERNAL DATA SOURCE NYC_Taxi_File_Drop
WITH (
    LOCATION = 'https://synlakehousedev.dfs.core.windows.net/file-drop/'
)

CREATE EXTERNAL DATA SOURCE NYC_Taxi_File_Drop_HTTPS
WITH (
    LOCATION = 'https://synlakehousedev.dfs.core.windows.net/file-drop/'
)

CREATE EXTERNAL DATA SOURCE NYC_Taxi_File_Drop_ABFSS
WITH (
    LOCATION = 'abfss://file-drop@synlakehousedev.dfs.core.windows.net/'
)


/*
Benefits: Cleans queries and makes it easier for developers to query data lake.
Ability to create reusable sources that point to different zones in the lakehouse.
*/
IF NOT EXISTS (
    SELECT name FROM sys.external_data_sources 
    WHERE name = 'NYC_Taxi_Raw'
)

    CREATE EXTERNAL DATA SOURCE NYC_Taxi_Raw
    WITH (
        LOCATION = 'https://synlakehousedev.dfs.core.windows.net/nyc-taxi/raw'
    );


IF NOT EXISTS (
    SELECT name FROM sys.external_data_sources 
    WHERE name = 'NYC_Taxi_Processed'
)

    CREATE EXTERNAL DATA SOURCE NYC_Taxi_Processed
    WITH (
        LOCATION = 'https://synlakehousedev.dfs.core.windows.net/nyc-taxi/processed'
    );


IF NOT EXISTS (
    SELECT name FROM sys.external_data_sources 
    WHERE name = 'NYC_Taxi_Curated'
)

    CREATE EXTERNAL DATA SOURCE NYC_Taxi_Curated
    WITH (
        LOCATION = 'https://synlakehousedev.dfs.core.windows.net/nyc-taxi/curated'
    );


-- Examine Data Sources
SELECT 
    name 
    ,location
FROM sys.external_data_sources;


-- Drop Data Source
DROP EXTERNAL DATA SOURCE NYC_Taxi_File_Drop
GO


DROP EXTERNAL DATA SOURCE NYC_Taxi_File_Drop_HTTPS
GO


-- Drop Data Source (IF EXISTS)
IF EXISTS (
    SELECT name FROM sys.external_data_sources 
    WHERE name = 'NYC_Taxi_Curated'
)
BEGIN
    DROP EXTERNAL DATA SOURCE NYC_Taxi_Curated
END