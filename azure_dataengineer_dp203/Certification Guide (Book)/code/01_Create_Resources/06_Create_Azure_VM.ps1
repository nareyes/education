# Create and Set Variables
$resourceGroup = "<INSERT RESOURCE GROUP NAME>"
$region = "<INSERT REGION NAME>"
$vmName = "sampleVM"
$password = "<INSERT SAMPLE PASSWORD>" # Use AAD
$image = "UbuntuLTS"
$diskName = "sampleDisk"
$subnetName = "sampleSubnet"
$pubIpName = "samplePubIp"
$vnetName = "sampleVnet"
$nicName = "sampleNIC"

# Find Available Ubuntu Images
az vm image list \
    --all \
    --offer Ubuntu \
    --all

# Find Azure Regions
az account list \
    -locations \
    --output table

# Create VM
az vm create \
    --resource-group $resourceGroup \
    --name $vmName \
    --image $image \
    --admin-username  \
    --admin-password $password \
    --location $region

# Create and Attach Managed Disk
az vm disk attach \
    --resource-group $resourceGroup \
    --vm-name $vmName \
    --name $diskName \
    --size-gb 64 -new


## Create an Azure VNet and VM
# Create VNet
az network vnet create \
    --address-prefixes 10.20.0.0/16 \
    --name $vnetName \
    --resource-group $resourceGroup \
    --subnet-name $subnetName \
    --subnet-prefixes 10.20.0.0/24

# Create Public IP
az network public-ip create \
    --resource-group $resourceGroup \
    --name $pubIpName \
    --allocation-method dynamic

# Create Network Interface Card (NIC)
az network nic create \
    --resource-group $resourceGroup \
    --vnet-name $vnetName \
    --subnet $subnetName  \
    --name $nicName \
    --public-ip-address $pubIpName

# Create VM Within VNet
az vm create \
    --resource-group $resourceGroup \
    --name $vmName \
    --nics $nicName \
    --image $image \
    --generate-ssh-keys