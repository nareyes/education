COPY INTO [dbo].[Trip]
FROM 'https://nytaxiblob.blob.core.windows.net/2013/Trip2013/QID6392_20171107_05910_0.txt.gz'
WITH (
    FILE_TYPE = 'CSV'
    , FIELDTERMINATOR = '|'
    , FIELDQUOTE = ''
    , ROWTERMINATOR='0X0A'
    , COMPRESSION = 'GZIP'
)

OPTION (LABEL = 'COPY : Load [dbo].[Trip] - Taxi Dataset');