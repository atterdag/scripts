cell = AdminControl.getCell()
serverClusters = AdminConfig.list('ServerCluster').splitlines()
for serverCluster in serverClusters:
  serverClusterName = AdminConfig.showAttribute(serverCluster,"name")
  clusterMembers = AdminConfig.list('ClusterMember', AdminConfig.getid( '/Cell:' + cell + '/ServerCluster:' + serverClusterName + '/')).splitlines()
  for clusterMember in clusterMembers:
    clusterMemberNodeName = AdminConfig.showAttribute(clusterMember,"nodeName")
    clusterMemberName = AdminConfig.showAttribute(clusterMember,"memberName")
    print 'enable traffic to ' + clusterMemberName + ' on ' + clusterMemberNodeName
    result = AdminTask.updateClusterMemberWeights('[-clusterName PortalCluster -members [[' + clusterMemberNodeName + ' ' + clusterMemberName + ' 2]]]')

print "***** saving configuration *****"
result = AdminConfig.save()
