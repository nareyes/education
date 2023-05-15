USE NYC_Taxi_Serverless
GO

-- Query JSON Values
SELECT
    JSON_VALUE (jsonDoc, '$.payment_type') AS PaymentType
    ,JSON_VALUE (jsonDoc, '$.payment_type_desc') AS PaymentTypeDescription
FROM
    OPENROWSET(
        BULK 'payment_type.json',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV', -- Even for JSON
        PARSER_VERSION = '1.0',
        FIELDTERMINATOR = '0x0b',
        FIELDQUOTE = '0x0b',
        ROWTERMINATOR = '0x0a'
    ) 
    WITH(
        jsonDoc NVARCHAR(MAX)
    ) AS PaymentType


-- Query JSON Values w/ Data Type
SELECT
    CAST (JSON_VALUE (jsonDoc, '$.payment_type') AS SMALLINT) AS PaymentType
    ,CAST (JSON_VALUE (jsonDoc, '$.payment_type_desc') AS VARCHAR(15)) AS PaymentTypeDescription
FROM
    OPENROWSET(
        BULK 'payment_type.json',
        DATA_SOURCE = 'NYC_Taxi_Raw',
        FORMAT = 'CSV', -- Even for JSON
        PARSER_VERSION = '1.0',
        FIELDTERMINATOR = '0x0b',
        FIELDQUOTE = '0x0b',
        ROWTERMINATOR = '0x0a'
    ) 
    WITH(
        jsonDoc NVARCHAR(MAX)
    ) AS PaymentType