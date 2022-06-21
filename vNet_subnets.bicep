//
//  
//

param vNetName string
param addressPrefixes string

param subnets array
param location string

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
  
resource Subnets 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = [for (sn, index) in subnets : {
  parent: vNet
  name: sn.name
  properties: {
    addressPrefix: sn.subnetPrefix
  }
  //dependsOn: [vNet]
}]

 