module.exports = (io, config) ->

  io.on 'connection', (socket) ->
    console.log 'A client has just connected', socket.id

    socket.on 'camera', (data) ->
      socket.broadcast.emit 'camera', data

    socket.on 'move', (data) ->
      socket.broadcast.emit 'move', data
