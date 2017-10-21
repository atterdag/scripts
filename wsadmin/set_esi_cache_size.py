import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

print 'getting cell name'
cell = AdminControl.getCell()

nodes = AdminTask.listNodes().splitlines()
for node in nodes:
  webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + node + ']').splitlines()
  for webserver in webservers:
    pluginProperties = AdminConfig.list('PluginProperties', webserver)
    print 'enable ESI cache for ' + webserver
    result = AdminConfig.modify(pluginProperties, [['ESIEnable', 'true']])
    print 'increasing ESI cache size to 10240 KB for ' + webserver
    result = AdminConfig.modify(pluginProperties, [['ESIMaxCacheSize', '10240' ]])
    print 'enable ESI edge cache invalidation for ' + webserver
    result = AdminConfig.modify(pluginProperties, [['ESIInvalidationMonitor', 'true' ]])

synchronizeActiveNodes()
propagatePluginCfg()
