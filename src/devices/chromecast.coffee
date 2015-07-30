{EventEmitter} = require 'events'
scanner        = require 'chromecast-scanner'
debug          = require('debug')('meshblu-device-discoverer:chromecast')

class Chromecast extends EventEmitter
  search: =>
    debug 'searching for chromecast'
    scanner (error, service) =>
      return debug 'error scanning', error if error?
      @found service

  found: (chromecast) =>
    debug 'found chromecast', chromecast
    device =
      type: 'chromecast'
      device: chromecast
    @emit 'device', device

module.exports = Chromecast
