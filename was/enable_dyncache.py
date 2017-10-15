execfile('common.py')

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  print 'iterating through all servers in node ' + managedNodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    serverClusterName = AdminConfig.showAttribute(server, 'clusterName')
    serverId = AdminConfig.getid('/Node:' + managedNodeName + '/Server:' + serverName)
    dynamicCache = AdminConfig.list('DynamicCache', serverId)
    print 'modifying dynamic cache ' + dynamicCache
    result = AdminConfig.modify(dynamicCache, [['enableCacheReplication', 'true'], ['replicationType', 'NONE'], ['enable', 'true'], ['cacheSize', '3000']])
    drssettings = AdminConfig.showAttribute(dynamicCache, 'cacheReplication')
    if drssettings == None:
      print 'creating DRSSettings for cacheReplication on dynamic cache ' + dynamicCache
      result = AdminConfig.create('DRSSettings', dynamicCache, [['messageBrokerDomainName', serverClusterName ]])
    else:
      print 'setting DRSSettings for cacheReplication on dynamic cache ' + dynamicCache
      result = AdminConfig.modify(drssettings, [['messageBrokerDomainName', serverClusterName ]])

saveConfiguration()
