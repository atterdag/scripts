execfile('common.py')

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
