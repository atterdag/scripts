import re

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
