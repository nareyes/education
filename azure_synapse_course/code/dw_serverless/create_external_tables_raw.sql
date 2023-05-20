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


-- Trip Data CSV
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
        ,REJECTED_ROW_LOCATION = 'rejections/trip_csv'
    );

SELECT TOP 100 * FROM Raw.TripCSV;


-- Trip Data Parquet (Column Names Need to Match Source)
IF OBJECT_ID ('Raw.TripParquet') IS NOT NULL
    DROP EXTERNAL TABLE Raw.TripParquet
    GO

CREATE EXTERNAL TABLE Raw.TripParquet (
    VendorID	            TINYINT
    ,lpep_pickup_datetime	DATETIME2(0) 2
    ,lpep_dropoff_datetime	DATETIME2(0)
    ,store_and_fwd_flag	    VARCHAR(10)
    ,RatecodeID	            SMALLINT
    ,PULocationID	        SMALLINT
    ,DOLocationID	        SMALLINT
    ,passenger_count	    TINYINT
    ,trip_distance	        FLOAT
    ,fare_amount	        FLOAT
    ,extra	                FLOAT
    ,mta_tax	            FLOAT
    ,tip_amount	            FLOAT
    ,tolls_amount	        FLOAT
    ,ehail_fee	            VARCHAR(50)
    ,improvement_surcharge  FLOAT
    ,total_amount	        FLOAT
    ,payment_type	        BIGINT
    ,trip_type              BIGINT
    ,congestion_surcharge   FLOAT
)

    WITH (
        LOCATION = 'trip_data_green_parquet/**'
        ,DATA_SOURCE = NYC_Taxi_Raw
        ,FILE_FORMAT = Parquet_File_Format
        ,REJECT_VALUE = 10
        ,REJECTED_ROW_LOCATION = 'rejections/trip_parquet'
    );

SELECT TOP 100 * FROM Raw.TripParquet;


-- Trip Data Delta (Column Names Need to Match Source)
IF OBJECT_ID ('Raw.TripDelta') IS NOT NULL
    DROP EXTERNAL TABLE Raw.TripDelta
    GO

CREATE EXTERNAL TABLE Raw.TripDelta (
    VendorID	            TINYINT
    ,lpep_pickup_datetime	DATETIME2(0)
    ,lpep_dropoff_datetime	DATETIME2(0)
    ,store_and_fwd_flag	    VARCHAR(10)
    ,RatecodeID	            SMALLINT
    ,PULocationID	        SMALLINT
    ,DOLocationID	        SMALLINT
    ,passenger_count	    TINYINT
    ,trip_distance	        FLOAT
    ,fare_amount	        FLOAT
    ,extra	                FLOAT
    ,mta_tax	            FLOAT
    ,tip_amount	            FLOAT
    ,tolls_amount	        FLOAT
    ,ehail_fee	            VARCHAR(50)
    ,improvement_surcharge  FLOAT
    ,total_amount	        FLOAT
    ,payment_type	        BIGINT
    ,trip_type              BIGINT
    ,congestion_surcharge   FLOAT
)

    WITH (
        LOCATION = 'trip_data_green_delta'
        ,DATA_SOURCE = NYC_Taxi_Raw
        ,FILE_FORMAT = Delta_File_Format
        -- Reject Value Not Supported
        -- ,REJECT_VALUE = 10
        -- ,REJECTED_ROW_LOCATION = 'rejections/trip_delta'
    );

SELECT TOP 100 * FROM Raw.TripDelta;