EHStreamJsonDF.writeStream.format("delta")\ 
  .outputMode("append")\ 
  .option("checkpointLocation", "dbfs:/TripsCheckpointLocation/")\
  .start("dbfs:/TripsEventHubDelta")
