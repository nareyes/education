# Create and Set Variables
$resourceGroup = "<INSERT RESOURCE GROUP NAME>"
$storageAccount ="<INSERT STORAGE ACCOUNT NAME>"
$storageKey = "<INSERT STORAGE KEY>" # Use AAD
$region = "<INSERT REGION NAME>"
$queueName = "<INSERT QUEUE NAME>"

$env:AZURE_STORAGE_ACCOUNT=$storageAccount
$env:AZURE_STORAGE_KEY=$storageKey

# Create Azure Queue
az storage queue create \
    --name $queueName 
    --account-name $storageAccount


# List Queues
az storage queue list \
    --account-name $storageAccount


# Add Message
az storage message put \
    --queue-name $queueName \
    --content "test"


# View Message
az storage message peek \
    --queue-name $queueName