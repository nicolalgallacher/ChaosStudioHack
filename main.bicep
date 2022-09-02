//
//
//
//

targetScope ='subscription'

param location string = deployment().location
var resourceGroupName = 'ChaosHack'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

param vNetName string
param addressPrefix string 
param subnets array

param loadBalancerName string
param backendPoolName string

param imageOffer string
param imagePublisher string 
param imageSku string
param vmSize string 

module vNetSetup 'vNet_subnets.bicep' = {
  scope: resourceGroup
  name: 'vNetNameDeploy'
  params: {
    vNetName: vNetName
    addressPrefixes: addressPrefix
    subnets: subnets
    location: location
    //lbSubnetName: lbSubnetName
    //poolSubnetName: poolSubnetName
  }
}

//Create VMs in PoolSubnet (but this could be repurposed to make VMs in other subnets)
module vmCreation 'vm.bicep' = {
  scope: resourceGroup
  name: 'vmDeploy'
  params: {
    location: location
    //vmName: vmName
    poolSubnetID: vNetSetup.outputs.poolSubnetID
    imageOffer: imageOffer
    imagePublisher: imagePublisher
    imageSku: imageSku
    vmSize: vmSize
    backendPoolID: loadBalancerSetup.outputs.backendpoolID
  }
  dependsOn: [vNetSetup
  loadBalancerSetup]
}

module loadBalancerSetup 'loadBalancer.bicep' = {
  scope: resourceGroup
  name: 'lbDepoly'
  params: {
    loadBalancerName: loadBalancerName
    location: location
    backendPoolName: backendPoolName
    //lbSubnetName: lbSubnetName
    //vNetName: vNetName
    //lbSubnetID: vNetSetup.outputs.lbSubnetID
  }
  dependsOn: [vNetSetup]
}

