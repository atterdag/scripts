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
    print '-f /tmp/change_dump_directory.py <directory>'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      directory     is directory to save dump files in'
    print
    print 'Sample:'
    print '=============================================================================='
    print 'wsadmin -lang jython -user wasadmin -password passw0rd'
    print ' -f "/tmp/change_dump_directory.py" \'${SERVER_LOG_ROOT}\''
    print '=============================================================================='
    print
S

# Verify that the correct number of parameters exist
if not (len(sys.argv) == 1):
    sys.stderr.write("Invalid number of arguments\n")
    printUsage()
    sys.exit(101)

dumpDirectory = sys.argv[0]

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    print 'iterating through all servers in node ' + managedNodeName
    servers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for server in servers:
        serverName = AdminConfig.showAttribute(server, 'name')
        javaProcessDef = AdminConfig.list('JavaProcessDef', server)
        print 'Setting heapdump properties on ' + serverName
        result = AdminConfig.modify(javaProcessDef, [[
            'environment', [[['name', 'IBM_COREDIR'], ['value', dumpDirectory]]
                            ]
        ]])
        result = AdminConfig.modify(javaProcessDef, [[
            'environment', [[['name', 'IBM_HEAPDUMPDIR'],
                             ['value', dumpDirectory]]]
        ]])
        result = AdminConfig.modify(javaProcessDef, [[
            'environment', [[['name', 'IBM_JAVACOREDIR'],
                             ['value', dumpDirectory]]]
        ]])

synchronizeActiveNodes()
