execfile('common.py')

cell = AdminControl.getCell()
nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    configureHpel(server,nodeName)
  dmgrs = AdminTask.listServers('[-serverType DEPLOYMENT_MANAGER -nodeName ' + nodeName + ']').splitlines()
  for dmgr in dmgrs:
    configureHpel(dmgr,nodeName)
  nodeagents = AdminTask.listServers('[-serverType NODE_AGENT -nodeName ' + nodeName + ']').splitlines()
  for nodeagent in nodeagents:
    configureHpel(nodeagent,nodeName)

synchronizeActiveNodes()
