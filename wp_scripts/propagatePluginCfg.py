cell = AdminControl.getCell()
cellCompleteobjectName = AdminControl.completeObjectName('type=CellSync,cell=' + cell + ',*')
nodes = AdminTask.listNodes().splitlines()
for node in nodes:
  webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + node + ']').splitlines()
  for webserver in webservers:
    webserverName = AdminConfig.showAttribute(webserver, 'name')
    generator = AdminControl.completeObjectName('type=PluginCfgGenerator,*')
    print "Generating plugin-cfg.xml for " + webserverName + " on " + node
    result = AdminControl.invoke(generator, 'generate', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +  ' ' + node + ' ' + webserverName + ' false')
    print "Propagating plugin-cfg.xml for " + webserverName + " on " + node
    result = AdminControl.invoke(generator, 'propagate', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell + ' ' + node + ' ' + webserverName)
    print "Propagating keyring for " + webserverName + " on " + node
    result = AdminControl.invoke(generator, 'propagateKeyring', '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell + ' ' + node + ' ' + webserverName)
    webserverCON = AdminControl.completeObjectName('type=WebServer,*')
    print "Stopping " + webserverName + " on " + node
    result = AdminControl.invoke(webserverCON, 'stop', '[' + cell + ' ' + node + ' ' + webserverName + ']')
    print "Starting " + webserverName + " on " + node
    result = AdminControl.invoke(webserverCON, 'start', '[' + cell + ' ' + node + ' ' + webserverName + ']')

result = AdminConfig.save()
