user = 'was'
group = 'was'

execfile('common.py')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    print '------------------------------------------------------------------------------'
    print server
    print '------------------------------------------------------------------------------'
    setProcessExecution(server, user, group)
  nodeagents = AdminTask.listServers('[-serverType NODE_AGENT -nodeName ' + nodeName + ']').splitlines()
  for nodeagent in nodeagents:
    print '------------------------------------------------------------------------------'
    print nodeagent
    print '------------------------------------------------------------------------------'
    setProcessExecution(nodeagent, user, group)
  dmgrs = AdminTask.listServers('[-serverType DEPLOYMENT_MANAGER -nodeName ' + nodeName + ']').splitlines()
  for dmgr in dmgrs:
    print '------------------------------------------------------------------------------'
    print dmgr
    print '------------------------------------------------------------------------------'
    setProcessExecution(dmgr, user, group)

saveConfiguration()
