var socket = io.connect('/');

socket.on('user joined', function(nametag) {
  $.gritter.add({
    title: nametag,
    text: 'joined the bingo'
  });
});

socket.on('reload board', function(board) {
  $('#board').html(board);
});

$(function(){
  $('#get-board').submit(function(e){
    e.preventDefault();
    window._bingo_seed = $('#seed').val();
    window._nametag    = $('#nametag').val();
    window._color      = $('#color').val();

    if(!_bingo_seed) {
      alert('you must enter a seed number');
      return;
    }

    if(!_nametag) {
      alert('you must enter a name/team');
      return;
    }

    // join the bingo
    socket.emit('join bingo', _bingo_seed, _nametag, _color);
  });

  $(document).on('click', '#bingo td', function(e){
    console.log('clicked');
    var square = $(this).attr('id');
    socket.emit('update square', _bingo_seed, _nametag, square);
  });
});
