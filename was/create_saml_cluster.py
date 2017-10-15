execfile('common.py')

cell = AdminControl.getCell()

print 'create SamlCluster'
result = AdminTask.createCluster('[-clusterConfig [-clusterName SamlCluster -preferLocal true]]')

isFirstMemberMade = 'false'
managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  if ( isFirstMemberMade != 'true' ):
    print 'create a cluster member SamlServer_' + managedNodeName + ' on each node ' + managedNodeName + ' as first member'
    result = AdminTask.createClusterMember('[-clusterName SamlCluster -memberConfig [-memberNode ' + managedNodeName + ' -memberName SamlServer_' + managedNodeName + ' -memberWeight 2 -genUniquePorts true -replicatorEntry false] -firstMember [-templateName default -nodeGroup DefaultNodeGroup -coreGroup DefaultCoreGroup -resourcesScope cluster]]')
    isFirstMemberMade = 'true'
  else:
    print 'create a cluster member SamlServer_' + managedNodeName + ' on each node ' + managedNodeName
    result = AdminTask.createClusterMember('[-clusterName SamlCluster -memberConfig [-memberNode ' + managedNodeName + ' -memberName SamlServer_' + managedNodeName + ' -memberWeight 2 -genUniquePorts true -replicatorEntry false]]')

synchronizeActiveNodes()

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  applicationServers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for applicationServer in applicationServers:
    applicationServerName = AdminConfig.showAttribute(applicationServer, 'name')
    if applicationServerName == 'SamlServer_' + managedNodeName:
      print 'starting ' + applicationServerName + ' on ' + managedNodeName
      AdminControl.startServer(applicationServerName,managedNodeName)

apps = AdminApp.list().splitlines()
for app in apps:
  if ( app == 'DefaultApplication.ear' ):
    print 'uninstalling previously installed DefaultApplication.ear'
    result =  AdminApp.uninstall('DefaultApplication.ear')

print 'installing DefaultApplication.ear'
result = AdminApp.install('/opt/IBM/WebSphere/AppServer/installableApps/DefaultApplication.ear')

synchronizeActiveNodes()

print 'map DefaultApplication.ear to SamlCluster, and webservers'
mapModulesToServer = 'WebSphere:cell=' + cell + ',cluster=SamlCluster'
unmanagedNodeNames = AdminTask.listUnmanagedNodes().splitlines()
for unmanagedNodeName in unmanagedNodeNames:
  webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + unmanagedNodeName + ']').splitlines()
  for webserver in webservers:
    webserverName = AdminConfig.showAttribute(webserver, 'name')
    mapModulesToServer = mapModulesToServer + '+WebSphere:cell=' + cell + ',node=' + unmanagedNodeName + ',server=' + webserverName

result = AdminApp.edit('DefaultApplication.ear', '[ -MapModulesToServers [[ "Increment EJB module" Increment.jar,META-INF/ejb-jar.xml ' + mapModulesToServer + ' ][ "Default Web Application" DefaultWebApplication.war,WEB-INF/web.xml ' + mapModulesToServer + ']]]' )

synchronizeActiveNodes()
propagatePluginCfg()

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  applicationServers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for applicationServer in applicationServers:
    applicationServerName = AdminConfig.showAttribute(applicationServer, 'name')
    if applicationServerName == 'SamlServer_' + managedNodeName:
      print 'starting DefaultApplication.ear on ' + managedNodeName
      appManager = AdminControl.queryNames('type=ApplicationManager,process=SamlServer_' + managedNodeName + ',*')
      result = AdminControl.invoke(appManager, 'startApplication','DefaultApplication.ear')
