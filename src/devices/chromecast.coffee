{EventEmitter} = require 'events'
mdns           = require 'mdns'
_              = require 'lodash'
debug          = require('debug')('meshblu-device-discoverer:chromecast')

class Chromecast extends EventEmitter
  constructor: ->


  search: =>
    debug 'searching for chromecast'
    browser = mdns.createBrowser mdns.tcp('googlecast')
    browser.on 'serviceUp', @found
    browser.start();

  found: (chromecast={}) =>
    chromecast = _.pick chromecast, ['name', 'host', 'type', 'port', 'fullname', 'networkInterface', 'txtRecord', 'addresses']
    debug 'found chromecast', chromecast
    device =
      type: 'chromecast'
      device: chromecast
    @emit 'device', device

module.exports = Chromecast
