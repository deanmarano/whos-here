### Knock, knock.

# Who's Here?

Who's Here came from a need to show all of the users currently looking at the
page who else is on the page (similar to how ZenDesk shows you who else is
looking at the page). I figured the best tool for this job was a WebSocket /
Node.js / Redis combination, and this is it. If you're looking to use this in
your app, follow the integration steps below.

## How's it work?

On page load, a socket is opened. You send a clientId, a page identifier,
and the way you want to identify users.

Whenever someone joins (including yourself) you'll get an update message back
saying who joined and all of the people currently in the room. Similarly, when
someone leaves, you'll get a message saying who left and all of the people
currently in the room.

## Integration

Copy down client/whosHereClient.min.js and include it in your project. To use
it, you'll need a few things.

1. Create your user join listener.

```
var userJoined = function (newUserData, allUserArray) { // do your thing here }
```

2. Create your user left listener.

```
var userLeft = function (newUserData, allUserArray) { // do your thing here }
```

3. Shove data into WhosHere.

```
WhosHere.setup({
  clientId: clientIdString,
  setKey: pageIdentifierString,
  data: optionalDataToAdd,
  setAddListener: userJoined,
  setRemoveListener: userLeft
  });
```

In most cases, the pageIdentifierString should be the URL that you want to
group people by. You may want to clean off any params before sending, or your
users may get lumped into the wrong buckets. Your data will get automatically
serialized and deserialized, so no need to worry about stringifying/parsing it.
There is an upper limit of 200 characters per data object, if this is too small
for you let's talk about your needs.

## Contributing

Please do! Regular process - fork, pull request.
