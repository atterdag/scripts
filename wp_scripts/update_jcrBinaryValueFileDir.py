cell = AdminControl.getCell()
managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  print 'iterating through all servers in node ' + managedNodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    if serverName == 'WebSphere_Portal_1':
      print '-iterating through all resource environment providers in server ' + serverName
      resourceEnvironmentProviders = AdminConfig.list('ResourceEnvironmentProvider', AdminConfig.getid('/Cell:' + cell + '/Node:' + managedNodeName + '/Server:' + serverName + '/')).splitlines()
      for resourceEnvironmentProvider in resourceEnvironmentProviders:
        resourceEnvironmentProviderName = AdminConfig.showAttribute(resourceEnvironmentProvider, 'name')
        if resourceEnvironmentProviderName == 'JCR ConfigService PortalContent':
          print '--iterating through all custom properties in resource environment provider ' + resourceEnvironmentProviderName
          resourceEnvironmentProviderPropertySet = AdminConfig.showAttribute(resourceEnvironmentProvider, 'propertySet')
          j2EEResourceProperty = AdminConfig.list('J2EEResourceProperty', resourceEnvironmentProviderPropertySet) 
          j2EEResourcePropertyName = AdminConfig.showAttribute(j2EEResourceProperty, 'name')
          if j2EEResourcePropertyName == 'jcr.binaryValueFileDir':
            print '---setting custom properties jcr.binaryValueFileDir to /opt/IBM/WebSphere/wp_profile/PortalServer/jcr/binaryValues_1'
            result = AdminConfig.modify(j2EEResourceProperty, [['value', '/opt/IBM/WebSphere/wp_profile/PortalServer/jcr/binaryValues_1']])

print '*** saving configuration ***'
result = AdminConfig.save()

print '+++ synchronizing configuration +++'
dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
nodes = AdminControl.invoke(dmgr, 'syncActiveNodes', 'true')
print 'the following nodes have been synchronized:'
for node in nodes.splitlines():
  print ' - ' + node
