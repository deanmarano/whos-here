console.log('js loaded!');

window.onload = function () {
  console.log('js executed!');
  var nameInput = document.getElementById('name');
  var socket = io.connect('http://localhost');

  nameInput.addEventListener('keypress', function(e) {
    if (e.charCode == 13) {
      console.log('firing an event');
      socket.emit('sadd', {
        setKey: window.location.href,
        data: nameInput.value
      });
    }
  });

  socket.on('sadded', function (data) {
    console.log('event received');
    console.log(data);
    document.getElementById('whosHere').innerHTML = JSON.stringify(data);
  });
}
