socket = io.connect '/'
window.bingo = bingo =
  users: []
  session: null
  client: null
  points: (color)->
    # $('#board').find(".#{color}").length
    ''

error = (error)->
  alert = templates.alert
    title: 'Error!'
    message: error
    type: 'error'

  $(alert).hide().prependTo('#main').fadeIn('fast')

###
  When a user joins, the full list of clients is
  also emitted to all members of the session
###
socket.on 'update userlist', (users)->
  bingo.users = users
  $('#user-list').html templates.user_list({users: users})

###
  When we join, broadcast to all other members of the session
###
socket.on 'user joined', (user)->
  $.gritter.add
    title: user.nickname
    text: 'joined the session'

###
  replace board in the DOM on update
###
socket.on 'update session', (data)->
  $('#board').html data.board
  bingo.session = data.session
  bingo.client = data.client

###
  report any errors in the form
###
socket.on 'error', (msg)->
  error(msg)

###
  helper for getting the selected color
###
user_color = ->
  $('#color .active').val()

$ ->
  # wire the form submission to socket.io
  $('#join-session').submit (e)=>
    e.preventDefault()
    @bingo ?= {}
    @bingo.seed = $('#seed').val()
    @bingo.nickname = $('#nickname').val()
    @bingo.name = $('#session_name').val()
    @bingo.password = $('#password').val()
    @bingo.color = user_color()

    if !_.every @bingo
      error 'You must fill out all fields'
      return

    # join the bingo
    socket.emit 'join bingo', @bingo
    return

  # user updates
  $(document).on 'click', '.navbar .btn-group button', (e)->
    if bingo.client
      bingo.client.color = $('.navbar .btn-group .active').val()
      socket.emit 'user update', bingo.client

  #square clickin
  $(document).on 'click', '#bingo td', (e)->
    if $(this).hasClass('popout')
      return

    square_id = $(this).attr('id')
    console.log square_id
    if square_id
      socket.emit 'update square', bingo.session, bingo.client, square_id

templates =
  alert: _.template '' +
    '<div class="alert alert-<%= type %>">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <strong><%= title %></strong>&nbsp;&nbsp;<%= message %>
    </div>'
  user_list: _.template '' +
    '<li class="nav-header">User List</li>
    <% _.each(users, function(user){%>
      <li><%= user.nickname %><span class="badge <%= user.color %> badge-success pull-right">&nbsp;</span></li>
    <%}); %>'
console.log templates
