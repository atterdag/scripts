import os

realmName = "ldap.example.com:636"
cacheMonitorAdministratorGroupDN = 'cn=wasmonitors,ou=groups,o=example'
cacheMonitorAdministratorGroupCN = 'wasmonitors'

execfile('common.py')

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

applicationInstalled = 'false'
applications = AdminApp.list().splitlines()
for application in applications:
  if application == 'Dynamic Cache Monitor':
    print '"Dynamic Cache Monitor" is already installed'
    applicationInstalled = 'true'

if applicationInstalled == 'false':
  result = AdminApp.install(os.environ['WAS_HOME'] + '/installableApps/CacheMonitor.ear', '[ -appname "Dynamic Cache Monitor" -MapModulesToServers [[ "Dynamic Cache Monitor" CacheMonitor.war,WEB-INF/web.xml ' + mapModulesToServers + ' ]]]' )

saveConfiguration()

print 'map wasmonitor to administrator role'
result = AdminApp.edit('Dynamic Cache Monitor', '[ -MapRolesToUsers [[ administrator AppDeploymentOption.No AppDeploymentOption.No "" ' + cacheMonitorAdministratorGroupCN + ' AppDeploymentOption.No "" group:' + realmName + '/' + cacheMonitorAdministratorGroupDN + ' ]]]' )

synchronizeActiveNodes()
propagatePluginCfg()

print 'starting Dynamic Cache Monitor'
applicationManagers=AdminControl.queryNames('type=ApplicationManager,process=*,*').splitlines()
for applicationManager in applicationManagers:
  result = AdminControl.invoke(applicationManager, 'startApplication', '["Dynamic Cache Monitor"]')
