-- COLLATE defines the encoding type

-- Apply COLLATE at the database level
CREATE DATABASE TripsDB COLLATE Latin1_General_100_BIN2_UTF8;

-- Apply COLLATE at the table level
CREATE EXTERNAL TABLE FactTrips (
    [tripId] INT NOT NULL COLLATE Latin1_General_100_BIN2_UTF8,
    [driverId] INT NOT NULL,
    [customerId] INT NOT NULL,
    [tripDate] INT,
    [startLocation] VARCHAR(40),
    [endLocation] VARCHAR(40)
 );
