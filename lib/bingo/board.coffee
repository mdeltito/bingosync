_            = require('lodash')
url          = require('url')
jsdom        = require('jsdom')
jQuery       = require('jquery')
crypto       = require('crypto')
Phantom      = require('phantom')
Promise      = require('bluebird')
EventEmitter = require('events').EventEmitter

module.exports = (_store, _config_data)->
  class Board extends EventEmitter
    namespace: 'board'
    constructor: (session, callback = ->)->
      @seed = session.seed
      @session = session
      @key = "bingo:#{@namespace}:#{@session.key}"
      @url = @get_url(session.type)

    get_url: (type)->
      config = _.find(_config_data.types, {code: type})
      urlObj = url.parse(config.url) 
      urlObj.query = {seed: @seed}

      if config.params
        urlObj.query = _.extend(config.params, urlObj.query)
      url.format urlObj
      
    set: Promise.promisify(_store.set, _store)
    load: Promise.promisify(_store.get, _store)

    save: (table)->
      @set(@key, table)
        .then (status)->
          return table

    get: ()->
      @load @key
        .then (reply)=>
          if !reply
            return @fetch().then (table)=>
              return @save(table)
          else
            return reply

    fetch: ()->
      page = null
      instance = null

      Phantom.create()
        .then (_instance)=>
          instance = _instance
          instance.createPage()
        .then (_page)=>
          page = _page
          page.open @url
        .then (status)=>
          bingoHtml = page.evaluate =>
            document.getElementById('bingo').outerHTML
        .then (_html)=>
          page.close()
          instance.exit()
          html = _html
        .catch (error)=>
          console.log error
          instance.exit()
          
    update: (square, color)->
      $ = jQuery(jsdom.jsdom().defaultView)

      @get()
        .then (table)=>
          $table = $(table)
          $square = $table.find("#" + square)
          classes = $square[0].className.split(/\s+/)
          color_class = "btn-#{color}"

          # if the square was previously selected by the user,
          # or is not already locked
          if _.includes(classes, color_class) or not $square.hasClass("locked")
            $square.toggleClass color_class
            $square.toggleClass "locked"
            @table = $table[0].outerHTML
            return @set(@key, @table)
          else
            @table = $table[0].outerHTML
        .then ()=>
          @emit 'board updated', @table
          return @table
