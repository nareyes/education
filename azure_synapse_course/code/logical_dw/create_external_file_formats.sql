USE NYC_Taxi_Serverless
GO

-- CSV
IF NOT EXISTS (
    SELECT * FROM sys.external_file_formats
    WHERE Name = 'CSV_File_Format'
)

    CREATE EXTERNAL FILE FORMAT CSV_File_Format
    WITH (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS (
            FIELD_TERMINATOR = ','
            ,STRING_DELIMITER = '"'
            ,FIRST_ROW = 2
            ,USE_TYPE_DEFAULT = FALSE -- True Replaces NULLs w/ Default Values
            ,ENCODING = 'UTF8'
            ,PARSER_VERSION = '2.0'
        )
    );


-- PARQUET



-- DELTA