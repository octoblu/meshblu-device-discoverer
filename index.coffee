'use strict';
{EventEmitter} = require 'events'
Discoverer     = require './src/discoverer'
debug          = require('debug')('meshblu-device-discoverer:index')

MESSAGE_SCHEMA =
  type: 'object'
  properties: {}

OPTIONS_SCHEMA =
  type: 'object'
  properties: {}

class Plugin extends EventEmitter
  constructor: ->
    debug 'starting plugin...'
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA

  updateDevice: (properties={})=>
    @emit 'update', properties

  emitError: (error) =>
    debug 'emitting error', error
    @emit 'message',
      devices: ['*']
      topic: 'error'
      payload:
        error: error

  emitDevice: (device) =>
    debug 'emitting device', device
    @emit 'message',
      devices: ['*']
      topic: 'discovered_device'
      payload:
        device: device

  onMessage: (message) =>
    payload = message.payload;
    debug 'onMessage', payload

  startDiscovery: =>
    debug 'starting discovery'
    @discoverer = new Discoverer @config
    @discoverer.start()
    @discoverer.on 'error', @emitError
    @discoverer.on 'device', @emitDevice
    @discoverer.on 'update', @updateDevice

  onConfig: (device) =>
    @config = device
    @startDiscovery()
    @setOptions device.options

  setOptions: (options={}) =>
    @options = options

module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
