USE NYC_Taxi_Serverless
GO

-- Data Written to ADLS Cannot be Deleted Here
-- Delete via Pipelines and Call Script as a Best Practice

-- Vendor
IF OBJECT_ID ('Processed.Vendor') IS NOT NULL
    DROP EXTERNAL TABLE Processed.Vendor
    GO

CREATE EXTERNAL TABLE Processed.Vendor

    WITH (
        LOCATION = 'vendor'
        ,DATA_SOURCE = NYC_Taxi_Processed
        ,FILE_FORMAT = Parquet_File_Format
    )

AS

    -- SELECT *
    -- FROM Raw.Vendor;

    -- Alternate: Use OPENROWSET if Raw Table Does Not Exists
    -- Preferred Method, Simple Column Renaming
    SELECT
        *
    FROM
        OPENROWSET(
            BULK 'vendor.csv'
            ,DATA_SOURCE = 'NYC_Taxi_Raw'
            ,FORMAT = 'CSV'
            ,PARSER_VERSION = '2.0'
            ,HEADER_ROW = TRUE
        )

        WITH (
            VendorID    SMALLINT    1
            ,VendorName VARCHAR(50) 2
        ) AS Vendor


-- Query Processed Table
-- SELECT TOP 10 * FROM Processed.Vendor;