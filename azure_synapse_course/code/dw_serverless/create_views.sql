USE NYC_Taxi_Serverless
GO

-- Rate Code (JSON Source)
DROP VIEW IF EXISTS Raw.View_RateCode
GO

CREATE VIEW Raw.View_RateCode
AS
    SELECT
        RateCodeID
        ,RateCodeDescription
    FROM
        OPENROWSET (
            BULK 'rate_code.json',
            DATA_SOURCE = 'NYC_Taxi_Raw',
            FORMAT = 'CSV', -- Even for JSON
            PARSER_VERSION = '1.0',
            FIELDTERMINATOR = '0x0b',
            FIELDQUOTE = '0x0b',
            ROWTERMINATOR = '0x0b' -- Vertical Tab
        ) 
        WITH (
            jsonDoc NVARCHAR(MAX)
        ) AS RateCode

    CROSS APPLY OPENJSON(jsonDoc) -- Return Key Value Pairs
        WITH (
            RateCodeID              TINYINT     '$.rate_code_id'
            ,RateCodeDescription    VARCHAR(20) '$.rate_code'
        );
GO

SELECT * FROM Raw.View_RateCode;
GO


-- Payment Type
DROP VIEW IF EXISTS Raw.View_PaymentType
GO

CREATE VIEW Raw.View_PaymentType
AS
    SELECT
        PaymentType
        ,PaymentTypeDescription
    FROM
        OPENROWSET (
            BULK 'payment_type.json',
            DATA_SOURCE = 'NYC_Taxi_Raw',
            FORMAT = 'CSV', -- Even for JSON
            PARSER_VERSION = '1.0',
            FIELDTERMINATOR = '0x0b',
            FIELDQUOTE = '0x0b',
            ROWTERMINATOR = '0x0a'
        ) 
        WITH (
            jsonDoc NVARCHAR(MAX)
        ) AS PaymentType

    CROSS APPLY OPENJSON(jsonDoc) -- Return Key Value Pairs
        WITH (
            PaymentType             SMALLINT    '$.payment_type'
            ,PaymentTypeDescription VARCHAR(15) '$.payment_type_desc'
        )
GO

SELECT * FROM Raw.View_PaymentType;
GO
