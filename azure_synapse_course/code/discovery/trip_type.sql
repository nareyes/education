USE NYC_Taxi_Serverless
GO

SELECT
    *
FROM
    OPENROWSET(
        BULK 'trip_type.tsv',
        DATA_SOURCE = 'NYC_Taxi_File_Drop',
        FORMAT = 'CSV',
        FIELDTERMINATOR = '\t',
        PARSER_VERSION = '2.0',
        HEADER_ROW = TRUE
    )
    WITH(
        TripType                SMALLINT    1
        ,TripTypeDescription    VARCHAR(25) 2
    ) AS TripType