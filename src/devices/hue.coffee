HueUtil        = require 'hue-util'
{EventEmitter} = require 'events'
_              = require 'lodash'
debug          = require('debug')('meshblu-device-discoverer:hue')

class Hue extends EventEmitter
  constructor: (@config)->
    debug 'on config', apikey: @config.apikey
    @apikey = @config.apikey || {}

  onUsernameChange: (username) =>
    debug 'onUsernameChange', username
    @apikey.username = username
    @emit 'update', apikey: @apikey

  start: =>

  search: =>
    debug 'searching for hue'
    bridgeHue = new HueUtil 'octoblu', null, @apikey?.username, @onUsernameChange
    bridgeHue.getRawBridges (error, bridges) =>
      return @emit 'error', error: error, type: 'hue-bridge' if error?
      _.each bridges, @foundBridge

  startForBridge: (bridge) =>
    hue = new HueUtil 'octoblu', bridge?.internalipaddress, @apikey?.username, @onUsernameChange
    hue.getLights (error, lights) =>
      return @emit 'error', error: error, type: 'hue-light' if error?
      _.each _.keys(lights), (id) =>
        light = lights[id]
        light.id = id
        @foundLight light

  foundBridge: (bridge) =>
    debug 'found hue-bridge', bridge
    device =
      type: 'hue-bridge'
      device: bridge
    @emit 'device', device
    @startForBridge bridge

  foundLight: (light) =>
    debug 'found hue-light', light
    device =
      type: 'hue-light'
      device:
        light: light
    @emit 'device', device

module.exports = Hue
