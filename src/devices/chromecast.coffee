{EventEmitter} = require 'events'
mdns           = require 'mdns-js'
_              = require 'lodash'
debug          = require('debug')('meshblu-device-discoverer:chromecast')

class Chromecast extends EventEmitter
  constructor: ->

  start: =>
    debug 'starting for chromecast'
    browser = mdns.createBrowser mdns.tcp('googlecast')
    browser.on 'update', @found
    browser.on 'ready', =>
      browser.discover();

  search: =>
    debug 'searching for chromecast'

  saneifyData: (data) =>
    device = {}
    device.address = _.first data.addresses
    device.addresses = data.addresses
    device.name = data.host.replace '.local', '' if data.host
    device.name ?= data.host
    device.port = data.port
    txtRecord = {}
    _.each data.txt, (item) =>
      return unless item?
      items = item.split '='
      txtRecord[items[0]] = items[1]
    device.txtRecord = txtRecord
    device.types = _.pluck data.type, 'name'
    return device;

  found: (data={}) =>
    chromecast = @saneifyData data
    debug 'found chromecast', state: 'update', chromecast
    device =
      state: 'update'
      id: chromecast.name
      type: 'device:chromecast'
      connector: 'meshblu-chromecast'
      device: chromecast
    @emit 'device', device

module.exports = Chromecast
