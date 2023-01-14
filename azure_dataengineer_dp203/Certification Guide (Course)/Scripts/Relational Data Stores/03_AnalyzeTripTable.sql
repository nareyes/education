-- Inspect Data
SELECT TOP (100)
    DateID
    , MedallionID
    , HackneyLicenseID
    , PickupTimeID
    , DropoffTimeID
    , PickupGeographyID
    , DropoffGeographyID
    , PickupLatitude
    , PickupLongitude
    , PickupLatLong
    , DropoffLatitude
    , DropoffLongitude
    , DropoffLatLong
    , PassengerCount
    , TripDurationSeconds
    , TripDistanceMiles
    , PaymentType
    , FareAmount
    , SurchargeAmount
    , TaxAmount
    , TipAmount
    , TollsAmoun
    , TotalAmount
FROM dbo.Trip;


-- Count Records
SELECT COUNT (*) FROM dbo.Trip;


-- Trip Distance by Passenger Count
SELECT
    PassengerCount
    , SUM (TripDistanceMiles) AS SumTripDistance
    , AVG (TripDistanceMiles) AS AvgTripDistance
FROM dbo.Trip
WHERE TripDistanceMiles > 0 AND PassengerCount > 0
GROUP BY PassengerCount
ORDER BY PassengerCount ASC;