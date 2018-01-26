import os, re, java.io.File, sys
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')

cell = AdminControl.getCell()

print 'check that you can login to the following URLs:'
unmanagedNodeNames = AdminTask.listUnmanagedNodes().splitlines()
for unmanagedNodeName in unmanagedNodeNames:
    unmanagedNode = AdminConfig.getid(
        '/Cell:' + cell + '/Node:' + unmanagedNodeName + ' ')
    unmanagedNodeNameHostName = AdminConfig.showAttribute(
        unmanagedNode, 'hostName')
    print ' https://' + unmanagedNodeNameHostName + '/snoop'

print 'after checking that snoop works, then *DO NOT* close your browser.'
print 'press [ENTER] when you are done'
result = sys.stdin.readline()

print 'testing session failover'
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
            print ''
            print '>>>>>>>>>> check that snoop is still working on the webserver(s) listed above, and that you are not asked to login again'
            print 'press [ENTER] when you are done'
            result = sys.stdin.readline()
            print 'starting ' + applicationServerName + ' on ' + managedNodeName
            result = AdminControl.startServer(applicationServerName,
                                              managedNodeName)

print ''
print '>>>>>>>>> So if you did not lose you snoop session while starting, and stopping the servers, then that means that WAS is working as expected'
