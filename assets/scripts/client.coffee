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
  $('body').addClass 'loaded'

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
  chat message
###
socket.on 'chat message', (client, message, timestamp)->
  item = templates.chat_message
    user: client
    message: message
    time: moment().format('h:mm a')
  update_chatpane(item)

###
  report any errors in the form
###
socket.on 'error', (msg)->
  $('#join').button('reset')
  error(msg) if _.isString(msg)

###
  window events
###
window.onbeforeunload = ()->
  bingo_disconnect()
  return 'Your session will be closed'

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
    # table header click
    if $(this).hasClass('popout')
      return

    # local planning click
    if e.shiftKey
      return planning_click.call(this, e)
    # completed square click
    else
      square_id = $(this).attr('id')
      if square_id
        socket.emit 'record click', bingo.client, square_id

  # chat events
  $('#chat-send').on 'click', send_chat

  $('#chat-message').keydown (e)->
    if e.which == 13
      send_chat()

  $('.panel-heading', '#chat-widget').on 'click', toggle_chat

  $('#chat-message').on 'focus', (e)->
    $(this).closest('.panel').removeClass('panel-warning')

  # on board update
  bingo.board.bind 'update', (data)->
    # update badge counts
    _.each bingo.users, (user)->
      count = bingo.board.find(".btn-#{user.color}").length
      $(".badge-#{user.color}").text count
    # reapply local planning
    apply_planning()


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
  chat_message: _.template '' +
    '<li class="clearfix">
      <div class="chat-body clearfix">
        <div class="header">
          <strong class="primary-font"><%= user.nickname %></strong>
          <small class="pull-right text-muted"><span class="glyphicon glyphicon-time"></span><%= time %></small>
        </div>
        <p><%= message %></p>
      </div>
    </li>'

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
  socket.emit 'leave', bingo?.client
  socket?.disconnect()
  hide_chat()
  $('body').removeClass 'loaded'
  bingo.loaded = false

###
  planning click for local markers
###
planning_ids = []
planning_click = (e)->
  id = $(this).attr('id')
  cur_idx = _.indexOf(planning_ids, id)
  if cur_idx >= 0
    planning_ids.splice cur_idx, 1
  else
    planning_ids.push id

  apply_planning()

apply_planning = ()->
  $('.glyphicon-bookmark', '#board').remove()
  _.forEach planning_ids, (id)->
    $("##{id}").append('<span class="glyphicon glyphicon-bookmark"></span>')

###
  chat helpers
###
update_chatpane = (item)->
  if chat_requires_highlight()
    $('#chat-widget .panel').addClass('panel-warning')

  $('#chat-widget .chat').append item
  $('#chat-widget .panel-body').animate
    scrollTop: $("#chat-widget .panel-body")[0].scrollHeight
  , 200

send_chat = (e)->
  message = $('#chat-message').val()
  if bingo.loaded && bingo.client && message
    socket.emit 'chat message', bingo.client, message
    $('#chat-message').val('')

hide_chat = (e)->
  $('#chat-widget .panel-body').addClass('collapsed')

toggle_chat = (e)->
  if bingo.loaded && bingo.client
    $('#chat-widget .panel').removeClass('panel-warning')
    $(e.target).next('.panel-body').toggleClass 'collapsed'

chat_requires_highlight = ()->
  $('#chat-widget .panel-body').hasClass('collapsed') ||
    (!$('#chat-send').is(':focus, :active') && !$('#chat-message').is(':focus'))
