# Create and Set Variables
$subscriptionName = "<INSERT SUBSCRIPTION NAME>"
$resourceGroup = "<INSERT RESOURCE GROUP NAME>"
$region = "<INSERT REGION NAME>"

# Set Subscription
az account set \
    --subscription $subscriptionName

# Create Resource Group
az group create \
    --name $resourceGroup 
    --location $region