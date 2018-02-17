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
    print '-f /tmp/remove_server.py <nodeName> <serverName>'
    print '      $WAS_HOME       is the installation directory for WebSphere'
    print '      username        is the WebSphere Application Server user name'
    print '      password        is the WebSphere Application Server user password'
    print '      serverName      is the server name'
    print '      managedNodeName is the node where the server is running'
    print
    print 'Sample:'
    print '=============================================================================='
    print 'wsadmin -lang jython -user wasadmin -password passw0rd'
    print ' -f "/tmp/remove_server.py" server1 [wasNode01]'
    print '=============================================================================='
    print


# Verify that the correct number of parameters exist
if not (len(sys.argv) == 1):
    sys.stderr.write("Invalid number of arguments\n")
    printUsage()
    sys.exit(101)
serverName = sys.argv[0]
if (len(sys.argv) == 2):
    managedNodeName = sys.argv[1]
else:
    managedNodeName = ''
if managedNodeName == '':
    managedNodeNames = AdminTask.listManagedNodes().splitlines()
    for managedNodeName in managedNodeNames:
        print "serverName: " + serverName
        print "managedNodeName: " + managedNodeName
        deleteServer(managedNodeName, serverName)
else:
    deleteServer(managedNodeName, serverName)
saveConfiguration()
