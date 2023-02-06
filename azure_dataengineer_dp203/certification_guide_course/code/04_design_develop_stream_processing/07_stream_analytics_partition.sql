-- Parallelization helps divide data in subsets (partitions)
-- Partitions are based on a partition key
-- INTO n Required with PARTITION BY, specifies # of partitions
-- Embarrassingly Parallel Jobs Connects:
  -- One partition of the input to one instance of the query to one partition of the output

SELECT *
INTO StreamOutput 
FROM StreamInput
PARTITION BY [PartitionKey_Column]
INTO 10; 
