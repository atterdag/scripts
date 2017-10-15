import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

startupLevel = '*=info: com.ibm.portal.puma.*=all: com.ibm.ws.wssecurity.*=all: com.ibm.ws.security.*=all'
runtimeLevel = startupLevel

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
