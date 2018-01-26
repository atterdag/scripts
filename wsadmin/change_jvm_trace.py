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
    print '-f /tmp/change_jvm_trace.py <runtimelevel> [startuplevel]'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      runtimelevel  is JVM runtime trace level'
    print '      startuplevel  is JVM startup trace level'
    print '                     if omitted it defaults to runtimelevel'
    print
    print 'Sample:'
    print '=============================================================================='
    print 'wsadmin -lang jython -user wasadmin -password passw0rd'
    print ' -f "/tmp/change_jvm_trace.py"'
    print ' \'*=info:com.ibm.ws.wssecurity.*=all:com.ibm.ws.security.*=all\''
    print ' \'*=info\''
    print '=============================================================================='
    print


# Verify that the correct number of parameters exist
if not (len(sys.argv) == 1):
    sys.stderr.write("Invalid number of arguments\n")
    printUsage()
    sys.exit(101)

startupLevel = sys.argv[0]

if sys.argv[1] == "":
    runtimeLevel = startupLevel
else:
    runtimeLevel = sys.argv[1]

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
    nodeName = AdminConfig.showAttribute(node, 'name')
    print 'iterating through all servers in node ' + nodeName
    servers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']'
    ).splitlines()
    for server in servers:
        print '------------------------------------------------------------------------------'
        print server
        print '------------------------------------------------------------------------------'
        configureTraceLog(server, "10", "50")
        print '------------------------------------------------------------------------------'
        configureJvmStartupTrace(server, startupLevel)
        print '------------------------------------------------------------------------------'
        configureJvmRuntimeTrace(server, runtimeLevel)

saveConfiguration()
