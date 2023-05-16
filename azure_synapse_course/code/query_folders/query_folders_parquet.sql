USE NYC_Taxi_Serverless
GO

-- Query Folder w/ Wildcard
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/month=01/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData


-- Query Folder w/ Sub-Folders
SELECT
    TOP 100 *
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/**',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData


-- Query Folder w/ FILENAME Function
SELECT
    TOP 100
    TripData.filename() AS file_name
    ,TripData.*
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=2020/**',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData


-- Query Folder w/ FILEPATH Function
SELECT
    TripData.filepath(1) AS year
    ,TripData.filepath(2) AS month
    ,TripData.filepath(3) AS file_name
    ,COUNT(1) AS record_count
FROM
    OPENROWSET(
        BULK 'trip_data_green_parquet/year=*/month=*/*.parquet',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'PARQUET'
    ) AS TripData
WHERE 1=1
    AND TripData.filepath(1) = '2020'
    AND TripData.filepath(2) IN ('01', '04', '06')
GROUP BY TripData.filepath(1), TripData.filepath(2), TripData.filepath(3)
ORDER BY TripData.filepath(1), TripData.filepath(2), TripData.filepath(3);