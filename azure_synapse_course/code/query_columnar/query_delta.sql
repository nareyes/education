USE NYC_Taxi_Serverless
GO

-- Query Delta Sub-Folder
-- Will Fail, Delta Does Not Support
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_delta/year=2020/',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'DELTA'
    ) AS TripData


-- Query Delta Folder
-- Includes Partition Metadata Columns (Used for Filtering)
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_delta/',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'DELTA'
    ) AS TripData


-- Query Data Types
EXEC sp_describe_first_result_set N'
    SELECT
        TOP 100 *
    FROM
        OPENROWSET(
            BULK ''trip_data_green_delta/'',
            DATA_SOURCE = ''NYC_Taxi_Raw'',
            FORMAT = ''DELTA''
        ) AS TripData
'


-- Query Delta Folders w/ Explicit Data Types
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_delta/',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'DELTA'
    ) 
    WITH(
        VendorID                INT
        ,lpep_pickup_datetime   DATETIME2(7)
        ,lpep_dropoff_datetime  DATETIME2(7)
        ,passenger_count        INT
        ,trip_distance          FLOAT
        ,total_amount           FLOAT
        ,trip_type              INT
        ,year                   VARCHAR(4)
        ,month                  VARCHAR(2)
    ) AS TripData


-- Target Specified Partitions w/ Metadata Columns
SELECT
    passenger_count
    ,COUNT(1) AS trip_count
    ,AVG(total_amount) AS avg_trip_cost
FROM
    OPENROWSET(
        BULK 'trip_data_green_delta/',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'DELTA'
    ) 
    WITH(
        passenger_count        INT
        ,trip_distance          FLOAT
        ,total_amount           FLOAT
        ,year                   VARCHAR(4)
        ,month                  VARCHAR(2)
    ) AS TripData
WHERE 1=1
    AND year = '2020'
    AND month = '01'
GROUP BY passenger_count
ORDER BY passenger_count ASC;