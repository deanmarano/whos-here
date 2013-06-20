http = require("http")
fs = require("fs")
redis = require("redis")
client = redis.createClient()

client.on "error", (err) ->
  console.log "Error " + err

handler = (req, res) ->
  switch req.url
    when '/', '/index.html'
      fileRequested = '/index.html'
      fullPath = __dirname.replace('/src', '') + fileRequested
      loadAndReturnFile(fileRequested, fullPath, req, res)
    when '/client/whosHereClient.js'
      fullPath = __dirname.replace('/src', '') + req.url
      loadAndReturnFile(req.url, fullPath, req, res)
    else
      res.writeHead 404
      res.end '404 Not Found :('

loadAndReturnFile = (fileRequested, path, req, res) ->
  fs.readFile path, {encoding: 'UTF-8'}, (err, data) ->
    if err
      res.writeHead 500
      return res.end("Error loading index.html at #{path}")
    res.writeHead 200
    res.end data

sendSetUpdate = (allSockets, key, action) ->
  updateAgain = false
  client.hgetall key, (err, setData = {}) ->
    socketIds = Object.keys(setData)
    values = socketIds.map (v) -> setData[v]
    # Get the socket IDs
    socketIds.forEach (socketId) ->
      if s = allSockets[socketId]
        s.emit(action, values)
      else
        client.hdel(key, socketId)
        updateAgain = true
  sendSetUpdate(allSockets, key, 'sremed') if updateAgain

client.on 'ready', ->
  app = http.createServer(handler)
  io = require("socket.io").listen(app)

  io.sockets.on "connection", (socket) ->
    socket.on 'disconnect',  ->
      socket.get 'setKey', (err, key) ->
        client.hdel(key, socket.id)
        sendSetUpdate(io.sockets.sockets, key, 'sremed')

    socket.on 'sadd', (saddEvent) ->
      socket.set 'setKey', saddEvent.setKey
      client.hset(saddEvent.setKey, socket.id, saddEvent.data)

      sendSetUpdate(io.sockets.sockets, saddEvent.setKey, 'sadded')

  app.listen 8080
