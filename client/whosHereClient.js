WhosHere = {
  setup: function(options) {
    var socket = io.connect('http://atom.deanoftech.com:3000');
    socket.emit('sadd', {
      clientId: options.clientId,
      setKey: options.setKey,
      data: options.data
    });

    socket.on('sadded', function (data) {
      options.setAddListener(null, data);
    });

    socket.on('sremed', function (data) {
      options.setRemoveListener(null, data);
    });
  }
};
