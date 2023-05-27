USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Processed.InsertRateCode

AS

BEGIN

    -- Rate Code
    IF OBJECT_ID ('Processed.RateCode') IS NOT NULL
        DROP EXTERNAL TABLE Processed.RateCode;

    CREATE EXTERNAL TABLE Processed.RateCode

        WITH (
            LOCATION = 'rate_code'
            ,DATA_SOURCE = NYC_Taxi_Processed
            ,FILE_FORMAT = Parquet_File_Format
        )

    AS

        SELECT
            RateCodeID
            ,RateCodeDescription
        FROM
            OPENROWSET (
                BULK 'rate_code.json'
                ,DATA_SOURCE = 'NYC_Taxi_Raw'
                ,FORMAT = 'CSV' -- Even for JSON
                ,PARSER_VERSION = '1.0'
                ,FIELDTERMINATOR = '0x0b'
                ,FIELDQUOTE = '0x0b'
                ,ROWTERMINATOR = '0x0b' -- Vertical Tab
            ) 

                WITH (
                    jsonDoc NVARCHAR(MAX)
                ) AS RateCode

        CROSS APPLY OPENJSON(jsonDoc) -- Return Key Value Pairs
            WITH (
                RateCodeID              TINYINT     '$.rate_code_id'
                ,RateCodeDescription    VARCHAR(20) '$.rate_code'
            )

END;