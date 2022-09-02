//
//
//

param location string 
param loadBalancerName string
var lbSku = 'Standard'

//param vNetName string
//param lbSubnetName string

var lbpublicIPname = 'lbpublicIP'
param backendPoolName string
var frontendName = 'loadBalancerFrontEnd'

//param lbSubnetID string 

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: lbpublicIPname 
  location: location
  sku: {
    name: lbSku
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-08-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name:lbSku
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendName
        properties:{
          publicIPAddress: {
            id: publicIP.id
          }
        }
        
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName 
      }
    ]
    loadBalancingRules: [
      {
        name: 'HTTPrule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, frontendName)//publicIP.id
          }
          backendAddressPool: {
            id:  resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)
          }
          frontendPort: 80
          backendPort: 80
          protocol: 'Tcp'
          loadDistribution: 'Default'
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, 'lbProbe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'lbProbe'
        properties: {
          port: 80
          protocol: 'Tcp'
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
  dependsOn: [
    publicIP
  ]
}

output backendpoolID string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)
