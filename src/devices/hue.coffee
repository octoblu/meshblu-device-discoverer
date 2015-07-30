HueUtil        = require 'hue-util'
{EventEmitter} = require 'events'
_              = require 'lodash'
debug          = require('debug')('meshblu-device-discoverer:hue')

class Hue extends EventEmitter
  constructor: (@config)->
    @username = @config.username

  onUsernameChange: (username) =>
    debug 'onUsernameChange', username
    @username = username
    @emit 'update', username: @username

  search: =>
    debug 'searching for hue'
    @hue = new HueUtil 'octoblu', null, @username, @onUsernameChange
    @hue.getRawBridges (error, bridges) =>
      return @emit 'error', error if error?
      _.each bridges, @foundBridge

    @hue.getLights (error, lights) =>
      return @emit 'error', error if error?
      _.each _.keys(lights), (id) =>
        light = lights[id]
        light.id = id
        @foundLight light

  foundBridge: (ip) =>
    device =
      type: 'hue-bridge'
      device:
        ip: ip
    @emit 'device', device

  foundLight: (light) =>
    device =
      type: 'hue-light'
      device:
        light: light
    @emit 'device', device

module.exports = Hue
