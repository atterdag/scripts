cell = AdminControl.getCell()
cellCompleteobjectName = AdminControl.completeObjectName('type=CellSync,cell=' + cell + ',*')
nodes = AdminTask.listNodes().splitlines()
for node in nodes:
  nodeCompleteObjectName = AdminControl.completeObjectName('type=NodeSync,node=' + node + ',*')
  if ( nodeCompleteObjectName != '' ):
    nodeAgentCompleteObjectName = AdminControl.completeObjectName('type=ConfigRepository,node=' + node + ',process=nodeagent,*')
    print "performing full resynchronize of " + node + ":"
    result = AdminControl.invoke(nodeCompleteObjectName, 'sync')
    result = AdminControl.invoke(nodeAgentCompleteObjectName, 'refreshRepositoryEpoch')
    result = AdminControl.invoke(cellCompleteobjectName, 'syncNode', '[' + node + ']')

print '##############################################################################'
print '# Synchronizing configuration                                                #'
print '##############################################################################'
print
dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
nodes = AdminControl.invoke(dmgr, 'syncActiveNodes', 'true')
print 'the following nodes have been synchronized:'
for node in nodes.splitlines():
  print ' - ' + node

print
print '***** saving configuration *****'
result = AdminConfig.save()
