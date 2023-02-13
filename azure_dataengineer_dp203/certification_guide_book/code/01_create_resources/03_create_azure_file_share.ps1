# Create and Set Variables
$resourceGroup = "<INSERT RESOURCE GROUP NAME>"
$storageAccount ="<INSERT STORAGE ACCOUNT NAME>"
$storageKey = "<INSERT STORAGE KEY>" # Use AAD
$region = "<INSERT REGION NAME>"
$fileshareName = "<INSERT FILE SHARE NAME>"
$filePath = Data/testfile.txt

$env:AZURE_STORAGE_ACCOUNT=$storageAccount
$env:AZURE_STORAGE_KEY=$storageKey

# Create Azure File Share
az storage share-rm create \
    --resource-group $resourceGroup \
    --storage-account $storageAccount \
    --name $fileshareName \
    --quota 1024

# List File Shares
az storage share list \
    --account-name $storageAccount

# Add File
az storage file upload \
    --share-name $fileshareName \
    --source $filePath

# List Files
az storage file list \
    --share-name $fileshareName

# Download File
az storage file download \
    --share-name $fileshareName \
    --path testfile.txt \
    --dest ./testfile.txt