{EventEmitter} = require 'events'
debug          = require('debug')('meshblu-device-discoverer:discoverer')
_              = require 'lodash'
Chromecast     = require './devices/chromecast'
Lifx           = require './devices/lifx'
Hue            = require './devices/hue'

SEARCH_INTERVAL=3 * 60 * 1000

class Discoverer extends EventEmitter
  constructor: (@config={})->
    @config.options ?= {}
    @config.options.searchInterval ?= SEARCH_INTERVAL
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
    searchInterval = @config.options?.searchInterval || SEARCH_INTERVAL
    debug 'searchInterval', searchInterval
    _.delay @search, searchInterval

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
