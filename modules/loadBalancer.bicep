//
// Load Balancer Module
// Creates Standard Lb with Public IP address 
// Inbound rule of 80 > 80 allow
// Health probe checking port 80
// 
//

param location string 
param loadBalancerName string
var lbSku = 'Standard'

var lbpublicIPname = 'lbpublicIP'
param backendPoolName string
var frontendName = 'loadBalancerFrontEnd'

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
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          protocol: 'Tcp'
          loadDistribution: 'Default'
          disableOutboundSnat: true
          enableTcpReset: true
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
    outboundRules: [
       {
         name: 'outboundRule'
         properties: {
          allocatedOutboundPorts: 10000
          enableTcpReset: false
          idleTimeoutInMinutes: 15          
          frontendIPConfigurations:  [
             {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, frontendName)
             }
          ] 
          backendAddressPool: {
              id:  resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)

          }
          protocol: 'All'
         }
        
       }
    ]
  }
  dependsOn: [
    publicIP
  ]
}

// Used by VM creation to put VMs in the backend pool of the load balancer
output backendpoolID string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)


//Not used but code to create a NAT Rule on the Load Balancer
// resource natRule 'Microsoft.Network/loadBalancers/inboundNatRules@2022-01-01' = {
//     name: '${loadBalancerName}/iisHTTPNATrule'
//      properties: {
//        backendAddressPool: {
//           id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)
//        } 
//        backendPort: 80
//        frontendIPConfiguration: {
//           id: loadBalancer.properties.frontendIPConfigurations[0].id
//        } 
//        frontendPort:222 
//        //frontendPortRangeStart: 80
//        //frontendPortRangeEnd: 90
//        protocol: 'Tcp'
//        idleTimeoutInMinutes: 4
//      }
// }
