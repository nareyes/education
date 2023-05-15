USE NYC_Taxi_Serverless
GO

-- Query JSON Values w/ OPENJSON
-- OPENJSON = More Efficient, More Functionality
SELECT
    PaymentType
    ,PaymentTypeDescription
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

CROSS APPLY OPENJSON(jsonDoc) -- Return Key Value Pairs
    WITH(
        PaymentType             SMALLINT    '$.payment_type'
        ,PaymentTypeDescription VARCHAR(15) '$.payment_type_desc'
    )