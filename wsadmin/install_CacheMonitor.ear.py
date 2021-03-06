import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


def printUsage():
    print
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username] [-password password]'
    print '-f /tmp/install_CacheMonitor.py "<group RDN value>" "<group DN>"'
    print '      $WAS_HOME         is the installation directory for WebSphere'
    print '                         Application Server'
    print '      profilename       is the WebSphere Application Server profile'
    print '      username          is the WebSphere Application Server user name'
    print '      password          is the WebSphere Application Server user password'
    print '      group RDN value   is group relative distinguished name value'
    print '      group DN value    is group full distinguished name'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/install_CacheMonitor.py"'
    print ' "wasmonitors" "cn=wasmonitors,ou=groups,o=example"'
    print '=============================================================================='
    print


if not (len(sys.argv) == 2):
    sys.stderr.write('Invalid number of arguments\n')
    printUsage()
    sys.exit(101)

cacheMonitorAdministratorGroupCN = sys.argv[0]
cacheMonitorAdministratorGroupDN = sys.argv[1]
realmName = AdminTask.getIdMgrDefaultRealm()

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
    if application == 'Dynamic Cache Monitor':
        print '"Dynamic Cache Monitor" is already installed'
        applicationInstalled = 'true'

if applicationInstalled == 'false':
    result = AdminApp.install(
        os.environ['WAS_HOME'] + '/installableApps/CacheMonitor.ear',
        '[ -appname "Dynamic Cache Monitor" -MapModulesToServers [[ "Dynamic Cache Monitor" CacheMonitor.war,WEB-INF/web.xml '
        + mapModulesToServers + ' ]]]')

saveConfiguration()

print 'map wasmonitor to administrator role'
result = AdminApp.edit(
    'Dynamic Cache Monitor',
    '[ -MapRolesToUsers [[ administrator AppDeploymentOption.No AppDeploymentOption.No "" '
    + cacheMonitorAdministratorGroupCN + ' AppDeploymentOption.No "" group:' +
    realmName + '/' + cacheMonitorAdministratorGroupDN + ' ]]]')

synchronizeActiveNodes()
propagatePluginCfg()

print 'starting Dynamic Cache Monitor'
applicationManagers = AdminControl.queryNames(
    'type=ApplicationManager,process=*,*').splitlines()
for applicationManager in applicationManagers:
    result = AdminControl.invoke(applicationManager, 'startApplication',
                                 '["Dynamic Cache Monitor"]')
