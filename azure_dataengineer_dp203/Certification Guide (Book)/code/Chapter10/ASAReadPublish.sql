-- Read and publish data in ASA
SELECT
  System.Timestamp AS WindowEnd,
  startLocation AS Location,
  COUNT (*) AS TripCount
 INTO [ASA-PowerBI]  -- insert output name
 FROM [EH-ASA-Stream] -- insert input name
 GROUP BY
  TUMBLINGWINDOW (s, 5),
  Location;
