crypto = require 'crypto'
EventEmitter = require('events').EventEmitter

module.exports = ()->
  class Session extends EventEmitter
    namespace: 'bingo:session'
    constructor: (bingo)->
      @type     = bingo.type
      @seed     = bingo.seed
      @name     = bingo.name
      hash      = crypto.createHash('md5').update(("#{@name}:#{bingo.password}")).digest("hex")
      @key      = "#{@namespace}:#{@seed}:#{hash}"
