import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

# can either be 'none', 'basic', 'extended', 'all', or 'custom'. If using 'custom', then you must define the specific counters manually in ISC.
statisticSet = 'all'

cell = AdminControl.getCell()
managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  print 'iterating through all servers in node ' + managedNodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    print 'listing PMI services in server ' + serverName
    pmiServices = AdminConfig.list('PMIService', AdminConfig.getid('/Cell:' + cell + '/Node:' + managedNodeName + '/Server:' + serverName + '/')).splitlines()
    for pmiService in pmiServices:
      print pmiService
      print 'setting PMI statistics set to ' + statisticSet + ' on ' + managedNodeName + '/' + serverName
      result = AdminConfig.modify(pmiService, '[[synchronizedUpdate false] [enable true] [statisticSet ' + statisticSet + ' ]]')
    perfPrivateMBean = AdminControl.queryNames('WebSphere:name=PerfPrivateMBean,node=' + managedNodeName + ',process=' + serverName + ',*')
    if perfPrivateMBean != '':
      result = AdminControl.invoke(perfPrivateMBean, 'setSynchronizedUpdate', '[false]')
      result = AdminControl.invoke(perfPrivateMBean, 'setStatisticSetID', '[' + statisticSet + ']')

synchronizeActiveNodes()