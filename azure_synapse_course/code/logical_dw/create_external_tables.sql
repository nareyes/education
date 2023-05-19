USE NYC_Taxi_Serverless
GO

-- Calendar
IF OBJECT_ID ('Raw.Calendar') IS NOT NULL
    DROP EXTERNAL TABLE Raw.Calendar
    GO

CREATE EXTERNAL TABLE Raw.Calendar (
    DateKey         INT         
    ,Date           DATE        
    ,Year           SMALLINT    
    ,Month          TINYINT     
    ,Day            TINYINT     
    ,DayName        VARCHAR(10) 
    ,DayOfYear      SMALLINT    
    ,WeekOfMonth    TINYINT     
    ,WeekOfYear     TINYINT     
    ,MonthName      VARCHAR(10) 
    ,YearMonth      INT         
    ,YearWeek       INT         
)

    WITH (
        LOCATION = 'calendar.csv'
        ,DATA_SOURCE = NYC_Taxi_Raw
        ,FILE_FORMAT = CSV_File_Format
        ,REJECT_VALUE = 10
        ,REJECTED_ROW_LOCATION = 'rejections/calendar'
    );

SELECT * FROM Raw.Calendar;


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
        ,REJECTED_ROW_LOCATION = 'rejections/taxi_zone'
    );

SELECT * FROM Raw.TaxiZone;


-- Trip Type
IF OBJECT_ID ('Raw.TripType') IS NOT NULL
    DROP EXTERNAL TABLE Raw.TripType
    GO

CREATE EXTERNAL TABLE Raw.TripType (
    TripType                SMALLINT
    ,TripTypeDescription    VARCHAR(25)
)

    WITH (
        LOCATION = 'trip_type.tsv'
        ,DATA_SOURCE = NYC_Taxi_Raw
        ,FILE_FORMAT = TSV_File_Format
        ,REJECT_VALUE = 10
        ,REJECTED_ROW_LOCATION = 'rejections/trip_type'
    );

SELECT * FROM Raw.TripType;


-- Vendor
IF OBJECT_ID ('Raw.Vendor') IS NOT NULL
    DROP EXTERNAL TABLE Raw.Vendor
    GO

CREATE EXTERNAL TABLE Raw.Vendor (
    VendorID    SMALLINT
    ,VendorName VARCHAR(35)
)

    WITH (
        LOCATION = 'vendor.csv'
        ,DATA_SOURCE = NYC_Taxi_Raw
        ,FILE_FORMAT = CSV_File_Format
        ,REJECT_VALUE = 10
        ,REJECTED_ROW_LOCATION = 'rejections/trip_type'
    );

SELECT * FROM Raw.Vendor;


-- Trip Data
IF OBJECT_ID ('Raw.TripCSV') IS NOT NULL
    DROP EXTERNAL TABLE Raw.TripCSV
    GO

CREATE EXTERNAL TABLE Raw.TripCSV (
    VendorID	            TINYINT
    ,PickupDateTime	        DATETIME2(0)
    ,DropoffDateTime	    DATETIME2(0)
    ,StoreAndFwdFlag	    VARCHAR(10)
    ,RateCodeID	            SMALLINT
    ,PULocationID	        SMALLINT
    ,DOLocationID	        SMALLINT
    ,PassengerCount	        TINYINT
    ,TripDistance	        FLOAT
    ,FareAmount	            FLOAT
    ,Extra	                FLOAT
    ,MTATax	                FLOAT
    ,TipAmount	            FLOAT
    ,TollsAmount	        FLOAT
    ,EhailFee	            VARCHAR(50)
    ,ImprovementSurcharge   FLOAT
    ,TotalAmount	        FLOAT
    ,PaymentType	        BIGINT
    ,TripType               BIGINT
    ,CongestionSurcharge    FLOAT
)

    WITH (
        LOCATION = 'trip_data_green_csv/**'
        ,DATA_SOURCE = NYC_Taxi_Raw
        ,FILE_FORMAT = CSV_File_Format
        ,REJECT_VALUE = 10
        ,REJECTED_ROW_LOCATION = 'rejections/trip_type'
    );

SELECT TOP 100 * FROM Raw.TripCSV;