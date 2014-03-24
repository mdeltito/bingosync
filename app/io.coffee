_ = require 'lodash'

module.exports = (app)->
  Session = app.bingo.Session
  Board = app.bingo.Board
  io = require('socket.io').listen app.server
  io.configure ()->
    io.set "log level", 0

  app.boards ?= {}
  app.clients ?= []

  session_clients = (key) ->
    clients = _.filter app.clients, (client)->
      client.session == key

  io.sockets.on "connection", (socket) ->

    socket.on "leave", (client)->
      _.remove app.clients, (c)->
        c.id == socket.id

      io.sockets.in(client.session).emit "update userlist", session_clients(client.session)


    socket.on 'end', ->
       # TODO remove the client from the array,
       # and fire and event so we can update the browser
      console.log "session detached: #{socket.id}"

    socket.on "join bingo", (bingo) ->
      if isNaN(bingo.seed)
        return socket.emit 'error', "Invalid bingo seed entered"

      session = new Session(bingo)
      client =
        id: socket.id
        nickname: bingo.nickname
        session: session.key
        color: bingo.color

      app.clients.push(client)

      if app.boards[session.key]?
        board = app.boards[session.key]
      else
        board = new Board(session)
        app.boards[session.key] = board

      # join the bingo
      socket.join session.key
      socket.emit 'connected', session
      # console.log "session attached: #{client.nickname} => #{session.type} (#{session.key})"

      # notify everyone
      socket.broadcast.to(session.key).emit "user joined", client
      clients = session_clients(session.key)
      io.sockets.in(session.key).emit "update userlist", clients

      # send the session board
      board.get()
        .then (table)->
          payload = {session: session, client: client, board: table}
          socket.emit 'update session', payload

    # handle updateing squares
    socket.on "record click", (client, square) ->
      board = app.boards[client.session]
      board.update(square, client.color)
        .then (table)->
          io.sockets.in(client.session).emit 'update session', { board: table }

    # handle updates to user state, such as color
    socket.on "update user", (client) ->
      # find client idx
      user_idx = _.findIndex app.clients, (c)->
        c.id == client.id

      # replace client with new user data
      app.clients[user_idx] = client
      io.sockets.in(client.session).emit "update userlist", session_clients(client.session)
