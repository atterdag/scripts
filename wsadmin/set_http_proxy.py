import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

wasJvmHttpProxyHost='cache.example.com'
wasJvmHttpProxyPort='3128'
wasJvmHttpNonProxyHosts='localhost|127.0.0.1|*.example.com|*.example.lan'

execfile('common.py')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  print 'iterating through all servers in node ' + nodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    setJvmCustomProperties(server, [[['name', 'http.proxyHost'], ['value', wasJvmHttpProxyHost]]])
    setJvmCustomProperties(server, [[['name', 'http.proxyPort'], ['value', wasJvmHttpProxyPort]]])
    setJvmCustomProperties(server, [[['name', 'http.nonProxyHosts'], ['value', wasJvmHttpNonProxyHosts]]])
    setJvmCustomProperties(server, [[['name', 'https.proxyHost'], ['value', wasJvmHttpProxyHost]]])
    setJvmCustomProperties(server, [[['name', 'https.proxyPort'], ['value', wasJvmHttpProxyPort]]])
    setJvmCustomProperties(server, [[['name', 'https.nonProxyHosts'], ['value', wasJvmHttpNonProxyHosts]]])
    setJvmCustomProperties(server, [[['name', 'ftp.proxyHost'], ['value', wasJvmHttpProxyHost]]])
    setJvmCustomProperties(server, [[['name', 'ftp.proxyPort'], ['value', wasJvmHttpProxyPort]]])
    setJvmCustomProperties(server, [[['name', 'ftp.nonProxyHosts'], ['value', wasJvmHttpNonProxyHosts]]])

saveConfiguration()
