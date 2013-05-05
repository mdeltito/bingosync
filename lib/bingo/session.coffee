crypto = require 'crypto'
EventEmitter = require('events').EventEmitter

module.exports = ()->
  class Session extends EventEmitter
    namespace: 'bingo:session'
    constructor: (data)->
      @seed     = data.seed
      @name     = data.name
      hash      = crypto.createHash('md5').update(("#{@name}:#{data.password}")).digest("hex")
      @key      = "#{@namespace}:#{@seed}:#{hash}"
