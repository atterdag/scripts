import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')

print 'installing, and mapping application to all clusters, and web servers'
mapModulesToServersList = []
mapModulesToServers = ''
cell = AdminControl.getCell()
nodeNames = AdminTask.listNodes().splitlines()

serverClusters = AdminConfig.list(
    'ServerCluster', AdminConfig.getid('/Cell:' + cell + '/')).splitlines()
for serverCluster in serverClusters:
    serverClusterName = AdminConfig.showAttribute(serverCluster, 'name')
    mapModulesToServersList.append(
        'WebSphere:cell=' + cell + ',cluster=' + serverClusterName)

for nodeName in nodeNames:
    webServers = AdminTask.listServers(
        '[-serverType WEB_SERVER -nodeName ' + nodeName + ']').splitlines()
    for webServer in webServers:
        webServerName = AdminConfig.showAttribute(webServer, 'name')
        mapModulesToServersList.append('WebSphere:cell=' + cell + ',node=' +
                                       nodeName + ',server=' + webServerName)

for x in range(len(mapModulesToServersList)):
    mapModulesToServers += mapModulesToServersList[x]
    y = len(mapModulesToServersList) - x
    if (y > 1):
        mapModulesToServers += '+'

applicationInstalled = 'false'
applications = AdminApp.list().splitlines()
for application in applications:
    if application == 'DynaCacheEsi':
        print '"DynaCacheEsi" is already installed'
        applicationInstalled = 'true'

if applicationInstalled == 'false':
    result = AdminApp.install(
        os.environ['WAS_HOME'] + '/installableApps/DynaCacheEsi.ear',
        '[ -appname DynaCacheEsi -MapModulesToServers [[ DynaCacheEsi DynaCacheEsi.war,WEB-INF/web.xml '
        + mapModulesToServers + ' ]]]')

synchronizeActiveNodes()
propagatePluginCfg()

print 'starting DynaCacheEsi'
applicationManagers = AdminControl.queryNames(
    'type=ApplicationManager,process=*,*').splitlines()
for applicationManager in applicationManagers:
    result = AdminControl.invoke(applicationManager, 'startApplication',
                                 '[DynaCacheEsi]')
