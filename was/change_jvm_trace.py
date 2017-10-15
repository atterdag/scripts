startupLevel = '*=info: com.ibm.portal.puma.*=all: com.ibm.ws.wssecurity.*=all: com.ibm.ws.security.*=all'
runtimeLevel = startupLevel

execfile('common.py')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  print 'iterating through all servers in node ' + nodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    print '------------------------------------------------------------------------------'
    print server
    print '------------------------------------------------------------------------------'
    configureTraceLog(server,"10","50")
    print '------------------------------------------------------------------------------'
    configureJvmStartupTrace(server,startupLevel)
    print '------------------------------------------------------------------------------'
    configureJvmRuntimeTrace(server,runtimeLevel)

saveConfiguration()
