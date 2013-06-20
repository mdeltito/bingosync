module.exports = (app)->
  app.get '/', (req, res)->
    @board_types = app.conf.load(__dirname + '/../config/board_type.yml');
    res.render 'index'
