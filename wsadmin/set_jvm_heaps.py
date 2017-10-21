import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

dmgrHeapSizeMax='1024'
dmgrHeapSizeMin='300'
naHeapSizeMax='1024'
naHeapSizeMin='300'
wasHeapSizeMax='2048'
wasHeapSizeMin='2048'
wasJvmNurserySize='1024'

execfile('common.py')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  print 'iterating through all servers in node ' + nodeName
  dmgrs = AdminTask.listServers('[-serverType DEPLOYMENT_MANAGER -nodeName ' + nodeName + ']').splitlines()
  for dmgr in dmgrs:
    setJavaVirtualMachineProperty(dmgr, [['initialHeapSize', dmgrHeapSizeMin], ['maximumHeapSize', dmgrHeapSizeMax], ['verboseModeGarbageCollection', 'false']])
  nodeagents = AdminTask.listServers('[-serverType NODE_AGENT -nodeName ' + nodeName + ']').splitlines()
  for nodeagent in nodeagents:
    setJavaVirtualMachineProperty(nodeagent, [['initialHeapSize', naHeapSizeMin], ['maximumHeapSize', naHeapSizeMax], ['verboseModeGarbageCollection', 'false']])
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    setJavaVirtualMachineProperty(server, [['initialHeapSize', wasHeapSizeMin], ['maximumHeapSize', wasHeapSizeMax]])
    setJvmGenericArguements(nodeName, serverName, '-Xmn' + wasJvmNurserySize + 'M')

synchronizeActiveNodes()
