USE NYC_Taxi_Serverless
GO

-- FILENAME Function
SELECT
    TripData.filename() AS file_name
    ,COUNT(1) AS record_count
FROM
    OPENROWSET(
        BULK 'trip_data_green_csv/year=*/month=*/*.csv', -- ** All Folders and Sub-Folders
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TripData
GROUP BY TripData.filename()
ORDER BY file_name ASC;


-- FILENAME Function w/ WHERE Clause
SELECT
    TripData.filename() AS file_name
    ,COUNT(1) AS record_count
FROM
    OPENROWSET(
        BULK 'trip_data_green_csv/year=*/month=*/*.csv', -- ** All Folders and Sub-Folders
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TripData
WHERE TripData.filename() IN ('green_tripdata_2020-01.csv', 'green_tripdata_2021-01.csv') -- Alternate to Specifying in BULK
GROUP BY TripData.filename()
ORDER BY file_name ASC;


-- FILEPATH Function
SELECT
    TripData.filepath() AS file_path
    -- Using Ordinal Wildcard Position
    ,TripData.filepath(1) AS year
    ,TripData.filepath(2) AS month
    ,TripData.filepath(3) AS file_name
    ,COUNT(1) AS record_count
FROM
    OPENROWSET(
        BULK 'trip_data_green_csv/year=*/month=*/*.csv', -- ** All Folders and Sub-Folders
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TripData
GROUP BY TripData.filepath(), TripData.filepath(1), TripData.filepath(2), TripData.filepath(3)
ORDER BY file_path ASC;


-- FILEPATH Function w/ WHERE Clause
SELECT
    TripData.filepath() AS file_path
    -- Using Ordinal Wildcard Position
    ,TripData.filepath(1) AS year
    ,TripData.filepath(2) AS month
    ,TripData.filepath(3) AS file_name
    ,COUNT(1) AS record_count
FROM
    OPENROWSET(
        BULK 'trip_data_green_csv/year=*/month=*/*.csv', -- ** Best Practice be Explicit
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TripData
WHERE 1=1
    AND TripData.filepath(1) = '2020'
    AND TripData.filepath(2) IN ('06', '07', '08')
GROUP BY TripData.filepath(), TripData.filepath(1), TripData.filepath(2), TripData.filepath(3)
ORDER BY file_path ASC;