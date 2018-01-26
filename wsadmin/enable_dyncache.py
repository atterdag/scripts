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
    print '-f /tmp/enable_dyncache.py <size>'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      size          is the cache size in entries'
    print
    print 'Sample:'
    print '=============================================================================='
    print 'wsadmin -lang jython -user wasadmin -password passw0rd'
    print ' -f "/tmp/enable_dyncache.py" 3000'
    print '=============================================================================='
    print


# Verify that the correct number of parameters exist
if not (len(sys.argv) == 1):
    sys.stderr.write("Invalid number of arguments\n")
    printUsage()
    sys.exit(101)

cacheSize = sys.argv[0]

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    print 'iterating through all servers in node ' + managedNodeName
    servers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for server in servers:
        serverName = AdminConfig.showAttribute(server, 'name')
        serverClusterName = AdminConfig.showAttribute(server, 'clusterName')
        serverId = AdminConfig.getid(
            '/Node:' + managedNodeName + '/Server:' + serverName)
        dynamicCache = AdminConfig.list('DynamicCache', serverId)
        print 'modifying dynamic cache ' + dynamicCache
        result = AdminConfig.modify(
            dynamicCache,
            [['enableCacheReplication', 'true'], ['replicationType', 'NONE'],
             ['enable', 'true'], ['cacheSize', cacheSize]])
        drssettings = AdminConfig.showAttribute(dynamicCache,
                                                'cacheReplication')
        if drssettings == None:
            print 'creating DRSSettings for cacheReplication on dynamic cache ' + dynamicCache
            result = AdminConfig.create(
                'DRSSettings', dynamicCache,
                [['messageBrokerDomainName', serverClusterName]])
        else:
            print 'setting DRSSettings for cacheReplication on dynamic cache ' + dynamicCache
            result = AdminConfig.modify(
                drssettings, [['messageBrokerDomainName', serverClusterName]])

saveConfiguration()
