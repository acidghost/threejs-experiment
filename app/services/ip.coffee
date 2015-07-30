os = require('os')

module.exports = ->
  interfaces = os.networkInterfaces()
  addresses = []
  for k of interfaces
    for k2 of interfaces[k]
      address = interfaces[k][k2]
      if address.family == 'IPv4' and !address.internal
        addresses.push address.address
  addresses
