import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

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
