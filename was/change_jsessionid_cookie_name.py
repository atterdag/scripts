jsessionIdCookieName='JSESSIONID'

execfile('common.py')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  print 'iterating through all servers in node ' + nodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    setDefaultCookieName(server, jsessionIdCookieName)

saveConfiguration()
