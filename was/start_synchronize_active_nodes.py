
print '##############################################################################'
print '# Synchronizing configuration                                                #'
print '##############################################################################'
print
dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
nodes = AdminControl.invoke(dmgr, 'syncActiveNodes', 'true')
print 'the following nodes have been synchronized:'
for node in nodes.splitlines():
  print ' - ' + node
