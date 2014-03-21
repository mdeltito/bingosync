module.exports = (app)->

  app.get '/', (req, res)->
    board_data = app.get('board_data')
    res.render('index', {board_types: board_data.types})

  app.get '/get-board', (req, res)->
    bingo =
      type: 'oot-normal'
      # seed: Math.floor(Math.random() * (130443 - 300 + 1)) + 300;
      seed: 10000
      name: 'test'
      password: 'test'

    session = new app.bingo.Session(bingo)
    board = new app.bingo.Board(session)
    board.update('slot25', 'red')
      .then (table)->
        console.log "resp" + table
      .error (err)->
        console.log err

