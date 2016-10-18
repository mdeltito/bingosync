module.exports = (app)->
  process.env.REDIS_HOST ?= 'redis'
  process.env.REDIS_PORT ?= '6379'

  try
    return require("redis").createClient(process.env.REDIS_PORT, process.env.REDIS_HOST)
  catch e
    throw new Error 'Unable to create Redis client'
