noflo = require "noflo"
mongodb = require "mongodb"
url = require "url"

exports.getComponent = ->
  MongoClient = mongodb.MongoClient
  parseConnectionString = (data) ->
    databaseUrl = try
      url.parse data.url
    catch e
      console.log e
         
    [..., serverUrl, databaseName] = databaseUrl.href.split('/')
    serverUrl = 'mongodb://' + data.username + ':' + data.password + '@' + serverUrl + '/' + databaseName

  c = new noflo.Component
  c.icon = 'fire'
  c.icon = 'description'

  c.inPorts.add 'url',
    dataType: 'string',
    required: yes,
    description: 'Gets the URL to connect to MongoDB instance'
  c.inPorts.add 'username',
    dataType: 'string',
    required: yes,
    description: 'Sets the MongoDB username'
  c.inPorts.add 'password',
    dataType: 'password',
    required: yes,
    description: 'Sets the MongoDB password'
  c.inPorts.add 'selector',
    dataType: 'string'
    required: yes,
    description: 'Sets the selector based on which documents will be returned'
  c.inPorts.add 'collection',
    dataType: 'string',
    required: yes,
    description: 'Sets the collection to be used for retrieving documents'
  c.outPorts.add "mongoresult",
    dataType: 'array'
  noflo.helpers.WirePattern c,
    async: true,
    in: ['url', 'username', 'password', 'selector', 'collection'],
    out: 'mongoresult' 
  , (data, groups, out, callback) ->
    serverUrl = parseConnectionString data

    #Connect to MongoDB
    MongoClient.connect serverUrl, (err, db) ->
      if err
        console.log "", err
      else
        # Parse the JSON
        selection_string = JSON.parse data.selector

        db.collection data.collection
        .find selection_string
        .toArray (err, items) ->
          if err
            console.log "", err,
          else
            c.outPorts.mongoresult.send items