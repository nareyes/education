-- Query is triggered whenever an event happends in the input
-- In this example, an event was a new file in the blob input container
-- Query from input and store in output (tabular format)

SELECT
    City
    , Region
    , Coordinates.Latitude
    , Coordinates.Longitude
    , Population
INTO StreamInput
FROM StreamOutput;