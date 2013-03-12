var express = require('express')
  , http = require('http')
  , Browser = require("zombie")
  , _ = require('underscore')
  , $ = require('jquery');

var app = express();
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);

var _SRL_BINGO_URL = "http://speedrunslive.com/tools/oot-bingo/?seed=";

// the css is already ripped from SRL and compiled,
// so we don't need to load it again
Browser.loadCSS = false;

// store each board's HTML
var boards = {};

// log it all
io.set("log level", 1);

app.configure(function(){
  app.use(express.logger('dev'));
  app.use(express.static('public'));
});

var port = process.env.PORT || 1418;
server.listen(port);

io.sockets.on('connection', function (socket) {
  socket.on('join bingo', function (seed, nametag, color) {
    console.log(nametag + ' joined seed ' + seed);
    // join the bingo
    socket.join(seed);

    // tell the other clients that a user joined
    socket.broadcast.to(seed).emit('user joined', nametag);

    // store the details of this user
    if(!boards[seed]) {
      boards[seed] = {users: {}};
    }

    boards[seed].users[nametag] = {color: color};
    console.log(boards[seed].users);

    // trigger a refresh of the board for all clients
    reload_board(seed);
  });

  socket.on('update square', function (seed, nametag, square) {
    var table_html = boards[seed].table;
    var $table     = $(table_html);
    var $square    = $table.find('#' + square);
    var color      = boards[seed].users[nametag].color;
    var classes    = $square[0].className.split(/\s+/);

    // if the square was previously selected by the user,
    // or is not already locked
    if(_.contains(classes, color) || !$square.hasClass('locked')) {
      $square.toggleClass(color);
      $square.toggleClass('locked');
    }

    boards[seed].table = $table[0].outerHTML;
    reload_board(seed);
  });
});

function reload_board(seed) {
  if(!_.has(boards[seed], 'table')) {
    console.log('loading board from SRL with seed: ' + seed);
    var browser = new Browser();
    var bingo_url = _SRL_BINGO_URL + seed;

    browser.visit(bingo_url, function(){
      var table = browser.query("#bingo").outerHTML;
      boards[seed].table = table;

      console.log('board with seed ' + seed + ' loaded');
      reload_board(seed);
    });
  }
  else {
    console.log('updating ' + seed);
    io.sockets.in(seed).emit('reload board', boards[seed].table);
  }
}
