dumpDirectory = '${SERVER_LOG_ROOT}'

execfile('common.py')

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  print 'iterating through all servers in node ' + managedNodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    javaProcessDef = AdminConfig.list('JavaProcessDef', server)
    print 'Setting heapdump properties on ' + serverName
    result = AdminConfig.modify(javaProcessDef, [['environment', [[['name', 'IBM_COREDIR'], ['value', dumpDirectory]]]]])
    result = AdminConfig.modify(javaProcessDef, [['environment', [[['name', 'IBM_HEAPDUMPDIR'], ['value', dumpDirectory]]]]])
    result = AdminConfig.modify(javaProcessDef, [['environment', [[['name', 'IBM_JAVACOREDIR'], ['value', dumpDirectory]]]]])

synchronizeActiveNodes()
