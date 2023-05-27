USE NYC_Taxi_Serverless
GO

CREATE OR ALTER PROCEDURE Processed.InsertPaymentType

AS

BEGIN

    -- Payment Type
    IF OBJECT_ID ('Processed.PaymentType') IS NOT NULL
        DROP EXTERNAL TABLE Processed.PaymentType;

    CREATE EXTERNAL TABLE Processed.PaymentType

        WITH (
            LOCATION = 'payment_type'
            ,DATA_SOURCE = NYC_Taxi_Processed
            ,FILE_FORMAT = Parquet_File_Format
        )

    AS

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

END;