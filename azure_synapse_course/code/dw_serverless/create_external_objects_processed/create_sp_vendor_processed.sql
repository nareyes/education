USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Processed.InsertVendor

AS

BEGIN

    -- Vendor
    IF OBJECT_ID ('Processed.Vendor') IS NOT NULL
        DROP EXTERNAL TABLE Processed.Vendor;

    CREATE EXTERNAL TABLE Processed.Vendor

        WITH (
            LOCATION = 'vendor'
            ,DATA_SOURCE = NYC_Taxi_Processed
            ,FILE_FORMAT = Parquet_File_Format
        )

    AS

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

END;