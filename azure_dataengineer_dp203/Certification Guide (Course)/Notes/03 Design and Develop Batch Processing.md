# Exam Perspective
- Data Factory Integration runtime is important topic, you should know difference between diff runtime, and in which scenario which runtime should be used.
- Self-hosted runtime is more important.

# General Notes

##### Integration Runtime
- The integration runtime is the execution environment that provides the compute infrastructure for Data Factory.
- Further study: [Integration runtime in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/concepts-integration-runtime)

##### Self-Hosted Runtime
- When you use the Copy activity to copy data between Azure and a private network, you must use the self-hosted integration runtime.
- Further study: [Create and configure a self-hosted integration runtime](https://docs.microsoft.com/en-us/azure/data-factory/create-self-hosted-integration-runtime)

##### Azure Integration Runtime
- This is required when you need to copy data between Azure and public cloud services.
- Further study: [How to create and configure Azure Integration Runtime](https://docs.microsoft.com/en-us/azure/data-factory/create-azure-integration-runtime)

##### Azure-SSIS integration runtime.
- This is required when you want to run existing SSIS packages natively.
- Further study: [Create Azure-SSIS Integration Runtime in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/create-azure-ssis-integration-runtime)  
  

##### Linked Service
- A linked service stores the connection information from the source dataset, like user credentials, server address and database name.
- Linked service will be used by the dataset.
- Further study: [Linked services in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/concepts-linked-services)

##### Activity
- An activity is the task that is executed, like copying data or performing a lookup. Activities use datasets to read or write data as the result of a pipeline.

##### Pipeline
- A pipeline is a group of activities linked together to form a data pipeline.
- Further study:
	- [Pipelines and activities in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/concepts-pipelines-activities)
	- [Datasets in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/concepts-datasets-linked-services)

##### Triggers
- A tumbling window can define the starting time in the WindowStart setting and the ending time in the WindowEnd setting, defining a time frame to run the data pipeline.
- Manual trigger – allow you to manually start pipelines
- Schedule trigger – schedule execution of pipeline
- Further study:
	- [Pipeline execution and triggers in Azure Data Factory](https://docs.microsoft.com/en-us/azure/data-factory/concepts-pipeline-execution-triggers)
	- [Create a trigger that runs a pipeline in response to an event](https://docs.microsoft.com/en-us/azure/data-factory/how-to-create-event-trigger)  
	- [Create a trigger that runs a pipeline on a schedule](https://docs.microsoft.com/en-us/azure/data-factory/how-to-create-schedule-trigger)  
	- [Create a trigger that runs a pipeline on a tumbling window](https://docs.microsoft.com/en-us/azure/data-factory/how-to-create-tumbling-window-trigger)

##### Databricks
- This is an Apache Spark-based technology that allows you to run code in notebooks.
- Code can be written in SQL, Python, Scala, and R.
- You can have data automatically generate pie charts and bar charts when you run a notebook.
- You can override the default language by specifying the language magic command (%language) at the beginning of a cell.
	- %Scala, %Python, %SQL, etc.
	- When working in a Jupyter notebook locally, the syntax is %%language