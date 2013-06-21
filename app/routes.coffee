module.exports = (app)->

  app.get '/', (req, res)->
    board_data = app.get('board_data')
    res.render('index', {board_types: board_data.types})
