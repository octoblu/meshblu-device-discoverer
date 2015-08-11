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
    @startDevice @chromecast
    @startDevice @lifx
    @startDevice @hue
    @search()

  search: =>
    debug 'Discoverer->search()'
    @searchForDevice @hue
    @searchForDevice @lifx
    @searchForDevice @chromecast
    debug 'searchInterval', @config.options.searchInterval
    _.delay @search, @config.options.searchInterval || 60 * 1000

  searchForDevice: (device) =>
    device.search()

  startDevice: (device) =>
    device.on 'device', @emitDevice
    device.on 'update', @updateDevice
    device.on 'error', @emitError
    device.start()

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
