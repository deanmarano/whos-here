http = require("http")
fs = require("fs")
redis = require("redis")
client = redis.createClient()

client.on "error", (err) ->
  console.log "Error " + err

handler = (req, res) ->
  console.log req.url
  switch req.url
    when '/', '/index.html'
      console.log 'loading index'
      fileRequested = '/index.html'
      fullPath = __dirname.replace('/src', '') + fileRequested
      loadAndReturnFile(fileRequested, fullPath, req, res)
    when '/client/whosHereClient.js'
      console.log 'loading js'
      fullPath = __dirname.replace('/src', '') + req.url
      loadAndReturnFile(req.url, fullPath, req, res)
    else
      res.writeHead 404
      res.end '404 Not Found :('

loadAndReturnFile = (fileRequested, path, req, res) ->
  console.log 'hello'
  fs.readFile path, {encoding: 'UTF-8'}, (err, data) ->
    if err
      res.writeHead 500
      return res.end("Error loading index.html at #{path}")
    res.writeHead 200
    res.end data.
      replace('{{headers}}', JSON.stringify(req.headers)).
      replace('{{path}}', req.url)

client.on 'ready', ->
  app = http.createServer(handler)
  io = require("socket.io").listen(app)

  sendSetUpdate = (key) ->
    client.hgetall key, (err, setData = {}) ->
      console.log setData
      socketIds = Object.keys(setData)
      values = socketIds.map (v) -> setData[v]
      # Get the socket IDs
      socketIds.forEach (socketId) ->
        s = io.sockets.sockets[socketId]
        s.emit('sadded', values) if s?

  app.listen 8080
  io.sockets.on "connection", (socket) ->
    socket.on 'disconnect',  ->
      socket.get 'setKey', (err, key) ->
        console.log "id #{socket.id} key #{key}"
        client.hdel(key, socket.id)
        sendSetUpdate(key)

    socket.on 'sadd', (saddEvent) ->
      # Add the socket id and the data
      socket.set 'setKey', saddEvent.setKey
      client.hset(saddEvent.setKey, socket.id, saddEvent.data)

      # get the user data to send
      sendSetUpdate(saddEvent.setKey)
