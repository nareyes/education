USE NYC_Taxi_Serverless
GO

-- Taxi Zone
IF OBJECT_ID ('Raw.TaxiZone') IS NOT NULL
    DROP EXTERNAL TABLE Raw.TaxiZone
    GO

CREATE EXTERNAL TABLE Raw.TaxiZone (
    LocationID      SMALLINT
    ,Borough        VARCHAR(15)
    ,Zone           VARCHAR(50)
    ,ServiceZone    VARCHAR(15)
)

    WITH (
        LOCATION = 'taxi_zone.csv'
        ,DATA_SOURCE = NYC_Taxi_Raw
        ,FILE_FORMAT = CSV_File_Format
        ,REJECT_VALUE = 10
        ,REJECTED_ROW_LOCATION = 'rejections/tax_zone'
    );

SELECT * FROM Raw.TaxiZone;