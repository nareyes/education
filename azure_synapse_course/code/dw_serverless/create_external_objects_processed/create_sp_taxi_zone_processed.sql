USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Processed.InsertTaxiZone

AS

BEGIN

    -- Taxi Zone
    IF OBJECT_ID ('Processed.TaxiZone') IS NOT NULL
        DROP EXTERNAL TABLE Processed.TaxiZone;

    CREATE EXTERNAL TABLE Processed.TaxiZone

        WITH (
            LOCATION = 'taxi_zone'
            ,DATA_SOURCE = NYC_Taxi_Processed
            ,FILE_FORMAT = Parquet_File_Format
        )

    AS

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

END;