execfile('common.py')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    result = AdminTask.setJVMProperties('[-nodeName ' + nodeName + ' -serverName ' + serverName + ' -verboseModeGarbageCollection true ]')

synchronizeActiveNodes()

restartApplicationServers()
