# Formula1 Prooject

### Tools
- Azure Databricks
- Azure Data Lake Gen2
- Azure Data Factory
- Azure Key Vault

<br>

## Project Requirements

### Data Discovery
- Schema applied to raw data
- Discovery capability on raw data
- Discovery using Databricks Notebooks

### Data Ingestion
- Ingestion using Databricks
- Ingested data to be stored in Parquet format
- Ingested data to be stored as tables and views
- Ingested data must have a schema and audit columns
- Ingested data must be able to handle incremental load

### Data Transformation
- Join key information required for reporting to create new tables
- Join key information required for analysis to create new tables
- Transformed data must be stored in Parquet format
- Transformed data must be able to be analyzed using T-SQL
- Transformed data must be able to handle incremental transformation

### Scheduling Requirements
- Pipelines to run at regular intervals
- Ability to monitor pipelines
- Ability to re-run failed pipelines
- Ability to set-up alerts on failures

### Reporting Requirements
- Driver Standings
- Constructor Standings

### Analysis Requirements
- Dominant Drivers
- Dominant Teams
- Visualize Outputs
- Dtaabricks Dashboards

## Formula1 Data Overview
[API Documentation](http://ergast.com/mrd/)
<br>

![](https://github.com/nareyes/education/blob/main/azure_databricks_course/imgs/ergast_er_diagram.png)

## Solution Architecture
![](https://github.com/nareyes/education/blob/main/azure_databricks_course/imgs/solution_architecture.png)
