USE NYC_Taxi_Serverless
GO

-- Select All Files From Folder w/ Single File
SELECT
    TOP 100
    TripData.filename() AS file_name
    ,TripData.*
FROM
    OPENROWSET(
        BULK 'trip_data_green_csv/year=2020/month=01/', -- *, *.csv
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TripData


-- Select All Files From Folder w/ Sub-Folders
SELECT
    TOP 100
    TripData.filename() AS file_name
    ,TripData.*
FROM
    OPENROWSET(
        BULK 'trip_data_green_csv/year=2020/**', -- ** All Underlying Sub-Folders
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TripData


SELECT
    TOP 100
    TripData.filename() AS file_name
    ,TripData.*
FROM
    OPENROWSET(
        BULK 'trip_data_green_csv/year=*/month=*/*.csv', -- ** All Folders and Sub-Folders
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TripData


-- Select All Files From Folder and Specified Sub-Folders
SELECT
    TOP 100
    TripData.filename() AS file_name
    ,TripData.*
FROM
    OPENROWSET(
        BULK    (
            'trip_data_green_csv/year=2020/month=01/*.csv',
            'trip_data_green_csv/year=2020/month=03/*.csv'
        ),
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    ) AS TripData