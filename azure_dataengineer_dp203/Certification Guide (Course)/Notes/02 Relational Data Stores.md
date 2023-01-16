# Exam Perspective

##### PolyBase
- 6 steps are very important. You should remember all 6 steps in sequence. You will get a question, where you will be given many steps, and you will have to choose the right steps and put those steps in sequence;
	- Create a master key
	- Create a database scoped credential with the storage key
	- Create an external data source
	- Create an external file format
	- Create an external table
	- Load from the external table
- PolyBase instructions from Microsoft Learn;
	- Extract the source data into text files
	- Land the data into Azure Blob Storage or ADLS Gen2 Storage
	- Prepare the data for loading
	- Load the data into dedicated SQL pool staging tables using PolyBase
	- Transform the data
	- Insert the date into production tables

##### Azure SQL Data Warehouse
- Data distribution is very important. You should have a clear understanding about three distribution methods. Scenarios will be given, and you will be asked to choose the right distribution method.
	- Replicate
	- Hash
	- Round Robin
- Geo-replication was removed from the syllabus on July 31, 2020. But even after that questions are coming based on this concept, maybe Microsoft has not updated their test yet.

# General Notes

##### Managed Instance Deployment
- The managed instance deployment option is useful if you have an on-premises SQL Server instance with multiple databases that must all be moved to the cloud.
- This deployment option is almost 100% compatible with an on-premises instance.
- All databases in a managed instance deployment share the same resources.
- Further study: [What is Azure SQL Database managed instance?](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-managed-instance)

##### Elastic Pool
- An elastic pool allows you to deploy multiple databases to a single logical instance and have all databases share a pool of resources.
- All on-premises features are not available with Azure SQL Server or Elastic Pool 
	- You cannot take advantage of CLR features with an elastic pool.
- Further study: [Elastic pools help you manage and scale multiple Azure SQL databases](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-pool)

##### Data Sync
- Data Sync is a service that lets you synchronize data across multiple Azure SQL Databases and on-premises SQL Server instances bi-directionally.
- This is not the preferred solution for disaster recovery scenarios.
- Further study: [Sync data across multiple cloud and on-premises databases with SQL Data Sync](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-sync-data)

##### Geo-Replication
- Active geo-replication is a disaster recovery solution for Azure SQL Database that allows replicating a database to another Azure region.
- The synchronization direction is only from the master to the replica database, and you only have read access to the replica database.
- Further study:
	- [Creating and using active geo-replication](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-active-geo-replication)
	- [Sync data across multiple cloud and on-premises databases with SQL Data Sync](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-sync-data)

