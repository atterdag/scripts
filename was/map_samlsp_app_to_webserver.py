execfile('common.py')

cell = AdminControl.getCell()

print 'map WebSphereSamlSPWeb.war to PortalCluster, and webservers'
mapModulesToServer = 'WebSphere:cell=' + cell + ',cluster=PortalCluster'
unmanagedNodeNames = AdminTask.listUnmanagedNodes().splitlines()
for unmanagedNodeName in unmanagedNodeNames:
  webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + unmanagedNodeName + ']').splitlines()
  for webserver in webservers:
    webserverName = AdminConfig.showAttribute(webserver, 'name')
    mapModulesToServer = mapModulesToServer + '+WebSphere:cell=' + cell + ',node=' + unmanagedNodeName + ',server=' + webserverName

result = AdminApp.edit('WebSphereSamlSP', '[ -MapModulesToServers [[ WebSphereSamlSPWeb WebSphereSamlSPWeb.war,WEB-INF/web.xml ' + mapModulesToServer + ']]]' )

synchronizeActiveNodes()
propagatePluginCfg()

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  applicationServers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for applicationServer in applicationServers:
    applicationServerName = AdminConfig.showAttribute(applicationServer, 'name')
    if applicationServerName == 'SamlServer_' + managedNodeName:
      print 'starting WebSphereSamlSP on ' + managedNodeName
      appManager = AdminControl.queryNames('type=ApplicationManager,process=SamlServer_' + managedNodeName + ',*')
      result = AdminControl.invoke(appManager, 'startApplication','WebSphereSamlSP')
