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
    print '-f /tmp/configure_cross_site_scripting_prevention.py <cookiename>'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      cookiename    is the cookie name to set httponly flag on'
    print
    print 'Sample:'
    print '=============================================================================='
    print 'wsadmin -lang jython -user wasadmin -password passw0rd'
    print ' -f "/tmp/configure_cross_site_scripting_prevention.py" JSESSIONID'
    print '=============================================================================='
    print


# Verify that the correct number of parameters exist
if not (len(sys.argv) == 1):
    sys.stderr.write("Invalid number of arguments\n")
    printUsage()
    sys.exit(101)

jsessionIdCookieName = sys.argv[0]

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
    nodeName = AdminConfig.showAttribute(node, 'name')
    servers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']'
    ).splitlines()
    for server in servers:
        setHttponlyCookies(server, jsessionIdCookieName)

print "Setting httponly for all cookies custom property for Global Security"
result = AdminTask.setAdminActiveSecuritySettings(
    '[-customProperties[\"com.ibm.ws.security.addHttpOnlyAttributeToCookies=true\"]]'
)

saveConfiguration()
