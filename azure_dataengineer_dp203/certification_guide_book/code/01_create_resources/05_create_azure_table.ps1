# Create and Set Variables
$resourceGroup = "<INSERT RESOURCE GROUP NAME>"
$storageAccount ="<INSERT STORAGE ACCOUNT NAME>"
$storageKey = "<INSERT STORAGE KEY>" # Use AAD
$region = "<INSERT REGION NAME>"
$tableName = "<INSERT QUEUE NAME>"

$env:AZURE_STORAGE_ACCOUNT=$storageAccount
$env:AZURE_STORAGE_KEY=$storageKey

# Create Azure Table
az storage table create \
    --name $tableName \ 
    --account-name $storageAccount

# List Tables
az storage table list \
    --account-name $storageAccount

# Add Entity
az storage entity insert \
    --table-name $tableName \ 
    --entity PartitionKey=testPartitionKey RowKey=testRowKey Content=testContent

# View Entity
az storage entity show \
--table-name $tableName \ 
--partition-key testPartKey \
--row-key testRowKey