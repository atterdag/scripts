managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  print 'iterating through all servers in node ' + managedNodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    serverClusterName = AdminConfig.showAttribute(server, 'clusterName')
    if serverName == 'WebSphere_Portal':
      print 'creating new server ' + managedNodeName + '/' + serverName + '_1'
      result = AdminTask.createClusterMember('[-clusterName PortalCluster -memberConfig [-memberNode ' + managedNodeName + ' -memberName ' + serverName + '_1 -memberWeight 2 -genUniquePorts true -replicatorEntry false]]')
      serverId = AdminConfig.getid('/Node:' + managedNodeName + '/Server:' + serverName + '_1')
      dynamicCache = AdminConfig.list('DynamicCache', serverId)
      print 'modifying dynamic cache ' + dynamicCache
      result = AdminConfig.modify(dynamicCache, [['enableCacheReplication', 'true'], ['replicationType', 'NONE'], ['enable', 'true'], ['cacheSize', '3000']])
      print 'creating DRSSettings for cacheReplication on dynamic cache ' + dynamicCache
      result = AdminConfig.create('DRSSettings', dynamicCache, [['messageBrokerDomainName', serverClusterName ]])

print '*** saving configuration ***'
result = AdminConfig.save()
