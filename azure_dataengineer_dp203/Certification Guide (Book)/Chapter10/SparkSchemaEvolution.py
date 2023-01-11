# Spark scehma evolution option
StreamDF.writeStream.format("delta")\ 
  .option("mergeSchema", "true") \ 
  .outputMode("append")\ 
  .option("checkpointLocation", "dbfs:/CheckpointLocation/")\ 
  .start("dbfs:/StreamData")
