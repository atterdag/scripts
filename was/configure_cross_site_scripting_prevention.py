jsessionIdCookieName='JSESSIONID'

execfile('common.py')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    httponlyCookies(server,jsessionIdCookieName)

print "Setting httponly for all cookies custom property for Global Security"
result = AdminTask.setAdminActiveSecuritySettings('[-customProperties[\"com.ibm.ws.security.addHttpOnlyAttributeToCookies=true\"]]')

saveConfiguration()
