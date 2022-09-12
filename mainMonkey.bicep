//
// Subcription Spoke Deployment
// Creates vNet with Subnets defined in parameters files + Bastion subnet
// Creates Load Balancer with Public IP address 
// Creates VMs for the backend pool subnet       
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

param bastionSubnetName string
param bastionSubnetPrefix string

param loadBalancerName string
param backendPoolName string

param imageOffer string
param imagePublisher string 
param imageSku string
param vmSize string 

// module netGateway 'natGateway.bicep' = {
//   scope: resourceGroup
//   name: 'natGatewayDeploy'
//   params: {
//     location: location
//   }
// }

module vNetSetup 'modules/vNet_subnets.bicep' = {
  scope: resourceGroup
  name: 'vNetNameDeploy'
  params: {
    vNetName: vNetName
    addressPrefixes: addressPrefix
    subnets: subnets
    location: location
    bastionSubnetName: bastionSubnetName
    bastionSubnetPrefix: bastionSubnetPrefix
    //poolSubnetName: loadBalancerSetup.output
    //natGatewayID: netGateway.outputs.natgatewayID
  }
  //  dependsOn: [
  //    netGateway
  //  ]
}

//Create VMs in PoolSubnet (but this could be repurposed to make VMs in other subnets)
module vmCreation 'modules/vm.bicep' = {
  scope: resourceGroup
  name: 'vmDeploy'
  params: {
    location: location
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

module loadBalancerSetup 'modules/loadBalancer.bicep' = {
  scope: resourceGroup
  name: 'lbDepoly'
  params: {
    loadBalancerName: loadBalancerName
    location: location
    backendPoolName: backendPoolName
  }
  dependsOn: [vNetSetup]
}

