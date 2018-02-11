print 'installing, and mapping application to all clusters, and web servers'
mapModulesToServersList = []
mapModulesToServers = ''
cell = AdminControl.getCell()
nodeNames = AdminTask.listNodes().splitlines()

serverClusters = AdminConfig.list('ServerCluster', AdminConfig.getid( '/Cell:' + cell + '/')).splitlines()
for serverCluster in serverClusters:
  serverClusterName = AdminConfig.showAttribute(serverCluster, 'name')
  mapModulesToServersList.append('WebSphere:cell=' + cell + ',cluster=' + serverClusterName)

for nodeName in nodeNames:
  webServers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + nodeName + ']').splitlines()
  for webServer in webServers:
    webServerName = AdminConfig.showAttribute(webServer, 'name')
    mapModulesToServersList.append('WebSphere:cell=' + cell + ',node=' + nodeName + ',server=' + webServerName)

for x in range(len(mapModulesToServersList)):
  mapModulesToServers += mapModulesToServersList[x]
  y = len(mapModulesToServersList) - x
  if ( y > 1 ):
    mapModulesToServers += '+'

result = AdminApp.install('/net/files/srv/install/wp/wp.zproxy/wp.zproxy.ear', '[ -appname "AJAX Proxy Servlet for Context Mapping" -MapModulesToServers [[ "AJAX Proxy Servlet for Context Mapping" wp.zproxy.war,WEB-INF/web.xml ' + mapModulesToServers + ' ]]]' )

print '+++ saving configuration +++'
result = AdminConfig.save()

print 'allow access to proxy endpoints to authenticated users'
result = AdminApp.edit('AJAX Proxy Servlet for Context Mapping', '[ -MapRolesToUsers [[ "Allowed Proxy Users" AppDeploymentOption.No AppDeploymentOption.Yes "" "" AppDeploymentOption.No "" "" ]]]' ) 

print '+++ saving configuration +++'
result = AdminConfig.save()

print '+++ synchronizing configuration +++'
dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
nodes = AdminControl.invoke(dmgr, 'syncActiveNodes', 'true')
print 'the following nodes have been synchronized:'
for node in nodes.splitlines():
  print ' - ' + node

for nodeName in nodeNames:
  webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + nodeName + ']').splitlines()
  for webserver in webservers:
    webserverName = AdminConfig.showAttribute(webserver, 'name')
    generator = AdminControl.completeObjectName('type=PluginCfgGenerator,*')
    print "Generating plugin-cfg.xml for " + webserverName + " on " + nodeName
    result = AdminControl.invoke(generator, 'generate', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +  ' ' + nodeName + ' ' + webserverName + ' false')
    print "Propagating plugin-cfg.xml for " + webserverName + " on " + nodeName
    result = AdminControl.invoke(generator, 'propagate', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell + ' ' + nodeName + ' ' + webserverName)
    print "Propagating keyring for " + webserverName + " on " + nodeName
    result = AdminControl.invoke(generator, 'propagateKeyring', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell + ' ' + nodeName + ' ' + webserverName)
    webserverCON = AdminControl.completeObjectName('type=WebServer,*')
    print "Stopping " + webserverName + " on " + nodeName
    result = AdminControl.invoke(webserverCON, 'stop', '[' + cell + ' ' + nodeName + ' ' + webserverName + ']')
    print "Starting " + webserverName + " on " + nodeName
    result = AdminControl.invoke(webserverCON, 'start', '[' + cell + ' ' + nodeName + ' ' + webserverName + ']')

print 'starting "AJAX Proxy Servlet for Context Mapping"'
applicationManagers=AdminControl.queryNames('type=ApplicationManager,process=*,*').splitlines()
for applicationManager in applicationManagers:
  result = AdminControl.invoke(applicationManager, 'startApplication','"AJAX Proxy Servlet for Context Mapping"')
