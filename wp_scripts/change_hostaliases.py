# define new default host ports
WC_defaulthost='10139'
WC_defaulthost_secure='10142'

cell = AdminControl.getCell()
createDefaultHostPort = 'true'
createDefaultHostSecurePort = 'true'
hostAliases = AdminConfig.list('HostAlias', AdminConfig.getid( '/Cell:' + cell + '/VirtualHost:default_host/')).splitlines()
for hostAlias in hostAliases:
  hostAliasPort = AdminConfig.showAttribute(hostAlias, 'port')
  if hostAliasPort == '10059' or hostAliasPort == '10062':
    print 'deleting old default_host host alias port ' + hostAliasPort
    result = AdminConfig.remove(hostAlias)
  if hostAliasPort == WC_defaulthost:
    print 'found existing default_host host alias port ' + WC_defaulthost
    createDefaultHostPort = 'false'
  if hostAliasPort == WC_defaulthost_secure:
    print 'found existing default_host host alias port ' + WC_defaulthost
    createDefaultHostSecurePort = 'false'

if createDefaultHostPort == 'true':
  print 'creating default_host host alias port ' + WC_defaulthost
  result = AdminConfig.create('HostAlias', AdminConfig.getid('/Cell:' + cell + '/VirtualHost:default_host/'), '[[port ' + WC_defaulthost + '] [hostname "*"]]')

if createDefaultHostSecurePort == 'true':
  print 'creating default_host host alias port ' + WC_defaulthost_secure
  result = AdminConfig.create('HostAlias', AdminConfig.getid('/Cell:' + cell + '/VirtualHost:default_host/'), '[[port ' + WC_defaulthost_secure + '] [hostname "*"]]')

print '*** saving configuration ***'
result = AdminConfig.save()

print '+++ synchronizing configuration +++'
dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
nodes = AdminControl.invoke(dmgr, 'syncActiveNodes', 'true')
print 'the following nodes have been synchronized:'
for node in nodes.splitlines():
  print ' - ' + node
