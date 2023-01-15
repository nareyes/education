CREATE TABLE [dbo].[Trip]
(
    [DateID]                INT NOT NULL
    , [MedallionID]         INT NOT NULL
    , [HackneyLicenseID]    INT NOT NULL
    , [PickupTimeID]        INT NOT NULL
    , [DropoffTimeID]       INT NOT NULL
    , [PickupGeographyID]   INT NULL
    , [DropoffGeographyID]  INT NULL
    , [PickupLatitude]      FLOAT NULL
    , [PickupLongitude]     FLOAT NULL
    , [PickupLatLong]       VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    , [DropoffLatitude]     FLOAT NULL
    , [DropoffLongitude]    FLOAT NULL
    , [DropoffLatLong]      VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    , [PassengerCount]      INT NULL
    , [TripDurationSeconds] INT NULL
    , [TripDistanceMiles]   FLOAT NULL
    , [PaymentType]         VARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    , [FareAmount]          MONEY NULL
    , [SurchargeAmount]     MONEY NULL
    , [TaxAmount]           MONEY NULL
    , [TipAmount]           MONEY NULL
    , [TollsAmount]         MONEY NULL
    , [TotalAmount]         MONEY NULL
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
)
GO