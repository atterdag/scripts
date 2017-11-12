import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

def printUsage():
  print
  print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
  print '[-profileName profilename]'
  print '[-user username] [-password password]'
  print '-f /tmp/set_esi_cache_size.py <size>'
  print '      $WAS_HOME     is the installation directory for WebSphere'
  print '                     Application Server'
  print '      profilename   is the WebSphere Application Server profile'
  print '      username      is the WebSphere Application Server user name'
  print '      password      is the WebSphere Application Server user password'
  print '      size          is the cache size in KB'
  print
  print 'Sample:'
  print '=============================================================================='
  print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
  print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
  print ' -f "/tmp/set_esi_cache_size.py" 10240'
  print '=============================================================================='
  print

if not (len(sys.argv) == 2):
  sys.stderr.write('Invalid number of arguments\n')
  printUsage()
  sys.exit(101)

esiMaxCacheSize=sys.argv[0]

nodes = AdminTask.listNodes().splitlines()
for node in nodes:
  webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + node + ']').splitlines()
  for webserver in webservers:
    pluginProperties = AdminConfig.list('PluginProperties', webserver)
    print 'enable ESI cache for ' + webserver
    result = AdminConfig.modify(pluginProperties, [['ESIEnable', 'true']])
    print 'increasing ESI cache size to ' + esiMaxCacheSize + ' KB for ' + webserver
    result = AdminConfig.modify(pluginProperties, [['ESIMaxCacheSize', esiMaxCacheSize ]])
    print 'enable ESI edge cache invalidation for ' + webserver
    result = AdminConfig.modify(pluginProperties, [['ESIInvalidationMonitor', 'true' ]])

synchronizeActiveNodes()
propagatePluginCfg()
