import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


def printUsage():
    print
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-user username] [-password password]'
    print '-f /tmp/create_cluster.py <prefix>'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      prefix        is the cluster, and members name prefix'
    print
    print 'Sample:'
    print '=============================================================================='
    print 'wsadmin -lang jython -user wasadmin -password passw0rd'
    print ' -f "/tmp/create_cluster.py" "default"'
    print '=============================================================================='
    print


# Verify that the correct number of parameters exist
if not (len(sys.argv) == 1):
    sys.stderr.write("Invalid number of arguments\n")
    printUsage()
    sys.exit(101)

prefix = sys.argv[0]

cell = AdminControl.getCell()

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    applicationServers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for applicationServer in applicationServers:
        applicationServerName = AdminConfig.showAttribute(
            applicationServer, 'name')
        if applicationServerName == prefix + 'Server_' + managedNodeName:
            print 'stopping ' + applicationServerName + ' on ' + managedNodeName
            result = AdminControl.stopServer(applicationServerName,
                                             managedNodeName)
            print 'deleting ' + applicationServerName + ' on ' + managedNodeName
            result = AdminTask.deleteServer(
                '[-serverName ' + applicationServerName + ' -nodeName ' +
                managedNodeName + ' ]')

saveConfiguration()

serverClusters = AdminConfig.list('ServerCluster').splitlines()
for serverCluster in serverClusters:
    serverClusterName = AdminConfig.showAttribute(serverCluster, 'name')
    if (serverClusterName == prefix + 'Cluster'):
        print 'deleting ' + prefix + 'Cluster'
        result = AdminTask.deleteCluster(
            '[-clusterName ' + prefix + 'Cluster ]')

synchronizeActiveNodes()

print 'create ' + prefix + 'Cluster'
result = AdminTask.createCluster(
    '[-clusterConfig [-clusterName ' + prefix + 'Cluster -preferLocal true]]')

isFirstMemberMade = 'false'
managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    if (isFirstMemberMade != 'true'):
        print 'create a cluster member ' + prefix + 'Server_' + managedNodeName + ' on each node ' + managedNodeName + ' as first member'
        result = AdminTask.createClusterMember(
            '[-clusterName ' + prefix + 'Cluster -memberConfig [-memberNode ' +
            managedNodeName + ' -memberName ' + prefix + 'Server_' +
            managedNodeName +
            ' -memberWeight 2 -genUniquePorts true -replicatorEntry false] -firstMember [-templateName default -nodeGroup DefaultNodeGroup -coreGroup DefaultCoreGroup -resourcesScope cluster]]'
        )
        isFirstMemberMade = 'true'
    else:
        print 'create a cluster member ' + prefix + 'Server_' + managedNodeName + ' on each node ' + managedNodeName
        result = AdminTask.createClusterMember(
            '[-clusterName ' + prefix + 'Cluster -memberConfig [-memberNode ' +
            managedNodeName + ' -memberName ' + prefix + 'Server_' +
            managedNodeName +
            ' -memberWeight 2 -genUniquePorts true -replicatorEntry false]]')

synchronizeActiveNodes()

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    applicationServers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for applicationServer in applicationServers:
        applicationServerName = AdminConfig.showAttribute(
            applicationServer, 'name')
        if applicationServerName == prefix + 'Server_' + managedNodeName:
            print 'set monitoring policy to RUNNING for ' + managedNodeName + '/' + applicationServerName
            monitoringPolicy = AdminConfig.list('MonitoringPolicy',
                                                applicationServer)
            result = AdminConfig.modify(
                monitoringPolicy,
                '[[autoRestart "true"] [maximumStartupAttempts "3"] [nodeRestartState "RUNNING"] [pingTimeout "300"] [pingInterval "60"]]'
            )
            print 'starting ' + applicationServerName + ' on ' + managedNodeName
            AdminControl.startServer(applicationServerName, managedNodeName)

appInstalled = 'false'
apps = AdminApp.list().splitlines()
for app in apps:
    if (app == 'DefaultApplication.ear'):
        appInstalled = 'true'

if (appInstalled == 'false'):
    print 'installing DefaultApplication.ear'
    result = AdminApp.install(
        os.environ['WAS_HOME'] + '/installableApps/DefaultApplication.ear')

synchronizeActiveNodes()

print 'map DefaultApplication.ear to ' + prefix + 'Cluster, and webservers'
mapModulesToServer = 'WebSphere:cell=' + cell + ',cluster=' + prefix + 'Cluster'
unmanagedNodeNames = AdminTask.listUnmanagedNodes().splitlines()
for unmanagedNodeName in unmanagedNodeNames:
    webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' +
                                       unmanagedNodeName + ']').splitlines()
    for webserver in webservers:
        webserverName = AdminConfig.showAttribute(webserver, 'name')
        mapModulesToServer = mapModulesToServer + '+WebSphere:cell=' + cell + ',node=' + unmanagedNodeName + ',server=' + webserverName

result = AdminApp.edit(
    'DefaultApplication.ear',
    '[ -MapModulesToServers [[ "Increment EJB module" Increment.jar,META-INF/ejb-jar.xml '
    + mapModulesToServer +
    ' ][ "Default Web Application" DefaultWebApplication.war,WEB-INF/web.xml '
    + mapModulesToServer + ']]]')

synchronizeActiveNodes()

nodeNames = AdminTask.listNodes().splitlines()
for nodeName in nodeNames:
    webservers = AdminTask.listServers(
        '[-serverType WEB_SERVER -nodeName ' + nodeName + ']').splitlines()
    for webserver in webservers:
        webserverName = AdminConfig.showAttribute(webserver, 'name')
        generator = AdminControl.completeObjectName(
            'type=PluginCfgGenerator,*')
        print 'Generating plugin-cfg.xml for ' + webserverName + ' on ' + nodeName
        result = AdminControl.invoke(
            generator, 'generate',
            '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +
            ' ' + nodeName + ' ' + webserverName + ' false')
        print 'Propagating plugin-cfg.xml for ' + webserverName + ' on ' + nodeName
        result = AdminControl.invoke(
            generator, 'propagate',
            '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +
            ' ' + nodeName + ' ' + webserverName)
        print 'Propagating keyring for ' + webserverName + ' on ' + nodeName
        result = AdminControl.invoke(
            generator, 'propagateKeyring',
            '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +
            ' ' + nodeName + ' ' + webserverName)
        webserverCON = AdminControl.completeObjectName('type=WebServer,*')
        print 'Stopping ' + webserverName + ' on ' + nodeName
        result = AdminControl.invoke(
            webserverCON, 'stop',
            '[' + cell + ' ' + nodeName + ' ' + webserverName + ']')
        print 'Starting ' + webserverName + ' on ' + nodeName
        result = AdminControl.invoke(
            webserverCON, 'start',
            '[' + cell + ' ' + nodeName + ' ' + webserverName + ']')

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    applicationServers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for applicationServer in applicationServers:
        applicationServerName = AdminConfig.showAttribute(
            applicationServer, 'name')
        if applicationServerName == '' + prefix + 'Server_' + managedNodeName:
            print 'starting DefaultApplication.ear on ' + managedNodeName
            appManager = AdminControl.queryNames(
                'type=ApplicationManager,process=' + prefix + 'Server_' +
                managedNodeName + ',*')
            result = AdminControl.invoke(appManager, 'startApplication',
                                         'DefaultApplication.ear')
