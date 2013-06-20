console.log('js loaded!')

var nameInput = document.getElementById('name')
var socket = io.connect('http://localhost');
socket.emit('sadd', {
  setId: window.location.href,
  data: 
});
socket.on('sadded', function (data) {
  console.log(data);
});
