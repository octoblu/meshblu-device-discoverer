{Client}       = require 'node-lifx'
{EventEmitter} = require 'events'
_              = require 'lodash'
debug          = require('debug')('meshblu-device-discoverer:lifx')

class Lifx extends EventEmitter
  start: =>
    debug 'starting for lifx'
    @client = new Client
    @client.on 'bulb-new', @found
    @client.init()

  search: =>
    debug 'searching for lifx'
    lights = @client.lights()
    _.each lights, @found

  found: (light) =>
    delete light.client
    debug 'found lifx light', light
    device =
      id: light.id
      type: 'device:lifx-light'
      connector: 'meshblu-lifx-light'
      device: light
    @emit 'device', device

module.exports = Lifx
