-- IoT simulator will send data to IoT Hub
-- IoT Hub will send events to input of Streaming Analytics Job
-- Query will process the input and store result in output (Blob storage in this example)

SELECT
    MessageID
    , DeviceID
    , Temperature
    , Humidity
    , EventProcessedUtcTime
    , *
INTO StreamOutput 
FROM StreamInput
HAVING Temperature > 27;