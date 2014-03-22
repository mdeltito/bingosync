socket = io.connect '/'
window.bingo = bingo =
  loaded: false
  users: []
  session: null
  client: null
  points: null

###
  set up default growl options
###
$.growl.default_options = _.extend $.growl.default_options,
  position:
    from: 'top'
    align: 'center'

###
  helper function for showing an error
###
error = (message, scope = "#sidebar")->
  alert = templates.alert
    title: 'Error!'
    message: message
    type: 'error'

  $('.alert', scope).remove()
  $(alert).hide().appendTo(scope).fadeIn('fast')

###
  toggle the forms
###
show_form = (type)->
  $('#quit-session, #join-session').addClass('hide')
  $("##{type}-session").removeClass('hide')

###
  helper for getting the selected color
###
user_color = ->
  $('input[name=color]:checked').val()

###
  helper for disconnecting from a session
###
bingo_disconnect = ->
  socket.emit 'leave', bingo?.client?.id
  socket?.disconnect()
  bingo.loaded = false

###
  When a user joins, the full list of clients is
  also emitted to all members of the session
###
socket.on 'update userlist', (users)->
  bingo.users = users
  _.each users, (user)->
    user.points = $('#board').find(".#{user.color}").length

  $('#user-list').html(templates.user_list({users: users}))
  bingo.board.trigger 'update'

###
  When we join, broadcast to all other members of the session
###
socket.on 'user joined', (user)->
  $.growl
    title: user.nickname
    icon: 'glyphicon glyphicon-user'
    message: 'has joined the session'
    type: 'info'

###
  On Connect
###
socket.on 'connected', (session)->
  window.ga? 'send', {
    'hitType': 'pageview'
    'title': session.type
    'page': '/login',
  }

  show_form('quit')

  $.growl
    title: 'Connected'
    icon: 'glyphicon glyphicon-transfer'
  ,
    type: 'success'

###
  replace board in the DOM on update
###
socket.on 'update session', (data)->
  $('#join').button('reset')

  if !bingo.loaded
    # first load
    $('#board').hide().html(data.board).fadeIn()
    bingo.loaded = true
  else
    # update
    $('#board').html(data.board)

  bingo.session = data.session if data.session
  bingo.client = data.client if data.client
  bingo.board.trigger 'update'

###
  report any errors in the form
###
socket.on 'error', (msg)->
  $('#join').button('reset')
  error(msg) if _.isString(msg)

###
  on ready
###
$ ->
  bingo.board = $('#board')

  # wire the form submission to socket.io
  $('#join-session').submit (e)=>
    if !socket.socket.connected
      socket.socket.connect()

    e.preventDefault()
    $('#join').button('loading')
    @bingo ?= {}
    @bingo.seed = $('#seed').val()
    @bingo.type = $('#type').val()
    @bingo.nickname = $('#nickname').val()
    @bingo.name = $('#session_name').val()
    @bingo.password = $('#password').val()
    @bingo.color = user_color()

    if !_.every @bingo
      error 'You must fill out all fields'
      return $('#join').button('reset')

    # join the bingo
    socket.emit 'join bingo', @bingo

  # disconnect
  $('#quit-session').submit (e)=>
    e.preventDefault()
    bingo_disconnect()
    $('#user-list').html('')
    $('#board').fadeOut ->
      $(this).html(' ')
      show_form('join')

  # user updates
  $(document).on 'change', 'input[name=color]', (e)->
    if bingo.client
      bingo.client.color = $(this).val()
      socket.emit 'update user', bingo.client

  #square click
  $(document).on 'click', '#bingo td', (e)->
    if $(this).hasClass('popout')
      return

    square_id = $(this).attr('id')
    if square_id
      socket.emit 'record click', bingo.client, square_id

  # on board update
  bingo.board.bind 'update', (data)->
    # update badge counts
    _.each bingo.users, (user)->
      count = bingo.board.find(".btn-#{user.color}").length
      $(".badge-#{user.color}").text count

templates =
  alert: _.template '' +
    '<div class="alert alert-<%= type %> alert-dismissable alert-danger">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <strong><%= title %></strong>&nbsp;&nbsp;<%= message %>
    </div>'
  user_list: _.template '' +
    '<li class="nav-header">User List</li>
    <% _.each(users, function(user){%>
      <li><%= user.nickname %><span class="badge badge-<%= user.color %> pull-right"><%= user.points %></span></li>
    <%}); %>'
