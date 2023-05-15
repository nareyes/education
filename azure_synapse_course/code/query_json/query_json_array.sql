USE NYC_Taxi_Serverless
GO

-- Query JSON Array w/ JSON_VALUES
SELECT
    JSON_VALUE (jsonDoc, '$.payment_type') AS PaymentType
    ,JSON_VALUE (jsonDoc, '$.payment_type_desc[0].value') AS PaymentTypeDescription -- Use Index Position of Array
FROM
    OPENROWSET(
        BULK 'payment_type_array.json',
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


-- Query JSON Array w/ OPENJSON
SELECT
    PaymentType
    ,PaymentTypeDescription
FROM
    OPENROWSET(
        BULK 'payment_type_array.json',
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

CROSS APPLY OPENJSON(jsonDoc) -- Return Key Value Pairs
    WITH(
        PaymentType         SMALLINT        '$.payment_type'
        ,payment_type_desc  NVARCHAR(MAX)   AS JSON
    )

CROSS APPLY OPENJSON(payment_type_desc)
    WITH(
        PaymentSubType          SMALLINT    '$.sub_type'
        ,PaymentTypeDescription VARCHAR(20) '$.value'
    )