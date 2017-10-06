cell = AdminControl.getCell()
serverClusters = AdminConfig.list('ServerCluster').splitlines()
for serverCluster in serverClusters:
  clusterName = AdminConfig.showAttribute(serverCluster, 'name')
  print 'performing ripple start of cluster: ' + clusterName
  clusterCompleteObjectName = AdminControl.completeObjectName('cell=' + cell + ',type=Cluster,name=' + clusterName + ',*')
  result = AdminControl.invoke(clusterCompleteObjectName, 'rippleStart')
