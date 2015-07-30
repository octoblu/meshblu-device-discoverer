{Client}       = require 'node-lifx'
{EventEmitter} = require 'events'
_              = require 'lodash'
debug          = require('debug')('meshblu-device-discoverer:lifx')

class Lifx extends EventEmitter
  search: =>
    debug 'searching for lifx'
    @client = new Client
    @client.on 'bulb-new', @found
    lights = @client.lights()
    _.each lights, @found
    @client.init()

  found: (light) =>
    delete light.client
    device =
      type: 'lifx'
      device: light
    @emit 'device', device

module.exports = Lifx
