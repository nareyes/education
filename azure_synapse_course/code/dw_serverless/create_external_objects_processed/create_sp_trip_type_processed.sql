USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Processed.InsertTripType

AS

BEGIN

    -- Trip Type
    IF OBJECT_ID ('Processed.TripType') IS NOT NULL
        DROP EXTERNAL TABLE Processed.TripType;

    CREATE EXTERNAL TABLE Processed.TripType

        WITH (
            LOCATION = 'trip_type'
            ,DATA_SOURCE = NYC_Taxi_Processed
            ,FILE_FORMAT = Parquet_File_Format
        )

    AS

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

END;