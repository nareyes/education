USE NYC_Taxi_Serverless
GO

-- Explore Files to Join
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData

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
        location_id     SMALLINT    1
        ,borough        VARCHAR(15) 2
        ,zone           VARCHAR(50) 3   
        ,service_zone   VARCHAR(15) 4
    ) AS TaxiZone


-- Identify NULL PULocationID (No Records)
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData
WHERE PULocationID IS NULL;


-- Join Files
SELECT
    TaxiZone.Borough
    ,COUNT(1) AS TripCount
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=*/month=*/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData

INNER JOIN
    OPENROWSET(
        BULK 'taxi_zone.csv',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    )
    WITH(
        LocationID      SMALLINT    1
        ,Borough        VARCHAR(15) 2
        ,Zone           VARCHAR(50) 3   
        ,ServiceZone    VARCHAR(15) 4
    ) AS TaxiZone

    ON TripData.PULocationID = TaxiZone.LocationID

GROUP BY TaxiZone.Borough
ORDER BY TaxiZone.Borough;