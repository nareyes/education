USE NYC_Taxi_Serverless
GO

-- Data Written to ADLS Cannot be Deleted Here
-- Delete via Pipelines and Call Script as a Best Practice

-- Taxi Zone
IF OBJECT_ID ('Processed.RateCode') IS NOT NULL
    DROP EXTERNAL TABLE Processed.RateCode
    GO

CREATE EXTERNAL TABLE Processed.RateCode

    WITH (
        LOCATION = 'rate_code'
        ,DATA_SOURCE = NYC_Taxi_Processed
        ,FILE_FORMAT = Parquet_File_Format
    )

AS

    -- SELECT *
    -- FROM Raw.View_RateCode;

    -- Alternate: Use OPENROWSET if Raw Table Does Not Exists
    -- Preferred Method, Simple Column Renaming
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


-- Query Processed Table
-- SELECT TOP 10 * FROM Processed.RateCode;