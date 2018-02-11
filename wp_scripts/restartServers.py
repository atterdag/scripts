nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  nodeAgentCompleteObjectName = AdminControl.completeObjectName('type=NodeAgent,node=' + nodeName + ',process=nodeagent,*')
  if ( nodeAgentCompleteObjectName != '' ):
    servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
    for server in servers:
      serverName = AdminConfig.showAttribute(server, 'name')
      serverCompleteObjectName = AdminControl.completeObjectName('type=Server,node=' + nodeName + ',process=' + serverName + ',*')
      if ( serverCompleteObjectName != '' ):
        print 'stopping ' + nodeName + '/' + serverName
        print AdminControl.stopServer(serverName, nodeName)
      else:
        print nodeName + '/' + serverName + ' is already stopped'
  else:
    print '***' + nodeName + ' is not a application server node! ***'
