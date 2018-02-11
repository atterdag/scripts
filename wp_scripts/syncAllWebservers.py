cell = AdminControl.getCell()
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
