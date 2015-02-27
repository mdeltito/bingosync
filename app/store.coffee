module.exports = (app)->
  try
    if process.env.REDISTOGO_URL
      rtg = require("url").parse process.env.REDISTOGO_URL
      redis = require("redis").createClient rtg.port, rtg.hostname
      redis.auth(rtg.auth.split(":")[1])
      return redis
    else if process.env.REDIS_URL
      redis_server = require("url").parse process.env.REDIS_URL
      redis = require("redis").createClient redis_server.port, redis_server.hostname
      return redis
    else
      return require("redis").createClient()
  catch e
    throw new Error 'Unable to create Redis client'