##### Data Migration Assistance
- DMA is an assessment tool for migrating SQL Server instances to Azure SQL Database.
- It evaluates incompatibilities and recommends performance improvements for the target database.
- Further study: [Overview of Data Migration Assistant](https://docs.microsoft.com/en-us/sql/dma/dma-overview)

##### Azure Database Migration Service
- This is a fully managed service to migrate multiple database sources to Azure with minimal downtime.
- Further study: [What is Azure Database Migration Service?](https://docs.microsoft.com/en-us/azure/dms/dms-overview)

##### Data Redundancy Strategy
- Local Redundant Storage (LRS): Replicate data in the same availability zone. This redundancy level will expose the application in case of an Azure outage in a specific availability zone.
- Zone Redundant Storage (ZRS): This redundancy strategy replicates data in other availability zones in the same Azure region.
- Geo Redundant Storage (GRS): This redundancy strategy will replicate data to another Azure region.
- Further Study: Azure Storage redundancy

##### SQL Server Agent
- This solution allows you to run administrative tasks in a specific database.
- Only supported in on-premises SQL Server instances or Azure SQL managed instances.
- Further Study: [SQL Server Agent](https://learn.microsoft.com/en-us/sql/ssms/agent/sql-server-agent?view=sql-server-ver16)

##### Elastic Database Jobs
- Allows you to run jobs against all the databases in the elastic pool.
- Supports PowerShell scripts.
- Job definition is stored in a job database.
- Internal system databases in the elastic pool are configured in a target group.
- Further study:
	- [Automate management tasks using database jobs](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-job-automation-overview)
	- [Create, configure, and manage elastic jobs](https://docs.microsoft.com/en-us/azure/sql-database/elastic-jobs-overview)

##### Azure Alerts Action Group
- An action group is a collection of notification preferences used by Azure Monitor to respond to an alert.
- These notification preferences could also include automated remediation actions, like executing an Azure function or running an automated runbook written in PowerShell.
- An action group should be attached to an alert.
- You need to manually create all the connection and target servers logic in a runbook script, which increases administrative efforts.
- Further study: C[reate and manage action groups in the Azure portal](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups)

##### Columnstore Index
- In-memory table used in operational analytics.

##### Azure SQL Data Warehouse
- SQL Data Warehouse allows you to perform parallel queries using MPP architecture on Big Data

##### Distribution Method
- Replicate: A replicated table is copied across all the compute nodes in a data warehouse. This improves the performance of queries for data in small tables.
	- Small dimension tables in a star schema with less than 2GB of storage after compression
- Hash: Data is sharded across compute nodes by a column that you specify. Useful for large tables.
	- Fact tables
	- Large-dimension tables
- Round Robin: A round-robin distribution shards data evenly. Generally useful for staging tables.
	- Default distribution method
	- Temporary or staging tables
	- No obvious joining key or good candidate column
- Further study: [Guidance for designing distributed tables in Azure SQL Data Warehouse](https://docs.microsoft.com/en-us/azure/sql-data-warehouse/sql-data-warehouse-tables-distribute)

##### Deciding Distribution Method
- Which table should be used in which scenario?
	- For a large fact table, you should create a hash-distributed table. 
		- Query performance improves when the table is joined with a replicated table or with a table that is distributed on the same column. 
		- This avoids data movement.
	- For a staging table with unknown data, you should create a round-robin distributed table. 
		- The data will be evenly distributed across the nodes, and no distribution column needs to be chosen.
	- For a small dimension table, you should use a replicated table. 
		- No data movement is involved when the table is joined with another table on any column.
	- For a table that has queries that scan a date range, you should create a partitioned table. 
		- Partition elimination can improve the performance of the scans when the scanned range is a small part of the table.

##### Data Masking and Encryption
- Data masking functions are important, you will be given an example, and asked which function you should use to get this desire result. Or if you use this function, what will be the output.
- You will see few question based on TDE and Always encryption. Make sure you have good understanding about difference between these two.
- Deterministic Encryption: Encrypted to the same value every time
- Randomized encryption: Encrypted to different value every time
- Further study (data masking):
	- Documentation and available functions: [Dynamic Data Masking](https://docs.microsoft.com/en-us/sql/relational-databases/security/dynamic-data-masking?view=sql-server-2017)  
	- [SQL Database dynamic data masking](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-dynamic-data-masking-get-started)
- Further study (always encryption):
	- [Always Encrypted (Database Engine)](https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/always-encrypted-database-engine?view=sql-server-2017)  
	- [Always Encrypted (client development)](https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/always-encrypted-client-development?view=sql-server-2017)

##### Advance Data Security
- Advanced Data Security is a package that helps to find and classify sensitive data.
- It also identifies potential database vulnerabilities and anomalous activity, which may indicate a threat to your Azure SQL Database
- Further study: [Advanced data security for Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-advanced-data-security)

##### Row-level Security
- Row-level security is not in syllabus, but you may still see questions based on it.
- Good link to read about Row-level security: [https://www.sqlshack.com/introduction-to-row-level-security-in-sql-server/](https://www.sqlshack.com/introduction-to-row-level-security-in-sql-server/)
- Further study: [Row-Level Security](https://docs.microsoft.com/en-us/sql/relational-databases/security/row-level-security?view=sql-server-2017)
