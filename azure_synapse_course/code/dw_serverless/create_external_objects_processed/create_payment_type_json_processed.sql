USE NYC_Taxi_Serverless
GO

-- Data Written to ADLS Cannot be Deleted Here
-- Delete via Pipelines and Call Script as a Best Practice

-- Taxi Zone
IF OBJECT_ID ('Processed.PaymentType') IS NOT NULL
    DROP EXTERNAL TABLE Processed.PaymentType
    GO

CREATE EXTERNAL TABLE Processed.PaymentType

    WITH (
        LOCATION = 'payment_type'
        ,DATA_SOURCE = NYC_Taxi_Processed
        ,FILE_FORMAT = Parquet_File_Format
    )

AS

    -- SELECT *
    -- FROM Raw.View_RateCode;

    -- Alternate: Use OPENROWSET if Raw Table Does Not Exists
    -- Preferred Method, Simple Column Renaming
    SELECT
        PaymentType
        ,PaymentTypeDescription
    FROM
        OPENROWSET (
            BULK 'payment_type.json'
            ,DATA_SOURCE = 'NYC_Taxi_Raw'
            ,FORMAT = 'CSV' -- Even for JSON
            ,PARSER_VERSION = '1.0'
            ,FIELDTERMINATOR = '0x0b'
            ,FIELDQUOTE = '0x0b'
            ,ROWTERMINATOR = '0x0a'
        ) 

            WITH (
                jsonDoc NVARCHAR(MAX)
            ) AS PaymentType

    CROSS APPLY OPENJSON(jsonDoc) -- Return Key Value Pairs
        WITH (
            PaymentType             SMALLINT    '$.payment_type'
            ,PaymentTypeDescription VARCHAR(15) '$.payment_type_desc'
        )


-- Query Processed Table
-- SELECT TOP 10 * FROM Processed.PaymentType;