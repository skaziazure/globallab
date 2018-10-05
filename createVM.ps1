

$resourceGroup = "GRP-NA-LAB-FUNC-RG1"
$vmName = "CENAAZ-SHUMAZ1T"
$vnet = "GRP-NA-SHARED-LAB-RG1-vnet"
$location = "eastus2"
$publicIP = "$vmName-PIP"
$nic = "$vmName-NIC"
$userID = "skazi"
$password = "Testing@123"
$cle = ConvertTo-SecureString -String $password -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential $userID,$cle
$subscription_id = "f386634b-3dfd-47f8-af84-7fe9d01952f4"
$tenant_id = "a289d6c2-3b1f-4bc4-8fa0-6866ff300052"
$vnetRG = "GRP-NA-SHARED-LAB-RG1"
$nsgID = "$vmName-NSG"

$AzureRMAccount = Login-AzureRmAccount 

if ($AzureRMAccount){

#Set the Subscription

	Set-AzureRmContext  -SubscriptionId $subscription_id  -TenantId $tenant_id

#Get the VNET

   $vnet = Get-AzureRmVirtualNetwork -Name $vnet -ResourceGroupName $vnetRG

# Create a public IP address and specify a DNS name

    $pip = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
    -Name $publicIP -AllocationMethod Static -IdleTimeoutInMinutes 4

 # Create a network security group

    $nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
    -Name $nsgID
  
# Create a virtual network card and associate with public IP address

    $nic = New-AzureRmNetworkInterface -Name $nic -ResourceGroupName $resourceGroup -Location $location `
    -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id
   
  
# Create a virtual machine configuration

	$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize Standard_D1 | `
	Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -Credential $credentials | `
	Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
	Add-AzureRmVMNetworkInterface -Id $nic.Id

# Create a virtual machine

   New-AzureRmVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig


}