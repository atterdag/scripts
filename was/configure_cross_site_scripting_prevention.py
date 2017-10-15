import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

jsessionIdCookieName='JSESSIONID'

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    setHttponlyCookies(server,jsessionIdCookieName)

print "Setting httponly for all cookies custom property for Global Security"
result = AdminTask.setAdminActiveSecuritySettings('[-customProperties[\"com.ibm.ws.security.addHttpOnlyAttributeToCookies=true\"]]')

saveConfiguration()
