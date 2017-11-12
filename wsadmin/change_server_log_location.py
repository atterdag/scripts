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
  print '-f /tmp/change_server_log_location.py <directory>'
  print '      $WAS_HOME     is the installation directory for WebSphere'
  print '      username      is the WebSphere Application Server user name'
  print '      password      is the WebSphere Application Server user password'
  print '      directory     is the directory to save dump files in'
  print
  print 'Sample:'
  print '=============================================================================='
  print 'wsadmin -lang jython -user wasadmin -password passw0rd'
  print ' -f "/tmp/change_server_log_location.py" "/var/log/was"'
  print '=============================================================================='
  print

# Verify that the correct number of parameters exist
if not (len(sys.argv) == 1):
  sys.stderr.write("Invalid number of arguments\n")
  printUsage()
  sys.exit(101)

rootLogDirectory = sys.argv[0]

cell = AdminControl.getCell()
nodes = AdminTask.listNodes().splitlines()
for node in nodes:
  nodeId = AdminConfig.getid('/Node:' + node + '/')
  variableSubstitutionEntries = AdminConfig.list('VariableSubstitutionEntry',nodeId).splitlines()
  variableSubstitutionEntryNameFound = 'false'
  for variableSubstitutionEntry in variableSubstitutionEntries:
    variableSubstitutionEntryName = AdminConfig.showAttribute(variableSubstitutionEntry, 'symbolicName')
    if variableSubstitutionEntryName == 'WAS_NODE_NAME':
      variableSubstitutionEntryNameFound = 'true'
    if variableSubstitutionEntryName == 'LOG_ROOT':
      print 'Modifying variable: ' + variableSubstitutionEntryName + ', value: ' + rootLogDirectory + '/\${WAS_CELL_NAME}/\${WAS_NODE_NAME} on node: ' + node
      result = AdminConfig.modify(variableSubstitutionEntry, [['value', rootLogDirectory + '/\${WAS_CELL_NAME}/\${WAS_NODE_NAME}']])
    if variableSubstitutionEntryName == 'SERVER_LOG_ROOT':
      print 'Modifying variable: ' + variableSubstitutionEntryName + ', value: \${LOG_ROOT}/\${WAS_SERVER_NAME} on node: ' + node
      result = AdminConfig.modify(variableSubstitutionEntry, [['value', '\${LOG_ROOT}/\${WAS_SERVER_NAME}']])
  print "ensuring that all nodes have a WAS_NODE_NAME variable"
  if variableSubstitutionEntryNameFound == 'false':
    print "creating variable WAS_NODE_NAME=" + node
    result = AdminConfig.create('VariableSubstitutionEntry', '(cells/' + cell + '/node/' + node + '|variables.xml#VariableMap_1)', '[[symbolicName "WAS_NODE_NAME"] [value "' + node + '"]]')

saveConfiguration()
