'use strict';
{EventEmitter} = require 'events'
_              = require 'lodash'
async          = require 'async'
Discoverer     = require './src/discoverer'
debug          = require('debug')('meshblu-device-discoverer:index')

MESSAGE_SCHEMA =
  type: 'object'
  properties: {}

OPTIONS_SCHEMA =
  type: 'object'
  properties:
    searchInterval:
      type: 'number',
      required: true
      default: 60 * 1000

class Plugin extends EventEmitter
  constructor: ->
    debug 'starting plugin...'
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA
    @queue = async.queue @refreshQueue

  updateDevice: (properties={})=>
    @emit 'update', properties

  emitError: (error) =>
    debug 'emitting error', error
    return console.error error
    @emit 'message',
      devices: '*'
      topic: 'error'
      payload:
        error: error

  emitDevice: (device) =>
    @queue.push
      devices: '*'
      topic: 'discovered_device'
      payload: device

  refreshQueue: (task, callback=->)=>
    debug 'emitting device', task
    @emit 'message', task
    _.delay callback, 500

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
    @options = _.extend searchInterval: 60 * 1000, options

module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
