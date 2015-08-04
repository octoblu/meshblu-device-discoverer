{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-device-discoverer:discoverer')
_              = require 'lodash'
Chromecast     = require './devices/chromecast'
Lifx           = require './devices/lifx'
Hue            = require './devices/hue'

class Discoverer extends EventEmitter
  constructor: (@config={})->
    @chromecast = new Chromecast @config
    @lifx       = new Lifx @config
    @hue        = new Hue @config

  start: =>
    debug 'Discoverer->start()'
    _.delay @start, 30 * 1000
    @searchForDevice @chromecast
    @searchForDevice @lifx
    @searchForDevice @hue

  searchForDevice: (device) =>
    device.search()
    device.on 'device', @emitDevice
    device.on 'update', @updateDevice
    device.on 'error', @emitError

  updateDevice: (properties={}) =>
    debug 'Discoverer->udpateDevice()'
    @emit 'update', properties

  emitDevice: (device) =>
    debug 'Discoverer->emitDevice()'
    @emit 'device', device

  emitError: (error) =>
    debug 'Discoverer->emitError()'
    @emit 'error', error

module.exports = Discoverer
