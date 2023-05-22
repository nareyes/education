USE NYC_Taxi_Serverless
GO

-- Data Written to ADLS Cannot be Deleted Here
-- Delete via Pipelines and Call Script as a Best Practice

-- Taxi Zone
IF OBJECT_ID ('Processed.Trip') IS NOT NULL
    DROP EXTERNAL TABLE Processed.Trip
    GO

CREATE EXTERNAL TABLE Processed.Trip

    WITH (
        LOCATION = 'trip'
        ,DATA_SOURCE = NYC_Taxi_Processed
        ,FILE_FORMAT = Parquet_File_Format
    )

AS

    -- SELECT *
    -- FROM Raw.TripCSV;

    -- Alternate: Use OPENROWSET if Raw Table Does Not Exists
    -- Preferred Method, Simple Column Renaming
    -- Issue w/ Partitioned Data: This Will Not Maintain Partitions (Added ParitionYear and PartitionMonth for Simple Parition-Like Filtering)
    SELECT TOP 100
        Trip.filepath(1) AS PartitionYear
        ,Trip.filepath(2) AS PartitionMonth
        ,Trip.*
    FROM
        OPENROWSET (
            BULK 'trip_data_green_csv/year=*/month=*/*.csv'
            ,DATA_SOURCE = 'NYC_Taxi_Raw'
            ,FORMAT = 'CSV'
            ,PARSER_VERSION = '2.0'
            ,HEADER_ROW = TRUE
        ) AS Trip


-- Query Processed Table
SELECT TOP 10 * FROM Processed.Trip;