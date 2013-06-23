socket = io.connect '/'
window.bingo = bingo =
  loaded: false
  users: []
  session: null
  client: null
  points: null

###
  helper function for showing an error
###
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
  _.each users, (user)->
    user.points = $('#board').find(".#{user.color}").length

  $('#user-list').html(templates.user_list({users: users}))
  bingo.board.trigger 'update'

###
  When we join, broadcast to all other members of the session
###
socket.on 'user joined', (user)->
  $.gritter.add
    title: user.nickname
    text: 'joined the session'

###
  On Connect
###
socket.on 'connected', (session)->
  window.ga? 'send', {
    'hitType': 'pageview'
    'title': session.type
    'page': '/login',
  }

  $.gritter.add
    text: 'connected'

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
  helper for getting the selected color
###
user_color = ->
  $('#color .active').val()

###
  on ready
###
$ ->
  bingo.board = $('#board')

  # wire the form submission to socket.io
  $('#join-session').submit (e)=>
    $('#join').button('loading')
    e.preventDefault()
    @bingo ?= {}
    @bingo.seed = $('#seed').val()
    @bingo.type = $('#type').val()
    @bingo.nickname = $('#nickname').val()
    @bingo.name = $('#session_name').val()
    @bingo.password = $('#password').val()
    @bingo.color = user_color()

    if !_.every @bingo
      error 'You must fill out all fields'
      $('#join').button('reset')
      return

    # join the bingo
    socket.emit 'join bingo', @bingo
    $('#join-session').fadeOut 300, ->
      $('#quit-session').fadeIn(300)

  # disconnect
  $('#quit-session').submit (e)=>
    e.preventDefault()
    socket?.disconnect()
    bingo.loaded = false
    $('#user-list').html('')
    $('#board').fadeOut ->
      $(this).html(' ')
      $('#quit-session').fadeOut 300, ->
        $('#join-session').fadeIn(300)



  # user updates
  $(document).on 'click', '.navbar .btn-group button', (e)->
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
    '<div class="alert alert-<%= type %>">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      <strong><%= title %></strong>&nbsp;&nbsp;<%= message %>
    </div>'
  user_list: _.template '' +
    '<li class="nav-header">User List</li>
    <% _.each(users, function(user){%>
      <li><%= user.nickname %><span class="badge badge-<%= user.color %> pull-right"><%= user.points %></span></li>
    <%}); %>'
