import re
servers = AdminConfig.list('Server').splitlines()
for server in servers:
  serverType = AdminConfig.showAttribute(server, 'serverType')
  if serverType == 'NODE_AGENT':
    services = AdminConfig.list('Service', server).splitlines()
    configSyncServiceRE = re.compile('.*ConfigSynchronizationService.*')
    for service in services:
      if configSyncServiceRE.match(service):
        serverName = AdminConfig.showAttribute(server,"name")
        print "disabling file synchronization service on " + serverName
        result = AdminConfig.modify(service, '[[autoSynchEnabled "false"]]')
result = AdminConfig.save()
