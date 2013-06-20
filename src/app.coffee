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

app = require("http").createServer(handler)
io = require("socket.io").listen(app)
fs = require("fs")

app.listen 8080
io.sockets.on "connection", (socket) ->
  socket.emit "news",
    hello: "world"

  socket.on "my other event", (data) ->
    console.log data

