# Exam Perspective
- Windowing functions will be going to dominate this section in the exam.
- Also, you should understand the difference between the event hub and IoT hub.
- One question can be on Reference data (similar to dimensions), which can be put on SQL Server or Blob.

# General Notes
##### Stream Analytics
- Big data analytics solution that allows you to analyze real-time events simultaneously.
- The input data source can be an event hub, an IoT hub, blob storage or SQL Server.
- The reference input is data that never or rarely changes (such as dimensions). Reference data can be saved in Azure SQL Database or Blob storage.
- Further study: [What is Azure Stream Analytics?](https://docs.microsoft.com/en-us/azure/stream-analytics/stream-analytics-introduction)

##### Event Hubs
- Event Hub is an Azure resource that allows you to stream big data to the cloud.
- Event Hub accepts streaming telemetry data from other sources. It is basically a big data pipeline. It allows you to capture, retain, and replay telemetry data.
- It accepts streaming data over HTTPS and AMQP.
- A Stream Analytics job can read data from Event Hubs and store the transformed data in a variety of output data sources, including Power BI.

##### IOT Hub
- IoT Hub is an Azure resource that allows you to stream big data to the cloud.
- It supports per-device provisioning.
- It accepts streaming data over HTTPS, AMQP, and Message Queue Telemetry Transport (MQTT).
- A Stream Analytics job can read data from IOT Hubs and store the transformed data in a variety of output data sources, including Power BI.
- Further study:
	- [Choosing a real-time message ingestion technology in Azure](https://docs.microsoft.com/en-us/azure/architecture/data-guide/technology-choices/real-time-ingestion)  
	- [Choosing a stream processing technology in Azure](https://docs.microsoft.com/en-us/azure/architecture/data-guide/technology-choices/stream-processing)
	- [Choose between Azure messaging services - Event Grid, Event Hubs, and Service Bus](https://docs.microsoft.com/en-us/azure/event-grid/compare-messaging-services)

##### Windowing Functions
- [Introduction to Stream Analytics windowing functions](https://docs.microsoft.com/en-us/azure/stream-analytics/stream-analytics-window-functions)

###### Tumbling Windows
- Tumbling windows are a series of fixed-sized, non-overlapping and contiguous time intervals.
- Each event is only counted once.
- However, they do not check the time duration between events and do not filter out periods of time when no events are streamed.
- Future study: [Tumbling Window (Azure Stream Analytics)](https://docs.microsoft.com/en-us/stream-analytics-query/tumbling-window-azure-stream-analytics)

###### Hopping Windows
- Hopping windows are a series of fixed-sized and contiguous time intervals. 
- They hop forward by a specified fixed time. 
- If the hop size is less than a size of the window, hopping windows overlap, and that is why an event may be part of several windows.
- Hopping windows do not check the time duration between events and do not filter out periods of time when no events are streamed.
- Further study: [Hopping Window (Azure Stream Analytics)](https://docs.microsoft.com/en-us/stream-analytics-query/hopping-window-azure-stream-analytics)

###### Sliding Windows
- Sliding windows are a series of fixed-sized and contiguous time intervals. 
- They produce output only when an event occurs, so you can filter out periods of times where no events are streamed.
- However, they may overlap and that is why an event may be included in more than one window. 
- Sliding windows also do not check the time duration between events.
- Further study: [Sliding Window (Azure Stream Analytics)](https://docs.microsoft.com/en-us/stream-analytics-query/sliding-window-azure-stream-analytics)

###### Session Windows
- Session windows begin when the defect detection event occurs, and they continue to extend, including new events occurring within the set time interval (timeout).
- If no further events are detected, then the window will close. 
- The window will also close if the maximum duration parameter is set for the session window, and then a new session window may begin.
- The session window option will effectively filter out periods of time where no events are streamed. 
- Each event is only counted once.
- Further study: [Session window (Azure Stream Analytics)](https://docs.microsoft.com/en-us/stream-analytics-query/session-window-azure-stream-analytics)

  
##### Other Concepts
###### Event Grid
- Event Grid is a publish-subscribe platform for events. 
- Event publishers send the events to Event Grid. 
- Subscribers subscribe to the events they want to handle.  
  
###### Azure Relay
Azure Relay allows client applications to access on-premises services through Azure.

###### HDInsight
- HDInsight is a streaming technology that allows you to use C#, F#, Java, Python, and Scala.
- It does not allow you to use a SQL-like language.

###### WebJob
- WebJob runs in the context of an Azure App Service app.
- It can be invoked on a schedule or by a trigger.
- You can use C#, Java, Node.js, PHP, Python to implement WebJobs.
- However, you cannot use a SQL-like language.

###### Function App
- A function app is similar to a WebJob in that it can be invoked on a schedule or by a trigger.
- You can use many different languages to create a function in a function app.
- However, you cannot use a SQL-like language.