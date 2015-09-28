noflo = require "noflo"
jwt = require "jsonwebtoken"

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'lock'
  c.description = "This component receives an xpress/Server request on the IN port, and forwards the request along the OUT port if auth is successful."
  
  c.inPorts.add 'in',
    dataType: 'object',
    required: yes,
    description: "A request object from an xpress/Server component."
  c.inPorts.add 'secret',
    datatype: 'string',
    required: yes,
    description: "JWT secret"
  
  c.outPorts.add 'out',
    datatype: 'object'
    description: "The forwarded request object, if auth was successful."
  c.outPorts.add 'fail',
    datatype: 'object'
    description: "The forwarded request object, if auth was unsuccessful."
  noflo.helpers.WirePattern c,
    async: yes,
    in: ['in','secret'],
    out: ['out'],
    forwardGroups: yes
  ,
    (data, groups, out) ->
      token = data.in.req.headers.token
      secret = data.secret
      try
        decoded = jwt.verify token secret
        c.outPorts.out.send data.in
      catch err
        if c.outPorts.fail.isAttached()
          c.outPorts.fail.send err
        else
          throw err

