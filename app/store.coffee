module.exports = (app)->
  if process.env.REDISTOGO_URL
    rtg = require("url").parse process.env.REDISTOGO_URL
    require("redis").createClient rtg.port, rtg.hostname
  else
    require('redis').createClient()
