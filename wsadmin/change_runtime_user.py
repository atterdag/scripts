import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

def printUsage():
  print
  print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
  print '[-user username] [-password password]'
  print '-f /tmp/change_runtime_user.py <user> <group>'
  print '      $WAS_HOME     is the installation directory for WebSphere'
  print '      username      is the WebSphere Application Server user name'
  print '      password      is the WebSphere Application Server user password'
  print '      user          is JVM runtime user name'
  print '      group         is JVM startup group name'
  print
  print 'Sample:'
  print '=============================================================================='
  print 'wsadmin -lang jython -user wasadmin -password passw0rd'
  print ' -f "/tmp/change_runtime_user.py" was was'
  print '=============================================================================='
  print

# Verify that the correct number of parameters exist
if not (len(sys.argv) == 2):
  sys.stderr.write("Invalid number of arguments\n")
  printUsage()
  sys.exit(101)

user = sys.argv[0]
group = sys.argv[1]

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
  nodeName = AdminConfig.showAttribute(node, 'name')
  servers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']').splitlines()
  for server in servers:
    print '------------------------------------------------------------------------------'
    print server
    print '------------------------------------------------------------------------------'
    setProcessExecution(server, user, group)
  nodeagents = AdminTask.listServers('[-serverType NODE_AGENT -nodeName ' + nodeName + ']').splitlines()
  for nodeagent in nodeagents:
    print '------------------------------------------------------------------------------'
    print nodeagent
    print '------------------------------------------------------------------------------'
    setProcessExecution(nodeagent, user, group)
  dmgrs = AdminTask.listServers('[-serverType DEPLOYMENT_MANAGER -nodeName ' + nodeName + ']').splitlines()
  for dmgr in dmgrs:
    print '------------------------------------------------------------------------------'
    print dmgr
    print '------------------------------------------------------------------------------'
    setProcessExecution(dmgr, user, group)

saveConfiguration()
