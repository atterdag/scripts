logViewerPortletEarFile = '/net/files/srv/install/wp/logviewer.portlet.ear/binaries/logviewer.portlet.ear'
wpsadminDn = 'uid=wpsadmin,ou=users,o=example'
wpsadminUid = 'wpsadmin'
wpsadminsDn = 'cn=wpsadmins,ou=groups,o=example'
wpsadminsCn = 'wpsadmins'
wpsusersDn = 'cn=wpsusers,ou=groups,o=example'
wpsusersCn = 'wpsusers'

cell = AdminControl.getCell()
print 'install logviewer.portlet to PortalCluster, and webservers'
mapModulesToServer = 'WebSphere:cell=' + cell + ',cluster=PortalCluster'
unmanagedNodeNames = AdminTask.listUnmanagedNodes().splitlines()
for unmanagedNodeName in unmanagedNodeNames:
  webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + unmanagedNodeName + ']').splitlines()
  for webserver in webservers:
    webserverName = AdminConfig.showAttribute(webserver, 'name')
    mapModulesToServer = mapModulesToServer + '+WebSphere:cell=' + cell + ',node=' + unmanagedNodeName + ',server=' + webserverName

# All the additional switches below should be set by default, so no need to define them explicitly
# -nopreCompileJSPs -distributeApp -nouseMetaDataFromBinary -nodeployejb -createMBeansForResources -noreloadEnabled -nodeployws -validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude -noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema 
result = AdminApp.install(logViewerPortletEarFile, '[ -appname logviewer.portlet -MapModulesToServers [[ "IBM Log Viewer Portlet" logviewer.portlet.war,WEB-INF/web.xml ' + mapModulesToServer + ' ][ logviewer.webservice logviewer.webservice.war,WEB-INF/web.xml ' + mapModulesToServer + ' ]]]' )

print '******* saving configuration *******'
result = AdminConfig.save()

print 'allow access to proxy endpoints to authenticated users'
realm = AdminTask.listSecurityRealms()
result = AdminApp.edit('logviewer.portlet', '[ -MapRolesToUsers [[ lvrs-user AppDeploymentOption.No AppDeploymentOption.No "" ' + wpsadminsCn + '|' + wpsusersCn + ' AppDeploymentOption.No "" group:' + realm + '/' + wpsadminsDn + '|group:' + realm + '/' + wpsusersDn + ' ][ logviewer-user AppDeploymentOption.No AppDeploymentOption.No "" ' + wpsusersCn + ' AppDeploymentOption.No "" group:' + realm + '/' + wpsusersDn  + ' ][ logviewer-admin AppDeploymentOption.No AppDeploymentOption.No ' + wpsadminUid + ' ' + wpsadminsCn + ' AppDeploymentOption.No user:' + realm + '/' + wpsadminDn + ' group:' + realm + '/' + wpsadminsDn + ' ]]]' )

print '******* saving configuration *******'
result = AdminConfig.save()

print '+++ synchronizing configuration +++'
dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
nodes = AdminControl.invoke(dmgr, 'syncActiveNodes', 'true')
print 'the following nodes have been synchronized:'
for node in nodes.splitlines():
  print ' - ' + node

nodeNames = AdminTask.listNodes().splitlines()
for nodeName in nodeNames:
  webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + nodeName + ']').splitlines()
  for webserver in webservers:
    webserverName = AdminConfig.showAttribute(webserver, 'name')
    generator = AdminControl.completeObjectName('type=PluginCfgGenerator,*')
    print 'Generating plugin-cfg.xml for ' + webserverName + ' on ' + nodeName
    result = AdminControl.invoke(generator, 'generate', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +  ' ' + nodeName + ' ' + webserverName + ' false')
    print 'Propagating plugin-cfg.xml for ' + webserverName + ' on ' + nodeName
    result = AdminControl.invoke(generator, 'propagate', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell + ' ' + nodeName + ' ' + webserverName)
    print 'Propagating keyring for ' + webserverName + ' on ' + nodeName
    result = AdminControl.invoke(generator, 'propagateKeyring', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell + ' ' + nodeName + ' ' + webserverName)
    webserverCON = AdminControl.completeObjectName('type=WebServer,*')

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  applicationServers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for applicationServer in applicationServers:
    applicationServerName = AdminConfig.showAttribute(applicationServer, 'name')
    if applicationServerName == 'WebSphere_Portal':
      print 'starting logviewer.portlet on ' + managedNodeName
      appManager = AdminControl.queryNames('type=ApplicationManager,process=WebSphere_Portal,*')
      result = AdminControl.invoke(appManager, 'startApplication', '[logviewer.portlet]') 
