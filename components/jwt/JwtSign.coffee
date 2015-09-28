noflo = require "noflo"
jwt = require "jsonwebtoken"

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'lock'
  c.description = "This component takes an object on the IN port, and signs it against the provided secret."
  
  c.inPorts.add 'in',
    dataType: 'object',
    required: yes,
    description: "The object to sign."
  c.inPorts.add 'secret',
    datatype: 'string',
    required: yes,
    description: "JWT secret"
  
  c.outPorts.add 'out',
    datatype: 'object'
    description: "The signed object."
  c.outPorts.add 'error',
    datatype: 'object'
    description: ""
  noflo.helpers.WirePattern c,
    async: yes,
    in: ['in','secret'],
    out: ['out'],
    forwardGroups: yes
  ,
    (data, groups, out) ->
      objToSign = data.in
      secret = data.secret
      try
        signedObj = jwt.sign objToSign secret
        c.outPorts.out.send signedObj
      catch err
        if c.outPorts.fail.isAttached()
          c.outPorts.fail.send err
        else
          throw err
