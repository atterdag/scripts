import os
import re
import java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


def printUsage():
    print
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username] [-password password]'
    print '-f /tmp/set_http_proxy.py <host> <port> <no proxy> [username] [password]'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '                     Application Server'
    print '      profilename   is the WebSphere Application Server profile'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      host          is the proxy server FQDN'
    print '      port          is the proxy server listening port'
    print '      no proxy      is a CSV list of DIRECT URLs'
    print '      username      is a proxy user name'
    print '      password      is a proxy user password'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/set_http_proxy.py" "cache.example.com" 3128 '
    print ' "localhost|127.0.0.1|*.example.com|*.example.lan"'
    print ' "proxyuser" \'password\''
    print '=============================================================================='
    print


if not (len(sys.argv) == 3):
    sys.stderr.write('Invalid number of arguments\n')
    printUsage()
    sys.exit(101)

esiMaxCacheSize = sys.argv[0]

wasJvmHttpProxyHost = sys.argv[0]
wasJvmHttpProxyPort = sys.argv[1]
wasJvmHttpNonProxyHosts = sys.argv[2]
wasJvmHttpProxyUser = sys.argv[3]
wasJvmHttpProxyPassword = sys.argv[4]

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
    nodeName = AdminConfig.showAttribute(node, 'name')
    print 'iterating through all servers in node ' + nodeName
    servers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
    for server in servers:
        serverName = AdminConfig.showAttribute(server, 'name')
        setJvmCustomProperties(
            server, [[['name', 'http.proxyHost'], ['value', wasJvmHttpProxyHost]]])
        setJvmCustomProperties(
            server, [[['name', 'http.proxyPort'], ['value', wasJvmHttpProxyPort]]])
        setJvmCustomProperties(
            server, [[['name', 'http.nonProxyHosts'], ['value', wasJvmHttpNonProxyHosts]]])
        setJvmCustomProperties(
            server, [[['name', 'https.proxyHost'], ['value', wasJvmHttpProxyHost]]])
        setJvmCustomProperties(
            server, [[['name', 'https.proxyPort'], ['value', wasJvmHttpProxyPort]]])
        setJvmCustomProperties(
            server, [[['name', 'https.nonProxyHosts'], ['value', wasJvmHttpNonProxyHosts]]])
        setJvmCustomProperties(
            server, [[['name', 'ftp.proxyHost'], ['value', wasJvmHttpProxyHost]]])
        setJvmCustomProperties(
            server, [[['name', 'ftp.proxyPort'], ['value', wasJvmHttpProxyPort]]])
        setJvmCustomProperties(
            server, [[['name', 'ftp.nonProxyHosts'], ['value', wasJvmHttpNonProxyHosts]]])

if (wasJvmHttpProxyUser=! ""):
    if (wasJvmHttpProxyPassword == ""):
        print 'missing proxy user password'
        sys.exit(102)
    setJvmCustomProperties(
        server, [[['name', 'http.proxyUser'], ['value', wasJvmHttpProxyUser]]])
    setJvmCustomProperties(
        server, [[['name', 'http.proxyPassword'], ['value', wasJvmHttpProxyPassword]]])
    setJvmCustomProperties(
        server, [[['name', 'https.proxyUser'], ['value', wasJvmHttpProxyUser]]])
    setJvmCustomProperties(
        server, [[['name', 'https.proxyPassword'], ['value', wasJvmHttpProxyPassword]]])

saveConfiguration()
