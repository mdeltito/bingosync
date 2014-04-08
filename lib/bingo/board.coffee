_            = require('lodash')
$            = require('jquery')
crypto       = require('crypto')
Phantom      = require('node-phantom')
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
      params = {seed: @seed}
      config = _.findWhere(_config_data.types, {code: type})

      if config.params
        params = _.extend(config.params, params)

      query = $.param(params)
      "#{config.url}?#{query}"

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
      return new Promise (resolve, reject)=>
        Phantom.create (err, ph)=>
          return reject(err) if err

          ph.createPage (err, page)=>
            return reject(err) if err

            page.open @url, (err, status)->
              return reject(err) if err

              page.evaluate ()->
                return document.getElementById('bingo').outerHTML
              , (err, result)->
                reject(err) if err
                resolve(result)

    update: (square, color)->
      @get()
        .then (table)=>
          $table = $(table)
          $square = $table.find("#" + square)
          classes = $square[0].className.split(/\s+/)
          color_class = "btn-#{color}"

          # if the square was previously selected by the user,
          # or is not already locked
          if _.contains(classes, color_class) or not $square.hasClass("locked")
            $square.toggleClass color_class
            $square.toggleClass "locked"
            @table = $table[0].outerHTML
            return @set(@key, @table)
          else
            @table = $table[0].outerHTML
        .then ()=>
          @emit 'board updated', @table
          return @table
