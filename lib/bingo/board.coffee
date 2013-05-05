_            = require('underscore')
$            = require('jquery')
crypto       = require('crypto')
Browser      = require('zombie')
EventEmitter = require('events').EventEmitter

module.exports = (_store)->
  class Board extends EventEmitter
    namespace: 'board'
    resource: "http://speedrunslive.com/tools/oot-bingo"
    constructor: (session, callback = ->)->
      @browser = new Browser();

      @seed = session.seed
      @session = session
      @key = "bingo:#{@namespace}:#{@session.key}"
      @url = @get_url()

    get_url: ->
      query = $.param {seed: @seed}
      "#{@resource}?#{query}"

    setHtml: (table, callback = ->)->
      _store.set @key, table, =>
        @table = table
        this.emit 'table loaded', table
        callback table

    # alias
    load: (callback = ->)->
      @getHtml(callback)

    getHtml: (callback = ->)->
      _store.get @key, (err, replies)=>
        if !replies
          try
            @browser.visit @url, =>
              @table = @browser.query("#bingo").outerHTML
              @setHtml(@table)
              callback @table
          catch e
            this.emit 'error', e
        else
          callback replies

    update: (square, color)->
      # $square = $table.find("#" + square)
      # classes = $square[0].className.split(/\s+/)


      # # if the square was previously selected by the user,
      # # or is not already locked
      # if _.contains(classes, color) or not $square.hasClass("locked")
      #   $square.toggleClass color
      #   $square.toggleClass "locked"
      # boards[seed].table = $table[0].outerHTML
