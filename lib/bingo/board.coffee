_            = require('underscore')
$            = require('jquery')
crypto       = require('crypto')
Browser      = require('zombie')
EventEmitter = require('events').EventEmitter

module.exports = (_store, _config_data)->
  class Board extends EventEmitter
    namespace: 'board'
    constructor: (session, callback = ->)->
      @browser = new Browser();

      @seed = session.seed
      @session = session
      @key = "bingo:#{@namespace}:#{@session.key}"
      @url = @get_url(session.type)

    get_url: (type)->
      params = {seed: @seed}
      config = _.findWhere(_config_data.types, {code: type})

      if config.params
        params = _.extend(config.params, params)

      query = $.param(params)
      "#{config.url}?#{query}"

    set: (table, callback = ->)->
      _store.set @key, table, =>
        @table = table
        @emit 'board updated', table
        callback table

    # wrapper for `get` that calls fetch if necessary
    load: (callback = ->)->
      @get (err, reply)=>
        if !reply || err
          @fetch (table)=>
            @set table
            callback table
        else
          callback reply

    get: (callback = ->)->
      _store.get @key, callback

    fetch: (callback = ->)->
      @browser.visit @url, =>
        @table = @browser.query("#bingo").outerHTML
        callback @table
        return @table

    update: (square, color, callback = ->)->
      @load (table)=>
        $table = $(table)
        $square = $table.find("#" + square)
        classes = $square[0].className.split(/\s+/)
        color_class = "btn-#{color}"

        # if the square was previously selected by the user,
        # or is not already locked
        if _.contains(classes, color_class) or not $square.hasClass("locked")
          $square.toggleClass color_class
          $square.toggleClass "locked"
          @set $table[0].outerHTML, callback
