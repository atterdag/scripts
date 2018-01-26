import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')

cell = AdminControl.getCell()

print 'create TestCluster'
result = AdminTask.createCluster(
    '[-clusterConfig [-clusterName TestCluster -preferLocal true]]')

isFirstMemberMade = 'false'
managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    if (isFirstMemberMade != 'true'):
        print 'create a cluster member testserver_' + managedNodeName + ' on each node ' + managedNodeName + ' as first member'
        result = AdminTask.createClusterMember(
            '[-clusterName TestCluster -memberConfig [-memberNode ' +
            managedNodeName + ' -memberName testserver_' + managedNodeName +
            ' -memberWeight 2 -genUniquePorts true -replicatorEntry false] -firstMember [-templateName default -nodeGroup DefaultNodeGroup -coreGroup DefaultCoreGroup -resourcesScope cluster]]'
        )
        isFirstMemberMade = 'true'
    else:
        print 'create a cluster member testserver_' + managedNodeName + ' on each node ' + managedNodeName
        result = AdminTask.createClusterMember(
            '[-clusterName TestCluster -memberConfig [-memberNode ' +
            managedNodeName + ' -memberName testserver_' + managedNodeName +
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
        if applicationServerName == 'testserver_' + managedNodeName:
            print 'starting ' + applicationServerName + ' on ' + managedNodeName
            AdminControl.startServer(applicationServerName, managedNodeName)

print 'installing DefaultApplication.ear'
result = AdminApp.install(
    os.environ['WAS_HOME'] + '/installableApps/DefaultApplication.ear')

synchronizeActiveNodes()

print 'map DefaultApplication.ear to TestCluster, and webservers'
mapModulesToServer = 'WebSphere:cell=' + cell + ',cluster=TestCluster'
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
        if applicationServerName == 'testserver_' + managedNodeName:
            print 'starting DefaultApplication.ear on ' + managedNodeName
            appManager = AdminControl.queryNames(
                'type=ApplicationManager,process=testserver_' +
                managedNodeName + ',*')
            result = AdminControl.invoke(appManager, 'startApplication',
                                         'DefaultApplication.ear')

print ''
print '>>>>>>>>> The cluster is now started with all servers - SE LETS TEST!'
