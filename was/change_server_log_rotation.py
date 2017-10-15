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
    configureJvmLogRotation(server)
  nodeagents = AdminTask.listServers('[-serverType NODE_AGENT -nodeName ' + nodeName + ']').splitlines()
  for nodeagent in nodeagents:
    print '------------------------------------------------------------------------------'
    print nodeagent
    print '------------------------------------------------------------------------------'
    configureJvmLogRotation(server)
  dmgrs = AdminTask.listServers('[-serverType DEPLOYMENT_MANAGER -nodeName ' + nodeName + ']').splitlines()
  for dmgr in dmgrs:
    print '------------------------------------------------------------------------------'
    print dmgr
    print '------------------------------------------------------------------------------'
    configureJvmLogRotation(dmgr)

saveConfiguration()
