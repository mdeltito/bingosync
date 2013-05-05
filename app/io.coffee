_ = require 'underscore'

module.exports = (app)->
  Session = app.bingo.Session
  Board = app.bingo.Board
  io = require('socket.io').listen app.server
  io.set "log level", 3

  app.boards ?= {}
  app.clients ?= {}

  session_clients = (session) ->
    clients = _.filter app.clients, (client)->
      client.session == session.key

  io.sockets.on "connection", (socket) ->
    socket.on 'end', ->
      console.log "session detached: #{socket.id}"

    socket.on "join bingo", (bingo) ->
      if _.isNaN(parseInt(bingo.seed))
        socket.emit 'error', "Invalid bingo seed entered"
        return

      session = new Session(bingo)
      client =
        id: socket.id
        nickname: bingo.nickname
        session: session.key
        color: bingo.color

      app.clients[client.id] = client

      if app.boards[session.key]?
        board = app.boards[session.key]
      else
        board = new Board(session)
        app.boards[session.key] = board

      # join the bingo
      socket.join session.key
      console.log "session attached: #{client.nickname} => #{session.key}"

      socket.emit 'connected', session
      socket.broadcast.to(session.key).emit "user joined", client
      io.sockets.in(session.key).emit "update userlist", session_clients(session)

      # send the session board
      board.load (table)->
        socket.emit 'update session', {session: session, client: client, board: table}

    socket.on "update square", (session, client, square) ->
      console.log "SQUARE CLICKED"
      console.log session
      console.log client

    socket.on "update user", (client) ->
      session = app.sessions[client.session]
      app.clients[client.id] = client
      io.sockets.in(session.key).emit "update userlist", session_clients(session)

    #   table_html = boards[seed].table
    #   $table = $(table_html)
    #   $square = $table.find("#" + square)
    #   color = boards[seed].users[nametag].color
    #   classes = $square[0].className.split(/\s+/)

    #   # if the square was previously selected by the user,
    #   # or is not already locked
    #   if _.contains(classes, color) or not $square.hasClass("locked")
    #     $square.toggleClass color
    #     $square.toggleClass "locked"
    #   boards[seed].table = $table[0].outerHTML
    #   reload_board seed
