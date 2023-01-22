# write streaming data
EHStreamJsonDF.selectExpr(
  "tripId"\ ,
  "timestamp"\ ,
  "startLocation"\ ,
  "endLocation"\ ,
  "distance"\ ,
  "fare")\ 
.writeStream.format("delta")\ 
.outputMode("append")\ 
.option(
  "checkpointLocation", 
  "dbfs:/TripsCheckpointLocation/"
)\ 
.start("dbfs:/TripsEventHubDelta")

# create and query data
%sql
CREATE TABLE IF NOT EXISTS TripsAggTumbling 
  USING DELTA LOCATION "dbfs:/TripsEventHubDelta/" ;
  
SELECT * FROM TripsAggTumbling;
