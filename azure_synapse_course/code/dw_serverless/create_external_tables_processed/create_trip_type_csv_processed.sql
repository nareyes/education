USE NYC_Taxi_Serverless
GO

-- Data Written to ADLS Cannot be Deleted Here
-- Delete via Pipelines and Call Script as a Best Practice

-- Taxi Zone
IF OBJECT_ID ('Processed.TripType') IS NOT NULL
    DROP EXTERNAL TABLE Processed.TripType
    GO

CREATE EXTERNAL TABLE Processed.TripType

    WITH (
        LOCATION = 'trip_type'
        ,DATA_SOURCE = NYC_Taxi_Processed
        ,FILE_FORMAT = Parquet_File_Format
    )

AS

    -- SELECT *
    -- FROM Raw.TripType;

    -- Alternate: Use OPENROWSET if Raw Table Does Not Exists
    -- Preferred Method, Simple Column Renaming
    SELECT
        *
    FROM
        OPENROWSET (
            BULK 'trip_type.tsv'
            ,DATA_SOURCE = 'NYC_Taxi_Raw'
            ,FORMAT = 'CSV'
            ,FIELDTERMINATOR = '\t'
            ,PARSER_VERSION = '2.0'
            ,HEADER_ROW = TRUE
        )

        WITH (
            TripType                SMALLINT    1
            ,TripTypeDescription    VARCHAR(25) 2
        ) AS TripType


-- Query Processed Table
-- SELECT TOP 10 * FROM Processed.TripType;