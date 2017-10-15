import re

execfile('common.py')

cell = AdminControl.getCell()
nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  print 'iterating through all servers in node ' + nodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    setJvmGenericArguements(nodeName, serverName, '-Xhealthcenter')
    setJvmCustomProperties(server, [[['name', 'com.ibm.java.diagnostics.healthcenter.agent.port'], ['value', '1972']]])
    setJvmCustomProperties(server, [[['name', 'com.ibm.java.diagnostics.healthcenter.agent.transport'], ['value', 'JRMP']]])
    setJvmCustomProperties(server, [[['name', 'com.ibm.diagnostics.healthcenter.jmx'], ['value', 'on']]])
    setJvmCustomProperties(server, [[['name', 'com.ibm.java.diagnostics.healthcenter.agent.ssl.keyStore'], ['value', '\${USER_INSTALL_ROOT}/config/cells/' + cell + '/healthcenter.jks']]])
    setJvmCustomProperties(server, [[['name', 'com.ibm.java.diagnostics.healthcenter.agent.ssl.keyStorePassword'], ['value', 'WebAS']]])
    setJvmCustomProperties(server, [[['name', 'com.ibm.java.diagnostics.healthcenter.agent.authentication.file'], ['value','\${USER_INSTALL_ROOT}/config/cells/' + cell + '/healthcenter/authentication.txt']]])
    setJvmCustomProperties(server, [[['name', 'com.ibm.java.diagnostics.healthcenter.agent.authorization.file'], ['value', '\${USER_INSTALL_ROOT}/config/cells/' + cell + '/healthcenter/authorization.txt']]])
    setJvmCustomProperties(server, [[['name', 'com.ibm.java.diagnostics.healthcenter.data.collection.level'], ['value', 'off']]])

synchronizeActiveNodes()
