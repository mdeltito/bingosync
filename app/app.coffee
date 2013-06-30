_        = require('underscore')
$        = require('jquery')
Browser  = require('zombie')
http     = require('http')
express  = require('express')
app      = express()

app.configure ->
  if process.env.PORT
    app.set 'port', process.env.PORT
  else
    app.set 'port', 5000


  app.set 'views', "#{__dirname}/../views"
  app.set 'view engine', 'jade'

  # app.use express.logger('dev')
  app.use express.static('public')
  app.use require('connect-assets')()

app.conf  = require('node-yaml-config')
app.store = require('./store')(app)

app.set 'board_data', app.conf.load(__dirname + '/../config/board_data.yaml') || {}

app.bingo =
  Board:   require('../lib/bingo/board')(app.store, app.get('board_data'))
  Session: require('../lib/bingo/session')()

app.server = require('./server')(app)
app.routes = require('./routes')(app)
app.io     = require('./io')(app)

app.server.listen app.get('port')
console.info "info: HTTP server listening on port " + app.get('port')
