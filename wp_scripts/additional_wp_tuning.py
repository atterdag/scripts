import re
wpJvmNurserySize='1024'
wpTransactionServiceTotalTranLifetimeTimeout='600'
wpWebContainerMaxInMemorySessionCount='10000'

def setInMemorySessions(server, inMemorySessions):
  print 'setting max in memory session count to ' + inMemorySessions + ' on ' + server
  tuningParams = AdminConfig.list('TuningParams', server)
  AdminConfig.modify(tuningParams, [['maxInMemorySessionCount', inMemorySessions]])

def setJvmGenericArguements(nodeName, serverName, newArgument):
  existingJVMProperties = AdminTask.showJVMProperties('[-nodeName ' + nodeName + ' -serverName ' + serverName + ' -propertyName genericJvmArguments]')
  match = re.search(newArgument, existingJVMProperties)
  if not match:
    print nodeName + '/' + serverName + ' JVM arguement "' + newArgument + '" not found - adding'
    newJVMProperties = existingJVMProperties + ' ' + newArgument
    result = AdminTask.setJVMProperties('[-nodeName ' + nodeName + ' -serverName ' + serverName + ' -genericJvmArguments "' + newJVMProperties + '"]')
  else:
    print nodeName + '/' + serverName + ' JVM on arguement "' + newArgument + '" is already present - skipping'

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  print 'iterating through all servers in node ' + nodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    print 'enabling starting WAS components as needed on ' + server
    AdminConfig.modify(server, '[[provisionComponents true]]')
    print 'setting transaction timeout to ' + wpTransactionServiceTotalTranLifetimeTimeout + ' on ' + server
    AdminConfig.modify(AdminConfig.list('TransactionService', server), '[[totalTranLifetimeTimeout ' + wpTransactionServiceTotalTranLifetimeTimeout + ']]')
    setInMemorySessions(server, wpWebContainerMaxInMemorySessionCount)
    setJvmGenericArguements(nodeName, serverName, '-Xmn' + wpJvmNurserySize + 'm')
print '+++ saving configuration +++'
result = AdminConfig.save()
