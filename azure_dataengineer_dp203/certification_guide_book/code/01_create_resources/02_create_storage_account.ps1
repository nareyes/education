# Create and Set Variables
$resourceGroup = "<INSERT RESOURCE GROUP NAME>"
$storageAccount ="<INSERT STORAGE ACCOUNT NAME>"
$region = "<INSERT REGION NAME>"

# Create Storage Account
az storage account create \
    --name $storageAccount \
    --resource-group $resourceGroup \
    --location $region \
    --kind StorageV2 \
    --sku Standard_LRS

# Create Storage Account ADLS Gen2
az storage account createm \
    --name $storageAccount \
    --resource-group $resourceGroup \
    --location $region \
    --sku Standard_LRS \
    --enable-hierarchical-namespace True