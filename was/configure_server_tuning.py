sessionMaximum = '10000'
sessionTimeout = '10'
threadpoolWebContainer = '50'
transactionLifetimeTimeout = '600'

execfile('common.py')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  print 'iterating through all servers in node ' + nodeName
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    setSessionTuning(server, sessionTimeout, sessionMaximum)
    setWebcontainerThreadpoolTuning(server, threadpoolWebContainer)
    print 'enabling starting WAS components as needed on ' + server
    result = AdminConfig.modify(server, '[[provisionComponents true]]')
    print 'enabling servlet caching on ' + server
    result = AdminConfig.modify(AdminConfig.list('WebContainer', server), '[[enableServletCaching true]]')
    print 'enabling portlet fragment caching on ' + server
    result = AdminConfig.modify(AdminConfig.list('PortletContainer', server), '[[enablePortletCaching true]]')
    print 'setting transaction timeout to ' + transactionLifetimeTimeout + ' on ' + server
    result = AdminConfig.modify(AdminConfig.list('TransactionService', server), '[[totalTranLifetimeTimeout ' + transactionLifetimeTimeout + ']]')

saveConfiguration()
