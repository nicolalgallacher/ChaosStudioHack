//
//  Creates vNets & Subnets contained in the array parameter
//  Also creates a Bastion Subnet 
//  Creates an NSG allowing inbound traffic on port 80, attatches to all Subnets 

param vNetName string
param addressPrefixes string

param subnets array
param location string

param bastionSubnetName string
param bastionSubnetPrefix string

var poolSubnetName = 'vmSubnet' //TODO should be changed to a parameter

//param natGatewayID string

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'nsg_chaos'
  location: location 
   properties: {
    securityRules: [
       {
         name: 'AllowHTTPinbound'
          properties: {
            direction:  'Inbound'
            protocol:  'Tcp'
            access:  'Allow'
            sourceAddressPrefix: '*'
            sourcePortRange: '*'
            destinationPortRange: '80'
            description: 'Allow Inbound HTTP Traffic from Any to Any'
            destinationAddressPrefix: '*'
            priority: 100
          }
       }
    ] 
   } 
}

resource vNet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixes
      ]
    }
  }
}

@batchSize(1)
resource Subnets 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = [for (sn, index) in subnets : { 
  parent: vNet
  name: sn.name
  properties: {
    addressPrefix: sn.subnetPrefix 
    networkSecurityGroup: {
       id: nsg.id
    }
    // natGateway: {
    //    id: natGatewayID
    //  }
  } 
}]

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${vNetName}/${bastionSubnetName}'
  properties: {
    addressPrefix: bastionSubnetPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
   dependsOn: [
    Subnets
   ]
}

resource bastionIP 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'bastionIP'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: 'bastionHost'
  location: location
  properties: {
    ipConfigurations: [
       {
         name: 'bastionIPconfig'
          properties: {
            publicIPAddress: {
               id: bastionIP.id
            }
            subnet: {
               id: bastionSubnet.id
            }
          }
       }
    ]
  }
   dependsOn: [
    vNet
   ]
}


//Used to pass into VM creation so they know what subnet to be created in
output poolSubnetID string = resourceId('Microsoft.Network/VirtualNetworks/subnets', vNetName, poolSubnetName) 
