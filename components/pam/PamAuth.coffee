noflo = require "noflo"
pam = require "authenticate-pam"

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'lock'
  c.description = "This component takes a un/pw pair, and authenticates it via PAM. If successful, the un is passed on the OUT port"
  
  c.inPorts.add 'username',
    dataType: 'string',
    required: yes,
    description: "username"
  c.inPorts.add 'password',
    datatype: 'string',
    required: yes,
    description: "password"
  
  c.outPorts.add 'out',
    datatype: 'string'
    description: "The authed user."
  c.outPorts.add 'error',
    datatype: 'object'
    description: ""
  noflo.helpers.WirePattern c,
    async: yes,
    in: ['username','password'],
    out: ['out'],
    forwardGroups: yes
  ,
    (data, groups, out) ->
      un = data.username
      pwd = data.password
      
      pam.authenticate un, pwd, (err) ->
        if err
          c.outPorts.error.send err
        else
          c.outPorts.out.send un
        return
