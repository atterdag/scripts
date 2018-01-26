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
    print '-f /tmp/enable_healthcenter.py [hckeystorepw]'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      hckeystorepw  is the healthcenter keystore password'
    print '                     If omitted it defaults to "WebAS"'
    print
    print 'Sample:'
    print '=============================================================================='
    print 'wsadmin -lang jython -user wasadmin -password passw0rd'
    print ' -f "/tmp/enable_healthcenter.py "secret"'
    print '=============================================================================='
    print


# Verify that the correct number of parameters exist
if not (len(sys.argv) == 1):
    sys.stderr.write("Invalid number of arguments\n")
    printUsage()
    sys.exit(101)

healthcenterKeystorePassword = sys.argv[0]

if (healthcenterKeystorePassword == ''):
    healthcenterKeystorePassword = 'WebAS'

cell = AdminControl.getCell()
nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
    nodeName = AdminConfig.showAttribute(node, 'name')
    print 'iterating through all servers in node ' + nodeName
    servers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']'
    ).splitlines()
    for server in servers:
        serverName = AdminConfig.showAttribute(server, 'name')
        setJvmGenericArguements(nodeName, serverName, '-Xhealthcenter')
        setJvmCustomProperties(
            server,
            [[['name', 'com.ibm.java.diagnostics.healthcenter.agent.port'],
              ['value', '1972']]])
        setJvmCustomProperties(server, [[[
            'name', 'com.ibm.java.diagnostics.healthcenter.agent.transport'
        ], ['value', 'JRMP']]])
        setJvmCustomProperties(
            server, [[['name', 'com.ibm.diagnostics.healthcenter.jmx'],
                      ['value', 'on']]])
        setJvmCustomProperties(server, [[[
            'name', 'com.ibm.java.diagnostics.healthcenter.agent.ssl.keyStore'
        ], [
            'value',
            '\${USER_INSTALL_ROOT}/config/cells/' + cell + '/healthcenter.jks'
        ]]])
        setJvmCustomProperties(server, [[[
            'name',
            'com.ibm.java.diagnostics.healthcenter.agent.ssl.keyStorePassword'
        ], ['value', healthcenterKeystorePassword]]])
        setJvmCustomProperties(server, [[[
            'name',
            'com.ibm.java.diagnostics.healthcenter.agent.authentication.file'
        ], [
            'value', '\${USER_INSTALL_ROOT}/config/cells/' + cell +
            '/healthcenter/authentication.txt'
        ]]])
        setJvmCustomProperties(server, [[[
            'name',
            'com.ibm.java.diagnostics.healthcenter.agent.authorization.file'
        ], [
            'value', '\${USER_INSTALL_ROOT}/config/cells/' + cell +
            '/healthcenter/authorization.txt'
        ]]])
        setJvmCustomProperties(server, [[[
            'name',
            'com.ibm.java.diagnostics.healthcenter.data.collection.level'
        ], ['value', 'off']]])

synchronizeActiveNodes()
