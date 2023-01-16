# Exam Perspective
- Cosmos DB
	- 5 APIs are very important, you will see a few questions based on these.
	- You will get a scenario, and you will have to choose the best API for that given scenario.
	- If you found “graph” word in question, and Gremlin API is one of the options, that is the answer.
	- If SQL Like query is given in question - SQL API is the answer.
	- Partition is the next most important topic, you will definitely see a few questions based on this.
	- You will get the scenario and you will have to choose the right partition key.
	- Consistency level – You will see at least a few questions on this topic.
	- If you see “most recent committed version” in question – Strong consistency is the answer.
	- And if you see “Lowest Latency” in question – “Eventual consistency” is the answer.
	- Cosmos CLI is also important, you may see 1 or 2 question.
	- You will see a half-filled query to create a cosmos DB account, and you will have to choose the right option drop-down list to complete this query.

- Data Lake
	- This is not a very important topic for the exam, You may see 1 question
	- If you see “hierarchical namespace” in question, and one of the options is Data Lake, that is probably the right answer.

# General Notes

##### Blob Storage
- Always use a general-purpose v2 account.
- This account type incorporates all general-purpose v1 features, including blob storage.
- It delivers the lowest per-gigabyte capacity prices for Azure storage.

##### Block Blob Storage
- This is a specialized account type used to store block blobs and appends blobs.
- Low latency.
- Higher transaction rates.
- Block blob storage accounts only support premium tiers, which are more expensive than general-purpose v2 account types.

##### Table Storage
- Azure Table storage uses NoSQL, which allows you to store keys and attributes in a schema-less data store.
- This is similar to Cosmos DB with the Table API.
- Each entity (row) can store a varying number of attributes (fields). This allows different vendors to upload products with varying attributes.
- You can also use .NET to query the data.
- Further study:
	- [Azure Table storage overview](https://docs.microsoft.com/en-us/azure/cosmos-db/table-storage-overview)

##### Azure Data Lake
- Azure Data Lake is a big data storage solution that allows you to store data of any type and size.
- Repository for Big Data analytics workloads.
- Azure Data Lake Storage Gen2 has the capabilities of both Azure Blob Storage and Azure Data Lake Storage Gen1.
- Supports hierarchical namespaces.

##### Cosmos Table API
- Product with different number of attributes can be saved.
- Allows you to use OData and Language Integrated Query (LINQ) to query data.
- You can issue LINQ queries with .NET to query data.
- Does not support SQL-like queries from web applications.
- Further study:
	- [Introduction to Azure Cosmos DB: Table API](https://docs.microsoft.com/en-us/azure/cosmos-db/table-introduction)

##### Cosmos SQL API
- Allows you to use SQL to query data as JavaScript Object Notation (JSON) documents.
- You can use .NET to query Cosmos DB data that uses the SQL API.
- Supports a schema-less data store.

##### Cosmos Mongo API
- This API does not allow you to use SQL-like queries to access and filter data.

##### Cosmos Graph API
- This API does not support SQL-like queries.
- This API uses the Gremlin Graph Traversal Language to query data from a graph database.

##### Cosmos DB Partition key
- This partition key will distribute all the documents evenly across logical partitions.
- Further Study:
	- [Create a synthetic partition key](https://docs.microsoft.com/en-us/azure/cosmos-db/synthetic-partition-keys)
	- [Partitioning in Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/partitioning-overview)

##### Cosmos DB CLI
- Use GlobalDocumentDB to provision a Cosmos DB with the SQL API.

##### Cosmos DB Consistency Level
- Strong: This level is guaranteed to return the most recent committed version of a records.
- Eventual: Lowest latency. No guarantee of reading operations using the latest committed write.
- Session: The same user is guaranteed to read the same value within a single session. Even before replication occurs, the user that writes the data can read the same value. The user at the same location does not mean, they will be in the same session.
- Further study:
	- [Consistency levels in Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/consistency-levels)

##### Automatic Failover
- This is used to automatically failover Cosmos DB in disaster recovery scenarios.

##### Shared Access Signature
- SAS delegates access to blob containers in a storage account with granular control over how the client accesses your data.
- You can define a SAS token to allow access only to a specific blob container with a defined expiration.
- Further study:
	- [Grant limited access to Azure Storage resources using shared access signatures (SAS)](https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview)

##### Shared Key Authorization (Access Keys)
- Gives full administrative access to storage accounts, sometimes more access than necessary.
- Shared keys could be regenerated.
- They do not expire automatically.
- Further study:
	- [Authorize with Shared Key](https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key)

##### Azure Managed Disks
- These are virtual hard disks intended to be used as a part of Virtual Machine (VM) related storage.
