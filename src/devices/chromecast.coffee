{EventEmitter} = require 'events'
mdns           = require 'mdns'
_              = require 'lodash'
debug          = require('debug')('meshblu-device-discoverer:chromecast')

class Chromecast extends EventEmitter
  constructor: ->

  start: =>
    debug 'starting for chromecast'
    browser = mdns.createBrowser mdns.tcp('googlecast')
    browser.on 'serviceUp', @found 'serviceUp'
    browser.on 'serviceDown', @found 'serviceDown'
    browser.start();

  search: =>
    debug 'searching for chromecast'

  found: (state) =>
    (chromecast={}) =>
      chromecast = _.pick chromecast, ['name', 'host', 'type', 'port', 'fullname', 'networkInterface', 'txtRecord', 'addresses']
      debug 'found chromecast', state: state, chromecast
      device =
        state: state
        id: chromecast.name
        type: 'device:chromecast'
        connector: 'meshblu-chromecast'
        device: chromecast
      @emit 'device', device

module.exports = Chromecast
