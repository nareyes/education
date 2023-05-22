USE NYC_Taxi_Serverless
GO

-- Data Written to ADLS Cannot be Deleted Here
-- Delete via Pipelines and Call Script as a Best Practice

-- Taxi Zone
IF OBJECT_ID ('Processed.TaxiZone') IS NOT NULL
    DROP EXTERNAL TABLE Processed.TaxiZone
    GO

CREATE EXTERNAL TABLE Processed.TaxiZone

    WITH (
        LOCATION = 'taxi_zone'
        ,DATA_SOURCE = NYC_Taxi_Processed
        ,FILE_FORMAT = Parquet_File_Format
    )

AS

    -- SELECT *
    -- FROM Raw.TaxiZone;

    -- Alternate: Use OPENROWSET if Raw Table Does Not Exists
    -- Preferred Method, Simple Column Renaming
    SELECT
        *
    FROM
        OPENROWSET (
            BULK 'taxi_zone.csv'
            ,DATA_SOURCE = 'NYC_Taxi_Raw'
            ,FORMAT = 'CSV'
            ,PARSER_VERSION = '2.0'
            ,HEADER_ROW = TRUE
        )

        WITH (
            LocationID      SMALLINT    1
            ,Borough        VARCHAR(15) 2
            ,Zone           VARCHAR(50) 3
            ,ServiceZone    VARCHAR(15) 4
        ) AS TaxiZone


-- Query Processed Table
-- SELECT TOP 10 * FROM Processed.TaxiZone;