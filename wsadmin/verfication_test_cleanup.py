import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')

cell = AdminControl.getCell()

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    applicationServers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for applicationServer in applicationServers:
        applicationServerName = AdminConfig.showAttribute(
            applicationServer, 'name')
        if applicationServerName == 'testserver_' + managedNodeName:
            print 'stopping DefaultApplication.ear on ' + managedNodeName
            appManager = AdminControl.queryNames(
                'type=ApplicationManager,process=testserver_' +
                managedNodeName + ',*')
            result = AdminControl.invoke(appManager, 'stopApplication',
                                         'DefaultApplication.ear')

apps = AdminApp.list().splitlines()
for app in apps:
    if (app == 'DefaultApplication.ear'):
        print 'uninstalling DefaultApplication.ear'
        result = AdminApp.uninstall('DefaultApplication.ear')

saveConfiguration()

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    applicationServers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for applicationServer in applicationServers:
        applicationServerName = AdminConfig.showAttribute(
            applicationServer, 'name')
        if applicationServerName == 'testserver_' + managedNodeName:
            print 'stopping ' + applicationServerName + ' on ' + managedNodeName
            result = AdminControl.stopServer(applicationServerName,
                                             managedNodeName)
            print 'deleting ' + applicationServerName + ' on ' + managedNodeName
            result = AdminTask.deleteServer(
                '[-serverName ' + applicationServerName + ' -nodeName ' +
                managedNodeName + ' ]')

saveConfiguration()

clusters = AdminConfig.list('ServerCluster').splitlines()
for cluster in clusters:
    clusterName = AdminConfig.showAttribute(cluster, 'name')
    if (clusterName == 'TestCluster'):
        print 'deleting TestCluster'
        result = AdminTask.deleteCluster('[-clusterName TestCluster ]')

synchronizeActiveNodes()

print ''
print '>>>>>>>>> The test cluster, servers etc have now been removed'
