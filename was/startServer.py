def printUsage():
    print ''
    print 'Usage: <profile root>/bin/wsadmin -lang jython'
    print '       [-user username] [-password password]'
    print '       -f /tmp/startServer.py'
    print '       <server name>'
    print ''

if not (len(sys.argv) == 1):
  print ''
  sys.stderr.write('missing server name arguement\n')
  printUsage()
  sys.exit(101)

managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
  applicationServers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
  for applicationServer in applicationServers:
    applicationServerName = AdminConfig.showAttribute(applicationServer, 'name')
    if applicationServerName == sys.argv[0]:
      print 'starting ' + applicationServerName + ' on ' + managedNodeName
      #result = AdminControl.startServer(applicationServerName,managedNodeName)
    else:
      print ''
      sys.stderr.write('!!! server name not found\n')
      printUsage()
      sys.exit(101)
