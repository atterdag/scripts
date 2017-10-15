import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  print 'iterating through all servers in node ' + managedNodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    serverId = AdminConfig.getid('/Node:' + managedNodeName + '/Server:' + serverName)
    dynamicCache = AdminConfig.list('DynamicCache', serverId)
    print 'enabling dynamic cache disk cache on ' + dynamicCache
    result = AdminConfig.modify(dynamicCache, [['enableDiskOffload', 'true'], ['diskCacheEntrySizeInMB', '0'], ['diskCacheSizeInGB', '0'], ['pushFrequency', '1'], ['diskCacheCleanupFrequency', '0'], ['diskCacheSizeInEntries', '0']])

saveConfiguration()
