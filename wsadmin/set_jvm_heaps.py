import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

def printUsage():
  print
  print 'Usage: \$WAS_HOME/bin/wsadmin -lang jython'
  print '[-profileName profilename]'
  print '[-user username]'
  print '[-password password]'
  print '-f /tmp/create-webserver.py'
  print '[--dmgrHeapSizeMax <size in MB>]'
  print '[--dmgrHeapSizeMin <size in MB>]'
  print '[--naHeapSizeMax <size in MB>]'
  print '[--naHeapSizeMin <size in MB>]'
  print '[--wasHeapSizeMax <size in MB>]'
  print '[--wasHeapSizeMin <size in MB>]'
  print '[--wasJvmNurserySize <size in MB>]'
  print '      $WAS_HOME                is the installation directory for WebSphere'
  print '                                Application Server'
  print '      profilename              is the WebSphere Application Server profile'
  print '      username                 is the WebSphere Application Server'
  print '                                user'
  print '      password                 is the user password'
  print '      dmgrHeapSizeMax          is the deployment manager maximum HEAP size in MB'
  print '      dmgrHeapSizeMin          is the deployment manager minimum HEAP size in MB'
  print '      naHeapSizeMax            is the node agents maximum HEAP size in MB'
  print '      naHeapSizeMin            is the node agents minimum HEAP size in MB'
  print '      wasHeapSizeMax           is the application servers maximum HEAP size in MB'
  print '      wasHeapSizeMin           is the application servers minimum HEAP size in MB'
  print '      wasJvmNurserySize        is the JVM nusery size in MB'
  print
  print 'Sample:'
  print '=============================================================================='
  print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
  print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
  print ' -f "/tmp/configureLTPA.py"'
  print ' --dmgrHeapSizeMax 1024'
  print ' --dmgrHeapSizeMin 300'
  print ' --naHeapSizeMax 1024'
  print ' --naHeapSizeMin 300'
  print ' --wasHeapSizeMax 2048'
  print ' --wasHeapSizeMin 2048'
  print ' --wasJvmNurserySize 1024'
  print '=============================================================================='
  print

# sort the wsadmin sys.argv list into a tuple
optlist, args = getopt.getopt(sys.argv, 'x', [
  'dmgrHeapSizeMax=',
  'dmgrHeapSizeMin=',
  'naHeapSizeMax=',
  'naHeapSizeMin=',
  'wasHeapSizeMax=',
  'wasHeapSizeMin=',
  'wasJvmNurserySize='
])

# convert the tuple into a dict
optdict = dict(optlist)

# map the dict value into specific variables, and assign default values if no
# value specified
dmgrHeapSizeMax   = optdict.get('--dmgrHeapSizeMax', '1024')
dmgrHeapSizeMin   = optdict.get('--dmgrHeapSizeMin', '300')
naHeapSizeMax     = optdict.get('--naHeapSizeMax', '1024')
naHeapSizeMin     = optdict.get('--naHeapSizeMin', '300')
wasHeapSizeMax    = optdict.get('--wasHeapSizeMax', '2048')
wasHeapSizeMin    = optdict.get('--wasHeapSizeMin', '2048')
wasJvmNurserySize = optdict.get('--wasJvmNurserySize', '1024')

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  print 'iterating through all servers in node ' + nodeName
  dmgrs = AdminTask.listServers('[-serverType DEPLOYMENT_MANAGER -nodeName ' + nodeName + ']').splitlines()
  for dmgr in dmgrs:
    setJavaVirtualMachineProperty(dmgr, [['initialHeapSize', dmgrHeapSizeMin], ['maximumHeapSize', dmgrHeapSizeMax], ['verboseModeGarbageCollection', 'false']])
  nodeagents = AdminTask.listServers('[-serverType NODE_AGENT -nodeName ' + nodeName + ']').splitlines()
  for nodeagent in nodeagents:
    setJavaVirtualMachineProperty(nodeagent, [['initialHeapSize', naHeapSizeMin], ['maximumHeapSize', naHeapSizeMax], ['verboseModeGarbageCollection', 'false']])
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    serverName = AdminConfig.showAttribute(server, 'name')
    setJavaVirtualMachineProperty(server, [['initialHeapSize', wasHeapSizeMin], ['maximumHeapSize', wasHeapSizeMax]])
    setJvmGenericArguements(nodeName, serverName, '-Xmn' + wasJvmNurserySize + 'M')

synchronizeActiveNodes()
